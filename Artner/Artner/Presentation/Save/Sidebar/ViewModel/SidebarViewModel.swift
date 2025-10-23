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
    private let getAIDocentSettingsUseCase: GetAIDocentSettingsUseCase
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(getDashboardSummaryUseCase: GetDashboardSummaryUseCase, getAIDocentSettingsUseCase: GetAIDocentSettingsUseCase) {
        self.getDashboardSummaryUseCase = getDashboardSummaryUseCase
        self.getAIDocentSettingsUseCase = getAIDocentSettingsUseCase
        loadDashboardData()
        loadAIDocentSettings()
    }
    
    // MARK: - Published Properties
    // 로딩 상태
    @Published var isLoading: Bool = true
    @Published var isAISettingsLoading: Bool = true
    
    // 사용자 정보 (API에서 로드)
    @Published var userName: String = ""
    @Published var stats: [SidebarStat] = []
    @Published var aiDocent: String = ""
    
    // AI 설정 세부 데이터 (API에서 로드)
    @Published var lengthValue: String = ""
    @Published var speedValue: String = ""
    @Published var difficultyValue: String = ""
    @Published var easyMode: Bool = false
    @Published var fontSize: Float = 5
    @Published var lineSpacing: Float = 5
    
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
                        self?.isLoading = false
                    case .failure(let error):
                        print("❌ 대시보드 데이터 로드 실패: \(error.localizedDescription)")
                        // 에러 발생 시 기본값 유지
                        self?.isLoading = false
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
        
        // AI 설정은 별도 API에서 처리하므로 여기서는 제거
        
        #if DEBUG
        print("🔄 사이드바 데이터 업데이트 완료")
        print("   사용자: \(userName) (ID: \(dashboardSummary.user.id))")
        print("   좋아요: \(dashboardSummary.stats.likedItems)")
        print("   저장: \(dashboardSummary.stats.savedDocents)")
        print("   밑줄: \(dashboardSummary.stats.highlights)")
        print("   전시기록: \(dashboardSummary.stats.exhibitionRecords)")
        #endif
    }
    
    /// AI 도슨트 설정 데이터 로드
    private func loadAIDocentSettings() {
        getAIDocentSettingsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    switch completion {
                    case .finished:
                        print("📊 AI 도슨트 설정 데이터 로드 완료")
                        self?.isAISettingsLoading = false
                    case .failure(let error):
                        print("❌ AI 도슨트 설정 데이터 로드 실패: \(error.localizedDescription)")
                        // 실패 시 기본값 유지
                        self?.isAISettingsLoading = false
                    }
                },
                receiveValue: { [weak self] aiSettings in
                    self?.updateAIDocentSettings(aiSettings)
                }
            )
            .store(in: &cancellables)
    }
    
    /// AI 도슨트 설정 데이터 업데이트
    private func updateAIDocentSettings(_ aiSettings: AIDocentSettings) {
        // AI 도슨트 이름 업데이트
        aiDocent = aiSettings.personal
        
        // AI 설정 값 업데이트 (한글로 변환)
        lengthValue = aiSettings.lengthKorean
        speedValue = aiSettings.speedKorean
        difficultyValue = aiSettings.difficultyKorean
        
        // 뷰어 설정 값 업데이트
        fontSize = Float(aiSettings.viewerFontSize)
        lineSpacing = Float(aiSettings.viewerLineSpacing)
        
        #if DEBUG
        print("🔄 AI 도슨트 설정 업데이트 완료")
        print("   Personal: \(aiSettings.personal)")
        print("   Length: \(aiSettings.length) -> \(aiSettings.lengthKorean)")
        print("   Speed: \(aiSettings.speed) -> \(aiSettings.speedKorean)")
        print("   Difficulty: \(aiSettings.difficulty) -> \(aiSettings.difficultyKorean)")
        print("   Font Size: \(aiSettings.viewerFontSize)")
        print("   Line Spacing: \(aiSettings.viewerLineSpacing)")
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