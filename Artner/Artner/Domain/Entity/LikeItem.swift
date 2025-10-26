//
//  LikeItem.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation

/// 좋아요 아이템 Entity
struct LikeItem {
    let id: Int
    let type: LikeType
    let title: String
    let image: String?
    let createdAt: String
    let venue: String?
    let startDate: String?
    let endDate: String?
    
    // MARK: - Computed Properties
    var imageURL: URL? {
        guard let image = image, !image.isEmpty else { return nil }
        
        // image가 이미 /로 시작하는지 확인
        let imagePath = image.hasPrefix("/") ? image : "/\(image)"
        return URL(string: "https://artner.shop\(imagePath)")
    }
    
    var createdAtDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: createdAt)
    }
    
    var displayDate: String {
        guard let date = createdAtDate else { return "" }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    
    var typeDisplayName: String {
        return type.displayName
    }
    
    var displayPeriod: String {
        guard let startDate = startDate else { return "" }
        
        if let endDate = endDate {
            return "\(startDate) ~ \(endDate)"
        } else {
            return startDate
        }
    }
    
    var displayVenue: String {
        return venue ?? ""
    }
}

/// 좋아요 목록 Entity
struct LikeList {
    let count: Int
    let next: String?
    let previous: String?
    let items: [LikeItem]
}

/// 좋아요 타입 열거형
enum LikeType: String, CaseIterable {
    case exhibition = "exhibition"
    case artwork = "artwork"
    case artist = "artist"
    
    var displayName: String {
        switch self {
        case .exhibition:
            return "전시"
        case .artwork:
            return "작품"
        case .artist:
            return "작가"
        }
    }
}
