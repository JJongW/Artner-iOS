# ios.testing.setup_infrastructure

## 설명
XCTest 기반 테스트 타겟 및 Mock 인프라를 구축한다.

## 파라미터
- `testTarget` (String, 선택, 기본: ArtnerTests): 테스트 타겟 이름
- `mockingStrategy` (String, 선택, 기본: protocol_mock): 모킹 전략

## 생성 파일
- `ArtnerTests/Mocks/MockAPIService.swift`
- `ArtnerTests/Mocks/Mock{Repository}.swift`
- `ArtnerTests/Mocks/Mock{UseCase}.swift`
- `ArtnerTests/Helpers/XCTestCase+Extensions.swift`

## 핵심 패턴

### Mock APIService
```swift
import Foundation
import Combine
@testable import Artner

final class MockAPIService: APIServiceProtocol {
    var stubbedResult: Any?
    var stubbedError: Error?
    var requestCallCount = 0

    func request<T: Decodable>(_ target: APITarget) -> AnyPublisher<T, Error> {
        requestCallCount += 1
        if let error = stubbedError {
            return Fail(error: error).eraseToAnyPublisher()
        }
        if let result = stubbedResult as? T {
            return Just(result)
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        }
        return Fail(error: NSError(domain: "Mock", code: -1))
            .eraseToAnyPublisher()
    }
}
```

### Mock Repository (Protocol Mock)
```swift
@testable import Artner

final class MockFeedRepository: FeedRepository {
    var stubbedItems: [FeedItemType] = []
    var fetchCallCount = 0

    func fetchFeedItems(completion: @escaping ([FeedItemType]) -> Void) {
        fetchCallCount += 1
        completion(stubbedItems)
    }
}
```

### Mock UseCase
```swift
@testable import Artner

final class MockFetchFeedUseCase: FetchFeedUseCase {
    var stubbedResult: [FeedItemType] = []
    var executeCallCount = 0

    func execute(completion: @escaping ([FeedItemType]) -> Void) {
        executeCallCount += 1
        completion(stubbedResult)
    }
}
```

### XCTest Helper Extension
```swift
import XCTest
import Combine

extension XCTestCase {
    /// Combine Publisher 결과를 동기적으로 기다림
    func awaitPublisher<T: Publisher>(
        _ publisher: T,
        timeout: TimeInterval = 2.0,
        file: StaticString = #file,
        line: UInt = #line
    ) throws -> T.Output {
        var result: Result<T.Output, Error>?
        let expectation = expectation(description: "Awaiting publisher")

        let cancellable = publisher.sink(
            receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    result = .failure(error)
                }
                expectation.fulfill()
            },
            receiveValue: { value in
                result = .success(value)
            }
        )

        waitForExpectations(timeout: timeout)
        cancellable.cancel()

        let unwrappedResult = try XCTUnwrap(result, file: file, line: line)
        return try unwrappedResult.get()
    }
}
```

## 체크리스트
- [ ] `@testable import Artner` 사용
- [ ] Mock 클래스에 stubbed 프로퍼티 + callCount 추가
- [ ] Protocol 기반 Mock (의존성 역전 활용)
- [ ] Combine Publisher 테스트 헬퍼 (awaitPublisher)
- [ ] 테스트 타겟이 Xcode 프로젝트에 추가되어 있는지 확인
