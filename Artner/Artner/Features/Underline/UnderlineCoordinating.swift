//
//  UnderlineCoordinating.swift
//  Artner
//
//  Feature Isolation - Underline feature navigation protocol
//

import Foundation

/// Underline 피처의 네비게이션 프로토콜
/// AppCoordinator가 구현하여 Underline 화면에서 다른 화면으로의 이동을 처리
protocol UnderlineCoordinating: Coordinator {
    /// 하이라이트된 도슨트로 이동
    func showPlayer(docent: Docent)

    /// 홈 화면으로 이동
    func popToHome()
}
