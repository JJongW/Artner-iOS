//
//  DashboardRepositoryImpl.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// 대시보드 Repository 구현체
/// Clean Architecture: Data Layer에서 API 호출을 통한 대시보드 데이터 제공
final class DashboardRepositoryImpl: DashboardRepository {
    
    // MARK: - Properties
    private let apiService: APIServiceProtocol
    
    // MARK: - Initialization
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    // MARK: - DashboardRepository
    func getDashboardSummary() -> AnyPublisher<DashboardSummary, Error> {
        return apiService.getDashboardSummary()
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
