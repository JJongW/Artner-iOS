//
//  AIDocentSettingsRepositoryImpl.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// AI 도슨트 설정 Repository 구현체
final class AIDocentSettingsRepositoryImpl: AIDocentSettingsRepository {
    
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func fetchAIDocentSettings() -> AnyPublisher<AIDocentSettings, NetworkError> {
        return apiService.getAIDocentSettings()
    }
}
