//
//  ToastView.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import UIKit
import SnapKit

/// Toast 구성 정보를 담는 구조체
/// Clean Architecture를 위해 UI와 데이터를 분리
struct ToastConfiguration {
    let message: String
    let leftIcon: UIImage?
    let rightButtonTitle: String?
    let rightButtonAction: (() -> Void)?
    let backgroundColor: UIColor
    let textColor: UIColor
    let duration: TimeInterval
    
    /// 기본 설정으로 Toast 생성
    init(
        message: String,
        leftIcon: UIImage? = nil,
        rightButtonTitle: String? = nil,
        rightButtonAction: (() -> Void)? = nil,
        backgroundColor: UIColor = AppColor.toastBackground,
        textColor: UIColor = AppColor.toastText,
        duration: TimeInterval = 3.0
    ) {
        self.message = message
        self.leftIcon = leftIcon
        self.rightButtonTitle = rightButtonTitle
        self.rightButtonAction = rightButtonAction
        self.backgroundColor = backgroundColor
        self.textColor = textColor
        self.duration = duration
    }
}

/// 재사용 가능한 Toast UI 컴포넌트
/// 좌측 아이콘, 중앙 텍스트, 우측 버튼을 지원하는 유연한 구조
final class ToastView: UIView {
    
    // MARK: - UI Components
    
    private let containerStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.alignment = .center
        stack.distribution = .fill
        stack.spacing = 0
        return stack
    }()
    
    private let leftIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = AppColor.toastIcon
        return imageView
    }()
    
    private let messageLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = AppColor.toastText
        label.numberOfLines = 0
        label.textAlignment = .left
        return label
    }()
    
    private let rightButton: UIButton = {
        let button = UIButton(type: .system)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.setTitleColor(AppColor.toastText, for: .normal)
        return button
    }()
    
    // MARK: - Properties
    
    private var configuration: ToastConfiguration?
    
    // MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    /// UI 기본 설정
    /// Clean Architecture 원칙에 따라 UI 구성 로직을 분리
    private func setupUI() {
        layer.cornerRadius = 16
        clipsToBounds = true
        
        addSubview(containerStackView)
        
        // 좌측 아이콘 크기 설정 (20x20)
        leftIconImageView.snp.makeConstraints {
            $0.width.height.equalTo(20)
        }
    }
    
    /// Toast 구성 정보를 기반으로 UI 업데이트
    /// - Parameter configuration: Toast 설정 정보
    func configure(with configuration: ToastConfiguration) {
        self.configuration = configuration
        
        // 기본 설정
        backgroundColor = configuration.backgroundColor
        messageLabel.text = configuration.message
        messageLabel.textColor = configuration.textColor
        
        // 기존 스택뷰 내용 제거 및 제약조건 초기화
        containerStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        containerStackView.snp.removeConstraints()
        
        let hasLeftIcon = configuration.leftIcon != nil
        let hasRightButton = configuration.rightButtonTitle != nil
        
        // 여백 규칙에 따른 제약조건 설정
        if hasLeftIcon {
            // 아이콘이 있는 경우: 아이콘-토스트끝 18px, 글자-토스트끝 14px
            containerStackView.snp.makeConstraints {
                $0.top.bottom.equalToSuperview().inset(12)
                $0.leading.equalToSuperview().inset(18)
                $0.trailing.equalToSuperview().inset(14)
            }
            
            // 좌측 아이콘 설정
            leftIconImageView.image = configuration.leftIcon
            leftIconImageView.tintColor = AppColor.toastIcon
            containerStackView.addArrangedSubview(leftIconImageView)
            
            // 아이콘과 텍스트 간격 (8px)
            containerStackView.setCustomSpacing(8, after: leftIconImageView)
        } else {
            // 아이콘이 없는 경우: 좌 18px, 우 14px
            containerStackView.snp.makeConstraints {
                $0.top.bottom.equalToSuperview().inset(12)
                $0.leading.equalToSuperview().inset(18)
                $0.trailing.equalToSuperview().inset(14)
            }
        }
        
        // 중앙 텍스트 추가 (항상 포함)
        containerStackView.addArrangedSubview(messageLabel)
        
        // 우측 버튼 설정
        if hasRightButton {
            rightButton.setTitle(configuration.rightButtonTitle, for: .normal)
            rightButton.setTitleColor(configuration.textColor, for: .normal)
            rightButton.addTarget(self, action: #selector(rightButtonTapped), for: .touchUpInside)
            
            // 텍스트와 버튼 간격 (10px)
            containerStackView.setCustomSpacing(10, after: messageLabel)
            containerStackView.addArrangedSubview(rightButton)
        }
    }
    
    // MARK: - Actions
    
    @objc private func rightButtonTapped() {
        configuration?.rightButtonAction?()
    }
}
