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
    let id: Int?
    let user: Int?
    let visitDate: String
    let name: String
    let museum: String
    let note: String
    let imageUrl: String?
    let createdAt: String?
    let updatedAt: String?
    
    enum CodingKeys: String, CodingKey {
        case id, user, name, museum, note
        case visitDate = "visit_date"
        case imageUrl = "image_url"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
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
            id: id ?? 0, // 기본값 0
            user: user ?? 0, // 기본값 0
            visitDate: visitDate,
            name: name,
            museum: museum,
            note: note,
            imageUrl: imageUrl,
            createdAt: createdAt ?? "", // 기본값 빈 문자열
            updatedAt: updatedAt ?? "" // 기본값 빈 문자열
        )
    }
}

/// 전시기록 생성 요청 DTO
struct CreateRecordRequestDTO: Codable {
    let visitDate: String
    let name: String
    let museum: String
    let note: String? // 선택사항으로 변경
    let image: String? // 선택사항
    
    enum CodingKeys: String, CodingKey {
        case visitDate = "visit_date"
        case name
        case museum
        case note
        case image
    }
}
