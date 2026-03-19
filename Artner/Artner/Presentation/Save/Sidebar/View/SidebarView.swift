//
//  SidebarView.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//
//  Clean Architecture: 사이드바 전체 UI를 View로 분리, ViewController/VM과 바인딩

import UIKit
import SnapKit

final class SidebarView: UIView {
    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()
    let closeButton = UIButton(type: .system)
    let nameLabel = UILabel()
    let statContainerView = UIView() // 통계 버튼 컨테이너
    let statStackView = UIStackView()
    
    // 스켈레톤 UI 컴포넌트들
    let nameSkeletonView = UIView()
    let statSkeletonViews = [UIView(), UIView(), UIView(), UIView()]
    let aiSettingsSkeletonViews = [UIView(), UIView(), UIView()]
    // 최근 도슨트
    let recentDocentButton = UIButton(type: .system)
    let recentDocentArrow = UIImageView(image: UIImage(named: "ic_arrow"))
    let recentDocentSeparator = UIView()
    // AI 도슨트 설정
    let aiDocentTitleLabel = UILabel()
    let aiDocentContainer = UIView()
    let aiProfileImageView = UIImageView()
    let aiNameLabel = UILabel()
    let aiArrow = UIImageView(image: UIImage(named: "ic_arrow"))
    let aiDocentSeparator = UIView()

    /// AI 도슨트 설정 컨테이너 탭 콜백
    var onAIDocentContainerTapped: (() -> Void)?
    
    // AI 설정 세부 항목들
    let aiSettingsStack = UIStackView() // 길이, 속도, 난이도 전체 스택
    let lengthContainer = UIView()
    let speedContainer = UIView()
    let difficultyContainer = UIView()
    let lengthTitleLabel = UILabel()
    let speedTitleLabel = UILabel()
    let difficultyTitleLabel = UILabel()
    let lengthValueLabel = UILabel()
    let speedValueLabel = UILabel()
    let difficultyValueLabel = UILabel()
    // 쉬운 말 모드
    let easyModeTitleLabel = UILabel()
    let easyModeDescLabel = UILabel()
    let easyModeSwitch = UISwitch()
    let easyModeSeparator = UIView()
    // 뷰어 설정
    let viewerTitleLabel = UILabel()
    let resetButton = UIButton(type: .system)
    let resetIcon = UIImageView(image: UIImage(systemName: "arrow.clockwise"))
    let fontSizeSlider = UISlider()
    let lineSpacingSlider = UISlider()
    let fontSizeProgressView = UIView()
    let lineSpacingProgressView = UIView()
    let fontSizeIcon = UIImageView(image: UIImage(systemName: "textformat.size"))
    let lineSpacingIcon = UIImageView(image: UIImage(systemName: "line.3.horizontal"))
    let fontSizeLabel = UILabel()
    let lineSpacingLabel = UILabel()
    let fontSizeValueLabel = UILabel()
    let lineSpacingValueLabel = UILabel()
    let bottomMenuStackView = UIStackView()
    let bottomMenuSeparator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = UIColor.black
        // 닫기 버튼
        closeButton.setImage(UIImage(named: "ic_close"), for: .normal)
        closeButton.tintColor = .white
        // 이름
        nameLabel.font = UIFont.boldSystemFont(ofSize: 24)
        nameLabel.textColor = UIColor(named: "MainOrange") ?? .orange
        // 통계 버튼 컨테이너
        statContainerView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        statContainerView.layer.cornerRadius = 16
        // 통계 버튼 스택
        statStackView.axis = .horizontal
        statStackView.spacing = 16
        statStackView.distribution = .fillEqually
        // 최근 도슨트
        recentDocentButton.setTitle("최근 도슨트", for: .normal)
        recentDocentButton.setTitleColor(.white, for: .normal)
        recentDocentButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        recentDocentArrow.tintColor = UIColor.white.withAlphaComponent(0.7)
        recentDocentSeparator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        // AI 도슨트 설정
        aiDocentTitleLabel.text = "AI 도슨트 설정"
        aiDocentTitleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        aiDocentTitleLabel.textColor = .white
        aiDocentContainer.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        aiDocentContainer.layer.cornerRadius = 16
        let aiDocentTapGesture = UITapGestureRecognizer(target: self, action: #selector(aiDocentContainerTapped))
        aiDocentContainer.addGestureRecognizer(aiDocentTapGesture)
        aiDocentContainer.isUserInteractionEnabled = true
        aiProfileImageView.layer.cornerRadius = 18
        aiProfileImageView.clipsToBounds = true
        aiProfileImageView.backgroundColor = .gray
        aiNameLabel.text = "친절한 애나"
        aiNameLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        aiNameLabel.textColor = .white
        aiArrow.tintColor = UIColor.white.withAlphaComponent(0.7)
        aiDocentSeparator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        
        // AI 설정 세부 항목들
        aiSettingsStack.axis = .horizontal
        aiSettingsStack.distribution = .fillEqually
        aiSettingsStack.spacing = 0
        
        // 길이, 속도, 난이도 제목 설정
        lengthTitleLabel.text = "길이"
        lengthTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lengthTitleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        lengthTitleLabel.textAlignment = .center
        
        speedTitleLabel.text = "속도"
        speedTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        speedTitleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        speedTitleLabel.textAlignment = .center
        
        difficultyTitleLabel.text = "난이도"
        difficultyTitleLabel.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        difficultyTitleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        difficultyTitleLabel.textAlignment = .center
        
        // API 데이터 값들 설정
        lengthValueLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        lengthValueLabel.textColor = .white
        lengthValueLabel.textAlignment = .center
        lengthValueLabel.text = "짧게" // 기본값
        
        speedValueLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        speedValueLabel.textColor = .white
        speedValueLabel.textAlignment = .center
        speedValueLabel.text = "느리게" // 기본값
        
        difficultyValueLabel.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        difficultyValueLabel.textColor = .white
        difficultyValueLabel.textAlignment = .center
        difficultyValueLabel.text = "초급" // 기본값
        // 쉬운 말 모드
        easyModeTitleLabel.text = "쉬운 말 모드"
        easyModeTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        easyModeTitleLabel.textColor = .white
        easyModeDescLabel.text = "단어와 표현을 쉽게 풀어서 이야기 해줍니다."
        easyModeDescLabel.font = UIFont.systemFont(ofSize: 12)
        easyModeDescLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        easyModeSwitch.onTintColor = UIColor(red: 1.0, green: 0.486, blue: 0.153, alpha: 1.0) // #FF7C27
        easyModeSeparator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        // 뷰어 설정
        viewerTitleLabel.text = "뷰어 설정"
        viewerTitleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        viewerTitleLabel.textColor = .white
        
        // 초기화 버튼 - UIButtonConfiguration 사용
        var config = UIButton.Configuration.filled()
        config.title = "초기화"
        config.baseForegroundColor = .white
        config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.1)
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        if let originalImage = UIImage(named: "ic_refresh") {
            let size = CGSize(width: 16, height: 16)
            let renderer = UIGraphicsImageRenderer(size: size)
            config.image = renderer.image { _ in
                originalImage.draw(in: CGRect(origin: .zero, size: size))
            }
        }
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.cornerStyle = .capsule
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var outgoing = incoming
            outgoing.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            return outgoing
        }
        resetButton.configuration = config
        resetButton.layer.cornerRadius = 30
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: .touchUpInside)
        
        // 뷰어 설정 슬라이더들
        setupCustomSlider(fontSizeSlider, progressView: fontSizeProgressView, icon: fontSizeIcon, label: fontSizeLabel, valueLabel: fontSizeValueLabel, title: "글자 크기", value: 5)
        setupCustomSlider(lineSpacingSlider, progressView: lineSpacingProgressView, icon: lineSpacingIcon, label: lineSpacingLabel, valueLabel: lineSpacingValueLabel, title: "줄 간격", value: 5)
        
        // 슬라이더 값 변경 이벤트 추가
        fontSizeSlider.addTarget(self, action: #selector(fontSizeSliderChanged), for: .valueChanged)
        lineSpacingSlider.addTarget(self, action: #selector(lineSpacingSliderChanged), for: .valueChanged)
        
        // 커스텀 터치 제스처 추가
        setupCustomTouchGesture(for: fontSizeSlider)
        setupCustomTouchGesture(for: lineSpacingSlider)
        bottomMenuSeparator.backgroundColor = UIColor.white.withAlphaComponent(0.2)

        // 하단 메뉴 스택
        bottomMenuStackView.axis = .vertical
        bottomMenuStackView.spacing = 16
    }
    
    // MARK: - Helper Methods
    
    private func setupCustomSlider(_ slider: UISlider, progressView: UIView, icon: UIImageView, label: UILabel, valueLabel: UILabel, title: String, value: Int) {
        print("🔧 setupCustomSlider - title: \(title), value: \(value)")
        
        // 슬라이더 기본 설정
        slider.minimumValue = 1
        slider.maximumValue = 10
        slider.value = Float(value)
        
        // 값 강제 설정 (확실하게 하기 위해)
        slider.setValue(Float(value), animated: false)
        print("🔧 슬라이더 값 설정 후: \(slider.value)")
        slider.backgroundColor = UIColor(red: 0.133, green: 0.133, blue: 0.133, alpha: 1.0) // #222222
        slider.layer.cornerRadius = 16
        slider.clipsToBounds = true
        
        // 슬라이더 트랙 색상 설정 (투명하게 해서 커스텀 뷰로 처리)
        slider.minimumTrackTintColor = UIColor.clear
        slider.maximumTrackTintColor = UIColor.clear
        
        // 슬라이더 썸(흰 동그라미) 숨기기
        slider.setThumbImage(UIImage(), for: .normal)
        slider.setThumbImage(UIImage(), for: .highlighted)
        
        // 프로그레스 뷰 설정 (채움 효과)
        progressView.backgroundColor = UIColor(red: 1.0, green: 0.486, blue: 0.153, alpha: 1.0) // #FF7C27
        progressView.layer.cornerRadius = 16
        progressView.clipsToBounds = true
        
        // 아이콘 설정
        icon.tintColor = .white
        icon.contentMode = .scaleAspectFit
        
        // 라벨 설정
        label.text = title
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textColor = .white
        
        // 값 라벨 설정
        valueLabel.text = "\(value)"
        valueLabel.font = UIFont.boldSystemFont(ofSize: 16)
        valueLabel.textColor = .white
        valueLabel.textAlignment = .right
        
        // 값 최종 설정 (확실하게 하기 위해)
        slider.setValue(Float(value), animated: false)
        valueLabel.text = "\(value)"
    }
    
    private func setupCustomTouchGesture(for slider: UISlider) {
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handleSliderPan(_:)))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleSliderTap(_:)))
        
        slider.addGestureRecognizer(panGesture)
        slider.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleSliderPan(_ gesture: UIPanGestureRecognizer) {
        guard let slider = gesture.view as? UISlider else { return }
        
        let location = gesture.location(in: slider)
        let sliderWidth = slider.bounds.width
        
        // 슬라이더 너비가 0이면 처리하지 않음
        guard sliderWidth > 0 else { return }
        
        let percentage = max(0, min(1, location.x / sliderWidth))
        let newValue = slider.minimumValue + (slider.maximumValue - slider.minimumValue) * Float(percentage)
        slider.value = newValue
        
        // 프로그레스 뷰 업데이트
        updateSliderProgress(slider)
    }
    
    @objc private func handleSliderTap(_ gesture: UITapGestureRecognizer) {
        guard let slider = gesture.view as? UISlider else { return }
        
        let location = gesture.location(in: slider)
        let sliderWidth = slider.bounds.width
        
        // 슬라이더 너비가 0이면 처리하지 않음
        guard sliderWidth > 0 else { return }
        
        let percentage = max(0, min(1, location.x / sliderWidth))
        let newValue = slider.minimumValue + (slider.maximumValue - slider.minimumValue) * Float(percentage)
        slider.value = newValue
        
        // 프로그레스 뷰 업데이트
        updateSliderProgress(slider)
    }
    
    private func updateSliderProgress(_ slider: UISlider) {
        let value = slider.value
        let progress = CGFloat((value - slider.minimumValue) / (slider.maximumValue - slider.minimumValue))
        
        // 최소값(1)에 해당하는 최소 너비 보장 (슬라이더 너비의 약 10%)
        let minProgress: CGFloat = 0.1
        let adjustedProgress = max(progress, minProgress)
        
        if slider == fontSizeSlider {
            // 프로그레스 뷰 너비 업데이트 - 기존 제약조건 제거 후 새로 설정
            fontSizeProgressView.snp.remakeConstraints { make in
                make.leading.top.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(adjustedProgress)
            }
            
            // 값 라벨 업데이트
            fontSizeValueLabel.text = "\(Int(value))"
        } else if slider == lineSpacingSlider {
            // 프로그레스 뷰 너비 업데이트 - 기존 제약조건 제거 후 새로 설정
            lineSpacingProgressView.snp.remakeConstraints { make in
                make.leading.top.bottom.equalToSuperview()
                make.width.equalToSuperview().multipliedBy(adjustedProgress)
            }
            
            // 값 라벨 업데이트
            lineSpacingValueLabel.text = "\(Int(value))"
        }
        
        // 애니메이션으로 부드럽게 변경
        UIView.animate(withDuration: 0.1) {
            self.layoutIfNeeded()
        }
    }
    
    // MARK: - Slider Value Change Handlers
    
    @objc private func fontSizeSliderChanged() {
        updateSliderProgress(fontSizeSlider)
    }
    
    @objc private func lineSpacingSliderChanged() {
        updateSliderProgress(lineSpacingSlider)
    }
    
    private func setupLayout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(closeButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statContainerView)
        statContainerView.addSubview(statStackView)
        
        // 스켈레톤 UI 컴포넌트들 추가
        contentView.addSubview(nameSkeletonView)
        for skeletonView in statSkeletonViews {
            statContainerView.addSubview(skeletonView)
        }
        for skeletonView in aiSettingsSkeletonViews {
            aiSettingsStack.addSubview(skeletonView)
        }

        // 최근 도슨트
        contentView.addSubview(recentDocentButton)
        contentView.addSubview(recentDocentArrow)
        contentView.addSubview(recentDocentSeparator)

        // AI 도슨트 설정
        contentView.addSubview(aiDocentTitleLabel)
        contentView.addSubview(aiDocentContainer)
        aiDocentContainer.addSubview(aiProfileImageView)
        aiDocentContainer.addSubview(aiNameLabel)
        aiDocentContainer.addSubview(aiArrow)
        aiDocentContainer.addSubview(aiDocentSeparator)
        aiDocentContainer.addSubview(aiSettingsStack)
        
        // AI 설정 스택에 컨테이너들 추가
        aiSettingsStack.addArrangedSubview(lengthContainer)
        aiSettingsStack.addArrangedSubview(speedContainer)
        aiSettingsStack.addArrangedSubview(difficultyContainer)
        
        // 각 컨테이너에 제목과 값 라벨 추가
        lengthContainer.addSubview(lengthTitleLabel)
        lengthContainer.addSubview(lengthValueLabel)
        
        speedContainer.addSubview(speedTitleLabel)
        speedContainer.addSubview(speedValueLabel)
        
        difficultyContainer.addSubview(difficultyTitleLabel)
        difficultyContainer.addSubview(difficultyValueLabel)

        // 쉬운 말 모드
        contentView.addSubview(easyModeTitleLabel)
        contentView.addSubview(easyModeSwitch)
        contentView.addSubview(easyModeDescLabel)
        contentView.addSubview(easyModeSeparator)
        
        // 뷰어 설정
        contentView.addSubview(viewerTitleLabel)
        contentView.addSubview(resetButton)
        contentView.addSubview(fontSizeSlider)
        contentView.addSubview(lineSpacingSlider)
        
        // 슬라이더 내부 요소들 추가
        fontSizeSlider.addSubview(fontSizeProgressView)
        fontSizeSlider.addSubview(fontSizeIcon)
        fontSizeSlider.addSubview(fontSizeLabel)
        fontSizeSlider.addSubview(fontSizeValueLabel)
        lineSpacingSlider.addSubview(lineSpacingProgressView)
        lineSpacingSlider.addSubview(lineSpacingIcon)
        lineSpacingSlider.addSubview(lineSpacingLabel)
        lineSpacingSlider.addSubview(lineSpacingValueLabel)
        contentView.addSubview(bottomMenuStackView)
        contentView.addSubview(bottomMenuSeparator)

        scrollView.snp.makeConstraints { $0.edges.equalToSuperview() }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(42)
            $0.trailing.equalToSuperview().offset(-24)
            $0.width.height.equalTo(24)
        }
        nameLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(64)
            $0.leading.equalToSuperview().offset(24)
        }
        
        // 스켈레톤 UI 제약조건
        nameSkeletonView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(64)
            $0.leading.equalToSuperview().offset(24)
            $0.width.equalTo(120)
            $0.height.equalTo(20)
        }
        statContainerView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        statStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(14)
        }
        
        // 통계 스켈레톤 UI 제약조건
        for (index, skeletonView) in statSkeletonViews.enumerated() {
            skeletonView.snp.makeConstraints {
                $0.top.equalToSuperview().offset(14)
                $0.leading.equalToSuperview().offset(14 + CGFloat(index) * 80)
                $0.width.equalTo(60)
                $0.height.equalTo(60)
            }
        }
        // 최근 도슨트
        recentDocentButton.snp.makeConstraints {
            $0.top.equalTo(statContainerView.snp.bottom).offset(18)
            $0.leading.equalToSuperview().offset(20)
        }
        recentDocentArrow.snp.makeConstraints {
            $0.centerY.equalTo(recentDocentButton)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(24)
        }
        recentDocentSeparator.snp.makeConstraints {
            $0.top.equalTo(recentDocentButton.snp.bottom).offset(18)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        // AI 도슨트 설정
        aiDocentTitleLabel.snp.makeConstraints {
            $0.top.equalTo(recentDocentSeparator.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
        }
        aiDocentContainer.snp.makeConstraints {
            $0.top.equalTo(aiDocentTitleLabel.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        aiProfileImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.width.height.equalTo(36)
        }
        aiNameLabel.snp.makeConstraints {
            $0.centerY.equalTo(aiProfileImageView)
            $0.leading.equalTo(aiProfileImageView.snp.trailing).offset(12)
        }
        aiArrow.snp.makeConstraints {
            $0.centerY.equalTo(aiProfileImageView)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(24)
        }
        aiDocentSeparator.snp.makeConstraints {
            $0.top.equalTo(aiProfileImageView.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        // AI 설정 스택 레이아웃
        aiSettingsStack.snp.makeConstraints {
            $0.top.equalTo(aiDocentSeparator.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
        }
        
        // 길이 컨테이너 내부 레이아웃
        lengthTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        lengthValueLabel.snp.makeConstraints {
            $0.top.equalTo(lengthTitleLabel.snp.bottom).offset(88)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        // 속도 컨테이너 내부 레이아웃
        speedTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        speedValueLabel.snp.makeConstraints {
            $0.top.equalTo(speedTitleLabel.snp.bottom).offset(88)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        
        // 난이도 컨테이너 내부 레이아웃
        difficultyTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.centerX.equalToSuperview()
        }
        difficultyValueLabel.snp.makeConstraints {
            $0.top.equalTo(difficultyTitleLabel.snp.bottom).offset(88)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }
        // 쉬운 말 모드
        easyModeTitleLabel.snp.makeConstraints {
            $0.top.equalTo(aiDocentContainer.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        easyModeSwitch.snp.makeConstraints {
            $0.centerY.equalTo(easyModeTitleLabel)
            $0.trailing.equalToSuperview().offset(-20)
        }
        easyModeDescLabel.snp.makeConstraints {
            $0.top.equalTo(easyModeTitleLabel.snp.bottom).offset(4)
            $0.leading.equalToSuperview().offset(20)
        }
        
        // 쉬운 말 모드 divider
        easyModeSeparator.snp.makeConstraints {
            $0.top.equalTo(easyModeDescLabel.snp.bottom).offset(26)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        
        // 뷰어 설정
        viewerTitleLabel.snp.makeConstraints {
            $0.top.equalTo(easyModeSeparator.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(20)
        }

        // 초기화 버튼
        resetButton.snp.makeConstraints {
            $0.centerY.equalTo(viewerTitleLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(26)
        }
        
        // 글자 크기 슬라이더
        fontSizeSlider.snp.makeConstraints {
            $0.top.equalTo(viewerTitleLabel.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(50)
        }
        
        // 글자 크기 프로그레스 뷰 (채움 효과)
        fontSizeProgressView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(0.0) 
        }
        
        fontSizeIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        fontSizeLabel.snp.makeConstraints {
            $0.leading.equalTo(fontSizeIcon.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
        
        fontSizeValueLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        
        // 줄 간격 슬라이더
        lineSpacingSlider.snp.makeConstraints {
            $0.top.equalTo(fontSizeSlider.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(50)
        }
        
        // 줄 간격 프로그레스 뷰 (채움 효과)
        lineSpacingProgressView.snp.makeConstraints {
            $0.leading.top.bottom.equalToSuperview()
            $0.width.equalToSuperview().multipliedBy(1.0) 
        }
        
        lineSpacingIcon.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        
        lineSpacingLabel.snp.makeConstraints {
            $0.leading.equalTo(lineSpacingIcon.snp.trailing).offset(12)
            $0.centerY.equalToSuperview()
        }
        
        lineSpacingValueLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
        }
        bottomMenuSeparator.snp.makeConstraints {
            $0.top.equalTo(lineSpacingSlider.snp.bottom).offset(42)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(1)
        }
        bottomMenuStackView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(bottomMenuSeparator.snp.bottom).offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-42)
        }
        
        // 레이아웃 완료 후 초기 프로그레스 뷰 업데이트
        DispatchQueue.main.async {
            self.updateSliderProgress(self.fontSizeSlider)
            self.updateSliderProgress(self.lineSpacingSlider)
        }
    }
    
    // MARK: - Button Actions
    
    @objc private func resetButtonTapped() {
        // 두 슬라이더를 5로 초기화
        fontSizeSlider.setValue(5.0, animated: true)
        lineSpacingSlider.setValue(5.0, animated: true)

        // 프로그레스 뷰 업데이트
        updateSliderProgress(fontSizeSlider)
        updateSliderProgress(lineSpacingSlider)

        // VC의 슬라이더 변경 핸들러 트리거 (ViewModel/Manager 동기화)
        fontSizeSlider.sendActions(for: .valueChanged)
        lineSpacingSlider.sendActions(for: .valueChanged)
    }
    
    // MARK: - Skeleton UI Methods
    
    /// 스켈레톤 UI 설정
    func setupSkeletonUI() {
        // 이름 스켈레톤
        nameSkeletonView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        nameSkeletonView.layer.cornerRadius = 4
        nameSkeletonView.isHidden = true
        
        // 통계 스켈레톤
        for skeletonView in statSkeletonViews {
            skeletonView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            skeletonView.layer.cornerRadius = 8
            skeletonView.isHidden = true
        }
        
        // AI 설정 스켈레톤
        for skeletonView in aiSettingsSkeletonViews {
            skeletonView.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            skeletonView.layer.cornerRadius = 4
            skeletonView.isHidden = true
        }
    }
    
    /// 로딩 상태에 따른 UI 업데이트
    func updateLoadingState(isLoading: Bool, isAISettingsLoading: Bool) {
        // 이름 로딩 상태
        nameSkeletonView.isHidden = !isLoading
        nameLabel.isHidden = isLoading
        
        // 통계 로딩 상태
        for (index, skeletonView) in statSkeletonViews.enumerated() {
            skeletonView.isHidden = !isLoading
            if index < statStackView.arrangedSubviews.count {
                statStackView.arrangedSubviews[index].isHidden = isLoading
            }
        }
        
        // AI 설정 로딩 상태
        for (index, skeletonView) in aiSettingsSkeletonViews.enumerated() {
            skeletonView.isHidden = !isAISettingsLoading
        }
        
        // AI 설정 값들 로딩 상태 - 로딩 완료 시에만 표시
        lengthValueLabel.isHidden = isAISettingsLoading
        speedValueLabel.isHidden = isAISettingsLoading
        difficultyValueLabel.isHidden = isAISettingsLoading
        
        // 로딩 완료 시 애니메이션으로 부드럽게 전환
        if !isLoading && !isAISettingsLoading {
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }
    
    /// AI 설정 값들의 간격을 동적으로 조정
    func updateAISettingsSpacing() {
        // 길이 값에 따른 간격 조정
        let lengthSpacing = calculateSpacing(for: lengthValueLabel.text ?? "")
        lengthValueLabel.snp.updateConstraints {
            $0.top.equalTo(lengthTitleLabel.snp.bottom).offset(lengthSpacing)
        }
        
        // 속도 값에 따른 간격 조정
        let speedSpacing = calculateSpacing(for: speedValueLabel.text ?? "")
        speedValueLabel.snp.updateConstraints {
            $0.top.equalTo(speedTitleLabel.snp.bottom).offset(speedSpacing)
        }
        
        // 난이도 값에 따른 간격 조정
        let difficultySpacing = calculateSpacing(for: difficultyValueLabel.text ?? "")
        difficultyValueLabel.snp.updateConstraints {
            $0.top.equalTo(difficultyTitleLabel.snp.bottom).offset(difficultySpacing)
        }
        
        // 레이아웃 업데이트
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    /// 텍스트 길이에 따른 간격 계산
    private func calculateSpacing(for text: String) -> CGFloat {
        // 공백이 있으면 두 단어 이상으로 간주 (16pt)
        if text.contains(" ") {
            return 16
        } else {
            // 한 단어인 경우 (30pt)
            return 30
        }
    }
    
    // MARK: - Tap Handlers

    @objc private func aiDocentContainerTapped() {
        onAIDocentContainerTapped?()
    }

    /// 내부 컨텐츠 요소들의 alpha를 설정 (애니메이션용)
    /// - Parameter alpha: 설정할 alpha 값 (0.0 ~ 1.0)
    func setContentAlpha(_ alpha: CGFloat) {
        // 닫기 버튼은 항상 보이도록 (alpha 조정 안 함)
        // closeButton.alpha = alpha
        
        // 주요 컨텐츠 요소들
        nameLabel.alpha = alpha
        statContainerView.alpha = alpha
        recentDocentButton.alpha = alpha
        recentDocentArrow.alpha = alpha
        recentDocentSeparator.alpha = alpha
        aiDocentTitleLabel.alpha = alpha
        aiDocentContainer.alpha = alpha
        easyModeTitleLabel.alpha = alpha
        easyModeDescLabel.alpha = alpha
        easyModeSwitch.alpha = alpha
        easyModeSeparator.alpha = alpha
        viewerTitleLabel.alpha = alpha
        resetButton.alpha = alpha
        fontSizeSlider.alpha = alpha
        lineSpacingSlider.alpha = alpha
        bottomMenuStackView.alpha = alpha
        bottomMenuSeparator.alpha = alpha
    }
} 
