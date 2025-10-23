//
//  DIContainer.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation

/// 의존성 주입 컨테이너
final class DIContainer {
    
    // MARK: - Singleton
    static let shared = DIContainer()
    
    private init() {}
    
    // MARK: - Network Layer
    
    /// API 서비스 인스턴스 (싱글톤)
    lazy var apiService: APIServiceProtocol = {
        return APIService()
    }()
    
    // MARK: - Repository Layer
    
    /// Feed Repository 인스턴스
    lazy var feedRepository: FeedRepository = {
        return FeedRepositoryImpl(apiService: apiService)
    }()
    
    /// Docent Repository 인스턴스 (현재 Dummy 데이터 사용)
    lazy var docentRepository: DocentRepository = {
        return DocentRepositoryImpl() // API 의존성 제거
    }()
    
    /// Dashboard Repository 인스턴스
    lazy var dashboardRepository: DashboardRepository = {
        return DashboardRepositoryImpl(apiService: apiService)
    }()
    
    // MARK: - UseCase Layer
    
    /// Feed UseCase 인스턴스
    lazy var fetchFeedUseCase: FetchFeedUseCase = {
        return FetchFeedUseCaseImpl(repository: feedRepository)
    }()
    
    /// Docent UseCase 인스턴스
    lazy var playDocentUseCase: PlayDocentUseCase = {
        return PlayDocentUseCaseImpl(repository: docentRepository)
    }()
    
    /// Dashboard UseCase 인스턴스
    lazy var getDashboardSummaryUseCase: GetDashboardSummaryUseCase = {
        return GetDashboardSummaryUseCaseImpl(dashboardRepository: dashboardRepository)
    }()
}

// MARK: - ViewModel Factory
extension DIContainer {
    
    /// HomeViewModel 생성
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(fetchFeedUseCase: fetchFeedUseCase)
    }
    
    /// DocentListViewModel 생성
    func makeDocentListViewModel() -> DocentListViewModel {
        return DocentListViewModel(useCase: playDocentUseCase)
    }
    
    /// PlayerViewModel 생성
    /// TODO: 향후 PlayerViewModel이 UseCase 의존성을 가지도록 개선 고려
    func makePlayerViewModel(docent: Docent) -> PlayerViewModel {
        return PlayerViewModel(docent: docent)
    }
    
    /// SidebarViewModel 생성
    func makeSidebarViewModel() -> SidebarViewModel {
        return SidebarViewModel(getDashboardSummaryUseCase: getDashboardSummaryUseCase)
    }
}

// MARK: - Configuration
extension DIContainer {
    
    /// 앱 시작 시 설정
    func configure() {
        print("🔧 DIContainer 설정 완료")
        print("📡 API Base URL: \(APITarget.getFeedList.baseURL.absoluteString)")
    }
    
    /// 개발 모드 설정
    func configureForDevelopment() {
        configure()
        print("🛠️ 개발 모드로 설정됨")
    }
    
    /// 프로덕션 모드 설정
    func configureForProduction() {
        configure()
        print("🚀 프로덕션 모드로 설정됨")
    }
}
