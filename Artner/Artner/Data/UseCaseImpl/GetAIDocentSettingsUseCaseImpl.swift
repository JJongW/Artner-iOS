//
//  GetAIDocentSettingsUseCaseImpl.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// AI 도슨트 설정 조회 UseCase 구현체
final class GetAIDocentSettingsUseCaseImpl: GetAIDocentSettingsUseCase {
    
    private let aiDocentSettingsRepository: AIDocentSettingsRepository
    
    init(aiDocentSettingsRepository: AIDocentSettingsRepository) {
        self.aiDocentSettingsRepository = aiDocentSettingsRepository
    }
    
    func execute() -> AnyPublisher<AIDocentSettings, NetworkError> {
        return aiDocentSettingsRepository.fetchAIDocentSettings()
    }
}
