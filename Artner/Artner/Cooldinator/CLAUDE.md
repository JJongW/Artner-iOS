# Coordinator 네비게이션

모든 화면 전환의 단일 책임자. ViewController는 이벤트만 발생시키고, AppCoordinator가 화면 이동을 처리한다.

## 파일 구조

```
Cooldinator/
└── AppCoordinator.swift     # 전체 화면 전환 구현

Core/Base/Coordinator/
└── Coordinator.swift        # Coordinator 기본 프로토콜

Features/                    # 피처별 Coordinating 프로토콜 (VC가 참조)
├── Camera/CameraCoordinating.swift
├── Entry/EntryCoordinating.swift
├── Home/HomeCoordinating.swift
├── Launch/LaunchCoordinating.swift
├── Like/LikeCoordinating.swift
├── Player/PlayerCoordinating.swift
├── Record/RecordCoordinating.swift
├── Save/SaveCoordinating.swift
└── Underline/UnderlineCoordinating.swift
```

## 아키텍처 패턴

```
ViewController
  ├── coordinator: XxxCoordinating (프로토콜 참조 — 구현체 모름)
  └── 이벤트 발생 → coordinator.showXxx()

AppCoordinator
  └── XxxCoordinating 프로토콜 구현 (모든 화면 전환 메서드 보유)
```

## 전체 라우트 맵

| 메서드 | 트리거 | 이동 화면 | 방식 |
|--------|--------|-----------|------|
| `start()` | AppDelegate | Home | setViewControllers |
| `showEntry(docent:)` | Home 셀 탭 | Entry | push |
| `showCamera()` | Home 카메라 버튼 | Camera | present (fullScreen) |
| `showSidebar(from:)` | Home 사이드바 버튼 | Sidebar | SideMenuContainerView |
| `showChat(docent:keyword:)` | Entry 채팅 입력 | Chat | push |
| `showPlayer(docent:)` | Entry/Underline | Player | push (audioURL 없으면 streamAudio 먼저) |
| `showSave(folderId:)` | Player | Save | push |
| `showLike()` | Sidebar | Like | dismiss sidebar → push |
| `showSave()` | Sidebar | Save | dismiss sidebar → push |
| `showUnderline()` | Sidebar | Underline | dismiss sidebar → push |
| `showRecord()` | Sidebar | Record | dismiss sidebar → push |
| `showAIDocentSettings(currentPersonal:)` | Sidebar | AIDocentSettings | dismiss sidebar → push |
| `showRecordInput()` | Record | RecordInput | present (fullScreen) |
| `dismissCameraAndShowEntry(docent:)` | Camera | Entry | dismiss → push |
| `dismissCameraAndShowPlayer(docent:)` | Camera | Player | dismiss → push |
| `popToHome()` | Like/Save/Record/Underline | Home | popToRoot |
| `logout()` | Sidebar | Launch | dismiss sidebar → setViewControllers |

## 새 화면 추가 시 Coordinating 프로토콜 패턴

```swift
// 1. Features/NewFeature/NewFeatureCoordinating.swift
protocol NewFeatureCoordinating: AnyObject {
    func showNewScreen()
    func popViewController(animated: Bool)
}

// 2. ViewController에서 사용
final class NewFeatureViewController: BaseViewController {
    private weak var coordinator: NewFeatureCoordinating?

    init(coordinator: NewFeatureCoordinating) {
        self.coordinator = coordinator
    }
}

// 3. AppCoordinator에 채택 추가
final class AppCoordinator: ..., NewFeatureCoordinating {
    func showNewScreen() {
        let vm = container.makeNewFeatureViewModel()
        let vc = NewFeatureViewController(viewModel: vm, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }
}
```

## Sidebar 특이사항

- `SideMenuContainerView`로 커스텀 슬라이드 사이드메뉴 구현
- `sideMenu?.dismissMenu(completion:)` — 사이드바 닫은 후 화면 전환
- `currentSidebarViewModel` — AIDocentSettings 저장 후 Sidebar 값 갱신용 back-reference

## AI 작업 가이드

### 반드시 지킬 것
- VC 내부에서 `UINavigationController.pushViewController` 직접 호출 금지
- 화면 전환 로직은 항상 Coordinator 메서드로 위임
- 새 화면 추가 시: Coordinating 프로토콜 생성 → VC에 주입 → AppCoordinator 구현

### 금지사항
- VC에서 `DIContainer.shared.makeXxx()` 직접 호출 금지
- AppCoordinator에서 VC의 내부 상태를 직접 조작 금지 (콜백/델리게이트 패턴 사용)

## 관련 문서
- `../Presentation/*/CLAUDE.md` — 각 피처의 VC/VM 상세
- `../../CLAUDE.md` (루트) — 전체 아키텍처 원칙
