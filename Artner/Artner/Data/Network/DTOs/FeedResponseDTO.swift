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
    let description: String?
    let image: String?
    let type: String
    let likesCount: Int
    let createdAt: String?
    let venue: String?
    let startDate: String?
    let endDate: String?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, image, type, venue, status
        case likesCount = "likes_count"
        case createdAt = "created_at"
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
                        type: item.type,
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
                        type: item.type,
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
                        type: item.type,
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
            description: description ?? "",
            image: image ?? "",
            type: type,
            likesCount: likesCount,
            venue: venue ?? "",
            startDate: startDate ?? "",
            endDate: endDate ?? "",
            status: status ?? ""
        )
    }
    
    /// Artwork Items 변환 (임시 매핑)
    func toArtworkItems() -> ArtworkItems {
        return ArtworkItems(
            type: type,
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
            type: type,
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
          "id": 32,
          "title": "주슬아 개인전: 크랙",
          "description": "\n\n관람시간: 수~일요일 13:00~18:00\n관람료: 무료\n문의: 0507-1416-8691",
          "image": "/media/exhibitions/images/exhibition_32.jpg",
          "type": "exhibition",
          "likes_count": 0,
          "created_at": "2025-09-01T17:06:10.920316+09:00",
          "venue": "서울 서대문구 홍제천로 158/1층",
          "start_date": "2025-08-15",
          "end_date": "2025-09-14",
          "status": "ongoing"
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