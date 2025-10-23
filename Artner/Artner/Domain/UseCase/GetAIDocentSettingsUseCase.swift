//
//  GetAIDocentSettingsUseCase.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// AI 도슨트 설정 조회 UseCase 프로토콜
protocol GetAIDocentSettingsUseCase {
    func execute() -> AnyPublisher<AIDocentSettings, NetworkError>
}
