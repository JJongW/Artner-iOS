//
//  KakaoLoginUseCaseImpl.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// 카카오 로그인 UseCase 구현체
/// - Repository를 통해 실제 로그인 수행
/// - Domain Layer의 KakaoLoginUseCase protocol을 구현
final class KakaoLoginUseCaseImpl: KakaoLoginUseCase {
    
    // MARK: - Properties
    
    private let authRepository: AuthRepository
    
    // MARK: - Initialization
    
    /// 의존성 주입을 통한 초기화
    /// - Parameter authRepository: 인증 Repository (기본값: AuthRepositoryImpl)
    init(authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.authRepository = authRepository
    }
    
    // MARK: - KakaoLoginUseCase Implementation
    
    /// 카카오 로그인 실행
    /// - 비즈니스 로직: Repository를 통해 로그인 수행
    /// - Returns: 로그인 성공 시 사용자 정보
    func execute() -> AnyPublisher<UserInfo, Error> {
        return authRepository.loginWithKakao()
            .handleEvents(
                receiveSubscription: { _ in
                    print("🔐 카카오 로그인 UseCase 시작")
                },
                receiveOutput: { userInfo in
                    print("✅ 카카오 로그인 UseCase 성공 - User ID: \(userInfo.id)")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ 카카오 로그인 UseCase 실패: \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}

