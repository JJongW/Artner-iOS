# ios.networking.add_full_pipeline

## 설명
API 호출부터 ViewModel까지 전체 데이터 파이프라인을 생성한다.
APITarget → DTO → Repository(Protocol+Impl) → UseCase(Protocol+Impl) → DIContainer 등록.

## 파라미터
- `featureName` (String, 필수): 기능 이름
- `endpoint` (String, 필수): API 경로
- `responseType` (String, 필수): 응답 DTO 타입

## 생성/수정 파일 (순서대로)
1. `Data/Network/APITarget.swift` - enum case 추가
2. `Data/Network/DTOs/{ResponseType}.swift` - DTO 생성
3. `Domain/Entity/{Entity}.swift` - Entity 생성
4. `Domain/Repository/{Feature}Repository.swift` - Protocol 생성
5. `Data/RepositoryImpl/{Feature}RepositoryImpl.swift` - Impl 생성
6. `Domain/UseCase/{Action}UseCase.swift` - Protocol 생성
7. `Data/UseCaseImpl/{Action}UseCaseImpl.swift` - Impl 생성
8. `Data/Network/DIContainer.swift` - lazy var + factory 등록

## 핵심 패턴 (전체 흐름)

### 1. APITarget
```swift
case get{Feature}List
// path: "{endpoint}", method: .get, task: .requestPlain
```

### 2. DTO + Entity
```swift
struct {Feature}ResponseDTO: Codable { ... }
extension {Feature}ResponseDTO {
    func toDomainEntities() -> [{Entity}] { ... }
}
```

### 3. Repository
```swift
// Protocol (Domain)
protocol {Feature}Repository {
    func fetch{Feature}Items(completion: @escaping ([{Entity}]) -> Void)
}

// Impl (Data)
final class {Feature}RepositoryImpl: {Feature}Repository {
    private let apiService: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(apiService: APIServiceProtocol = APIService.shared) {
        self.apiService = apiService
    }

    func fetch{Feature}Items(completion: @escaping ([{Entity}]) -> Void) {
        // apiService 호출 → DTO → toDomainEntities() 변환
    }
}
```

### 4. UseCase
```swift
// Protocol (Domain)
protocol Fetch{Feature}UseCase {
    func execute(completion: @escaping ([{Entity}]) -> Void)
}

// Impl (Data)
final class Fetch{Feature}UseCaseImpl: Fetch{Feature}UseCase {
    private let repository: {Feature}Repository
    init(repository: {Feature}Repository) { self.repository = repository }
    func execute(completion: @escaping ([{Entity}]) -> Void) {
        repository.fetch{Feature}Items(completion: completion)
    }
}
```

### 5. DIContainer 등록
```swift
// Repository
lazy var {feature}Repository: {Feature}Repository = {
    return {Feature}RepositoryImpl(apiService: apiService)
}()

// UseCase
lazy var fetch{Feature}UseCase: Fetch{Feature}UseCase = {
    return Fetch{Feature}UseCaseImpl(repository: {feature}Repository)
}()

// ViewModel Factory
func make{Feature}ViewModel() -> {Feature}ViewModel {
    return {Feature}ViewModel(useCase: fetch{Feature}UseCase)
}
```

## 체크리스트
- [ ] APITarget에 case 추가 (path, method, task, headers)
- [ ] DTO Codable + CodingKeys (snake_case → camelCase)
- [ ] toDomainEntity() 변환 메서드
- [ ] Repository Protocol은 Domain, Impl은 Data 레이어
- [ ] UseCase Protocol은 Domain, Impl은 Data 레이어
- [ ] DIContainer에 lazy var (Repository, UseCase) + factory (ViewModel)
- [ ] 모든 의존성 주입은 init 파라미터로
