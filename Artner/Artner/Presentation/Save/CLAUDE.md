# Save — 저장 폴더 + Sidebar + AI 도슨트 설정

저장된 도슨트를 폴더로 관리하는 화면. 사이드바(Sidebar)와 AI 도슨트 설정(AIDocentSettings)도 이 모듈에 포함.

## 파일 구조

```
Save/
├── Model/
│   └── SaveFolderModel.swift            # 폴더 UI 모델
├── View/
│   ├── SaveView.swift                   # 폴더 목록 레이아웃
│   ├── SaveFolderCell.swift             # 폴더 셀
│   ├── SaveFolderDetailView.swift       # 폴더 상세 (도슨트 목록)
│   ├── SaveEmptyView.swift              # 빈 상태 뷰
│   ├── CreateFolderModalView.swift      # 폴더 생성 모달
│   ├── SelectFolderModalView.swift      # 폴더 선택 모달
│   └── FolderSelectBottomSheet.swift    # 바텀시트
├── ViewController/
│   ├── SaveViewController.swift         # 폴더 목록 VC
│   └── SaveFolderDetailViewController.swift  # 폴더 상세 VC
├── ViewModel/
│   └── SaveViewModel.swift              # 폴더 CRUD 상태 관리
│
├── Sidebar/                             # 사이드메뉴
│   ├── View/
│   │   ├── SidebarView.swift            # 사이드바 메뉴 레이아웃
│   │   ├── SidebarStatButton.swift      # 통계 버튼 (좋아요/저장/하이라이트/기록)
│   │   └── SideMenuContainerView.swift  # 사이드메뉴 컨테이너 (슬라이드 애니메이션)
│   ├── ViewController/
│   │   └── SidebarViewController.swift # 사이드바 VC + SidebarViewControllerDelegate
│   └── ViewModel/
│       └── SidebarViewModel.swift       # 대시보드 통계 + AI 도슨트 설정 보유
│
└── AIDocentSettings/                    # AI 도슨트 말하기 설정
    ├── View/
    │   └── AIDocentSettingsView.swift
    ├── ViewController/
    │   └── AIDocentSettingsViewController.swift
    ├── ViewModel/
    │   └── AIDocentSettingsViewModel.swift
    └── AIDocentSelection/               # 말하기 스타일 선택
        ├── AIDocentSelectionView.swift
        └── AIDocentSelectionViewController.swift
```

## 데이터 흐름

### Save (폴더 목록)
```
SaveView
  ↓
SaveViewController → viewModel.fetchFolders()
  ↓
SaveViewModel → GetFoldersUseCase.execute()
  ↓ GET /folders
SaveViewModel → folders (Publisher)
```

### Sidebar
```
SidebarView (메뉴 탭)
  ↓
SidebarViewController → delegate 메서드 호출 (SidebarViewControllerDelegate)
  ↓
AppCoordinator → showLike() / showSave() / showUnderline() / showRecord() / ...
```

### AIDocentSettings 저장 후 Sidebar 갱신
```
AIDocentSettingsViewController (저장 버튼)
  ↓
AIDocentSettingsViewController.onSave?(length, speed, difficulty)
  ↓
AppCoordinator → currentSidebarViewModel?.updateSpeakingDisplayValues(...)
```

## UseCase / Repository / API 맵

| 모듈 | UseCase | API |
|------|---------|-----|
| Save | GetFoldersUseCase, CreateFolderUseCase, UpdateFolderUseCase, DeleteFolderUseCase | GET/POST/PATCH/DELETE `/folders` |
| Sidebar | GetDashboardSummaryUseCase, GetAIDocentSettingsUseCase | GET `/dashboard`, GET `/docent/settings` |
| AIDocentSettings | (설정 저장 UseCase — 추가 필요 시) | POST `/docent/settings` |

## DIContainer 팩토리

```swift
container.makeSaveViewModel()
container.makeSidebarViewModel()
container.makeAIDocentSettingsViewModel(currentPersonal:currentLength:currentSpeed:currentDifficulty:)
```

## AI 작업 가이드

### 폴더 CRUD 패턴
- 생성: `viewModel.createFolder(name:)` → 성공 시 목록 갱신
- 수정: `viewModel.updateFolder(id:name:)` → 성공 시 목록 갱신
- 삭제: `viewModel.deleteFolder(id:)` → 성공 시 목록 갱신 + Toast
- 각 CRUD 완료 후 반드시 Toast 표시

### SidebarViewController 패턴
- VC → Coordinator 이벤트 전달은 `SidebarViewControllerDelegate` 프로토콜 사용
- 사이드바 닫기는 `coordinator.closeSidebar()` (SidebarCoordinating)

### AIDocentSettings 저장
- `AIDocentSettingsViewController.onSave` 콜백으로 결과 전달 (Coordinator에서 설정)
- 저장 후 Sidebar의 표시값 업데이트: `currentSidebarViewModel?.updateSpeakingDisplayValues`

### SaveViewController 특이사항
- `goToFeedHandler` — 홈으로 이동 클로저 (TabBar 없이 popToHome 사용)
- `navigateToFolder(folderId:)` — 특정 폴더로 직접 이동 (Player에서 저장 후 이동 시)

## 관련 문서
- `../Common/CLAUDE.md` — Toast
- `../../Cooldinator/CLAUDE.md` — showSave, showAIDocentSettings 라우트
