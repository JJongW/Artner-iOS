# AI_CONTEXT.md — 피처별 CLAUDE.md 분산 배치

## 1. 작업 목적

루트 CLAUDE.md 하나에 모든 컨텍스트가 집중되어 있어,
특정 피처 작업 시 AI가 불필요한 정보까지 읽어야 함.
각 레이어/피처 디렉토리에 CLAUDE.md를 배치해 컨텍스트 로딩을 최소화한다.

## 2. 파일 배치 전략

```
Artner/Artner/
├── Domain/CLAUDE.md             ← 도메인 레이어 규칙
├── Data/CLAUDE.md               ← 데이터 레이어 규칙
├── Data/Network/CLAUDE.md       ← 네트워크 서브시스템
├── Cooldinator/CLAUDE.md        ← 네비게이션 규칙
└── Presentation/
    ├── Common/CLAUDE.md         ← 공통 컴포넌트
    ├── Launch/CLAUDE.md
    ├── Home/CLAUDE.md
    ├── Entry/CLAUDE.md
    ├── Player/CLAUDE.md
    ├── Camera/CLAUDE.md
    ├── Save/CLAUDE.md
    ├── Like/CLAUDE.md
    ├── Record/CLAUDE.md
    └── Underline/CLAUDE.md
```

## 3. 기존 패턴 분석

### 기존 README 스타일 (README_RecordInput.md 참조)
- 개요, 주요 기능, API 연동, 파일 구조, 데이터 흐름, 주요 메서드, Toast/NotificationCenter, 유효성 검사, 변경 이력
- 매우 상세하고 사람 읽기용

### CLAUDE.md 추가 요소 (AI 작업 가이드)
- 이 모듈에서 작업 시 반드시 지켜야 할 패턴
- 금지사항 (실수하기 쉬운 것)
- DIContainer 팩토리 메서드명
- AppCoordinator 라우트명
- NotificationCenter 이름

## 4. 의존성 맵 (피처 → UseCase → Repository → API)

| 피처 | ViewModel | UseCase | Repository | API endpoint |
|------|-----------|---------|------------|-------------|
| Home | HomeViewModel | FetchFeedUseCase, GetLikesUseCase | FeedRepository, LikeRepository | GET /feeds, GET /likes |
| Entry | EntryViewModel, ChatViewModel | (직접 APIService 호출) | DocentRepository | - |
| Player | PlayerViewModel | PlayDocentUseCase | DocentRepository | streamAudio |
| Save | SaveViewModel | GetFoldersUseCase, CreateFolderUseCase, UpdateFolderUseCase, DeleteFolderUseCase | FolderRepository | /folders |
| Sidebar | SidebarViewModel | GetDashboardSummaryUseCase, GetAIDocentSettingsUseCase | DashboardRepository, AIDocentSettingsRepository | - |
| Like | LikeViewModel | GetLikesUseCase | LikeRepository | GET /likes |
| Record | RecordViewModel, RecordInputViewModel | GetRecordsUseCase, CreateRecordUseCase, DeleteRecordUseCase | RecordRepository | GET/POST/DELETE /records |
| Underline | UnderlineViewModel | GetHighlightsUseCase | HighlightRepository | GET /highlights |
| Launch | LaunchViewModel | KakaoLoginUseCase | AuthRepository | POST /auth/kakao |
| Camera | CameraViewController | (직접 APIService 또는 Coordinator) | - | - |

## 5. DIContainer 팩토리 현황

```swift
makeHomeViewModel()
makeDocentListViewModel()
makePlayerViewModel(docent:)
makeSidebarViewModel()
makeSaveViewModel()
makeRecordViewModel()
makeRecordInputViewModel()
makeLikeViewModel()
makeUnderlineViewModel()
makeLaunchViewModel()
makeAIDocentSettingsViewModel(currentPersonal:currentLength:currentSpeed:currentDifficulty:)
```

## 6. AppCoordinator 라우트 현황

```swift
start()                          // Home
showEntry(docent:)               // HomeCoordinating
showCamera()                     // HomeCoordinating
showSidebar(from:)               // HomeCoordinating
showChat(docent:keyword:)        // EntryCoordinating
showPlayer(docent:)              // EntryCoordinating, UnderlineCoordinating
showSave(folderId:)              // PlayerCoordinating
showLike()                       // SidebarCoordinating
showSave()                       // SidebarCoordinating (folderId=nil)
showUnderline()                  // SidebarCoordinating
showRecord()                     // SidebarCoordinating
showAIDocentSettings(currentPersonal:) // SidebarCoordinating
showRecordInput()                // RecordCoordinating
dismissCameraAndShowEntry(docent:)
dismissCameraAndShowPlayer(docent:)
navigateToEntryFromCamera(with:)
popToHome()
logout()
```

## 7. NotificationCenter 이름 (Core/Constants/NotificationNames.swift)

- `.forceLogout` — 토큰 만료 시 강제 로그아웃
- `.recordDidCreate` — 전시기록 생성 완료 (목록 갱신 트리거)
