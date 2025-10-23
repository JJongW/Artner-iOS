//
//  DashboardRepository.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// 대시보드 Repository 프로토콜
/// Clean Architecture: Domain Layer에서 대시보드 데이터 접근 인터페이스 정의
protocol DashboardRepository {
    func getDashboardSummary() -> AnyPublisher<DashboardSummary, Error>
}
