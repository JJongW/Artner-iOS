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
    let id: String
    let itemType: String // "artist" | "artwork" | possibly "exhibition"
    let itemName: String
    let artistName: String?
    let thumbnail: String?
    let createdAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case itemType = "item_type"
        case itemName = "item_name"
        case artistName = "artist_name"
        case thumbnail
        case createdAt = "created_at"
    }
}


