# Underline — 하이라이트(밑줄) 목록

Player에서 저장한 텍스트 하이라이트 목록을 조회하고 도슨트 재생으로 이어지는 화면.

## 파일 구조

```
Underline/
├── View/
│   ├── UnderlineView.swift          # 하이라이트 목록 레이아웃
│   └── UnderlineEmptyView.swift     # 빈 상태 뷰
├── ViewController/
│   └── UnderlineViewController.swift # 목록 로드, 셀 탭 → Player 이동
└── ViewModel/
    └── UnderlineViewModel.swift      # 하이라이트 목록 + 도슨트 정보 조합
```

## 데이터 흐름

```
UnderlineView (진입)
  ↓
UnderlineViewController → viewModel.fetchHighlights()
  ↓
UnderlineViewModel → GetHighlightsUseCase.execute()
  ↓ GET /highlights
UnderlineViewModel → highlights (Publisher)
  ↓
UnderlineViewController → 목록 표시

셀 탭 (해당 도슨트 재생)
  ↓
UnderlineViewController → coordinator.showPlayer(docent:)
```

## UseCase / Repository / API 맵

| 항목 | 값 |
|------|----|
| UseCase | `GetHighlightsUseCase` |
| Repository | `HighlightRepository` |
| API | GET `/highlights` |
| DIContainer | `makeUnderlineViewModel()` |

## 주요 컴포넌트

- `UnderlineViewController.goToFeedHandler` — 홈으로 이동 클로저
- `UnderlineViewModel.fetchHighlights()` — 하이라이트 목록 로드
- `UnderlineEmptyView` — 하이라이트 없을 때 표시

## AI 작업 가이드

### 반드시 지킬 것
- 하이라이트 셀 탭 → `coordinator.showPlayer(docent:)` (UnderlineCoordinating)
- 빈 목록: `UnderlineEmptyView` 표시
- 로드 실패: `ToastManager.shared.showError(...)`
- 홈 이동: `goToFeedHandler` → `coordinator.popToHome()`

### 금지사항
- UnderlineViewController에서 직접 API 호출 금지

## 관련 문서
- `../Player/CLAUDE.md` — 오디오 플레이어 (하이라이트 저장 위치)
- `../Common/CLAUDE.md` — Toast
- `../../Cooldinator/CLAUDE.md` — showUnderline, showPlayer 라우트
