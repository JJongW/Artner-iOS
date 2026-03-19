# ios.combine.create_binding

## 설명
ViewModel의 @Published 프로퍼티와 ViewController 간 Combine 바인딩을 설정한다.

## 파라미터
- `publishedProperties` (Array, 필수): @Published 프로퍼티 목록
- `actions` (Array, 선택): VC → VM 액션 메서드 목록

## 수정 대상 파일
- `Artner/Artner/Presentation/{Feature}/ViewModel/{Feature}ViewModel.swift`
- `Artner/Artner/Presentation/{Feature}/ViewController/{Feature}ViewController.swift`

## 핵심 패턴

### ViewModel 측
```swift
import Foundation
import Combine

final class {Feature}ViewModel {
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Output (VM → VC)
    @Published private(set) var items: [{Entity}] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Dependencies
    private let useCase: {Action}UseCase

    init(useCase: {Action}UseCase) {
        self.useCase = useCase
    }

    // MARK: - Input (VC → VM)
    func loadData() {
        isLoading = true
        useCase.execute { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false
                self?.items = result
            }
        }
    }

    func refresh() {
        loadData()
    }
}
```

### ViewController 측
```swift
override func setupBinding() {
    super.setupBinding()
    bindData()
    bindAction()
}

private func bindData() {
    // items → UI 업데이트
    viewModel.$items
        .receive(on: DispatchQueue.main)
        .sink { [weak self] _ in
            self?.{feature}View.tableView.reloadData()
        }
        .store(in: &cancellables)

    // isLoading → 로딩 표시
    viewModel.$isLoading
        .receive(on: DispatchQueue.main)
        .sink { [weak self] isLoading in
            if isLoading {
                // 로딩 표시
            } else {
                // 로딩 숨김
            }
        }
        .store(in: &cancellables)

    // errorMessage → 에러 토스트
    viewModel.$errorMessage
        .compactMap { $0 }
        .receive(on: DispatchQueue.main)
        .sink { message in
            ToastManager.shared.showError(message)
        }
        .store(in: &cancellables)
}

private func bindAction() {
    // 버튼 탭 → VM 호출
    {feature}View.actionButton.addTarget(
        self, action: #selector(handleAction), for: .touchUpInside
    )

    // 클로저 기반
    {feature}View.onRefresh = { [weak self] in
        self?.viewModel.refresh()
    }
}
```

## 바인딩 패턴 정리

| 방향 | 패턴 | 예시 |
|---|---|---|
| VM → VC | `$property.receive(on: .main).sink { }` | 데이터 → UI 업데이트 |
| VC → VM | `addTarget` 또는 클로저 | 버튼 탭 → 메서드 호출 |
| VM → Toast | `$errorMessage.compactMap.sink` | 에러 → 토스트 |

## 체크리스트
- [ ] ViewModel: `@Published private(set)` 접근 제어
- [ ] ViewController: `Set<AnyCancellable>` 선언
- [ ] `receive(on: DispatchQueue.main)` 메인 스레드 보장
- [ ] `[weak self]` 메모리 관리
- [ ] `.store(in: &cancellables)` 구독 유지
- [ ] `bindData()` + `bindAction()` 분리
- [ ] `setupBinding()`에서 호출
