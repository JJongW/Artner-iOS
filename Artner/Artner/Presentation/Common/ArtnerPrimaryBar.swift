//
//  ArtnerPrimaryBar.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import UIKit
import SnapKit

final class ArtnerPrimaryBar: UIView {

    // MARK: - UI Components

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 2
        stack.alignment = .leading
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = AppColor.textPrimary
        return label
    }()

    private let subtitlteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .left
        label.textColor = AppColor.textPrimary
        label.layer.opacity = 0.7
        return label
    }()
    
    // 상단 그라데이션 레이어 (플레이 중에만 표시)
    private let topGradientLayer = CAGradientLayer()
    private var isGradientVisible = false

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGradient()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = AppColor.background // 불투명 배경 복원

        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitlteLabel)

        // StackView 제약조건 설정 - SafeArea를 고려한 상단 패딩
        stackView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.equalTo(safeAreaLayoutGuide.snp.top).offset(12)  // SafeArea 고려
            $0.bottom.equalToSuperview().inset(12)
        }
    }
    
    private func setupGradient() {
        // 상단 그라데이션 설정 (아래 그라데이션과 이어지도록)
        topGradientLayer.colors = [
            UIColor(hex: "#FFE489", alpha: 0.4).cgColor,  // 밝은 골든
            UIColor(hex: "#CD9567", alpha: 0.3).cgColor,  // 미디엄 골든
            UIColor(hex: "#9A5648", alpha: 0.2).cgColor   // 다크 브라운
        ]
        topGradientLayer.locations = [0.0, 0.5, 1.0]
        topGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        topGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        topGradientLayer.opacity = 0.0  // 초기에는 숨김
        
        layer.insertSublayer(topGradientLayer, at: 0)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        topGradientLayer.frame = bounds
    }
    
    // MARK: - Public Method

    func setTitle(_ title: String, subtitle: String) {
        titleLabel.text = title
        subtitlteLabel.text = subtitle
    }
    
    // MARK: - Gradient Control
    
    /// 플레이 상태에 따른 그라데이션 표시/숨김
    func setGradientVisible(_ visible: Bool, animated: Bool = true) {
        guard isGradientVisible != visible else { return }
        
        isGradientVisible = visible
        let targetOpacity: Float = visible ? 1.0 : 0.0
        
        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.8)
            topGradientLayer.opacity = targetOpacity
            CATransaction.commit()
        } else {
            topGradientLayer.opacity = targetOpacity
        }
    }
}
