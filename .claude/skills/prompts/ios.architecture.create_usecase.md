# ios.architecture.create_usecase

## 설명
UseCase 프로토콜 (Domain) + Impl (Data) 쌍을 생성하고 DIContainer에 등록한다.

## 파라미터
- `action` (String, 필수): 유즈케이스 액션 (예: FetchSearchResults, GetLikes)
- `entityName` (String, 필수): 관련 Domain Entity 이름
- `repositoryName` (String, 필수): 의존 Repository 프로토콜 이름

## 생성/수정 파일
- `Artner/Artner/Domain/UseCase/{Action}UseCase.swift` (신규)
- `Artner/Artner/Data/UseCaseImpl/{Action}UseCaseImpl.swift` (신규)
- `Artner/Artner/Data/Network/DIContainer.swift` (수정 - lazy var 추가)

## 핵심 패턴

### UseCase Protocol (Domain 레이어)
```swift
import Foundation
import Combine

protocol {Action}UseCase {
    func execute(completion: @escaping ([{Entity}]) -> Void)
}

// Combine 기반 인터페이스가 필요한 경우
protocol {Action}UseCase {
    func execute() -> AnyPublisher<[{Entity}], Error>
}
```

### UseCase Impl (Data 레이어)
```swift
import Foundation
import Combine

final class {Action}UseCaseImpl: {Action}UseCase {
    private let repository: {RepositoryName}

    init(repository: {RepositoryName}) {
        self.repository = repository
    }

    func execute(completion: @escaping ([{Entity}]) -> Void) {
        repository.fetch{Entity}Items(completion: completion)
    }
}
```

### DIContainer 등록
```swift
// UseCase
lazy var {action}UseCase: {Action}UseCase = {
    return {Action}UseCaseImpl(repository: {repository}Repository)
}()
```

## 체크리스트
- [ ] Protocol은 `Domain/UseCase/` 에 위치
- [ ] Impl은 `Data/UseCaseImpl/` 에 위치
- [ ] `execute()` 메서드 네이밍 통일
- [ ] Repository 의존성 init 주입
- [ ] DIContainer에 `lazy var` 등록
- [ ] 기존 UseCase 패턴과 일관성 확인 (completion vs Combine)
