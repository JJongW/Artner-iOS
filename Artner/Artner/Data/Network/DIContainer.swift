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
    var apiService: APIServiceProtocol {
        return APIService.shared
    }
    
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
    
    /// AI Docent Settings Repository 인스턴스
    lazy var aiDocentSettingsRepository: AIDocentSettingsRepository = {
        return AIDocentSettingsRepositoryImpl(apiService: apiService)
    }()
    
    /// Folder Repository 인스턴스
    lazy var folderRepository: FolderRepository = {
        return FolderRepositoryImpl(apiService: apiService)
    }()
    
    /// Record Repository 인스턴스
    lazy var recordRepository: RecordRepository = {
        return RecordRepositoryImpl(apiService: apiService)
    }()
    
    /// Like Repository 인스턴스
    lazy var likeRepository: LikeRepository = {
        return LikeRepositoryImpl(apiService: apiService)
    }()
    
    /// Highlight Repository 인스턴스
    lazy var highlightRepository: HighlightRepository = {
        return HighlightRepositoryImpl(apiService: apiService)
    }()
    
    /// Auth Repository 인스턴스
    lazy var authRepository: AuthRepository = {
        return AuthRepositoryImpl(apiService: apiService)
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
    
    /// AI Docent Settings UseCase 인스턴스
    lazy var getAIDocentSettingsUseCase: GetAIDocentSettingsUseCase = {
        return GetAIDocentSettingsUseCaseImpl(aiDocentSettingsRepository: aiDocentSettingsRepository)
    }()
    
    /// Folder UseCase 인스턴스들
    lazy var getFoldersUseCase: GetFoldersUseCase = {
        return GetFoldersUseCaseImpl(folderRepository: folderRepository)
    }()
    
    lazy var createFolderUseCase: CreateFolderUseCase = {
        return CreateFolderUseCaseImpl(folderRepository: folderRepository)
    }()
    
    lazy var updateFolderUseCase: UpdateFolderUseCase = {
        return UpdateFolderUseCaseImpl(folderRepository: folderRepository)
    }()
    
    lazy var deleteFolderUseCase: DeleteFolderUseCase = {
        return DeleteFolderUseCaseImpl(folderRepository: folderRepository)
    }()
    
    /// Record UseCase 인스턴스
    lazy var getRecordsUseCase: GetRecordsUseCase = {
        return GetRecordsUseCaseImpl(recordRepository: recordRepository)
    }()
    
    lazy var createRecordUseCase: CreateRecordUseCase = {
        return CreateRecordUseCaseImpl(recordRepository: recordRepository)
    }()
    
    lazy var deleteRecordUseCase: DeleteRecordUseCase = {
        return DeleteRecordUseCaseImpl(recordRepository: recordRepository)
    }()
    
    /// Like UseCase 인스턴스
    lazy var getLikesUseCase: GetLikesUseCase = {
        return GetLikesUseCaseImpl(likeRepository: likeRepository)
    }()
    
    lazy var toggleLikeUseCase: ToggleLikeUseCase = {
        return ToggleLikeUseCaseImpl(likeRepository: likeRepository)
    }()
    
    /// Highlights UseCase 인스턴스
    lazy var getHighlightsUseCase: GetHighlightsUseCase = {
        return GetHighlightsUseCaseImpl(highlightRepository: highlightRepository)
    }()
    
    /// Kakao Login UseCase 인스턴스
    lazy var kakaoLoginUseCase: KakaoLoginUseCase = {
        return KakaoLoginUseCaseImpl(authRepository: authRepository)
    }()
}

// MARK: - ViewModel Factory
extension DIContainer {
    
    /// LaunchViewModel 생성
    func makeLaunchViewModel() -> LaunchViewModel {
        return LaunchViewModel(kakaoLoginUseCase: kakaoLoginUseCase)
    }
    
    /// HomeViewModel 생성
    func makeHomeViewModel() -> HomeViewModel {
        return HomeViewModel(fetchFeedUseCase: fetchFeedUseCase, getLikesUseCase: getLikesUseCase)
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
        return SidebarViewModel(
            getDashboardSummaryUseCase: getDashboardSummaryUseCase,
            getAIDocentSettingsUseCase: getAIDocentSettingsUseCase
        )
    }
    
    /// SaveViewModel 생성
    func makeSaveViewModel() -> SaveViewModel {
        return SaveViewModel(
            getFoldersUseCase: getFoldersUseCase,
            createFolderUseCase: createFolderUseCase,
            updateFolderUseCase: updateFolderUseCase,
            deleteFolderUseCase: deleteFolderUseCase
        )
    }
    
    /// RecordViewModel 생성
    func makeRecordViewModel() -> RecordViewModel {
        return RecordViewModel(getRecordsUseCase: getRecordsUseCase, deleteRecordUseCase: deleteRecordUseCase)
    }
    
    /// RecordInputViewModel 생성
    func makeRecordInputViewModel() -> RecordInputViewModel {
        return RecordInputViewModel(createRecordUseCase: createRecordUseCase)
    }
    
    /// LikeViewModel 생성
    func makeLikeViewModel() -> LikeViewModel {
        return LikeViewModel(getLikesUseCase: getLikesUseCase)
    }
    
    /// UnderlineViewModel 생성
    func makeUnderlineViewModel() -> UnderlineViewModel {
        return UnderlineViewModel(getHighlightsUseCase: getHighlightsUseCase)
    }

    /// AIDocentSettingsViewModel 생성
    func makeAIDocentSettingsViewModel(
        currentPersonal: String,
        currentLength: String = "medium",
        currentSpeed: String = "medium",
        currentDifficulty: String = "beginner"
    ) -> AIDocentSettingsViewModel {
        return AIDocentSettingsViewModel(
            currentPersonal: currentPersonal,
            currentLength: currentLength,
            currentSpeed: currentSpeed,
            currentDifficulty: currentDifficulty
        )
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
