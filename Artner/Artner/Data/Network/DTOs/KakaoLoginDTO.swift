//
//  KakaoLoginDTO.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation

// MARK: - Request

/// 카카오 로그인 요청 DTO
struct KakaoLoginRequestDTO: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
        case accessToken = "access_token"
    }
}

// MARK: - Response

/// 카카오 로그인 응답 DTO
/// 백엔드 실제 응답 구조에 맞춤
struct KakaoLoginResponseDTO: Codable {
    let access: String      // "access_token"이 아니라 "access"
    let refresh: String     // "refresh_token"이 아니라 "refresh"
    let user: KakaoUserDTO
    let isNewUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case access
        case refresh
        case user
        case isNewUser = "is_new_user"
    }
    
    /// 편의를 위한 computed property
    var accessToken: String { access }
    var refreshToken: String { refresh }
}

/// 카카오 로그인 사용자 정보 DTO
struct KakaoUserDTO: Codable {
    let id: Int
    let username: String
    let email: String
    let nickname: String
    let displayName: String
    let profileImage: String?
    let bio: String
    let preferences: [String]  // 빈 배열이지만 타입 정의
    let dateJoined: String
    let socialProvider: String
    let socialProviderDisplay: String
    let isSocialUser: Bool
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case email
        case nickname
        case displayName = "display_name"
        case profileImage = "profile_image"
        case bio
        case preferences
        case dateJoined = "date_joined"
        case socialProvider = "social_provider"
        case socialProviderDisplay = "social_provider_display"
        case isSocialUser = "is_social_user"
    }
}

