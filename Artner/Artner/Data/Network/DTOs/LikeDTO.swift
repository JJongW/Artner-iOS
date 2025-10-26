//
//  LikeDTO.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation

/// 좋아요 아이템 DTO
struct LikeItemDTO: Codable {
    let id: Int
    let title: String
    let description: String?
    let image: String?
    let type: String
    let likesCount: Int
    let createdAt: String
    let name: String?
    let lifePeriod: String?
    let artistName: String?
    let createdYear: String?
    let venue: String?
    let startDate: String?
    let endDate: String?
    let status: String?
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, image, type, name, venue, status
        case likesCount = "likes_count"
        case createdAt = "created_at"
        case lifePeriod = "life_period"
        case artistName = "artist_name"
        case createdYear = "created_year"
        case startDate = "start_date"
        case endDate = "end_date"
    }
}

/// 좋아요 목록 응답 DTO
struct LikeListResponseDTO: Codable {
    let likedItems: [LikeItemDTO]
    
    enum CodingKeys: String, CodingKey {
        case likedItems = "liked_items"
    }
}

/// 좋아요 토글 응답 DTO
struct LikeToggleResponseDTO: Codable {
    let status: String
    let likesCount: Int
    
    enum CodingKeys: String, CodingKey {
        case status
        case likesCount = "likes_count"
    }
    
    /// 좋아요 상태를 판단하는 computed property
    var isLiked: Bool {
        return status == "like_added"
    }
}

// MARK: - Domain Entity 변환
extension LikeItemDTO {
    /// Domain Entity로 변환
    func toDomainEntity() -> LikeItem {
        return LikeItem(
            id: id,
            type: LikeType(rawValue: type) ?? .exhibition, // 기본값으로 exhibition 설정
            title: title,
            image: image,
            createdAt: createdAt,
            venue: venue,
            startDate: startDate,
            endDate: endDate
        )
    }
}

extension LikeListResponseDTO {
    /// Domain Entity로 변환
    func toDomainEntity() -> LikeList {
        return LikeList(
            count: likedItems.count,
            next: nil, // 서버에서 제공하지 않음
            previous: nil, // 서버에서 제공하지 않음
            items: likedItems.map { $0.toDomainEntity() }
        )
    }
}
