# 🚀 Moya 기반 API 시스템 가이드

## 📋 개요

Artner iOS 앱의 네트워킹 시스템은 **Clean Architecture**를 준수하며, **Moya**를 사용하여 구축되었습니다.

## 🏗️ 아키텍처 구조

```
┌─────────────────┐
│   Presentation  │  ← ViewController, ViewModel
├─────────────────┤
│     Domain      │  ← Entity, UseCase, Repository (Protocol)
├─────────────────┤
│      Data       │  ← Repository Impl, API Service, DTOs
│  ┌─────────────┐│
│  │   Network   ││  ← Moya, APITarget, NetworkError
│  └─────────────┘│
└─────────────────┘
```

## 📁 파일 구조

### Network Layer
- `APITarget.swift` - API 엔드포인트 정의 (Moya TargetType)
- `APIService.swift` - 실제 네트워크 요청 처리
- `NetworkError.swift` - 네트워크 에러 정의
- `DIContainer.swift` - 의존성 주입 컨테이너

### DTOs (Data Transfer Objects)
- `FeedResponseDTO.swift` - Feed API 응답 모델
- `DocentResponseDTO.swift` - Docent API 응답 모델

### Repository Implementations
- `FeedRepositoryImpl.swift` - Feed Repository 구현체
- `DocentRepositoryImpl.swift` - Docent Repository 구현체

## 🔧 사용 방법

### 1. 새로운 API 엔드포인트 추가

```swift
// APITarget.swift에 추가
enum APITarget {
    case getNewEndpoint(parameter: String)
}

// TargetType 구현
extension APITarget: TargetType {
    var path: String {
        switch self {
        case .getNewEndpoint(let parameter):
            return "/new-endpoint/\(parameter)"
        }
    }
}
```

### 2. DTO 모델 정의 (실제 artner.shop API 기준)

```swift
// 실제 서버 응답 구조: https://artner.shop/api/feeds
struct FeedResponseDTO: Codable {
    let categories: [CategoryDTO]
}

struct CategoryDTO: Codable {
    let type: String      // "exhibitions", "artists", "artworks"
    let title: String     // "전시회", "작가", "작품"
    let items: [ItemDTO]
}

struct ItemDTO: Codable {
    let id: Int
    let title: String
    let description: String?
    let image: String?
    let likesCount: Int
    // ... 서버 필드에 맞는 속성들
    
    enum CodingKeys: String, CodingKey {
        case likesCount = "likes_count"
        // ... 서버 필드명 매핑
    }
}
```

### 3. API Service 메서드 추가

```swift
// APIService.swift에 추가
func getNewData() -> AnyPublisher<[NewEntity], NetworkError> {
    return request(target: .getNewEndpoint(parameter: "value"), responseType: NewResponseDTO.self)
        .map { response in
            return response.data.map { $0.toDomainEntity() }
        }
        .eraseToAnyPublisher()
}
```

### 4. Repository에서 API 사용

```swift
// NewRepositoryImpl.swift
func fetchNewData(completion: @escaping ([NewEntity]) -> Void) {
    apiService.getNewData()
        .sink(
            receiveCompletion: { result in
                if case .failure(let error) = result {
                    print("❌ API 실패: \(error.localizedDescription)")
                    completion([]) // Fallback
                }
            },
            receiveValue: { entities in
                completion(entities)
            }
        )
        .store(in: &cancellables)
}
```

## 🔄 데이터 흐름

1. **ViewController** → **ViewModel** → **UseCase** → **Repository**
2. **Repository** → **APIService** → **Moya Provider** → **서버**
3. **서버 응답** → **DTO** → **Domain Entity** → **ViewModel** → **View 업데이트**

## ⚡ 주요 특징

### 🛡️ 에러 처리
```swift
enum NetworkError: Error {
    case noInternetConnection    // 인터넷 연결 없음
    case timeout                // 타임아웃
    case serverError(Int)       // 서버 에러 (상태 코드)
    case decodingError          // JSON 디코딩 실패
    case unknownError           // 알 수 없는 에러
}
```

### 🔄 Fallback 시스템
- API 실패 시 더미 데이터로 자동 전환
- 사용자 경험 중단 없이 앱 동작 보장

### 📱 로깅
- Debug 모드에서 상세한 네트워크 로그
- 요청/응답 정보 자동 출력

### ⚡ 성능 최적화
- URLSession 타임아웃 설정 (30초/60초)
- 메인 스레드에서 결과 전달
- 이미지 캐싱 시스템 (UIImageView+Extension)

## 🎯 DI Container 사용

```swift
// AppCoordinator에서
let container = DIContainer.shared
container.configureForDevelopment()

// ViewModel 생성
let homeViewModel = container.makeHomeViewModel()
let playerViewModel = container.makePlayerViewModel(docent: docent)
```

## 📊 모니터링 및 디버깅

### Debug 모드
```swift
#if DEBUG
// 네트워크 로깅 활성화
plugins.append(NetworkLoggerPlugin(configuration: .verbose))
#endif
```

### 로그 출력 예시
```
🌐 요청: GET https://api.artner.com/v1/feeds
✅ 응답: 200 (https://api.artner.com/v1/feeds)
📦 받은 Feed 데이터 개수: 5
```

## ⚠️ 주의사항

1. **메인 스레드**: 모든 UI 업데이트는 메인 스레드에서 수행
2. **메모리 관리**: `weak self` 사용으로 순환참조 방지
3. **에러 핸들링**: 사용자 친화적인 에러 메시지 제공
4. **Fallback**: 네트워크 실패 시 더미 데이터 활용

## 🚀 향후 개선사항

- [ ] Refresh Token 자동 갱신
- [ ] 오프라인 캐싱 시스템
- [ ] GraphQL 지원 고려
- [ ] API 응답 압축 최적화
- [ ] 실시간 네트워크 상태 모니터링

---

📝 **작성자**: AI Assistant (15년차 iOS 개발자 관점)  
📅 **최종 업데이트**: 2025년
