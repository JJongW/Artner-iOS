//
//  AuthRepositoryImpl.swift
//  Artner
//
//  Created by AI Assistant
//  15년차 iOS 개발자의 Clean Architecture 구현
//

import Foundation
import Combine
import KakaoSDKUser
import KakaoSDKAuth

/// 인증 Repository 구현체
/// - 카카오 SDK와 백엔드 API를 실제로 호출하는 레이어
/// - Domain Layer의 AuthRepository protocol을 구현
final class AuthRepositoryImpl: AuthRepository {
    
    // MARK: - Properties
    
    private let apiService: APIServiceProtocol
    
    // MARK: - Initialization
    
    /// 의존성 주입을 통한 초기화
    /// - Parameter apiService: API 서비스 (기본값: shared singleton)
    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }
    
    // MARK: - AuthRepository Implementation
    
    /// 카카오 로그인 수행
    /// 1. 카카오톡 앱 또는 웹을 통해 OAuth 토큰 획득
    /// 2. 백엔드 서버에 카카오 accessToken 전송
    /// 3. 백엔드로부터 자체 accessToken/refreshToken 수신
    /// 4. Keychain에 토큰 저장
    /// - Returns: 로그인 성공 시 사용자 정보
    func loginWithKakao() -> AnyPublisher<UserInfo, Error> {
        return Future<UserInfo, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }
            
            // 1단계: 카카오 로그인 방식 결정 (앱 vs 웹)
            let loginPublisher: AnyPublisher<OAuthToken, Error>
            
            if UserApi.isKakaoTalkLoginAvailable() {
                // 카카오톡 앱 로그인
                loginPublisher = self.loginWithKakaoTalk()
            } else {
                // 카카오 계정 웹 로그인
                loginPublisher = self.loginWithKakaoAccount()
            }
            
            // 2단계: 카카오 OAuth 토큰으로 백엔드 로그인
            var cancellable: AnyCancellable?
            cancellable = loginPublisher
                .flatMap { oauthToken -> AnyPublisher<UserInfo, Error> in
                    print("✅ 카카오 로그인 성공 (accessToken 획득)")
                    return self.sendTokenToBackend(accessToken: oauthToken.accessToken)
                }
                .sink(
                    receiveCompletion: { completion in
                        if case .failure(let error) = completion {
                            promise(.failure(error))
                        }
                        cancellable?.cancel()
                    },
                    receiveValue: { userInfo in
                        promise(.success(userInfo))
                    }
                )
        }
        .eraseToAnyPublisher()
    }
    
    // MARK: - Private Methods
    
    /// 카카오톡 앱을 통한 로그인
    /// - Returns: OAuth 토큰
    private func loginWithKakaoTalk() -> AnyPublisher<OAuthToken, Error> {
        return Future<OAuthToken, Error> { promise in
            UserApi.shared.loginWithKakaoTalk { token, error in
                if let error = error {
                    print("❌ 카카오톡 로그인 실패: \(error.localizedDescription)")
                    promise(.failure(error))
                } else if let token = token {
                    print("✅ 카카오톡 로그인 성공")
                    promise(.success(token))
                } else {
                    promise(.failure(NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 카카오 계정 웹을 통한 로그인
    /// - Returns: OAuth 토큰
    private func loginWithKakaoAccount() -> AnyPublisher<OAuthToken, Error> {
        return Future<OAuthToken, Error> { promise in
            UserApi.shared.loginWithKakaoAccount { token, error in
                if let error = error {
                    print("❌ 카카오 계정 로그인 실패: \(error.localizedDescription)")
                    promise(.failure(error))
                } else if let token = token {
                    print("✅ 카카오 계정 로그인 성공")
                    promise(.success(token))
                } else {
                    promise(.failure(NSError(domain: "KakaoLogin", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unknown error"])))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 카카오 OAuth 토큰을 백엔드 서버로 전송
    /// - Parameter accessToken: 카카오 OAuth accessToken
    /// - Returns: 백엔드에서 받은 사용자 정보
    private func sendTokenToBackend(accessToken: String) -> AnyPublisher<UserInfo, Error> {
        return Future<UserInfo, Error> { [weak self] promise in
            guard let self = self else {
                promise(.failure(NSError(domain: "AuthRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "Self is nil"])))
                return
            }
            
            print("🚀 백엔드 서버로 토큰 전송 중...")
            
            // APIService의 completion handler 방식 사용
            self.apiService.request(APITarget.kakaoLogin(accessToken: accessToken)) { (result: Result<KakaoLoginResponseDTO, Error>) in
                switch result {
                case .success(let response):
                    print("✅ 백엔드 로그인 성공")
                    print("   - Backend Access Token: \(response.accessToken)")
                    print("   - Backend Refresh Token: \(response.refreshToken)")
                    print("   - User ID: \(response.user.id)")
                    print("   - Username: \(response.user.username)")
                    print("   - Nickname: \(response.user.nickname)")
                    print("   - Is New User: \(response.isNewUser)")
                    
                    // 백엔드에서 받은 토큰을 Keychain에 저장
                    TokenManager.shared.saveTokens(
                        access: response.accessToken,
                        refresh: response.refreshToken
                    )
                    
                    // DTO를 Domain Entity로 변환
                    let userInfo = UserInfo(
                        id: response.user.id,
                        username: response.user.username,
                        nickname: response.user.nickname,
                        email: response.user.email
                    )
                    
                    promise(.success(userInfo))
                    
                case .failure(let error):
                    print("❌ 백엔드 로그인 실패: \(error.localizedDescription)")
                    promise(.failure(error))
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    /// 로그아웃 수행
    func logout() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            print("🚪 로그아웃 시작")
            
            // TokenManager에서 refresh token 가져오기
            guard let refreshToken = TokenManager.shared.refreshToken else {
                print("❌ Refresh Token이 없습니다.")
                // Refresh Token이 없어도 로컬 토큰은 삭제
                TokenManager.shared.clearTokens()
                promise(.success(()))
                return
            }
            
            // 백엔드에 로그아웃 요청
            self.apiService.request(APITarget.logout(refreshToken: refreshToken)) { (result: Result<LogoutResponseDTO, Error>) in
                switch result {
                case .success(let response):
                    print("✅ 백엔드 로그아웃 성공")
                    print("   - Message: \(response.message)")
                    print("   - Success: \(response.success)")
                    
                    // 로컬 토큰 삭제
                    TokenManager.shared.clearTokens()
                    promise(.success(()))
                    
                case .failure(let error):
                    print("❌ 백엔드 로그아웃 실패: \(error.localizedDescription)")
                    // 실패해도 로컬 토큰은 삭제
                    TokenManager.shared.clearTokens()
                    promise(.success(())) // 로컬 토큰 삭제는 성공으로 처리
                }
            }
        }
        .eraseToAnyPublisher()
    }
}
