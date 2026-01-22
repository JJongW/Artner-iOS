//
//  LaunchCoordinating.swift
//  Artner
//
//  Feature Isolation - Launch feature navigation protocol
//

import Foundation

/// Launch 피처의 네비게이션 프로토콜
/// AppCoordinator가 구현하여 Launch 화면에서 다른 화면으로의 이동을 처리
protocol LaunchCoordinating: Coordinator {
    /// 메인 화면(Home)으로 이동
    func showMainScreen()
}
