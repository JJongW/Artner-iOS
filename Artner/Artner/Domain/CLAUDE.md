# Domain 레이어

비즈니스 규칙의 핵심. UIKit·Network·Storage에 의존하지 않는 순수 Swift 코드만 포함.

## 파일 구조

```
Domain/
├── Entity/                  # 도메인 모델 (순수 struct/class)
│   ├── AIDocentSettings.swift   # AI 도슨트 설정 (personal, length, speed, difficulty)
│   ├── DashboardSummary.swift   # 사이드바 통계 요약
│   ├── Docent.swift             # 도슨트 (id, title, artist, imageURL, audioURL, paragraphs)
│   ├── DocentScript.swift       # 도슨트 스크립트 문장 (startTime, text)
│   ├── FeedItem.swift           # 홈 피드 아이템
│   ├── Folder.swift             # 저장 폴더
│   ├── LikeItem.swift           # 좋아요 아이템
│   └── Record.swift             # 전시 기록
├── Repository/              # Repository 프로토콜 (Data 레이어가 구현)
│   ├── AIDocentSettingsRepository.swift
│   ├── AuthRepository.swift
│   ├── DashboardRepository.swift
│   ├── DocentRepository.swift
│   ├── FeedRepository.swift
│   ├── FolderRepository.swift
│   ├── HighlightRepository.swift
│   ├── LikeRepository.swift
│   └── RecordRepository.swift
└── UseCase/                 # UseCase 프로토콜 (Data 레이어가 구현)
    ├── FetchFeedUseCase.swift
    ├── GetAIDocentSettingsUseCase.swift
    ├── GetDashboardSummaryUseCase.swift
    ├── GetFoldersUseCase.swift
    ├── GetHighlightsUseCase.swift
    ├── GetLikesUseCase.swift
    ├── GetRecordsUseCase.swift
    ├── KakaoLoginUseCase.swift
    ├── LogoutUseCase.swift
    └── PlayerDocentUseCase.swift
```

## 핵심 Entity

### Docent
```swift
struct Docent {
    let id: Int
    let title: String
    let artist: String
    let description: String
    let imageURL: String
    let audioURL: URL?       // streamAudio 후 로컬 파일 URL
    let audioJobId: String?  // 서버 audio job ID
    let paragraphs: [DocentParagraph]
}
```

### AIDocentSettings
```swift
struct AIDocentSettings {
    let personal: String     // "casual" | "professional"
    let length: String       // "short" | "medium" | "long"
    let speed: String        // "slow" | "medium" | "fast"
    let difficulty: String   // "beginner" | "intermediate" | "advanced"
}
```

## AI 작업 가이드

### 반드시 지킬 것
- Entity: UIKit, Foundation 외 import 금지. Codable 필요 시 Data 레이어 DTO에서 변환
- Repository/UseCase 프로토콜: 메서드 시그니처는 도메인 용어로 (API 필드명 노출 금지)
- Entity는 Value Type(struct) 우선. 참조 의미가 필요할 때만 class 사용
- UseCase 프로토콜은 **의도가 드러나게** 명명: `execute()`, `fetchXxx()`, `createXxx()`

### 금지사항
- Domain에 URLSession, Moya, UIKit, AVFoundation 등 import 금지
- DTO(Codable)를 Domain Entity에 직접 포함 금지
- Repository 구현체(Impl)를 Domain에 두지 않음

### Entity 추가 패턴
1. `Domain/Entity/NewEntity.swift` 생성
2. 해당 Repository 프로토콜에 반환 타입으로 사용
3. Data DTO에서 `toDomain()` 변환 메서드 추가

### UseCase 추가 패턴
1. `Domain/UseCase/NewUseCase.swift` — 프로토콜 정의
2. `Data/UseCaseImpl/NewUseCaseImpl.swift` — 구현
3. `Data/Network/DIContainer.swift` — lazy var 등록 + factory 메서드 추가

## 관련 문서
- `../Data/CLAUDE.md` — Repository/UseCase 구현체
- `../../CLAUDE.md` (루트) — 전체 아키텍처 원칙
