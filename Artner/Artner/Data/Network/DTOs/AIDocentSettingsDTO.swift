//
//  AIDocentSettingsDTO.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation

/// AI 도슨트 설정 API 응답 DTO
struct AIDocentSettingsDTO: Codable {
    let id: Int
    let personal: String
    let length: String
    let speed: String
    let difficulty: String
    let viewerFontSize: Int
    let viewerLineSpacing: Int
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case personal
        case length
        case speed
        case difficulty
        case viewerFontSize = "viewer_font_size"
        case viewerLineSpacing = "viewer_line_spacing"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
    
    /// Domain Entity로 변환
    func toDomainEntity() -> AIDocentSettings {
        return AIDocentSettings(
            id: id,
            personal: personal,
            length: length,
            speed: speed,
            difficulty: difficulty,
            viewerFontSize: viewerFontSize,
            viewerLineSpacing: viewerLineSpacing,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
}
