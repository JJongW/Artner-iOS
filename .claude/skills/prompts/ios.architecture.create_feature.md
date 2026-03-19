# ios.architecture.create_feature

## 설명
새 Feature의 전체 스캐폴딩을 생성한다. 모든 Clean Architecture 레이어를 포함.
내부적으로 다른 스킬들을 체이닝하여 일관된 구조를 보장한다.

## 파라미터
- `featureName` (String, 필수): Feature 이름 (PascalCase)
- `hasApi` (Boolean, 선택, 기본 true): API 연동 포함 여부
- `components` (Array, 선택): UI 컴포넌트 목록

## 생성 파일 구조
```
Artner/Artner/
├── Presentation/{Feature}/
│   ├── ViewController/{Feature}ViewController.swift
│   ├── View/{Feature}View.swift
│   └── ViewModel/{Feature}ViewModel.swift
├── Domain/
│   ├── Entity/{Entity}.swift           (hasApi=true)
│   ├── Repository/{Feature}Repository.swift  (hasApi=true)
│   └── UseCase/Fetch{Feature}UseCase.swift   (hasApi=true)
├── Data/
│   ├── Network/DTOs/{Feature}DTO.swift       (hasApi=true)
│   ├── RepositoryImpl/{Feature}RepositoryImpl.swift (hasApi=true)
│   └── UseCaseImpl/Fetch{Feature}UseCaseImpl.swift  (hasApi=true)
├── Core/Base/Coordinator/{Feature}Coordinating.swift
└── Cooldinator/AppCoordinator.swift   (수정)
    Data/Network/DIContainer.swift     (수정)
```

## 실행 순서

### Step 1: Coordinating 프로토콜
```swift
protocol {Feature}Coordinating: Coordinator {
    func dismiss{Feature}()
}
```

### Step 2: Presentation 레이어 (VC + View + VM)
- `ios.uikit.create_screen` 패턴 적용

### Step 3: Data 파이프라인 (hasApi=true인 경우)
- `ios.networking.add_full_pipeline` 패턴 적용
- APITarget → DTO → Repository → UseCase → DIContainer

### Step 4: AppCoordinator 통합
```swift
// 클래스 선언에 프로토콜 채택 추가
final class AppCoordinator: ..., {Feature}Coordinating {

// 네비게이션 메서드 구현
func show{Feature}() {
    let viewModel = container.make{Feature}ViewModel()
    let viewController = {Feature}ViewController(
        viewModel: viewModel,
        coordinator: self
    )
    navigationController.pushViewController(viewController, animated: true)
}
```

### Step 5: DIContainer 등록
```swift
// Repository + UseCase (hasApi=true)
lazy var {feature}Repository: {Feature}Repository = { ... }()
lazy var fetch{Feature}UseCase: Fetch{Feature}UseCase = { ... }()

// ViewModel Factory
func make{Feature}ViewModel() -> {Feature}ViewModel { ... }
```

## 체크리스트
- [ ] 모든 레이어 파일 생성 완료
- [ ] Coordinating 프로토콜 생성 + AppCoordinator 채택
- [ ] DIContainer에 Repository, UseCase, ViewModel factory 등록
- [ ] AppCoordinator에 show 메서드 구현
- [ ] ViewController → BaseViewController 상속
- [ ] View → BaseView 상속
- [ ] Domain 레이어가 Data 레이어에 의존하지 않음
- [ ] 모든 의존성 init 주입
