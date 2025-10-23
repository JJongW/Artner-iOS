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
    let docentSettings: DocentSettingsDTO?
    let userInfo: UserInfoDTO
    
    enum CodingKeys: String, CodingKey {
        case counts
        case docentSettings = "docent_settings"
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

/// 도슨트 설정 DTO
struct DocentSettingsDTO: Codable {
    let length: String?
    let speed: String?
    let difficulty: String?
    
    enum CodingKeys: String, CodingKey {
        case length
        case speed
        case difficulty
    }
}

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
            stats: counts.toDomainEntity(),
            docentSettings: docentSettings?.toDomainEntity()
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

extension DocentSettingsDTO {
    /// DTO를 Domain Entity로 변환
    func toDomainEntity() -> DocentSettings {
        return DocentSettings(
            length: length ?? "짧게",
            speed: speed ?? "느리게", 
            difficulty: difficulty ?? "초급"
        )
    }
}
