//
//  LaunchView.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import UIKit
import SnapKit

/// 앱 시작 화면의 View
final class LaunchView: UIView {
    
    // MARK: - UI Components
    
    /// 그라데이션 배경 뷰
    private let gradientBackgroundView = GradientBackgroundView()
    
    /// 배경 벡터 이미지 (타이틀 뒤에 위치)
    /// artner 타이틀의 장식 요소로 사용
    private let backgroundVectorImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "background_vector_image")
        imageView.alpha = 0.75
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    /// 서브타이틀 라벨 (그라디언트 텍스트)
    private let subtitleLabel: GradientTextView = {
        let view = GradientTextView()
        view.setText("AI로 듣는 나만의 예술 파트너")
        view.setFont(UIFont.systemFont(ofSize: 18, weight: .medium))
        view.setGradientColors([
            UIColor(hex: "#D99053"),  // 좌측
            UIColor(hex: "#CFAC4A")   // 우측
        ])
        view.isHidden = true
        return view
    }()
    
    /// 앱 타이틀 라벨
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "artner"
        label.font = UIFont.poppinsMedium(size: 52)
        label.textColor = UIColor(hex: "#FFDB98")
        label.textAlignment = .center
        return label
    }()
    
    /// 로딩 인디케이터
    private let loadingIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = UIColor(hex: "#FFDB98")
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    /// 카카오 로그인 버튼
    /// 텍스트는 중앙, 아이콘은 좌측에 독립적으로 배치
    let kakaoLoginButton: UIButton = {
        let button = UIButton(type: .custom)
        
        // 텍스트 설정 (중앙 정렬)
        button.setTitle("카카오 로그인", for: .normal)
        button.setTitleColor(UIColor(hex: "#000000").withAlphaComponent(0.85), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        button.contentHorizontalAlignment = .center
        
        // 배경 및 스타일
        button.backgroundColor = UIColor(hex: "#FEE500")
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        
        button.isHidden = true
        
        return button
    }()
    
    /// 카카오 로그인 버튼 아이콘 (좌측 배치)
    private let kakaoIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_kakao_chat")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = UIColor(hex: "#000000")
        imageView.isHidden = true
        return imageView
    }()
    
    private let termsLabel: UILabel = {
        let label = UILabel()
        label.text = "시작과 동시에 아트너의 서비스 약관,\n개인정보 취급 방침에 동의하게 됩니다."
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = UIColor(hex: "#FFDB98").withAlphaComponent(0.6)  // 60% opacity
        label.textAlignment = .center
        label.numberOfLines = 0  // 여러 줄 표시
        label.isHidden = true  // 초기에는 숨김
        return label
    }()
    
    /// 로그인 버튼 콜백
    var onKakaoLoginTapped: (() -> Void)?
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        // 배경색을 투명하게 설정하여 그라데이션이 보이도록 함
        backgroundColor = .clear
        
        // 그라데이션 배경 추가
        addSubview(gradientBackgroundView)
        
        // 배경 벡터 이미지를 타이틀보다 먼저 추가 (z-index상 뒤에 위치)
        addSubview(backgroundVectorImageView)
        
        // 타이틀 관련 라벨 추가 (배경 이미지 위에 표시됨)
        addSubview(subtitleLabel)
        addSubview(titleLabel)
        addSubview(loadingIndicator)
        addSubview(kakaoLoginButton)
        addSubview(kakaoIconImageView)  // 아이콘을 버튼 위에 배치
        addSubview(termsLabel)
        
        print("🔍 [LaunchView] UI 설정 완료 - 그라데이션 배경 및 벡터 이미지 추가됨")
    }
    
    private func setupLayout() {
        // 그라데이션 배경 뷰 레이아웃
        gradientBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 서브타이틀 라벨 레이아웃 (그라디언트 텍스트)
        // "AI로 듣는 나만의 예술 파트너" - 타이틀 위로 10pt
        subtitleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()  // 화면 중앙
            $0.bottom.equalTo(titleLabel.snp.top).offset(-10)  // 타이틀 위로 10pt
        }
        
        // 타이틀 라벨 레이아웃
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(312)
        }
        
        // 배경 벡터 이미지 레이아웃
        backgroundVectorImageView.snp.makeConstraints {
            $0.centerX.equalTo(titleLabel.snp.leading).offset(-20)  // 이미지 중심이 타이틀 왼쪽으로 20
            $0.centerY.equalTo(titleLabel.snp.top).offset(-20)      // 이미지 중심이 타이틀 위로 30
            $0.width.equalTo(477)   // 임시 크기 설정 (조정 가능)
            $0.height.equalTo(479)  // 임시 크기 설정 (조정 가능)
        }
        
        loadingIndicator.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(60)
        }
        
        kakaoLoginButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-100)
            $0.leading.trailing.equalToSuperview().inset(40)
            $0.height.equalTo(50)
        }
        
        // 카카오 아이콘 레이아웃 (버튼 좌측에 독립 배치)
        kakaoIconImageView.snp.makeConstraints {
            $0.leading.equalTo(kakaoLoginButton).offset(16)  // 버튼 좌측에서 16pt
            $0.centerY.equalTo(kakaoLoginButton)  // 버튼 세로 중앙
            $0.width.height.equalTo(20)  // 아이콘 크기 20x20
        }
        
        // 약관 동의 안내 라벨 레이아웃
        // 카카오 로그인 버튼 아래로 16pt, 가운데 정렬
        termsLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalTo(kakaoLoginButton.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(40)
        }
    }
    
    private func setupActions() {
        kakaoLoginButton.addTarget(self, action: #selector(didTapKakaoLogin), for: .touchUpInside)
    }
    
    
    // MARK: - Public Methods
    
    /// 로딩 시작
    func startLoading() {
        loadingIndicator.startAnimating()
        kakaoLoginButton.isHidden = true
        kakaoIconImageView.isHidden = true
        subtitleLabel.isHidden = true
        termsLabel.isHidden = true
    }
    
    /// 로딩 완료 후 로그인 버튼, 서브타이틀, 약관 안내 표시
    func showLoginButton() {
        loadingIndicator.stopAnimating()
        kakaoLoginButton.isHidden = false
        kakaoIconImageView.isHidden = false
        subtitleLabel.isHidden = false
        termsLabel.isHidden = false
        
        // 페이드인 애니메이션
        kakaoLoginButton.alpha = 0
        kakaoIconImageView.alpha = 0
        subtitleLabel.alpha = 0
        termsLabel.alpha = 0
        UIView.animate(withDuration: 0.5) {
            self.kakaoLoginButton.alpha = 1
            self.kakaoIconImageView.alpha = 1
            self.subtitleLabel.alpha = 1
            self.termsLabel.alpha = 1
        }
    }
    
    // MARK: - Actions
    @objc private func didTapKakaoLogin() {
        onKakaoLoginTapped?()
    }
}

// MARK: - GradientTextView

/// 텍스트에 그라디언트 효과를 적용하는 커스텀 뷰
/// UIColor(patternImage:) 방식을 사용하여 간단하고 확실하게 구현
final class GradientTextView: UIView {
    
    // MARK: - Properties
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private var gradientColors: [UIColor] = []
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    // MARK: - Setup
    
    private func setupView() {
        addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor),
            label.bottomAnchor.constraint(equalTo: bottomAnchor),
            label.leadingAnchor.constraint(equalTo: leadingAnchor),
            label.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 레이아웃이 완료되면 그라디언트 적용
        if !gradientColors.isEmpty && label.bounds.width > 0 {
            applyGradient()
        }
    }
    
    // MARK: - Public Methods
    
    func setText(_ text: String) {
        label.text = text
    }
    
    func setFont(_ font: UIFont) {
        label.font = font
    }
    
    func setGradientColors(_ colors: [UIColor]) {
        gradientColors = colors
        if label.bounds.width > 0 {
            applyGradient()
        }
    }
    
    // MARK: - Private Methods
    
    private func applyGradient() {
        guard gradientColors.count >= 2,
              label.bounds.width > 0,
              label.bounds.height > 0 else {
            return
        }
        
        // 그라디언트 이미지 생성
        let gradientImage = UIImage.gradientImage(
            bounds: label.bounds,
            colors: gradientColors
        )
        
        // 패턴 이미지로 텍스트 색상 설정
        label.textColor = UIColor(patternImage: gradientImage)
    }
}

// MARK: - UIImage Extension

extension UIImage {
    /// 그라디언트 이미지 생성
    /// - Parameters:
    ///   - bounds: 이미지 크기
    ///   - colors: 그라디언트 색상 배열 (좌 -> 우)
    /// - Returns: 그라디언트가 적용된 UIImage
    static func gradientImage(bounds: CGRect, colors: [UIColor]) -> UIImage {
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        
        return renderer.image { context in
            let cgColors = colors.map { $0.cgColor }
            guard let gradient = CGGradient(
                colorsSpace: CGColorSpaceCreateDeviceRGB(),
                colors: cgColors as CFArray,
                locations: nil
            ) else {
                return
            }
            
            // 좌측에서 우측으로 그라디언트
            context.cgContext.drawLinearGradient(
                gradient,
                start: CGPoint(x: bounds.minX, y: bounds.midY),
                end: CGPoint(x: bounds.maxX, y: bounds.midY),
                options: []
            )
        }
    }
}
