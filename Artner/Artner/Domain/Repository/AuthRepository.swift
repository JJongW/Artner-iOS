//
//  AuthRepository.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// 인증 관련 Repository Protocol
/// Domain Layer에서 Data Layer의 구체적인 구현을 추상화
protocol AuthRepository {
    
    /// 카카오 로그인 수행
    /// - Returns: 로그인 결과 (UserInfo와 토큰 정보)
    func loginWithKakao() -> AnyPublisher<UserInfo, Error>
    
    /// 로그아웃 수행
    /// - Returns: 로그아웃 결과
    func logout() -> AnyPublisher<Void, Error>
}

