# Home — 홈 피드 화면

앱의 메인 화면. 도슨트 목록(피드)을 표시하고 Entry/Camera/Sidebar 진입점 제공.

## 파일 구조

```
Home/
├── View/
│   ├── HomeView.swift               # 피드 TableView + 배너 레이아웃
│   ├── HomeBannerView.swift         # 상단 배너 (프로모션/광고)
│   └── DocentTableViewCell.swift    # 도슨트 목록 셀 (이미지, 제목, 작가, 좋아요)
├── ViewController/
│   └── HomeViewController.swift    # 피드 로드, 셀 탭 → coordinator.showEntry
└── ViewModel/
    ├── HomeViewModel.swift          # 피드 데이터 + 좋아요 상태 관리
    └── DocentListViewModel.swift    # 도슨트 목록 전용 VM (더미 데이터)
```

## 데이터 흐름

```
HomeView (TableView)
  ↓
HomeViewController → viewModel.fetchFeed()
  ↓
HomeViewModel → FetchFeedUseCase.execute() + GetLikesUseCase.execute()
  ↓
FeedRepositoryImpl + LikeRepositoryImpl → APIService
  ↓
GET /feeds, GET /likes
  ↓ 성공
HomeViewModel → feedItems (CurrentValueSubject)
  ↓
HomeViewController → TableView reload
```

## UseCase / Repository / API 맵

| 항목 | 값 |
|------|----|
| UseCase | `FetchFeedUseCase`, `GetLikesUseCase` |
| Repository | `FeedRepository`, `LikeRepository` |
| API | GET `/feeds`, GET `/likes` |
| DIContainer | `makeHomeViewModel()` |

## 주요 컴포넌트

- `HomeViewController.onCameraTapped` — 카메라 버튼 콜백 → `coordinator.showCamera()`
- `HomeViewController.onShowSidebar` — 사이드바 버튼 콜백 → `coordinator.showSidebar(from:)`
- `HomeViewModel.toggleLike(type:id:)` — 좋아요 토글 (HomeCoordinating 위임)
- `DocentTableViewCell` — 이미지 비동기 로딩 (`UIImageView+Extension` Kingfisher 사용)

## AI 작업 가이드

### 반드시 지킬 것
- 도슨트 셀 탭 → `coordinator.showEntry(docent:)` 호출
- 좋아요 토글은 `coordinator.toggleLike(type:id:completion:)` 사용 (AppCoordinator 위임)
- 피드 로드 실패 시 `ToastManager.shared.showError(...)` 표시
- 스켈레톤 로딩: `SkeletonView` (Common) 사용

### 금지사항
- HomeViewController에서 DIContainer 직접 접근 금지
- 피드 데이터를 VC에서 직접 API 호출 금지

## 관련 문서
- `../Common/CLAUDE.md` — Toast, SkeletonView
- `../Entry/CLAUDE.md` — 도슨트 입장점
- `../../Cooldinator/CLAUDE.md` — showEntry, showCamera, showSidebar 라우트
