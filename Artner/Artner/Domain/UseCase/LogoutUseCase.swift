//
//  LogoutUseCase.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// 로그아웃 UseCase Protocol
protocol LogoutUseCase {
    /// 로그아웃 실행
    func execute() -> AnyPublisher<Void, Error>
}

