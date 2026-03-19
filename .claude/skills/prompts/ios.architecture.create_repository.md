# ios.architecture.create_repository

## 설명
Repository 프로토콜 (Domain) + Impl (Data) 쌍을 생성하고 DIContainer에 등록한다.

## 파라미터
- `entityName` (String, 필수): 관련 Entity 이름 (PascalCase)
- `methods` (Array, 필수): Repository 메서드 목록

## 생성/수정 파일
- `Artner/Artner/Domain/Repository/{Entity}Repository.swift` (신규)
- `Artner/Artner/Data/RepositoryImpl/{Entity}RepositoryImpl.swift` (신규)
- `Artner/Artner/Data/Network/DIContainer.swift` (수정)

## 핵심 패턴

### Repository Protocol (Domain 레이어)
```swift
import Foundation
import Combine

protocol {Entity}Repository {
    func fetch{Entity}Items(completion: @escaping ([{Entity}]) -> Void)
    func get{Entity}Detail(id: Int, completion: @escaping ({Entity}?) -> Void)
}

// Combine 기반
protocol {Entity}Repository {
    func fetch{Entity}Items() -> AnyPublisher<[{Entity}], Error>
}
```

### Repository Impl (Data 레이어)
```swift
import Foundation
import Combine

final class {Entity}RepositoryImpl: {Entity}Repository {
    private let apiService: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    func fetch{Entity}Items(completion: @escaping ([{Entity}]) -> Void) {
        apiService.request(.get{Entity}List)
            .map { (dto: {Entity}ResponseDTO) in dto.toDomainEntities() }
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        print("❌ {Entity} fetch 실패: \(error)")
                        completion([])
                    }
                },
                receiveValue: { entities in
                    completion(entities)
                }
            )
            .store(in: &cancellables)
    }
}
```

### DIContainer 등록
```swift
lazy var {entity}Repository: {Entity}Repository = {
    return {Entity}RepositoryImpl(apiService: apiService)
}()
```

## 체크리스트
- [ ] Protocol은 `Domain/Repository/` 에 위치
- [ ] Impl은 `Data/RepositoryImpl/` 에 위치
- [ ] APIServiceProtocol 의존성 주입 (기본값 APIService.shared)
- [ ] Combine sink + cancellables 패턴
- [ ] 에러 시 빈 배열/nil 반환 (앱 크래시 방지)
- [ ] DIContainer에 `lazy var` 등록
- [ ] Domain Protocol이 Data 레이어 타입에 의존하지 않음
