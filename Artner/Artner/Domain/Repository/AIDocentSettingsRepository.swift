//
//  AIDocentSettingsRepository.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// AI 도슨트 설정 Repository 프로토콜
protocol AIDocentSettingsRepository {
    func fetchAIDocentSettings() -> AnyPublisher<AIDocentSettings, NetworkError>
}
