# ios.networking.create_dto

## 설명
Codable DTO 구조체와 Domain Entity 변환 메서드를 생성한다.

## 파라미터
- `dtoName` (String, 필수): DTO 이름 (PascalCase, 예: SearchResult)
- `fields` (Array, 필수): 필드 목록 [{name, type, serverKey?}]
- `entityName` (String, 선택): 변환 대상 Domain Entity 이름

## 생성 파일
- `Artner/Artner/Data/Network/DTOs/{DtoName}DTO.swift`
- `Artner/Artner/Domain/Entity/{EntityName}.swift` (Entity가 없는 경우)

## 핵심 패턴

### DTO 구조체
```swift
import Foundation

struct {DtoName}ResponseDTO: Codable {
    let items: [{DtoName}DTO]
}

struct {DtoName}DTO: Codable {
    let id: Int
    let title: String
    let thumbnailUrl: String?

    enum CodingKeys: String, CodingKey {
        case id, title
        case thumbnailUrl = "thumbnail_url"  // snake_case → camelCase
    }
}
```

### Domain Entity 변환
```swift
// MARK: - Domain Entity 변환
extension {DtoName}DTO {
    func toDomainEntity() -> {EntityName} {
        return {EntityName}(
            id: id,
            title: title,
            thumbnail: thumbnailUrl.flatMap { URL(string: $0) }
        )
    }
}

extension {DtoName}ResponseDTO {
    func toDomainEntities() -> [{EntityName}] {
        return items.map { $0.toDomainEntity() }
    }
}
```

### Domain Entity (필요 시 생성)
```swift
import Foundation

struct {EntityName} {
    let id: Int
    let title: String
    let thumbnail: URL?
}
```

## 체크리스트
- [ ] `Codable` 프로토콜 채택
- [ ] snake_case 서버 키 → CodingKeys enum으로 camelCase 변환
- [ ] `toDomainEntity()` 변환 메서드 extension으로 분리
- [ ] Optional 필드 처리 (서버에서 null 가능한 필드)
- [ ] Response 래퍼 DTO (목록 응답 시 `{DtoName}ResponseDTO`)
- [ ] Domain Entity는 Domain 레이어에 위치 (Data 레이어 의존 금지)
