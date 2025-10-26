//
//  RecordDTO.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation

/// 전시기록 API 응답 DTO
struct RecordListDTO: Codable {
    let count: Int
    let next: String?
    let previous: String?
    let results: [RecordDTO]
}

/// 개별 전시기록 DTO
struct RecordDTO: Codable {
    let id: Int
    let title: String?
    let content: String?
    let exhibitionName: String
    let artistName: String?
    let artworkName: String?
    let createdAt: String
    let updatedAt: String
    let images: [String]?
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case exhibitionName = "exhibition_name"
        case artistName = "artist_name"
        case artworkName = "artwork_name"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case images
    }
}

// MARK: - Domain Entity 변환
extension RecordListDTO {
    /// Domain Entity로 변환
    func toDomainEntity() -> RecordList {
        return RecordList(
            count: count,
            next: next,
            previous: previous,
            results: results.map { $0.toDomainEntity() }
        )
    }
}

extension RecordDTO {
    /// Domain Entity로 변환
    func toDomainEntity() -> Record {
        return Record(
            id: id,
            title: title,
            content: content,
            exhibitionName: exhibitionName,
            artistName: artistName,
            artworkName: artworkName,
            createdAt: createdAt,
            updatedAt: updatedAt,
            images: images ?? []
        )
    }
}

/// 전시기록 생성 요청 DTO
struct CreateRecordRequestDTO: Codable {
    let visitDate: String
    let name: String
    let museum: String
    let note: String
    let image: String
    
    enum CodingKeys: String, CodingKey {
        case visitDate = "visit_date"
        case name
        case museum
        case note
        case image
    }
}
