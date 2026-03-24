# Data 레이어

Domain 프로토콜의 구현체 + 네트워크/스토리지 실제 동작. Presentation은 이 레이어를 직접 참조 불가.

## 파일 구조

```
Data/
├── Network/                 # 네트워크 서브시스템 (별도 CLAUDE.md 참조)
│   ├── APIService.swift         # 실제 네트워크 요청
│   ├── APITarget.swift          # Moya TargetType 엔드포인트
│   ├── NetworkError.swift       # 에러 정의
│   ├── DIContainer.swift        # 의존성 주입 컨테이너
│   └── DTOs/                    # Codable 응답 모델
├── RepositoryImpl/          # Repository 프로토콜 구현체
│   ├── AIDocentSettingsRepositoryImpl.swift
│   ├── AuthRepositoryImpl.swift
│   ├── DashboardRepositoryImpl.swift
│   ├── DocentRepositoryImpl.swift
│   ├── FeedRepositoryImpl.swift
│   ├── FolderRepositoryImpl.swift
│   ├── HighlightRepositoryImpl.swift
│   ├── LikeRepositoryImpl.swift
│   └── RecordRepositoryImpl.swift
├── UseCaseImpl/             # UseCase 프로토콜 구현체
│   ├── FetchFeedUseCaseImpl.swift
│   ├── GetAIDocentSettingsUseCaseImpl.swift
│   ├── GetDashboardSummaryUseCaseImpl.swift
│   ├── GetFoldersUseCaseImpl.swift
│   ├── KakaoLoginUseCaseImpl.swift
│   ├── LogoutUseCaseImpl.swift
│   └── PlayDocentUseCaseImpl.swift
└── Storage/                 # 로컬 스토리지
    ├── TokenManager.swift       # 토큰 추상화 프로토콜
    ├── KeychainTokenManager.swift  # Keychain 구현체
    ├── ViewerSettingsManager.swift # UserDefaults 기반 설정
    └── Dummy/                   # 개발용 더미 데이터
        ├── DummyDocentData.swift
        └── DummyDocentScript.swift
```

## Repository 구현 패턴

```swift
// 표준 패턴: APIService 주입 + DTO → Entity 변환
final class XxxRepositoryImpl: XxxRepository {
    private let apiService: APIServiceProtocol

    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }

    func fetchXxx() -> AnyPublisher<[XxxEntity], NetworkError> {
        return apiService.getXxx()
            .map { dtos in dtos.map { $0.toDomain() } }
            .eraseToAnyPublisher()
    }
}
```

## UseCase 구현 패턴

```swift
final class XxxUseCaseImpl: XxxUseCase {
    private let repository: XxxRepository

    init(xxxRepository: XxxRepository) {
        self.repository = xxxRepository
    }

    func execute() -> AnyPublisher<[XxxEntity], NetworkError> {
        return repository.fetchXxx()
    }
}
```

## DIContainer 등록 패턴

새 Repository/UseCase 추가 시 반드시 아래 순서로 등록:

```swift
// 1. Repository lazy var
lazy var xxxRepository: XxxRepository = {
    return XxxRepositoryImpl(apiService: apiService)
}()

// 2. UseCase lazy var
lazy var xxxUseCase: XxxUseCase = {
    return XxxUseCaseImpl(xxxRepository: xxxRepository)
}()

// 3. ViewModel factory (extension DIContainer)
func makeXxxViewModel() -> XxxViewModel {
    return XxxViewModel(xxxUseCase: xxxUseCase)
}
```

## Storage 사용 규칙
- **Keychain**: `KeychainTokenManager` — accessToken, refreshToken 저장
- **UserDefaults**: `ViewerSettingsManager` — UI 설정 (폰트 크기 등)
- Storage 타입을 Domain이 직접 모르게 (Protocol 필요 시 Domain/Repository에 정의)

## AI 작업 가이드

### 반드시 지킬 것
- Presentation이 RepositoryImpl/UseCaseImpl을 직접 import 금지
- DTO는 `toDomain()` 메서드로 Domain Entity로 변환 (DTO를 VM에 직접 노출 금지)
- APIService 호출은 반드시 Publisher 반환 (completion handler 방식 지양)
- 에러는 `NetworkError`로 통일 (catch/rethrow 시 타입 일치 유지)

### 금지사항
- RepositoryImpl에서 UIKit import 금지
- UseCase Impl이 다른 UseCase Impl을 직접 생성/참조 금지
- DIContainer 외부에서 Impl 직접 `init` 금지

## 관련 문서
- `Network/CLAUDE.md` — API, DTOs, DIContainer 상세
- `../Domain/CLAUDE.md` — Entity, Repository/UseCase 프로토콜
- `../../CLAUDE.md` (루트) — 전체 아키텍처 원칙
