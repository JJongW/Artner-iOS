# ios.navigation.add_route

## 설명
AppCoordinator에 새로운 네비게이션 메서드를 추가한다.

## 파라미터
- `fromFeature` (String, 필수): 출발 Feature 이름
- `toFeature` (String, 필수): 도착 Feature 이름
- `navigationType` (String, 선택): push | present | modal (기본: push)

## 수정 대상 파일
- `Artner/Artner/Cooldinator/AppCoordinator.swift` - show 메서드 추가
- 출발 Feature의 Coordinating 프로토콜 - 메서드 선언 추가 (필요 시)

## 핵심 패턴

### AppCoordinator에 메서드 추가
```swift
// MARK: - {ToFeature}Coordinating
extension AppCoordinator {
    func show{ToFeature}() {
        let viewModel = container.make{ToFeature}ViewModel()
        let viewController = {ToFeature}ViewController(
            viewModel: viewModel,
            coordinator: self
        )
        navigationController.pushViewController(viewController, animated: true)
    }
}
```

### Present 방식
```swift
func show{ToFeature}() {
    let viewModel = container.make{ToFeature}ViewModel()
    let viewController = {ToFeature}ViewController(
        viewModel: viewModel,
        coordinator: self
    )
    viewController.modalPresentationStyle = .fullScreen
    navigationController.present(viewController, animated: true)
}
```

### Coordinating 프로토콜에 메서드 추가
```swift
// {FromFeature}Coordinating.swift
protocol {FromFeature}Coordinating: Coordinator {
    func show{ToFeature}()  // 추가
}
```

### AppCoordinator 클래스 선언에 프로토콜 채택 확인
```swift
final class AppCoordinator:
    Coordinator,
    // ... 기존 프로토콜들 ...
    {ToFeature}Coordinating  // 추가 (새 프로토콜인 경우)
{
```

## 체크리스트
- [ ] AppCoordinator에 `show{ToFeature}()` 메서드 추가
- [ ] DIContainer에서 ViewModel 생성 (`container.make{ToFeature}ViewModel()`)
- [ ] 출발 Feature Coordinating 프로토콜에 메서드 선언 확인
- [ ] AppCoordinator 클래스 선언에 Coordinating 프로토콜 채택 확인
- [ ] navigationType에 따른 push/present 방식 적용
- [ ] animated 파라미터 기본 true
