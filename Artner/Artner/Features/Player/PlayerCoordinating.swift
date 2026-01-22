//
//  PlayerCoordinating.swift
//  Artner
//
//  Feature Isolation - Player feature navigation protocol
//

import Foundation
import Combine

/// Player 피처의 네비게이션 프로토콜
/// AppCoordinator가 구현하여 Player 화면에서 다른 화면으로의 이동을 처리
protocol PlayerCoordinating: Coordinator {
    /// Save 화면으로 이동 (특정 폴더로 이동 가능)
    func showSave(folderId: Int?)

    /// 폴더 목록 가져오기
    func getFolders() -> AnyPublisher<[Folder], any Error>

    /// Underline(밑줄) 화면으로 이동
    func showUnderlineFromPlayer()
}
