# ios.testing.unit_test_viewmodel

## 설명
ViewModel의 유닛 테스트를 작성한다. Mock UseCase를 주입하여 독립적으로 테스트.

## 파라미터
- `targetClass` (String, 필수): 테스트 대상 ViewModel 클래스
- `testCases` (Array, 선택): 테스트 케이스 목록

## 생성 파일
- `ArtnerTests/{TargetClass}Tests.swift`

## 핵심 패턴

### 테스트 클래스 구조
```swift
import XCTest
import Combine
@testable import Artner

final class {TargetClass}Tests: XCTestCase {
    private var sut: {TargetClass}!
    private var mockUseCase: Mock{Action}UseCase!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockUseCase = Mock{Action}UseCase()
        sut = {TargetClass}(useCase: mockUseCase)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockUseCase = nil
        cancellables = nil
        super.tearDown()
    }
}
```

### 테스트 케이스: 성공
```swift
func test_loadData_성공시_items가_업데이트된다() {
    // Given
    let expectedItems = [/* 테스트 데이터 */]
    mockUseCase.stubbedResult = expectedItems

    let expectation = expectation(description: "items 업데이트")

    sut.$items
        .dropFirst()  // 초기값 스킵
        .sink { items in
            XCTAssertEqual(items.count, expectedItems.count)
            expectation.fulfill()
        }
        .store(in: &cancellables)

    // When
    sut.loadData()

    // Then
    waitForExpectations(timeout: 2.0)
    XCTAssertEqual(mockUseCase.executeCallCount, 1)
}
```

### 테스트 케이스: 로딩 상태
```swift
func test_loadData_호출시_isLoading이_true가_된다() {
    // Given
    var loadingStates: [Bool] = []

    sut.$isLoading
        .sink { loadingStates.append($0) }
        .store(in: &cancellables)

    // When
    sut.loadData()

    // Then
    XCTAssertTrue(loadingStates.contains(true))
}
```

### 테스트 케이스: 에러
```swift
func test_loadData_실패시_errorMessage가_설정된다() {
    // Given
    mockUseCase.stubbedError = NSError(domain: "Test", code: -1)

    let expectation = expectation(description: "에러 메시지")

    sut.$errorMessage
        .compactMap { $0 }
        .sink { message in
            XCTAssertFalse(message.isEmpty)
            expectation.fulfill()
        }
        .store(in: &cancellables)

    // When
    sut.loadData()

    // Then
    waitForExpectations(timeout: 2.0)
}
```

## 테스트 네이밍 컨벤션
`test_{메서드}_{시나리오}_{기대결과}()`
- 한국어 설명 허용 (프로젝트 주석 컨벤션)

## 체크리스트
- [ ] Given-When-Then 구조
- [ ] setUp/tearDown에서 Mock + SUT 생성/정리
- [ ] `@Published` 프로퍼티는 `$property.dropFirst().sink` 패턴
- [ ] Mock UseCase의 callCount 검증
- [ ] 비동기 테스트에 XCTestExpectation 사용
- [ ] 메모리 누수 방지: tearDown에서 nil 처리
