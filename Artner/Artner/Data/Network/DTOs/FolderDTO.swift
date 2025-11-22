//
//  FolderDTO.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation

/// 폴더 API 응답 DTO
struct FolderDTO: Codable {
    let id: Int?
    let name: String
    let description: String?
    let createdAt: String?
    let updatedAt: String?
    let itemsCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case itemsCount = "items_count"
    }
}

/// 폴더 상세 아이템 DTO
struct FolderItemDTO: Codable {
    let id: Int
    let name: String
    let artistName: String?
    let savedAt: String?
    let thumbnail: String?
    let script: String?
    let audioJobId: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case artistName = "artist_name"
        case savedAt = "created_at" // API 응답 키에 맞춤
        case thumbnail
        case script
        case audioJobId = "audio_job_id"
    }
}

/// 폴더 상세 응답 DTO
struct FolderDetailDTO: Codable {
    let id: Int
    let name: String
    let items: [FolderItemDTO]
    let itemsCount: Int?
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case items = "docents" // API의 docents를 items로 매핑
        case itemsCount = "docents_count"
    }
}

/// 폴더 생성 요청 DTO
struct CreateFolderRequestDTO: Codable {
    let name: String
    let description: String
}

/// 폴더 수정 요청 DTO
struct UpdateFolderRequestDTO: Codable {
    let name: String
    let description: String
}

// MARK: - Domain Entity 변환
extension FolderDTO {
    /// Domain Entity로 변환
    func toDomainEntity() -> Folder {
        return Folder(
            id: id ?? 0, // 기본값 0
            name: name,
            description: description,
            createdAt: createdAt ?? "", // 기본값 빈 문자열
            updatedAt: updatedAt ?? "", // 기본값 빈 문자열
            itemsCount: itemsCount ?? 0 // 기본값 0
        )
    }
}
