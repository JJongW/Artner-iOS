//
//  GradientBackgroundView.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import UIKit

/// 그라데이션 배경을 담당하는 독립적인 뷰 컴포넌트
final class GradientBackgroundView: UIView {
    
    // MARK: - Properties
    
    /// 그라데이션 레이어
    private let gradientLayer = CAGradientLayer()
    
    /// 그라데이션 타입
    enum GradientType {
        case circular    // 원형 그라데이션
        case linear      // 선형 그라데이션
    }
    
    /// 현재 그라데이션 타입
    private var gradientType: GradientType = .circular
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGradient()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupGradient()
    }
    
    // MARK: - Setup
    private func setupGradient() {
        // 기본 원형 그라데이션 설정
        configureCircularGradient()
        
        // 레이어 추가
        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 그라데이션 레이어 크기를 뷰 크기에 맞춤
        gradientLayer.frame = bounds
        print("🔍 [GradientBackgroundView] 레이아웃 업데이트 - bounds: \(bounds)")
    }
    
    // MARK: - Public Methods
    
    /// 원형 그라데이션 설정
    /// 변경 이유: 기존 그라디언트가 너무 급격하게 변해 부자연스러웠음
    /// 개선 사항:
    /// 1. 중간 색상 추가로 더 부드러운 색상 전환
    /// 2. locations 배열로 색상 분포를 정밀하게 제어
    /// 3. 더 넓은 범위(1.5배)의 그라디언트로 자연스러운 효과
    /// 4. 간단하고 정확한 endPoint 계산
    func configureCircularGradient() {
        gradientType = .circular
        
        // 그라디언트 색상 설정 - 3개의 색상으로 부드러운 전환
        gradientLayer.colors = [
            UIColor(hex: "#000000").cgColor,  // 중앙 (순수 검은색)
            UIColor(hex: "#1A1109").cgColor,  // 중간 (매우 어두운 갈색) - 새로 추가
            UIColor(hex: "#241A11").cgColor   // 외곽 (어두운 갈색)
        ]
        
        // 색상 분포 위치 설정 - 더 부드러운 전환을 위해
        // 0.0 = 중앙, 0.6 = 중간 지점, 1.0 = 외곽
        // 중간 색상을 0.6 위치에 배치하여 자연스러운 전환 생성
        gradientLayer.locations = [0.0, 0.6, 1.0]
        
        // 원형 그라디언트로 설정
        gradientLayer.type = .radial
        
        // 그라디언트 중심점을 화면 정중앙으로 설정
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.5)  // 화면 중앙
        
        // 화면 전체를 부드럽게 커버하는 원형 그라디언트
        // 1.5배 더 큰 반지름으로 전체 화면을 자연스럽게 채움
        gradientLayer.endPoint = CGPoint(x: 2.5, y: 1.3)
    }
    
    /// 선형 그라데이션 설정 (향후 확장용)
    func configureLinearGradient() {
        gradientType = .linear
        
        // 그라데이션 색상 설정
        gradientLayer.colors = [
            UIColor(hex: "#000000").cgColor,  // 시작 색상
            UIColor(hex: "#241A11").cgColor   // 끝 색상
        ]
        
        // 선형 그라데이션으로 설정
        gradientLayer.type = .axial
        
        // 그라데이션 방향 설정 (상단에서 하단으로)
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)  // 상단 중앙
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)    // 하단 중앙
    }
    
    /// 커스텀 그라데이션 설정
    /// - Parameters:
    ///   - colors: 그라데이션 색상 배열
    ///   - type: 그라데이션 타입
    ///   - startPoint: 시작점
    ///   - endPoint: 끝점
    func configureCustomGradient(
        colors: [UIColor],
        type: GradientType,
        startPoint: CGPoint,
        endPoint: CGPoint
    ) {
        gradientType = type
        
        // 색상 설정
        gradientLayer.colors = colors.map { $0.cgColor }
        
        // 타입 설정
        gradientLayer.type = type == .circular ? .radial : .axial
        
        // 포인트 설정
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
    }
    
    /// 그라데이션 애니메이션 추가
    /// - Parameters:
    ///   - duration: 애니메이션 지속 시간
    ///   - colors: 애니메이션할 색상 배열
    func animateGradient(duration: TimeInterval, colors: [UIColor]) {
        let animation = CABasicAnimation(keyPath: "colors")
        animation.duration = duration
        animation.fromValue = gradientLayer.colors
        animation.toValue = colors.map { $0.cgColor }
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        
        gradientLayer.add(animation, forKey: "colorAnimation")
    }
}
