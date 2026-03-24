# Artner-iOS

iOS app for art docent (도슨트) experience - provides AI-powered audio guides for artwork.

## Project Structure

```
Artner/Artner/
├── AppDelegate.swift
├── SceneDelegate.swift
├── Cooldinator/          # Coordinator pattern for navigation
│   └── AppCoordinator.swift
├── Domain/               # Business logic layer (Clean Architecture)
│   ├── Entity/           # Domain models
│   ├── Repository/       # Repository protocols
│   └── UseCase/          # UseCase protocols
├── Data/                 # Data layer implementation
│   ├── Network/          # API service, DTOs, DIContainer
│   ├── RepositoryImpl/   # Repository implementations
│   ├── UseCaseImpl/      # UseCase implementations
│   └── Storage/          # Keychain, TokenManager
├── Presentation/         # UI layer
│   ├── Base/             # BaseViewController
│   ├── Common/           # Shared UI components (ToastManager, NavigationBar, etc.)
│   ├── Home/             # Main feed screen
│   ├── Entry/            # Docent entry point
│   ├── Player/           # Audio player screen
│   ├── Camera/           # Camera for artwork scanning
│   ├── Save/             # Saved folders
│   ├── Like/             # Liked items
│   ├── Record/           # Exhibition records
│   ├── Underline/        # Highlighted items
│   └── Launch/           # Login screen
├── Extension/            # UIKit extensions
└── Resources/            # Assets, colors, fonts
```

## Architecture

- **Clean Architecture** with Domain, Data, Presentation layers
- **Coordinator Pattern** for navigation (`AppCoordinator`)
- **MVVM** in Presentation layer
- **Dependency Injection** via `DIContainer` singleton
- **Combine** for reactive programming

## Key Components

### DIContainer (`Data/Network/DIContainer.swift`)
Singleton container for dependency injection. Use factory methods like:
- `makeHomeViewModel()`
- `makePlayerViewModel(docent:)`
- `makeSaveViewModel()`

### AppCoordinator (`Cooldinator/AppCoordinator.swift`)
Handles all navigation:
- `showEntry(docent:)` - Docent detail
- `showPlayer(docent:)` - Audio player
- `showCamera()` - Camera screen
- `showSidebar(from:)` - Side menu

### ToastManager (`Presentation/Common/ToastManager.swift`)
Singleton for toast notifications:
- `showSuccess(_:)`, `showError(_:)`, `showLoading(_:)`

## Build & Run

Open `Artner/Artner.xcodeproj` in Xcode.

### Environment Variables (Required for Development)
Set in Xcode: Product → Scheme → Edit Scheme → Run → Environment Variables:
- `DEV_ACCESS_TOKEN`
- `DEV_REFRESH_TOKEN`

## Common Patterns

### Creating a new screen
1. Create ViewModel in `Presentation/{Feature}/ViewModel/`
2. Create ViewController in `Presentation/{Feature}/ViewController/`
3. Create View in `Presentation/{Feature}/View/` (if needed)
4. Add factory method to `DIContainer`
5. Add navigation method to `AppCoordinator`

### API Calls
1. Define endpoint in `Data/Network/APITarget.swift`
2. Create DTO in `Data/Network/DTOs/`
3. Create/update Repository protocol in `Domain/Repository/`
4. Implement in `Data/RepositoryImpl/`
5. Create UseCase if needed

## Language

- Code comments and documentation: Korean (한국어)
- Variable/function names: English

## 피처별 CLAUDE.md

각 레이어/피처 디렉토리에 `CLAUDE.md`가 있습니다. 특정 피처 작업 시 해당 파일을 먼저 읽으세요.

| 경로 | 내용 |
|------|------|
| `Artner/Artner/Domain/CLAUDE.md` | 도메인 레이어 — Entity, Repository/UseCase 프로토콜 규칙 |
| `Artner/Artner/Data/CLAUDE.md` | 데이터 레이어 — RepositoryImpl, UseCaseImpl, Storage |
| `Artner/Artner/Data/Network/CLAUDE.md` | 네트워크 — APITarget, APIService, DTOs, DIContainer |
| `Artner/Artner/Cooldinator/CLAUDE.md` | 네비게이션 — AppCoordinator 라우트 전체 맵 |
| `Artner/Artner/Presentation/Common/CLAUDE.md` | 공통 UI — ToastManager, NavigationBar, SkeletonView |
| `Artner/Artner/Presentation/Launch/CLAUDE.md` | 로그인 화면 — 카카오 로그인 플로우 |
| `Artner/Artner/Presentation/Home/CLAUDE.md` | 홈 피드 — 도슨트 목록, 좋아요 |
| `Artner/Artner/Presentation/Entry/CLAUDE.md` | 도슨트 입장점 + AI 채팅 |
| `Artner/Artner/Presentation/Player/CLAUDE.md` | 오디오 플레이어 + 하이라이트 저장 |
| `Artner/Artner/Presentation/Camera/CLAUDE.md` | 카메라 스캔 |
| `Artner/Artner/Presentation/Save/CLAUDE.md` | 저장 폴더 + Sidebar + AI 도슨트 설정 |
| `Artner/Artner/Presentation/Like/CLAUDE.md` | 좋아요 목록 |
| `Artner/Artner/Presentation/Record/CLAUDE.md` | 전시 기록 (목록 + 입력) |
| `Artner/Artner/Presentation/Underline/CLAUDE.md` | 하이라이트(밑줄) 목록 |

## Skills System

프로젝트 전용 스킬 시스템이 `.claude/skills/`에 구축되어 있습니다. 슬래시 커맨드(`/커맨드명`)로 실행하거나, 자연어로 요청하면 자동 디스패치됩니다.

### 프로젝트 표준 문서

스킬 실행 시 반드시 `.claude/skills/templates/AI_MANUAL.md`를 먼저 참조합니다.

### 슬래시 커맨드 목록

| 커맨드 | 스킬 ID | 설명 |
|--------|---------|------|
| **Workflow** | | |
| `/plan` | `workflow.orchestrate` | **전체 파이프라인 진입점** — Plan → 구현 → 검증 → 리포트 → Ship 자동 실행 |
| `/orchestrate` | `workflow.orchestrate` | `/plan`과 동일한 전체 파이프라인 (별칭) |
| `/ship` | — | 워크플로우 완료 후 git commit & push |
| `/checklist` | `workflow.checklist_generate` | 체크리스트 단독 생성 |
| `/self-check` | `workflow.self_check` | 자가 검증 단독 실행 |
| `/report` | `workflow.report` | 리포트 단독 생성 |
| **Agent** | | |
| `/team` | `agent.team_orchestrate` | 에이전트 팀 오케스트레이션 |
| `/quality-review` | `agent.quality_review` | 품질 리뷰 |
| `/test-design` | `agent.test_design` | 테스트 설계 |
| **iOS - UI** | | |
| `/create-screen` | `ios.uikit.create_screen` | VC + View + VM 세트 생성 |
| `/create-cell` | `ios.uikit.create_cell` | TableViewCell / CollectionViewCell 생성 |
| **iOS - Architecture** | | |
| `/create-feature` | `ios.architecture.create_feature` | 피처 전체 스캐폴딩 |
| `/create-repository` | `ios.architecture.create_repository` | Repository 프로토콜 + Impl 생성 |
| `/create-usecase` | `ios.architecture.create_usecase` | UseCase 프로토콜 + Impl 생성 |
| **iOS - Networking** | | |
| `/add-endpoint` | `ios.networking.add_endpoint` | APITarget에 새 case 추가 |
| `/add-pipeline` | `ios.networking.add_full_pipeline` | API 전체 파이프라인 생성 |
| `/create-dto` | `ios.networking.create_dto` | Codable DTO 구조체 생성 |
| **iOS - Navigation** | | |
| `/add-route` | `ios.navigation.add_route` | AppCoordinator 라우트 추가 |
| `/create-protocol` | `ios.navigation.create_protocol` | Coordinating 프로토콜 생성 |
| **iOS - 기타** | | |
| `/add-storage` | `ios.persistence.add_storage` | Keychain/UserDefaults 저장소 추가 |
| `/create-binding` | `ios.combine.create_binding` | Combine 바인딩 패턴 생성 |
| **유지보수** | | |
| `/bugfix` | `ios.bugfix.diagnose_fix` | 버그 진단 및 수정 |
| `/refactor` | `ios.refactor.extract_pattern` | 리팩토링 패턴 추출 |
| `/diagnose-memory` | `ios.performance.diagnose_memory` | 메모리 누수 진단 |
| `/optimize-rendering` | `ios.performance.optimize_rendering` | 렌더링 성능 최적화 |
| **테스팅** | | |
| `/setup-tests` | `ios.testing.setup_infrastructure` | XCTest + Mock 인프라 구축 |
| `/test-viewmodel` | `ios.testing.unit_test_viewmodel` | ViewModel 유닛 테스트 |
| `/test-usecase` | `ios.testing.unit_test_usecase` | UseCase 유닛 테스트 |
| **문서/CI** | | |
| `/generate-docs` | `docs.generate_api_docs` | API/아키텍처 문서 생성 |
| `/setup-ci` | `ci_cd.setup_github_actions` | GitHub Actions 워크플로우 설정 |
| **메타** | | |
| `/skills` | — | 전체 스킬 목록 조회 |

### 자연어 디스패치

슬래시 커맨드 외에 자연어로도 스킬이 자동 선택됩니다. 디스패치 규칙은 `.claude/skills/dispatcher.md`를 참조합니다.

- 키워드 매칭 (한국어/영어 동의어)
- 동사 기반 의미 분류 (생성/추가/수정/진단/최적화)
- 복합 의도 → multi-skill chaining
- 폴백 → 일반 어시스트 (스킬 미적용)

### 스킬 시스템 디렉토리 구조

```
.claude/
├── commands/             # 슬래시 커맨드 (30개)
└── skills/
    ├── manifest.json     # 스킬 정의 (파라미터, 카테고리)
    ├── dispatcher.md     # 자연어 → 스킬 매핑 규칙
    ├── examples.md       # 사용 예시
    ├── prompts/          # 스킬별 프롬프트 (32개)
    └── templates/        # 출력 템플릿 (9개)
```
