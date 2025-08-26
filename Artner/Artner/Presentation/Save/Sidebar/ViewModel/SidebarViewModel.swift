//
//  SidebarViewModel.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//
//  Clean Architecture: 사이드바 상태/로직 분리, View와 ViewController에서 바인딩

import Foundation
import Combine

final class SidebarViewModel {
    // 사용자 정보
    @Published var userName: String = "엔젤리너스 커피"
    @Published var stats: [SidebarStat] = [
        .init(type: .like, count: 1000),
        .init(type: .save, count: 1000),
        .init(type: .underline, count: 1000),
        .init(type: .record, count: 1000)
    ]
    @Published var aiDocent: String = "친절한 애나"
    @Published var aiSettings: SidebarAISettings = .default
    @Published var easyMode: Bool = false
    @Published var fontSize: Float = 1
    @Published var lineSpacing: Float = 10
}

struct SidebarStat {
    enum StatType { case like, save, underline, record }
    let type: StatType
    let count: Int
}

struct SidebarAISettings {
    var length: String // "짧게"
    var speed: String // "느리게"
    var difficulty: String // "초급"
    static let `default` = SidebarAISettings(length: "짧게", speed: "느리게", difficulty: "초급")
} 