# ios.testing.unit_test_usecase

## 설명
UseCase의 유닛 테스트를 작성한다. Mock Repository를 주입하여 독립적으로 테스트.

## 파라미터
- `targetClass` (String, 필수): 테스트 대상 UseCase 클래스 (Impl)
- `mockRepository` (String, 필수): Mock Repository 이름

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
    private var mockRepository: Mock{Repository}!
    private var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        mockRepository = Mock{Repository}()
        sut = {TargetClass}(repository: mockRepository)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockRepository = nil
        cancellables = nil
        super.tearDown()
    }
}
```

### 테스트 케이스: execute 성공
```swift
func test_execute_성공시_repository_데이터를_반환한다() {
    // Given
    let expectedItems = [/* 테스트 Entity */]
    mockRepository.stubbedItems = expectedItems

    let expectation = expectation(description: "execute 완료")

    // When
    sut.execute { items in
        // Then
        XCTAssertEqual(items.count, expectedItems.count)
        expectation.fulfill()
    }

    waitForExpectations(timeout: 2.0)
    XCTAssertEqual(mockRepository.fetchCallCount, 1)
}
```

### 테스트 케이스: 빈 결과
```swift
func test_execute_결과없을때_빈배열을_반환한다() {
    // Given
    mockRepository.stubbedItems = []

    let expectation = expectation(description: "빈 결과")

    // When
    sut.execute { items in
        // Then
        XCTAssertTrue(items.isEmpty)
        expectation.fulfill()
    }

    waitForExpectations(timeout: 2.0)
}
```

### 테스트 케이스: Repository 호출 검증
```swift
func test_execute_호출시_repository를_정확히_한번_호출한다() {
    // Given & When
    sut.execute { _ in }

    // Then
    XCTAssertEqual(mockRepository.fetchCallCount, 1)
}
```

## 체크리스트
- [ ] Given-When-Then 구조
- [ ] Mock Repository 주입
- [ ] setUp/tearDown 정리
- [ ] Repository 호출 횟수 검증 (callCount)
- [ ] 성공/실패/빈결과 시나리오 커버
- [ ] 비동기 completion 테스트에 XCTestExpectation 사용
