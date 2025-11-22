//
//  AudioStatusDTO.swift
//  Artner
//
//  Created by AI Assistant on 2025-10-30.
//

import Foundation

/// 오디오 생성 상태 조회 응답 DTO
struct AudioStatusDTO: Codable {
    struct Timestamp: Codable {
        let time: Int // millisecond
        let type: String
        let start: Int
        let end: Int
        let value: String
    }
    
    let jobId: String
    let status: String // e.g., "completed", "pending", "failed"
    let audioUrl: String?
    let duration: Double?
    let fileSize: Int?
    let timestamps: [Timestamp]?
    let error: String?
    let format: String?
    
    enum CodingKeys: String, CodingKey {
        case jobId = "job_id"
        case status
        case audioUrl = "audio_url"
        case duration
        case fileSize = "file_size"
        case timestamps
        case error
        case format
    }
}


