//
//  EntryCoordinating.swift
//  Artner
//
//  Feature Isolation - Entry feature navigation protocol
//

import UIKit

/// Entry 피처의 네비게이션 프로토콜
/// AppCoordinator가 구현하여 Entry 화면에서 다른 화면으로의 이동을 처리
protocol EntryCoordinating: Coordinator {
    /// Chat 화면으로 이동
    func showChat(docent: Docent, keyword: String)

    /// Player 화면으로 이동
    func showPlayer(docent: Docent)

    /// Sidebar 표시
    func showSidebar(from viewController: UIViewController)
}
