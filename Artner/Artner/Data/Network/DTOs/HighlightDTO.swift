import Foundation

// MARK: - Highlights Response DTOs

struct HighlightsResponseDTO: Decodable {
    let results: [HighlightItemDTO]
    let next: String?
    let previous: String?
    
    private enum CodingKeys: String, CodingKey {
        case results
        case next
        case previous
    }
    
    init(results: [HighlightItemDTO], next: String? = nil, previous: String? = nil) {
        self.results = results
        self.next = next
        self.previous = previous
    }
    
    init(from decoder: Decoder) throws {
        // 서버가 [] (배열) 혹은 { results: [] } (객체)를 모두 반환할 수 있으므로 둘 다 지원
        let single = try? decoder.singleValueContainer()
        if let single = single, let array = try? single.decode([HighlightItemDTO].self) {
            self.results = array
            self.next = nil
            self.previous = nil
            return
        }
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.results = try container.decode([HighlightItemDTO].self, forKey: .results)
        self.next = try container.decodeIfPresent(String.self, forKey: .next)
        self.previous = try container.decodeIfPresent(String.self, forKey: .previous)
    }
}

struct HighlightItemDTO: Decodable {
    let itemType: String // "artist" | "artwork" | possibly "exhibition"
    let itemName: String
    let subtitle: String?
    let highlightCount: Int
    let thumbnailUrl: String?
    let latestDate: String?

    enum CodingKeys: String, CodingKey {
        case itemType = "item_type"
        case itemName = "item_name"
        case subtitle
        case highlightCount = "highlight_count"
        case thumbnailUrl = "thumbnail_url"
        case latestDate = "latest_date"
    }
}

// MARK: - Create Highlight Request DTO

struct CreateHighlightRequestDTO {
    let itemType: String        // "artist" | "artwork"
    let itemName: String        // 작품/작가 이름
    let itemInfo: String        // 추가 정보
    let highlightedText: String // 하이라이트된 텍스트
    let note: String            // 메모 (선택)
}

// MARK: - Create Highlight Response DTO

struct CreateHighlightResponseDTO: Codable {
    let id: Int
    let itemType: String?
    let itemName: String?
    let itemInfo: String?
    let highlightedText: String?
    let note: String?
    let createdAt: String?

    enum CodingKeys: String, CodingKey {
        case id
        case itemType = "item_type"
        case itemName = "item_name"
        case itemInfo = "item_info"
        case highlightedText = "highlighted_text"
        case note
        case createdAt = "created_at"
    }

    /// 서버 ID를 String으로 반환
    var serverId: String {
        return String(id)
    }
}

// EmptyResponse는 APIService.swift에 정의되어 있음
