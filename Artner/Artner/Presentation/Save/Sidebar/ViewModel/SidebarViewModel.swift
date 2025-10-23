//
//  SidebarViewModel.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//
//  Clean Architecture: 사이드바 상태/로직 분리, View와 ViewController에서 바인딩

import Foundation
import Combine

final class SidebarViewModel {
    
    // MARK: - Properties
    private let getDashboardSummaryUseCase: GetDashboardSummaryUseCase
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(getDashboardSummaryUseCase: GetDashboardSummaryUseCase) {
        self.getDashboardSummaryUseCase = getDashboardSummaryUseCase
        loadDashboardData()
    }
    
    // MARK: - Published Properties
    // 사용자 정보
    @Published var userName: String = "엔젤리너스 커피"
    @Published var stats: [SidebarStat] = [
        .init(type: .like, count: 1000),
        .init(type: .save, count: 1000),
        .init(type: .underline, count: 1000),
        .init(type: .record, count: 1000)
    ]
    @Published var aiDocent: String = "친절한 애나"
    @Published var aiSettings: SidebarAISettings = .default
    @Published var easyMode: Bool = false
    @Published var fontSize: Float = 1
    @Published var lineSpacing: Float = 10
    
    // MARK: - Private Methods
    
    /// 대시보드 데이터 로드
    private func loadDashboardData() {
        getDashboardSummaryUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("📊 대시보드 데이터 로드 완료")
                    case .failure(let error):
                        print("❌ 대시보드 데이터 로드 실패: \(error.localizedDescription)")
                        // 에러 발생 시 기본값 유지
                    }
                },
                receiveValue: { [weak self] dashboardSummary in
                    self?.updateDashboardData(dashboardSummary)
                }
            )
            .store(in: &cancellables)
    }
    
    /// 대시보드 데이터 업데이트
    private func updateDashboardData(_ dashboardSummary: DashboardSummary) {
        // 사용자 이름 업데이트 (nickname이 비어있으면 username 사용)
        let displayName = dashboardSummary.user.nickname.isEmpty ? 
            dashboardSummary.user.username : dashboardSummary.user.nickname
        userName = displayName
        
        // 통계 데이터 업데이트 (API 필드명에 맞춰 매핑)
        stats = [
            .init(type: .like, count: dashboardSummary.stats.likedItems),        // liked_items
            .init(type: .save, count: dashboardSummary.stats.savedDocents),     // saved_docents  
            .init(type: .underline, count: dashboardSummary.stats.highlights),  // highlights
            .init(type: .record, count: dashboardSummary.stats.exhibitionRecords) // exhibition_records
        ]
        
        #if DEBUG
        print("🔄 사이드바 데이터 업데이트 완료")
        print("   사용자: \(userName) (ID: \(dashboardSummary.user.id))")
        print("   좋아요: \(dashboardSummary.stats.likedItems)")
        print("   저장: \(dashboardSummary.stats.savedDocents)")
        print("   밑줄: \(dashboardSummary.stats.highlights)")
        print("   전시기록: \(dashboardSummary.stats.exhibitionRecords)")
        #endif
    }
}

struct SidebarStat {
    enum StatType { case like, save, underline, record }
    let type: StatType
    let count: Int
}

struct SidebarAISettings {
    var length: String // "짧게"
    var speed: String // "느리게"
    var difficulty: String // "초급"
    static let `default` = SidebarAISettings(length: "짧게", speed: "느리게", difficulty: "초급")
} 