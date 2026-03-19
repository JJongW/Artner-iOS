# ios.uikit.create_screen

## 설명
BaseViewController + BaseView + ViewModel 세트를 생성한다.
프로젝트의 Clean Architecture MVVM 패턴을 준수한다.

## 파라미터
- `featureName` (String, 필수): 기능 이름 (PascalCase, 예: Search)
- `components` (Array, 선택): UI 컴포넌트 (UITableView, UICollectionView, UISearchBar 등)
- `hasViewModel` (Boolean, 선택, 기본 true): ViewModel 포함 여부

## 생성 파일
- `Artner/Artner/Presentation/{Feature}/ViewController/{Feature}ViewController.swift`
- `Artner/Artner/Presentation/{Feature}/View/{Feature}View.swift`
- `Artner/Artner/Presentation/{Feature}/ViewModel/{Feature}ViewModel.swift` (hasViewModel=true일 때)

## 핵심 패턴

### ViewController
```swift
import UIKit
import Combine

final class {Feature}ViewController: BaseViewController<{Feature}ViewModel, any {Feature}Coordinating> {
    private let {feature}View = {Feature}View()
    private var cancellables = Set<AnyCancellable>()

    override func loadView() {
        self.view = {feature}View
    }

    override func setupUI() {
        super.setupUI()
        // UI 설정
    }

    override func setupBinding() {
        super.setupBinding()
        bindData()
        bindAction()
    }

    private func bindData() {
        // viewModel.$property → UI 업데이트
    }

    private func bindAction() {
        // UI 이벤트 → viewModel 호출
    }
}
```

### View (BaseView 상속, SnapKit)
```swift
import UIKit
import SnapKit

final class {Feature}View: BaseView {
    // UI 컴포넌트 선언
    let tableView = UITableView()

    override func setupUI() {
        backgroundColor = .white
        addSubview(tableView)
    }

    override func setupLayout() {
        tableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
}
```

### ViewModel
```swift
import Foundation
import Combine

final class {Feature}ViewModel {
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var items: [{Entity}] = []
    @Published private(set) var isLoading: Bool = false

    private let useCase: {Action}UseCase

    init(useCase: {Action}UseCase) {
        self.useCase = useCase
    }
}
```

## 체크리스트
- [ ] ViewController가 `BaseViewController<VM, any {Feature}Coordinating>` 상속
- [ ] View가 `BaseView` 상속, `setupUI()` + `setupLayout()` 오버라이드
- [ ] SnapKit으로 레이아웃 구성
- [ ] ViewModel에 `@Published` + `Set<AnyCancellable>` 사용
- [ ] loadView()에서 커스텀 View 주입
- [ ] `setupBinding()`에서 `bindData()` + `bindAction()` 분리
- [ ] DIContainer에 `make{Feature}ViewModel()` factory 추가
- [ ] Storyboard 미사용 (프로그래밍 방식 UI)
