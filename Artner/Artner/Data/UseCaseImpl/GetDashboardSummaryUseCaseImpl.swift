//
//  GetDashboardSummaryUseCaseImpl.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// 대시보드 요약 정보 조회 UseCase 구현체
/// Clean Architecture: Data Layer에서 Repository를 통한 비즈니스 로직 구현
final class GetDashboardSummaryUseCaseImpl: GetDashboardSummaryUseCase {
    
    // MARK: - Properties
    private let dashboardRepository: DashboardRepository
    
    // MARK: - Initialization
    init(dashboardRepository: DashboardRepository) {
        self.dashboardRepository = dashboardRepository
    }
    
    // MARK: - GetDashboardSummaryUseCase
    func execute() -> AnyPublisher<DashboardSummary, Error> {
        return dashboardRepository.getDashboardSummary()
            .eraseToAnyPublisher()
    }
}
