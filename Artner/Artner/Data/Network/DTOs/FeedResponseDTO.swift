//
//  FeedResponseDTO.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation

/// 서버에서 받는 Feed 응답 모델 (실제 artner.shop API 구조에 맞춤)
struct FeedResponseDTO: Codable {
    let categories: [CategoryDTO]
}

/// Category DTO - 실제 서버 응답 구조
struct CategoryDTO: Codable {
    let type: String      // "exhibitions", "artists", "artworks"
    let title: String     // "전시회", "작가", "작품"
    let items: [ItemDTO]
}

/// 통합 Item DTO - 실제 서버 응답 구조
struct ItemDTO: Codable {
    let id: Int
    let title: String
    let image: String?
    let venue: String?
    let startDate: String?
    let endDate: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, image, venue
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

// MARK: - DTO to Domain Entity 변환
extension FeedResponseDTO {
    /// 전체 응답을 개별 아이템 리스트로 변환 (각 아이템이 별도의 TableView 행이 됨)
    func toDomainEntities() -> [FeedItemType] {
        var feedItems: [FeedItemType] = []
        
        for category in categories {
            switch category.type.lowercased() {
            case "exhibitions":
                // 각각의 전시회를 개별 Exhibition으로 변환
                for item in category.items {
                    let exhibition = Exhibition(
                        id: item.id,
                        type: "exhibition",
                        title: item.title,
                        items: [item.toExhibitionItems()] // 단일 아이템
                    )
                    feedItems.append(.exhibition(exhibition))
                }
                
            case "artworks":
                // 각각의 작품을 개별 Artwork으로 변환
                for item in category.items {
                    let artwork = Artwork(
                        id: item.id,
                        type: "artwork",
                        title: item.title,
                        items: [item.toArtworkItems()] // 단일 아이템
                    )
                    feedItems.append(.artwork(artwork))
                }
                
            case "artists":
                // 각각의 작가를 개별 Artist로 변환
                for item in category.items {
                    let artist = Artist(
                        id: item.id,
                        type: "artist",
                        title: item.title,
                        items: [item.toArtistItems()] // 단일 아이템
                    )
                    feedItems.append(.artist(artist))
                }
                
            default:
                print("⚠️ Unknown category type: \(category.type)")
            }
        }
        
        return feedItems
    }
}

extension ItemDTO {
    /// Exhibition Items 변환
    func toExhibitionItems() -> ExhibitionItems {
        return ExhibitionItems(
            id: id,
            title: title,
            description: "", // 실제 API에는 description이 없음
            image: image ?? "",
            type: "exhibition",
            likesCount: 0, // 실제 API에는 likes_count가 없음
            venue: venue ?? "",
            startDate: startDate ?? "",
            endDate: endDate ?? "",
            status: "ongoing" // 기본값으로 설정
        )
    }
    
    /// Artwork Items 변환 (임시 매핑)
    func toArtworkItems() -> ArtworkItems {
        return ArtworkItems(
            type: "artwork",
            id: id,
            title: title,
            name: title, // 작가명이 따로 없으므로 title 사용
            lifePeriod: ""
        )
    }
    
    /// Artist Items 변환 (임시 매핑)
    func toArtistItems() -> ArtistItems {
        return ArtistItems(
            id: id,
            type: "artist",
            title: title,
            artistName: title, // 작가명이 따로 없으므로 title 사용
            createdYear: ""
        )
    }
}

// MARK: - 실제 서버 응답 예시 (artner.shop/api/feeds)
/*
{
  "categories": [
    {
      "type": "exhibitions",
      "title": "전시회",
      "items": [
        {
          "id": 8,
          "title": "김소연 개인전: 순공간",
          "image": "/media/exhibitions/images/exhibition_8.jpg",
          "venue": "서울 마포구 합정동 91-27",
          "start_date": "2025-08-29",
          "end_date": "2025-09-14"
        },
        {
          "id": 23,
          "title": "《Velvet Hammers》",
          "image": "/media/exhibitions/images/exhibition_23.jpg",
          "venue": "서울 용산구 유엔빌리지길 11/B104호 (2층)",
          "start_date": "2025-08-22",
          "end_date": "2025-09-27"
        }
      ]
    },
    {
      "type": "artists",
      "title": "작가", 
      "items": []
    },
    {
      "type": "artworks",
      "title": "작품",
      "items": []
    }
  ]
}
*/