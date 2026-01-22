//
//  Coordinator.swift
//  Artner
//
//  Feature Isolation Refactoring - Base Coordinator Protocol
//

import UIKit

/// 기본 Coordinator 프로토콜
/// 모든 Feature Coordinator 프로토콜이 상속해야 하는 기본 프로토콜
protocol Coordinator: AnyObject {
    /// 현재 화면을 닫고 이전 화면으로 이동
    func popViewController(animated: Bool)
}

// Note: Default parameter values are not supported for protocol requirements
// Each implementing type must implement popViewController(animated:) directly
