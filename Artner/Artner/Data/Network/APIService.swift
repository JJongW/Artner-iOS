//
//  APIService.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Moya
import Combine
import Alamofire

/// API 서비스 프로토콜
protocol APIServiceProtocol {
    func getFeedList() -> AnyPublisher<[FeedItemType], NetworkError>
    func getDashboardSummary() -> AnyPublisher<DashboardSummary, NetworkError>
    func getAIDocentSettings() -> AnyPublisher<AIDocentSettings, NetworkError>
    
    // MARK: - Folder API
    func getFolders() -> AnyPublisher<[Folder], NetworkError>
    func createFolder(name: String, description: String) -> AnyPublisher<Folder, NetworkError>
    func updateFolder(id: Int, name: String, description: String) -> AnyPublisher<Folder, NetworkError>
    func deleteFolder(id: Int) -> AnyPublisher<Void, NetworkError>
    
    // MARK: - Record API
    func getRecords() -> AnyPublisher<RecordList, NetworkError>
    func createRecord(visitDate: String, name: String, museum: String, note: String?, image: String?) -> AnyPublisher<Record, NetworkError>
    func deleteRecord(id: Int) -> AnyPublisher<Void, NetworkError>
    
    // MARK: - Folder Detail
    func getFolderDetail(id: Int) -> AnyPublisher<FolderDetailDTO, NetworkError>
    
    // MARK: - Audio Stream
    /// 서버에서 오디오 스트림을 받아 임시 파일 URL 반환
    func streamAudio(jobId: String) -> AnyPublisher<URL, NetworkError>
    
    // MARK: - Like API
    func getLikes() -> AnyPublisher<LikeList, NetworkError>
    func likeExhibition(id: Int) -> AnyPublisher<Bool, NetworkError>
    func likeArtwork(id: Int) -> AnyPublisher<Bool, NetworkError>
    func likeArtist(id: Int) -> AnyPublisher<Bool, NetworkError>
    // Docent 관련은 현재 Dummy 데이터 사용으로 제외
    
    // MARK: - Highlights API
    func getHighlights(filter: String?, itemName: String?, itemType: String?, ordering: String?, page: Int?, search: String?) -> AnyPublisher<HighlightsResponseDTO, NetworkError>
    
    // MARK: - Generic Request (범용 API 요청)
    /// Completion Handler 기반 네트워크 요청
    /// - Parameters:
    ///   - target: API 타겟
    ///   - completion: 결과 콜백
    func request<T: Codable>(_ target: APITarget, completion: @escaping (Result<T, Error>) -> Void)
}

/// Moya를 활용한 API 서비스 구현체
final class APIService: APIServiceProtocol {
    
    // MARK: - Singleton
    static let shared = APIService()
    
    // MARK: - Properties
    private let provider: MoyaProvider<APITarget>
    private let decoder: JSONDecoder
    private var isRefreshingToken = false
    private var refreshTokenQueue: [(Result<TokenRefreshResponseDTO, Error>) -> Void] = []
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    private init() {
        // Moya Provider 설정
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30.0    // 30초 타임아웃
        configuration.timeoutIntervalForResource = 60.0   // 60초 리소스 타임아웃
        
        let session = Session(configuration: configuration)
        
        // 로깅 플러그인 설정 (NetworkLoggerPlugin 호환성 문제로 제거)
        let plugins: [PluginType] = []
        
        self.provider = MoyaProvider<APITarget>(
            session: session,
            plugins: plugins
        )
        
        // JSON 디코더 설정
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - API Methods
    
    /// Feed 목록 조회
    func getFeedList() -> AnyPublisher<[FeedItemType], NetworkError> {
        return request(target: .getFeedList, responseType: FeedResponseDTO.self)
            .map { response in
                // DTO를 Domain Entity로 변환 (실제 서버 응답 구조 사용)
                let feedItems = response.toDomainEntities()
                
                #if DEBUG
                print("📦 변환된 Feed 아이템 개수: \(feedItems.count)")
                for (index, item) in feedItems.enumerated() {
                    switch item {
                    case .exhibition(let exhibition):
                        print("  [\(index)] 전시회: \(exhibition.title) (ID: \(exhibition.id))")
                    case .artwork(let artwork):
                        print("  [\(index)] 작품: \(artwork.title) (ID: \(artwork.id))")
                    case .artist(let artist):
                        print("  [\(index)] 작가: \(artist.title) (ID: \(artist.id))")
                    }
                }
                #endif
                
                return feedItems
            }
            .eraseToAnyPublisher()
    }
    
    /// 대시보드 요약 정보 조회
    func getDashboardSummary() -> AnyPublisher<DashboardSummary, NetworkError> {
        return request(target: .getDashboardSummary, responseType: DashboardSummaryDTO.self)
            .map { response in
                // DTO를 Domain Entity로 변환
                let dashboardSummary = response.toDomainEntity()
                
                #if DEBUG
                print("📊 대시보드 요약 정보 로드 완료")
                let displayName = dashboardSummary.user.nickname.isEmpty ? 
                    dashboardSummary.user.username : dashboardSummary.user.nickname
                print("   사용자: \(displayName) (ID: \(dashboardSummary.user.id))")
                print("   좋아요: \(dashboardSummary.stats.likedItems)")
                print("   저장: \(dashboardSummary.stats.savedDocents)")
                print("   밑줄: \(dashboardSummary.stats.highlights)")
                print("   전시기록: \(dashboardSummary.stats.exhibitionRecords)")
                #endif
                
                return dashboardSummary
            }
            .eraseToAnyPublisher()
    }
    
    // Docent 관련 메서드들은 현재 Dummy 데이터 사용으로 제외
}

// MARK: - Private Methods
private extension APIService {
    
    /// 공통 네트워크 요청 메서드 (Combine 방식)
    func request<T: Decodable>(
        target: APITarget,
        responseType: T.Type
    ) -> AnyPublisher<T, NetworkError> {
        return requestWithRetry(target: target, responseType: responseType, isRetrying: false)
    }
    
    /// 401 에러 재시도 포함 네트워크 요청 (Combine 방식)
    private func requestWithRetry<T: Decodable>(
        target: APITarget,
        responseType: T.Type,
        isRetrying: Bool
    ) -> AnyPublisher<T, NetworkError> {
        
        return Future<T, NetworkError> { [weak self] promise in
            guard let self = self else {
                promise(.failure(.unknownError))
                return
            }
            
            // 요청 시작 로그
            #if DEBUG
            print("🌐 요청: \(target.method.rawValue) \(target.baseURL.absoluteString)\(target.path)")
            #endif
            
            // Moya 요청 수행
            self.provider.request(target) { result in
                switch result {
                case .success(let response):
                    // 응답 로그
                    #if DEBUG
                    let emoji = 200...299 ~= response.statusCode ? "✅" : "❌"
                    print("\(emoji) 응답: \(response.statusCode) (\(target.path))")
                    #endif
                    
                    // 401 Unauthorized 처리 (토큰 만료) - Combine 방식
                    if response.statusCode == 401 && !isRetrying {
                        print("🔄 401 에러 감지 - 토큰 갱신 시도 (Combine)")
                        self.refreshTokenAndRetryCombine(originalTarget: target, responseType: responseType, promise: promise)
                        return
                    }
                    
                    // HTTP 상태 코드 검증
                    guard 200...299 ~= response.statusCode else {
                        promise(.failure(.serverError(response.statusCode)))
                        return
                    }
                    
                    // EmptyResponse인 경우 빈 데이터로 성공 처리
                    if T.self == EmptyResponse.self {
                        promise(.success(EmptyResponse() as! T))
                        return
                    }
                    
                    // 데이터 존재 확인
                    guard !response.data.isEmpty else {
                        promise(.failure(.noData))
                        return
                    }
                    
                    // JSON 디코딩
                    do {
                        // 디버깅: 성공 시에도 JSON 출력 (좋아요 API 디버깅용)
                        #if DEBUG
                        if let jsonString = String(data: response.data, encoding: .utf8) {
                            print("📝 Response JSON (\(target.path)): \(jsonString)")
                        }
                        #endif
                        
                        let decodedResponse = try self.decoder.decode(T.self, from: response.data)
                        promise(.success(decodedResponse))
                    } catch {
                        print("🚨 JSON Decoding Error: \(error)")
                        if let jsonString = String(data: response.data, encoding: .utf8) {
                            print("📝 Response JSON: \(jsonString)")
                        }
                        promise(.failure(.decodingError))
                    }
                    
                case .failure(let moyaError):
                    // 에러 로그
                    #if DEBUG
                    print("❌ 네트워크 에러: \(moyaError.localizedDescription) (\(target.path))")
                    #endif
                    promise(.failure(moyaError.toNetworkError()))
                }
            }
        }
        .receive(on: DispatchQueue.main)  // 메인 스레드에서 결과 전달
        .eraseToAnyPublisher()
    }
    
    /// 토큰 갱신 및 원래 요청 재시도 (Combine 방식)
    private func refreshTokenAndRetryCombine<T: Decodable>(
        originalTarget: APITarget,
        responseType: T.Type,
        promise: @escaping (Result<T, NetworkError>) -> Void
    ) {
        // 이미 토큰 갱신 중이면 대기열에 추가
        if isRefreshingToken {
            print("⏳ 토큰 갱신 중... 대기열에 추가 (Combine)")
            refreshTokenQueue.append({ [weak self] result in
                switch result {
                case .success:
                    // 토큰 갱신 성공 후 원래 요청 재시도
                    self?.requestWithRetry(target: originalTarget, responseType: responseType, isRetrying: true)
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    promise(.failure(error))
                                }
                            },
                            receiveValue: { value in
                                promise(.success(value))
                            }
                        )
                        .store(in: &self!.cancellables)
                case .failure(let error):
                    promise(.failure(error as! NetworkError))
                }
            })
            return
        }
        
        // 토큰 갱신 시작
        isRefreshingToken = true
        
        guard let refreshToken = TokenManager.shared.refreshToken else {
            print("❌ Refresh Token이 없습니다 - 로그아웃 필요 (Combine)")
            isRefreshingToken = false
            handleTokenRefreshFailure()
            promise(.failure(.unauthorized))
            return
        }
        
        print("🔄 토큰 갱신 API 호출 (Combine)")
        
        // 토큰 갱신 API 호출
        provider.request(.refreshToken(refreshToken: refreshToken)) { [weak self] result in
            guard let self = self else { return }
            
            self.isRefreshingToken = false
            
            switch result {
            case .success(let response):
                guard 200...299 ~= response.statusCode else {
                    print("❌ 토큰 갱신 실패 - 상태 코드: \(response.statusCode) (Combine)")
                    self.handleTokenRefreshFailure()
                    promise(.failure(.unauthorized))
                    self.processRefreshTokenQueue(result: .failure(NetworkError.unauthorized))
                    return
                }
                
                do {
                    let refreshResponse = try self.decoder.decode(TokenRefreshResponseDTO.self, from: response.data)
                    print("✅ 토큰 갱신 성공 (Combine)")
                    
                    // 새로운 토큰 저장
                    TokenManager.shared.saveTokens(
                        access: refreshResponse.accessToken,
                        refresh: refreshResponse.refreshToken
                    )
                    
                    // 대기열 처리
                    self.processRefreshTokenQueue(result: .success(refreshResponse))
                    
                    // 원래 요청 재시도
                    self.requestWithRetry(target: originalTarget, responseType: responseType, isRetrying: true)
                        .sink(
                            receiveCompletion: { completion in
                                if case .failure(let error) = completion {
                                    promise(.failure(error))
                                }
                            },
                            receiveValue: { value in
                                promise(.success(value))
                            }
                        )
                        .store(in: &self.cancellables)
                    
                } catch {
                    print("❌ 토큰 갱신 응답 디코딩 실패: \(error) (Combine)")
                    self.handleTokenRefreshFailure()
                    promise(.failure(.decodingError))
                    self.processRefreshTokenQueue(result: .failure(NetworkError.decodingError))
                }
                
            case .failure(let moyaError):
                print("❌ 토큰 갱신 네트워크 에러: \(moyaError) (Combine)")
                self.handleTokenRefreshFailure()
                promise(.failure(moyaError.toNetworkError()))
                self.processRefreshTokenQueue(result: .failure(moyaError.toNetworkError()))
            }
        }
    }
    
    // MARK: - AI Docent Settings API
    
    internal func getAIDocentSettings() -> AnyPublisher<AIDocentSettings, NetworkError> {
        return request(target: .getAIDocentSettings, responseType: AIDocentSettingsDTO.self)
            .map { (dto: AIDocentSettingsDTO) in
                print("📊 AI 도슨트 설정 데이터 로드 완료")
                print("   ID: \(dto.id)")
                print("   Personal: \(dto.personal)")
                print("   Length: \(dto.length) -> \(dto.toDomainEntity().lengthKorean)")
                print("   Speed: \(dto.speed) -> \(dto.toDomainEntity().speedKorean)")
                print("   Difficulty: \(dto.difficulty) -> \(dto.toDomainEntity().difficultyKorean)")
                print("   Viewer Font Size: \(dto.viewerFontSize)")
                print("   Viewer Line Spacing: \(dto.viewerLineSpacing)")
                return dto.toDomainEntity()
            }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Folder API 구현
    internal func getFolders() -> AnyPublisher<[Folder], NetworkError> {
        return request(target: .getFolders, responseType: [FolderDTO].self)
            .map { $0.map { $0.toDomainEntity() } }
            .eraseToAnyPublisher()
    }
    
    internal func createFolder(name: String, description: String) -> AnyPublisher<Folder, NetworkError> {
        return request(target: .createFolder(name: name, description: description), responseType: FolderDTO.self)
            .map { $0.toDomainEntity() }
            .eraseToAnyPublisher()
    }
    
    internal func updateFolder(id: Int, name: String, description: String) -> AnyPublisher<Folder, NetworkError> {
        return request(target: .updateFolder(id: id, name: name, description: description), responseType: FolderDTO.self)
            .map { $0.toDomainEntity() }
            .eraseToAnyPublisher()
    }
    
    internal func deleteFolder(id: Int) -> AnyPublisher<Void, NetworkError> {
        return request(target: .deleteFolder(id: id), responseType: EmptyResponse.self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Record API 구현
    internal func getRecords() -> AnyPublisher<RecordList, NetworkError> {
        return request(target: .getRecords, responseType: RecordListDTO.self)
            .map { $0.toDomainEntity() }
            .eraseToAnyPublisher()
    }
    
    internal func createRecord(visitDate: String, name: String, museum: String, note: String?, image: String?) -> AnyPublisher<Record, NetworkError> {
        return request(target: .createRecord(visitDate: visitDate, name: name, museum: museum, note: note, image: image), responseType: RecordDTO.self)
            .map { $0.toDomainEntity() }
            .eraseToAnyPublisher()
    }
    
    internal func deleteRecord(id: Int) -> AnyPublisher<Void, NetworkError> {
        return request(target: .deleteRecord(id: id), responseType: EmptyResponse.self)
            .map { _ in () }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Folder Detail API 구현
    internal func getFolderDetail(id: Int) -> AnyPublisher<FolderDetailDTO, NetworkError> {
        return request(target: .getFolderDetail(id: id), responseType: FolderDetailDTO.self)
            .eraseToAnyPublisher()
    }
    
    // MARK: - Audio Stream 구현
    internal func streamAudio(jobId: String) -> AnyPublisher<URL, NetworkError> {
        // 직접 URLSession으로 다운로드 (인증 헤더 포함)
        let base = APITarget.getFeedList.baseURL
        let url = base.appendingPathComponent(APITarget.streamAudio(jobId: jobId).path)
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        // 오디오 응답 수용
        request.setValue("audio/mpeg, audio/mp3, application/octet-stream", forHTTPHeaderField: "Accept")
        if let token = TokenManager.shared.accessToken {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        return URLSession.shared.dataTaskPublisher(for: request)
            .mapError { _ in NetworkError.unknownError }
            .tryMap { data, response in
                // 1) 응답이 오디오면 파일로 저장 후 로컬 URL 반환
                if let http = response as? HTTPURLResponse {
                    let contentType = http.value(forHTTPHeaderField: "Content-Type") ?? ""
                    if contentType.contains("audio") || contentType.contains("octet-stream") {
                        let tmpURL = FileManager.default.temporaryDirectory.appendingPathComponent("stream_\(jobId).mp3")
                        try data.write(to: tmpURL, options: .atomic)
                        return tmpURL
                    }
                }
                // 2) JSON에 오디오 URL이 담겨오는 경우 처리
                if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let urlString = (json["audio_url"] as? String) ?? (json["url"] as? String),
                       let url = URL(string: urlString) {
                        return url
                    }
                }
                // 3) 그 외에는 응답 URL 자체가 스트림인 경우 (리다이렉트 등)
                if let finalURL = (response as? HTTPURLResponse)?.url {
                    return finalURL
                }
                throw NetworkError.decodingError
            }
            .mapError { _ in NetworkError.decodingError }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Like API 구현
    internal func getLikes() -> AnyPublisher<LikeList, NetworkError> {
        return request(target: .getLikes, responseType: LikeListResponseDTO.self)
            .map { $0.toDomainEntity() }
            .eraseToAnyPublisher()
    }
    
    internal func likeExhibition(id: Int) -> AnyPublisher<Bool, NetworkError> {
        return request(target: .likeExhibition(id: id), responseType: LikeToggleResponseDTO.self)
            .map { $0.isLiked }
            .eraseToAnyPublisher()
    }
    
    internal func likeArtwork(id: Int) -> AnyPublisher<Bool, NetworkError> {
        return request(target: .likeArtwork(id: id), responseType: LikeToggleResponseDTO.self)
            .map { $0.isLiked }
            .eraseToAnyPublisher()
    }
    
    internal func likeArtist(id: Int) -> AnyPublisher<Bool, NetworkError> {
        return request(target: .likeArtist(id: id), responseType: LikeToggleResponseDTO.self)
            .map { $0.isLiked }
            .eraseToAnyPublisher()
    }
    
    // MARK: - Highlights API 구현
    internal func getHighlights(filter: String?, itemName: String?, itemType: String?, ordering: String?, page: Int?, search: String?) -> AnyPublisher<HighlightsResponseDTO, NetworkError> {
        return request(target: .getHighlights(filter: filter, itemName: itemName, itemType: itemType, ordering: ordering, page: page, search: search), responseType: HighlightsResponseDTO.self)
            .eraseToAnyPublisher()
    }
    
}

// MARK: - Completion Handler 방식 (UIKit 호환)
extension APIService {
    
    /// Completion Handler 기반 네트워크 요청
    /// UIKit ViewController에서 사용하기 위한 메서드
    func request<T: Codable>(
        _ target: APITarget,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        requestWithRetry(target, isRetrying: false, completion: completion)
    }
    
    /// 401 에러 재시도 포함 네트워크 요청
    private func requestWithRetry<T: Codable>(
        _ target: APITarget,
        isRetrying: Bool,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        provider.request(target) { [weak self] result in
            guard let self = self else {
                completion(.failure(NetworkError.unknownError))
                return
            }
            
            switch result {
            case .success(let response):
                // 응답 상태 코드 출력
                print("📊 Status Code: \(response.statusCode)")
                
                // 응답 데이터 크기 출력
                print("📦 Response Data Size: \(response.data.count) bytes")
                
                // 응답 JSON 전체 출력 (디코딩 전)
                if let jsonString = String(data: response.data, encoding: .utf8) {
                    print("📝 Raw Response JSON:")
                    print(jsonString)
                }
                
                // 401 Unauthorized 처리 (토큰 만료)
                if response.statusCode == 401 && !isRetrying {
                    print("🔄 401 에러 감지 - 토큰 갱신 시도")
                    self.refreshTokenAndRetry(originalTarget: target, completion: completion)
                    return
                }
                
                // HTTP 상태 코드 검증
                guard 200...299 ~= response.statusCode else {
                    completion(.failure(NetworkError.serverError(response.statusCode)))
                    return
                }
                
                // 데이터 존재 확인
                guard !response.data.isEmpty else {
                    print("⚠️ Response data is empty")
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                // JSON 디코딩
                do {
                    let decodedResponse = try self.decoder.decode(T.self, from: response.data)
                    print("✅ Decoding 성공!")
                    DispatchQueue.main.async {
                        completion(.success(decodedResponse))
                    }
                } catch {
                    print("🚨 JSON Decoding Error: \(error)")
                    DispatchQueue.main.async {
                        completion(.failure(NetworkError.decodingError))
                    }
                }
                
            case .failure(let moyaError):
                print("❌ 네트워크 에러: \(moyaError.localizedDescription)")
                DispatchQueue.main.async {
                    completion(.failure(moyaError.toNetworkError()))
                }
            }
        }
    }
    
    /// 토큰 갱신 및 원래 요청 재시도
    private func refreshTokenAndRetry<T: Codable>(
        originalTarget: APITarget,
        completion: @escaping (Result<T, Error>) -> Void
    ) {
        // 이미 토큰 갱신 중이면 큐에 추가
        if isRefreshingToken {
            print("⏳ 토큰 갱신 중... 대기열에 추가")
            refreshTokenQueue.append({ [weak self] result in
                switch result {
                case .success:
                    // 토큰 갱신 성공 후 원래 요청 재시도
                    self?.requestWithRetry(originalTarget, isRetrying: true, completion: completion)
                case .failure(let error):
                    completion(.failure(error))
                }
            })
            return
        }
        
        // 토큰 갱신 시작
        isRefreshingToken = true
        
        guard let refreshToken = TokenManager.shared.refreshToken else {
            print("❌ Refresh Token이 없습니다 - 로그아웃 필요")
            isRefreshingToken = false
            handleTokenRefreshFailure()
            completion(.failure(NetworkError.unauthorized))
            return
        }
        
        print("🔄 토큰 갱신 API 호출")
        
        // 토큰 갱신 API 호출
        provider.request(.refreshToken(refreshToken: refreshToken)) { [weak self] result in
            guard let self = self else { return }
            
            self.isRefreshingToken = false
            
            switch result {
            case .success(let response):
                guard 200...299 ~= response.statusCode else {
                    print("❌ 토큰 갱신 실패 - 상태 코드: \(response.statusCode)")
                    self.handleTokenRefreshFailure()
                    completion(.failure(NetworkError.unauthorized))
                    self.processRefreshTokenQueue(result: .failure(NetworkError.unauthorized))
                    return
                }
                
                do {
                    let refreshResponse = try self.decoder.decode(TokenRefreshResponseDTO.self, from: response.data)
                    print("✅ 토큰 갱신 성공")
                    
                    // 새로운 토큰 저장
                    TokenManager.shared.saveTokens(
                        access: refreshResponse.accessToken,
                        refresh: refreshResponse.refreshToken
                    )
                    
                    // 대기열 처리
                    self.processRefreshTokenQueue(result: .success(refreshResponse))
                    
                    // 원래 요청 재시도
                    self.requestWithRetry(originalTarget, isRetrying: true, completion: completion)
                    
                } catch {
                    print("❌ 토큰 갱신 응답 디코딩 실패: \(error)")
                    self.handleTokenRefreshFailure()
                    completion(.failure(NetworkError.decodingError))
                    self.processRefreshTokenQueue(result: .failure(NetworkError.decodingError))
                }
                
            case .failure(let moyaError):
                print("❌ 토큰 갱신 네트워크 에러: \(moyaError)")
                self.handleTokenRefreshFailure()
                completion(.failure(moyaError.toNetworkError()))
                self.processRefreshTokenQueue(result: .failure(moyaError.toNetworkError()))
            }
        }
    }
    
}

// MARK: - Token Refresh 공통 메서드
extension APIService {
    /// 토큰 갱신 대기열 처리
    fileprivate func processRefreshTokenQueue(result: Result<TokenRefreshResponseDTO, Error>) {
        refreshTokenQueue.forEach { callback in
            callback(result)
        }
        refreshTokenQueue.removeAll()
    }
    
    /// 토큰 갱신 실패 처리 (로그아웃)
    fileprivate func handleTokenRefreshFailure() {
        print("⚠️ 토큰 갱신 실패 - 로그아웃 처리")
        
        // 토큰 삭제
        TokenManager.shared.clearTokens()
        
        // 로그인 화면으로 이동 (메인 스레드에서 실행)
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name("ForceLogout"), object: nil)
        }
    }
}

// MARK: - Empty Response for DELETE operations
struct EmptyResponse: Codable {}

// MARK: - Network Logger 설정 완료
// 간단한 verbose 로깅 사용
