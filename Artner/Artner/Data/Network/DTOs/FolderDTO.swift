//
//  FolderDTO.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation

/// 폴더 API 응답 DTO
struct FolderDTO: Codable {
    let id: Int
    let name: String
    let description: String
    let createdAt: String
    let updatedAt: String
    let itemsCount: Int
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case itemsCount = "items_count"
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
            id: id,
            name: name,
            description: description,
            createdAt: createdAt,
            updatedAt: updatedAt,
            itemsCount: itemsCount
        )
    }
}
