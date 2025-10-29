//
//  RealtimeDocentDTO.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation

/// 실시간 도슨트 응답 DTO
struct RealtimeDocentResponseDTO: Codable {
    let text: String
    let itemType: String
    let itemName: String
    let audioJobId: String
    
    enum CodingKeys: String, CodingKey {
        case text
        case itemType = "item_type"
        case itemName = "item_name"
        case audioJobId = "audio_job_id"
    }
}

