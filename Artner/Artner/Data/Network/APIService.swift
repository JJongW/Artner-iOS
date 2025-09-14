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
    // Docent 관련은 현재 Dummy 데이터 사용으로 제외
}

/// Moya를 활용한 API 서비스 구현체
final class APIService: APIServiceProtocol {
    
    // MARK: - Properties
    private let provider: MoyaProvider<APITarget>
    private let decoder: JSONDecoder
    
    // MARK: - Initialization
    init() {
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
    
    // Docent 관련 메서드들은 현재 Dummy 데이터 사용으로 제외
}

// MARK: - Private Methods
private extension APIService {
    
    /// 공통 네트워크 요청 메서드
    func request<T: Codable>(
        target: APITarget,
        responseType: T.Type
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
                    
                    // HTTP 상태 코드 검증
                    guard 200...299 ~= response.statusCode else {
                        promise(.failure(.serverError(response.statusCode)))
                        return
                    }
                    
                    // 데이터 존재 확인
                    guard !response.data.isEmpty else {
                        promise(.failure(.noData))
                        return
                    }
                    
                    // JSON 디코딩
                    do {
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
}

// MARK: - Network Logger 설정 완료
// 간단한 verbose 로깅 사용
