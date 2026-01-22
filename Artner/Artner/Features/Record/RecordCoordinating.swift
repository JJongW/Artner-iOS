//
//  RecordCoordinating.swift
//  Artner
//
//  Feature Isolation - Record feature navigation protocol
//

import Foundation

/// Record 피처의 네비게이션 프로토콜
/// AppCoordinator가 구현하여 Record 화면에서 다른 화면으로의 이동을 처리
protocol RecordCoordinating: Coordinator {
    /// 전시 기록 입력 화면 표시
    func showRecordInput()

    /// 홈 화면으로 이동
    func popToHome()
}
