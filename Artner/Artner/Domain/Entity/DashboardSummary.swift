//
//  DashboardSummary.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation

/// 대시보드 요약 정보 Domain Entity
struct DashboardSummary {
    let user: UserInfo
    let stats: Stats
    let docentSettings: DocentSettings?
}

/// 사용자 정보 Domain Entity
struct UserInfo {
    let id: Int
    let username: String
    let nickname: String
    let email: String
}

/// 통계 정보 Domain Entity
struct Stats {
    let likedItems: Int
    let highlights: Int
    let exhibitionRecords: Int
    let savedDocents: Int
}

/// 도슨트 설정 Domain Entity
struct DocentSettings {
    let length: String
    let speed: String
    let difficulty: String
}
