//
//  LikeCoordinating.swift
//  Artner
//
//  Feature Isolation - Like feature navigation protocol
//

import Foundation

/// Like 피처의 네비게이션 프로토콜
/// AppCoordinator가 구현하여 Like 화면에서 다른 화면으로의 이동을 처리
protocol LikeCoordinating: Coordinator {
    /// Entry 화면으로 이동 (좋아요한 아이템 상세)
    func showEntry(docent: Docent)

    /// 홈 화면으로 이동
    func popToHome()
}
