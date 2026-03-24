# 네트워크 서브시스템

Moya 기반 API 통신 레이어. 엔드포인트 정의 → 요청 실행 → DTO 디코딩 → Publisher 반환.

> 상세 사용 가이드: `README_Network.md`

## 파일 구조

```
Network/
├── APITarget.swift          # Moya TargetType — 모든 엔드포인트 case 정의
├── APIService.swift         # 실제 요청 실행 + Publisher 반환
├── NetworkError.swift       # 에러 타입 (noInternetConnection, timeout, serverError, decodingError, ...)
├── DIContainer.swift        # 의존성 주입 컨테이너 (singleton)
└── DTOs/                    # Codable 응답/요청 모델
    ├── AIDocentSettingsDTO.swift
    ├── AudioStatusDTO.swift
    ├── BookmarkDTO.swift
    ├── DashboardSummaryDTO.swift
    ├── FeedResponseDTO.swift
    ├── FolderDTO.swift
    ├── HighlightDTO.swift
    ├── KakaoLoginDTO.swift
    ├── LikeDTO.swift
    ├── LogoutDTO.swift
    ├── RealtimeDocentDTO.swift
    ├── RecordDTO.swift
    └── TokenRefreshDTO.swift
```

## 엔드포인트 추가 패턴

```swift
// 1. APITarget.swift에 case 추가
enum APITarget {
    case getXxx
    case createXxx(param: String)
}

// path, method, task, headers 구현
extension APITarget: TargetType {
    var path: String {
        switch self {
        case .getXxx: return "/api/xxx"
        case .createXxx: return "/api/xxx"
        }
    }
    var method: Moya.Method {
        switch self {
        case .getXxx: return .get
        case .createXxx: return .post
        }
    }
}

// 2. APIService.swift에 메서드 추가
func getXxx() -> AnyPublisher<XxxResponseDTO, NetworkError> {
    return request(target: .getXxx, responseType: XxxResponseDTO.self)
}
```

## DTO 작성 패턴

```swift
struct XxxResponseDTO: Codable {
    let id: Int
    let name: String
    let createdAt: String

    enum CodingKeys: String, CodingKey {
        case createdAt = "created_at"  // snake_case → camelCase
    }

    // Domain Entity 변환
    func toDomain() -> XxxEntity {
        return XxxEntity(id: id, name: name)
    }
}
```

## DIContainer 역할

- 싱글톤(`DIContainer.shared`)으로 모든 Repository/UseCase/ViewModel 생성
- `configureForDevelopment()` — 앱 시작 시 AppCoordinator.start()에서 호출
- 새 의존성 추가 시 반드시 DIContainer에 lazy var + factory 메서드 등록

## 에러 처리

```swift
enum NetworkError: Error {
    case noInternetConnection
    case timeout
    case serverError(Int)      // HTTP status code
    case decodingError
    case unknownError
    case unauthorized          // 401 → forceLogout notification
}
```

- 401 응답 시 `.forceLogout` NotificationCenter 발송 → AppCoordinator가 로그인 화면으로 이동

## AI 작업 가이드

### 새 API 추가 순서
1. `DTOs/XxxDTO.swift` 생성 (request/response)
2. `APITarget.swift`에 case 추가 + TargetType 구현
3. `APIService.swift`에 메서드 추가
4. `Domain/Repository/XxxRepository.swift` — 프로토콜에 메서드 추가
5. `RepositoryImpl/XxxRepositoryImpl.swift` — 구현
6. `DIContainer.swift` — lazy var + factory 등록

### 금지사항
- APIService를 Presentation(VC/VM)에서 직접 호출 금지 (UseCase 경유 필수)
  - 예외: AppCoordinator의 `streamAudio` 호출 (구조적 이유로 허용)
- DTO를 Domain 밖으로 노출 금지 (`toDomain()` 변환 후 전달)
- 하드코딩된 URL 금지 (APITarget.baseURL 사용)

## 관련 문서
- `README_Network.md` — Moya 시스템 상세 가이드 + 예시 코드
- `../CLAUDE.md` — Data 레이어 전체 규칙
