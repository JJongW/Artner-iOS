//
//  TokenRefreshDTO.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation

// MARK: - Response

/// 토큰 갱신 응답 DTO
struct TokenRefreshResponseDTO: Codable {
    let access: String
    let refresh: String
    
    enum CodingKeys: String, CodingKey {
        case access
        case refresh
    }
    
    /// 편의를 위한 computed property
    var accessToken: String { access }
    var refreshToken: String { refresh }
}

