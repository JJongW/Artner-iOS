//
//  AIDocentSettings.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation

/// AI 도슨트 설정 Domain Entity
struct AIDocentSettings {
    let id: Int
    let personal: String
    let length: String
    let speed: String
    let difficulty: String
    let viewerFontSize: Int
    let viewerLineSpacing: Int
    let createdAt: String
    let updatedAt: String
    
    /// 영어 값을 한글로 변환
    var lengthKorean: String {
        switch length {
        case "very_short": return "아주 간단히"
        case "short": return "간단히"
        case "medium": return "보통"
        case "long": return "자세히"
        case "very_long": return "아주 자세히"
        default: return "보통"
        }
    }
    
    var speedKorean: String {
        switch speed {
        case "very_fast": return "빠르게"
        case "fast": return "약간 빠르게"
        case "medium": return "보통"
        case "slow": return "약간 느리게"
        case "very_slow": return "느리게"
        default: return "보통"
        }
    }
    
    var difficultyKorean: String {
        switch difficulty {
        case "beginner": return "초급"
        case "intermediate": return "중급"
        case "advanced": return "고급"
        default: return "초급"
        }
    }
}
