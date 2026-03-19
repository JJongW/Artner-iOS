# ios.refactor.extract_pattern

## 설명
기존 코드를 프로젝트 아키텍처 패턴에 맞게 리팩토링한다.

## 파라미터
- `targetFiles` (Array, 필수): 리팩토링 대상 파일 목록
- `refactorType` (String, 필수): 리팩토링 유형

## 리팩토링 유형

### callback_to_combine
콜백 패턴을 Combine Publisher 패턴으로 변환.
```swift
// Before
func fetchData(completion: @escaping (Result<[Item], Error>) -> Void) {
    apiService.request(.getData) { result in
        completion(result)
    }
}

// After
func fetchData() -> AnyPublisher<[Item], Error> {
    apiService.request(.getData)
        .map { (dto: ItemResponseDTO) in dto.toDomainEntities() }
        .eraseToAnyPublisher()
}
```

### extract_method
긴 메서드에서 논리적 단위를 별도 메서드로 추출.
```swift
// Before
override func setupUI() {
    // 50줄의 UI 설정 코드
}

// After
override func setupUI() {
    setupTableView()
    setupNavigationBar()
    setupRefreshControl()
}
```

### protocol_extraction
구체 타입 의존을 프로토콜로 추출.
```swift
// Before
class ViewModel {
    private let service: APIService  // 구체 타입

// After
class ViewModel {
    private let service: APIServiceProtocol  // 프로토콜
```

### move_to_layer
잘못된 레이어에 있는 코드를 올바른 레이어로 이동.
```swift
// Before: ViewController에서 직접 API 호출
viewModel.apiService.request(.getData) { ... }

// After: UseCase를 통한 호출
viewModel.loadData()  // 내부에서 UseCase.execute()
```

### decompose_viewcontroller
비대한 ViewController를 View + ViewModel로 분리.
```swift
// Before: VC에 UI + 로직 혼재

// After:
// {Feature}View.swift - UI 구성 (BaseView 상속)
// {Feature}ViewModel.swift - 비즈니스 로직
// {Feature}ViewController.swift - 바인딩만
```

## 리팩토링 절차
1. 대상 파일 전체 읽기
2. 현재 구조 분석 + 문제점 식별
3. 목표 구조 결정 (프로젝트 패턴 준수)
4. 단계적 변환 (한 번에 하나씩)
5. 기존 기능 보존 확인

## 체크리스트
- [ ] 리팩토링 전후 외부 인터페이스 동일 (또는 호출부 동시 수정)
- [ ] Clean Architecture 레이어 의존 방향 준수
- [ ] 기존 Combine/Closure 패턴과 일관성
- [ ] 코드 중복 제거
- [ ] 단일 책임 원칙 (SRP) 준수
