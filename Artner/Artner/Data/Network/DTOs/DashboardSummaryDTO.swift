//
//  DashboardSummaryDTO.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation

/// 대시보드 요약 정보 DTO
struct DashboardSummaryDTO: Codable {
    let counts: CountsDTO
    let userInfo: UserInfoDTO
    
    enum CodingKeys: String, CodingKey {
        case counts
        case userInfo = "user_info"
    }
}

/// 통계 카운트 DTO
struct CountsDTO: Codable {
    let likedItems: Int
    let highlights: Int
    let exhibitionRecords: Int
    let savedDocents: Int
    
    enum CodingKeys: String, CodingKey {
        case likedItems = "liked_items"
        case highlights
        case exhibitionRecords = "exhibition_records"
        case savedDocents = "saved_docents"
    }
}

// DocentSettingsDTO는 AIDocentSettingsDTO로 대체됨

/// 사용자 정보 DTO
struct UserInfoDTO: Codable {
    let id: Int
    let username: String
    let nickname: String
    let email: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case nickname
        case email
    }
}

// MARK: - Domain Entity 변환
extension DashboardSummaryDTO {
    /// DTO를 Domain Entity로 변환
    func toDomainEntity() -> DashboardSummary {
        return DashboardSummary(
            user: userInfo.toDomainEntity(),
            stats: counts.toDomainEntity()
        )
    }
}

extension UserInfoDTO {
    /// DTO를 Domain Entity로 변환
    func toDomainEntity() -> UserInfo {
        return UserInfo(
            id: id,
            username: username,
            nickname: nickname,
            email: email
        )
    }
}

extension CountsDTO {
    /// DTO를 Domain Entity로 변환
    func toDomainEntity() -> Stats {
        return Stats(
            likedItems: likedItems,
            highlights: highlights,
            exhibitionRecords: exhibitionRecords,
            savedDocents: savedDocents
        )
    }
}

// DocentSettingsDTO extension은 AIDocentSettingsDTO로 대체됨
