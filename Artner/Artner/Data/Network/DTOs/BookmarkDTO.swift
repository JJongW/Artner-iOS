//
//  BookmarkDTO.swift
//  Artner
//
//  Created by AI Assistant on 2025-10-30.
//

import Foundation

/// 도슨트 북마크 생성 요청 DTO
struct BookmarkDocentRequestDTO: Codable {
    let folderId: Int
    let itemType: String
    let name: String
    let lifePeriod: String
    let artistName: String
    let script: String
    let notes: String
    let thumbnail: String
    
    enum CodingKeys: String, CodingKey {
        case folderId = "folder_id"
        case itemType = "item_type"
        case name
        case lifePeriod = "life_period"
        case artistName = "artist_name"
        case script
        case notes
        case thumbnail
    }
}

/// 공백 응답
struct BookmarkResponseDTO: Codable {}

/// 도슨트 저장 상태 응답 DTO
struct DocentStatusResponseDTO: Codable {
    let saved: Bool
}


