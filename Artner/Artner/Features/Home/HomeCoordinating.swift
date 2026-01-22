//
//  HomeCoordinating.swift
//  Artner
//
//  Feature Isolation - Home feature navigation protocol
//

import UIKit

/// Home 피처의 네비게이션 프로토콜
/// AppCoordinator가 구현하여 Home 화면에서 다른 화면으로의 이동을 처리
protocol HomeCoordinating: Coordinator {
    /// Entry 화면으로 이동
    func showEntry(docent: Docent)

    /// Camera 화면으로 이동
    func showCamera()

    /// Sidebar 표시
    func showSidebar(from viewController: UIViewController)

    /// 좋아요 토글 처리
    /// - Parameters:
    ///   - type: 좋아요 타입 (artwork, artist, exhibition)
    ///   - id: 대상 아이템 ID
    ///   - completion: 완료 핸들러 (isLiked: 토글 후 좋아요 상태)
    func toggleLike(type: LikeType, id: Int, completion: @escaping (Result<Bool, any Error>) -> Void)
}
