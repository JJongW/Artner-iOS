//
//  GetDashboardSummaryUseCase.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// 대시보드 요약 정보 조회 UseCase
/// Clean Architecture: Domain Layer에서 비즈니스 로직 처리
protocol GetDashboardSummaryUseCase {
    func execute() -> AnyPublisher<DashboardSummary, Error>
}
