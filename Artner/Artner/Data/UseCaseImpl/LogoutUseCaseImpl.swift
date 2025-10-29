//
//  LogoutUseCaseImpl.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// 로그아웃 UseCase 구현
final class LogoutUseCaseImpl: LogoutUseCase {
    
    private let authRepository: AuthRepository
    
    init(authRepository: AuthRepository = AuthRepositoryImpl()) {
        self.authRepository = authRepository
    }
    
    /// 로그아웃 실행
    func execute() -> AnyPublisher<Void, Error> {
        print("🚪 로그아웃 UseCase 시작")
        
        return authRepository.logout()
            .handleEvents(
                receiveOutput: { _ in
                    print("✅ 로그아웃 UseCase 성공")
                },
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ 로그아웃 UseCase 실패: \(error.localizedDescription)")
                    }
                }
            )
            .eraseToAnyPublisher()
    }
}

