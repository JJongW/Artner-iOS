# Player — 오디오 플레이어 + 하이라이트

도슨트 오디오를 재생하고 스크립트 텍스트를 동기화. 텍스트 하이라이트(밑줄) 저장 기능 포함.

## 파일 구조

```
Player/
├── Model/
│   └── PlayerUIModel.swift          # 재생 상태 UI 표현 모델
├── View/
│   ├── PlayerView.swift             # 메인 플레이어 레이아웃 (스크립트 + 컨트롤)
│   ├── PlayerControlsView.swift     # 재생/일시정지/되감기 컨트롤
│   └── Components/
│       ├── ParagraphTableViewCell.swift  # 스크립트 문단 셀 (텍스트 선택 가능)
│       └── NonEditableTextView.swift     # 선택만 가능한 TextView (편집 불가)
├── ViewController/
│   └── PlayerViewController.swift  # AVPlayer 연동, 재생 제어, 하이라이트 저장
└── ViewModel/
    └── PlayerViewModel.swift        # 재생 상태, 스크립트 동기화, 하이라이트 관리
```

## 데이터 흐름

### 재생
```
PlayerView (재생 버튼)
  ↓
PlayerViewController → viewModel.togglePlayPause()
  ↓
PlayerViewModel → AVPlayer.play() / .pause()
  ↓ 시간 업데이트 (CMTime Observer)
PlayerViewModel → currentParagraphIndex 업데이트
  ↓
PlayerView → 현재 문단 하이라이트 (스크롤)
```

### 하이라이트 저장
```
ParagraphTableViewCell (텍스트 선택)
  ↓
PlayerViewController → viewModel.saveHighlight(TextHighlight)
  ↓
PlayerViewModel → HighlightRepository 또는 로컬 저장
  ↓
ToastManager.showSaved("하이라이트가 저장되었습니다") { viewAction }
```

### audioURL 없는 Docent 처리 (AppCoordinator에서 처리)
```
AppCoordinator.showPlayer(docent:)
  → audioURL == nil → streamAudio(jobId:) 호출
  → 로컬 파일 URL 획득 → Docent 재생성 → PlayerViewController 생성
```

## UseCase / API 맵

| 항목 | 값 |
|------|----|
| UseCase | `PlayDocentUseCase` (더미 도슨트 목록), 하이라이트는 직접 저장 |
| Repository | `DocentRepository` (더미), `HighlightRepository` |
| DIContainer | `makePlayerViewModel(docent:)` |

## 주요 컴포넌트

- `PlayerViewModel.currentTime` — AVPlayer 시간 → 문단 동기화
- `PlayerViewModel.saveHighlight(_:)` — 선택 텍스트 저장 + Toast 표시
- `GradientProgressView` — 재생 진행 바 (Common 컴포넌트)
- `PlayerCoordinating.showSave(folderId:)` — "보기" 버튼 → Save 화면

## AI 작업 가이드

### 반드시 지킬 것
- AVPlayer 정리: `deinit`에서 `player.pause()` + observer 제거
- 하이라이트 저장 성공: `ToastManager.showSaved(...)` (viewAction으로 showSave 연결)
- 재생 시간 Observer: `addPeriodicTimeObserver` (메모리 누수 주의 — `[weak self]`)
- 문단 동기화: Docent.paragraphs[].startTime/endTime 기준

### 금지사항
- PlayerViewModel에서 UIKit 직접 참조 금지
- AVPlayer를 ViewController에서 직접 생성 금지 (ViewModel이 관리)

## 관련 문서
- `../Underline/CLAUDE.md` — 하이라이트 목록 화면
- `../Common/CLAUDE.md` — GradientProgressView, Toast
- `../../Cooldinator/CLAUDE.md` — showSave, showPlayer 라우트
