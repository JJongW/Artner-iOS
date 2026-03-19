# ios.navigation.create_protocol

## 설명
Feature별 Coordinating 프로토콜을 생성하고 AppCoordinator에 채택한다.

## 파라미터
- `featureName` (String, 필수): Feature 이름 (PascalCase)
- `methods` (Array, 필수): 프로토콜 메서드 목록

## 생성/수정 파일
- `Artner/Artner/Core/Base/Coordinator/{Feature}Coordinating.swift` (신규)
- `Artner/Artner/Cooldinator/AppCoordinator.swift` (프로토콜 채택 추가)

## 핵심 패턴

### Coordinating 프로토콜
```swift
import UIKit

protocol {Feature}Coordinating: Coordinator {
    func show{SubFeature}()
    func dismiss{Feature}()
}
```

### AppCoordinator 채택
```swift
// AppCoordinator.swift 클래스 선언에 추가
final class AppCoordinator:
    Coordinator,
    // ... 기존 ...
    {Feature}Coordinating  // 추가
{
```

### AppCoordinator 구현
```swift
// MARK: - {Feature}Coordinating
extension AppCoordinator: {Feature}Coordinating {
    // 또는 클래스 본문에 직접 구현
    func show{SubFeature}() {
        // 네비게이션 구현
    }

    func dismiss{Feature}() {
        navigationController.popViewController(animated: true)
    }
}
```

## 참고: 기존 Coordinating 프로토콜 위치 확인
프로젝트에서 Coordinating 프로토콜 파일 위치가 혼재할 수 있음.
반드시 기존 패턴 확인 후 동일 경로에 생성:
- `Core/Base/Coordinator/` 또는 `Features/{Feature}/`

## 체크리스트
- [ ] `Coordinator` 프로토콜 상속 (`protocol {Feature}Coordinating: Coordinator`)
- [ ] 메서드 시그니처가 `show{Feature}()` 또는 파라미터 있는 경우 적절한 타입 포함
- [ ] AppCoordinator 클래스 선언에 프로토콜 채택
- [ ] AppCoordinator에 메서드 구현
- [ ] 기존 Coordinating 파일과 동일 디렉토리에 생성
