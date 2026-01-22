//
//  SaveCoordinating.swift
//  Artner
//
//  Feature Isolation - Save feature navigation protocol
//

import Foundation

/// Save 피처의 네비게이션 프로토콜
/// AppCoordinator가 구현하여 Save 화면에서 다른 화면으로의 이동을 처리
protocol SaveCoordinating: Coordinator {
    /// 홈 화면으로 이동
    func popToHome()

    /// Entry 화면으로 이동 (저장된 도슨트 재생)
    func showEntry(docent: Docent)
}

/// Sidebar 피처의 네비게이션 프로토콜
protocol SidebarCoordinating: Coordinator {
    /// Sidebar 닫기
    func closeSidebar()

    /// 좋아요 화면으로 이동
    func showLike()

    /// 저장 화면으로 이동
    func showSave()

    /// 밑줄 화면으로 이동
    func showUnderline()

    /// 전시 기록 화면으로 이동
    func showRecord()

    /// 로그아웃 처리
    func logout()
}
