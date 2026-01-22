//
//  CameraCoordinating.swift
//  Artner
//
//  Feature Isolation - Camera feature navigation protocol
//

import UIKit

/// Camera 피처의 네비게이션 프로토콜
/// AppCoordinator가 구현하여 Camera 화면에서 다른 화면으로의 이동을 처리
protocol CameraCoordinating: Coordinator {
    /// 카메라를 닫고 Entry 화면으로 이동
    func dismissCameraAndShowEntry(docent: Docent)

    /// 카메라를 닫고 Player 화면으로 이동
    func dismissCameraAndShowPlayer(docent: Docent)

    /// 카메라에서 Entry 화면으로 이동 (캡처된 이미지 포함)
    func navigateToEntryFromCamera(with capturedImage: UIImage?)
}
