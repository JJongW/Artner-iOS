# Like — 좋아요 목록

사용자가 좋아요한 도슨트/전시/작품 목록을 표시. 사이드바에서 진입.

## 파일 구조

```
Like/
├── View/
│   ├── LikeView.swift               # 좋아요 목록 레이아웃 (TableView)
│   └── LikeEmptyView.swift          # 빈 상태 뷰 ("좋아요한 항목이 없습니다")
├── ViewController/
│   └── LikeViewController.swift    # 목록 로드, 셀 탭 → Entry 이동
└── ViewModel/
    └── LikeViewModel.swift          # 좋아요 목록 + 좋아요 해제 상태 관리
```

## 데이터 흐름

```
LikeView (진입)
  ↓
LikeViewController → viewModel.fetchLikes()
  ↓
LikeViewModel → GetLikesUseCase.execute()
  ↓ GET /likes
LikeViewModel → likeItems (Publisher)
  ↓
LikeViewController → TableView reload

셀 탭
  ↓
LikeViewController → coordinator.showEntry(docent:)
```

## UseCase / Repository / API 맵

| 항목 | 값 |
|------|----|
| UseCase | `GetLikesUseCase` |
| Repository | `LikeRepository` |
| API | GET `/likes` |
| DIContainer | `makeLikeViewModel()` |

## 주요 컴포넌트

- `LikeViewController.goToFeedHandler` — 홈으로 이동 클로저 (네비게이션 바 홈 버튼)
- `LikeViewModel.fetchLikes()` — 목록 로드
- `LikeEmptyView` — 좋아요 항목 없을 때 표시

## AI 작업 가이드

### 반드시 지킬 것
- 빈 목록: `LikeEmptyView` 표시
- 로드 실패: `ToastManager.shared.showError(...)`
- 셀 탭 → `coordinator.showEntry(docent:)` (LikeCoordinating)
- 홈 이동: `goToFeedHandler` 클로저 → `coordinator.popToHome()`

### 금지사항
- LikeViewController에서 직접 API 호출 금지

## 관련 문서
- `../Common/CLAUDE.md` — Toast
- `../Entry/CLAUDE.md` — 도슨트 입장점
- `../../Cooldinator/CLAUDE.md` — showLike, popToHome 라우트
