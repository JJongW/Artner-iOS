//
//  KakaoLoginUseCase.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// 카카오 로그인 UseCase Protocol
/// 비즈니스 로직: 카카오톡 앱이 있으면 앱 로그인, 없으면 웹 로그인
protocol KakaoLoginUseCase {
    
    /// 카카오 로그인 실행
    /// - 카카오톡 앱이 설치되어 있으면 앱 로그인
    /// - 카카오톡 앱이 없으면 웹 로그인
    /// - Returns: 로그인 성공 시 사용자 정보
    func execute() -> AnyPublisher<UserInfo, Error>
}

