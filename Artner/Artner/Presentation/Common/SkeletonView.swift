//
//  SkeletonView.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import UIKit
import SnapKit

final class SkeletonView: UIView {
    
    // MARK: - UI Components
    
    private let containerView = UIView()
    private let loadingMessageLabel = UILabel()
    private let skeletonStackView = UIStackView()
    private var skeletonBars: [UIView] = []
    
    // MARK: - Properties
    
    private var animationTimer: Timer?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = AppColor.background
        
        addSubview(containerView)
        containerView.addSubview(loadingMessageLabel)
        containerView.addSubview(skeletonStackView)
        
        // 로딩 메시지 설정
        loadingMessageLabel.text = "아트너가 작품 설명을 준비하고 있어요.\n그동안 자유롭게 작품을 감상해 보세요!"
        loadingMessageLabel.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        loadingMessageLabel.textColor = AppColor.textPrimary
        loadingMessageLabel.textAlignment = .center
        loadingMessageLabel.numberOfLines = 0
        loadingMessageLabel.lineBreakMode = .byWordWrapping
        
        // 스켈레톤 스택뷰 설정
        skeletonStackView.axis = .vertical
        skeletonStackView.spacing = 16
        skeletonStackView.alignment = .fill
        skeletonStackView.distribution = .equalSpacing
        
        // 스켈레톤 바들 생성
        createSkeletonBars()
    }
    
    private func createSkeletonBars() {
        // 다양한 길이의 스켈레톤 바 생성 (문단을 시뮬레이션)
        let barConfigs = [
            (width: 0.9, height: 60.0), // 긴 문단
            (width: 0.7, height: 45.0), // 중간 문단
            (width: 0.8, height: 50.0), // 긴 문단
            (width: 0.6, height: 40.0), // 짧은 문단
            (width: 0.85, height: 55.0), // 긴 문단
            (width: 0.5, height: 35.0)  // 짧은 문단
        ]
        
        for (index, config) in barConfigs.enumerated() {
            let skeletonBar = createSkeletonBar(widthRatio: config.width, height: config.height)
            skeletonStackView.addArrangedSubview(skeletonBar)
            skeletonBars.append(skeletonBar)
            
            // 각 바마다 다른 지연시간으로 애니메이션 시작
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                self.startShimmerAnimation(for: skeletonBar)
            }
        }
    }
    
    private func createSkeletonBar(widthRatio: Double, height: Double) -> UIView {
        let container = UIView()
        container.backgroundColor = .clear
        
        let bar = UIView()
        bar.backgroundColor = AppColor.textSecondary.withAlphaComponent(0.3)
        bar.layer.cornerRadius = 8
        bar.clipsToBounds = true
        
        container.addSubview(bar)
        
        container.snp.makeConstraints {
            $0.height.equalTo(height)
        }
        
        bar.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(widthRatio)
            $0.height.equalTo(20)
        }
        
        return container
    }

    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
        }
        
        loadingMessageLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
        }
        
        skeletonStackView.snp.makeConstraints {
            $0.top.equalTo(loadingMessageLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
    
    // MARK: - Animation
    
    private func startShimmerAnimation(for view: UIView) {
        guard let bar = view.subviews.first else { return }
        
        let shimmerLayer = CAGradientLayer()
        shimmerLayer.colors = [
            UIColor.clear.cgColor,
            AppColor.textPoint.withAlphaComponent(0.3).cgColor,
            UIColor.clear.cgColor
        ]
        shimmerLayer.locations = [0.0, 0.5, 1.0]
        shimmerLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        shimmerLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        shimmerLayer.frame = bar.bounds
        
        bar.layer.addSublayer(shimmerLayer)
        
        let shimmerAnimation = CABasicAnimation(keyPath: "transform.translation.x")
        shimmerAnimation.fromValue = -bar.frame.width
        shimmerAnimation.toValue = bar.frame.width
        shimmerAnimation.duration = 1.5
        shimmerAnimation.repeatCount = .infinity
        shimmerAnimation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        
        shimmerLayer.add(shimmerAnimation, forKey: "shimmer")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 레이아웃이 변경될 때마다 shimmer 레이어 크기 업데이트
        for skeletonBar in skeletonBars {
            if let bar = skeletonBar.subviews.first,
               let shimmerLayer = bar.layer.sublayers?.first as? CAGradientLayer {
                shimmerLayer.frame = bar.bounds
            }
        }
    }
    
    // MARK: - Public Methods
    
    func startLoading() {
        isHidden = false
        alpha = 0
        
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1.0
        }
    }
    
    func stopLoading() {
        UIView.animate(withDuration: 0.3) {
            self.alpha = 0
        } completion: { _ in
            self.isHidden = true
            self.removeFromSuperview()
        }
    }
    
    deinit {
        animationTimer?.invalidate()
    }
} 
