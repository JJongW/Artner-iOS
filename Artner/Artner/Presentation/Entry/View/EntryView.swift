//
//  EntryView.swift
//  Artner
//
//  Created by 신종원 on 5/17/25.
//

import UIKit
import SnapKit

final class EntryView: BaseView {

    // MARK: - UI Components
    let scrollView = UIScrollView()
    let contentView = UIView()

    let customNavigationBar = CustomNavigationBar()
    let blurredImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_bot")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        return imageView
    }()
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        label.numberOfLines = 1
        label.text = "안녕하세요, 앤젤리너스 커피님!"
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .white
        label.numberOfLines = 0
        label.text = "작가의 이름이나 작품 명, 제작년도 등을\n자세히 적으면 더 구체적으로 설명해 드릴게요."
        return label
    }()
    let suggestionLabel: UILabel = {
        let label = UILabel()
        label.text = "이런 주제는 어떤가요?"
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white.withAlphaComponent(0.5)
        return label
    }()
    let suggestionStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    private var _textField: UITextField?
    var textField: UITextField {
        if let textField = _textField {
            return textField
        }
        
        // 메인 스레드에서만 UITextField 초기화 (스레드 안전성 보장)
        assert(Thread.isMainThread, "UITextField는 메인 스레드에서만 초기화되어야 합니다.")
        
        let textField = UITextField()
        
        // 기본 텍스트 설정
        textField.placeholder = "작품 또는 작가를 입력하세요."
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 16) // 높이에 맞춰 폰트 크기 조정
        
        // 배경 및 디자인
        textField.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        textField.layer.cornerRadius = 26 // 높이(52)에 맞춰 조정
        
        // 키보드 및 입력 설정 (RTI 에러 방지 - 직접 설정)
        textField.keyboardType = .asciiCapable  // 이모지 키보드 완전 비활성화
        textField.returnKeyType = .search
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no      // 자동완성 완전 비활성화
        textField.spellCheckingType = .no       // 맞춤법 검사 비활성화
        textField.smartDashesType = .no         // 스마트 대시 비활성화
        textField.smartQuotesType = .no         // 스마트 따옴표 비활성화
        textField.smartInsertDeleteType = .no   // 스마트 삽입/삭제 비활성화
        
        // 이모지 관련 RTI 에러 방지 설정
        if #available(iOS 15.0, *) {
            textField.keyboardLayoutGuide.followsUndockedKeyboard = false
        }
        
        // 이모지 검색 기능으로 인한 RTI 에러 방지
        textField.inputAssistantItem.leadingBarButtonGroups = []
        textField.inputAssistantItem.trailingBarButtonGroups = []
        textField.inputAssistantItem.allowsHidingShortcuts = true
        
        // placeholder 색상 설정
        textField.attributedPlaceholder = NSAttributedString(
            string: "작품 또는 작가를 입력하세요.",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        )
        
        // 패딩 설정 (높이에 맞춰 조정)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 54, height: 0)) // 검색 버튼(24) + 패딩(16+16) 고려
        textField.rightViewMode = .always
        
        // 접근성 설정
        textField.accessibilityLabel = "검색창"
        textField.accessibilityHint = "작품이나 작가 이름을 입력하세요"
        
        _textField = textField
        return textField
    }
    let searchButton = UIButton()
    private let bottomFadeView = UIView()
    private let gradientLayer = CAGradientLayer()

    // MARK: - Constraint Reference
    var textFieldBottomConstraint: Constraint?
    var greetingTopConstraint: Constraint?
    var descriptionTopConstraint: Constraint?
    var suggestionTopConstraint: Constraint?

    // MARK: - Callbacks
    var onBackButtonTapped: (() -> Void)?
    var didTapMenuButton: (() -> Void)?

    // MARK: - Setup
    override func setupUI() {
        super.setupUI()

        backgroundColor = AppColor.background

        addSubview(scrollView)
        scrollView.addSubview(contentView)

        scrollView.keyboardDismissMode = .interactive
        scrollView.alwaysBounceVertical = true

        [customNavigationBar, blurredImageView, greetingLabel, descriptionLabel, suggestionLabel, suggestionStack, textField, searchButton].forEach {
            contentView.addSubview($0)
        }
        
        // bottomFadeView를 스크롤뷰에 추가 (컨텐츠 위에 오버레이)
        addSubview(bottomFadeView)

        blurredImageView.contentMode = .scaleAspectFit
        blurredImageView.clipsToBounds = true
        blurredImageView.addSubview(blurEffectView)

        ["🖼️\n작품 표현\n방식에 대해", "🎨\n인상주의에\n대해", "🎨\n레오나르도 다빈치"].forEach { title in
            let button = UIButton()
            
            // 행간 조정을 위한 NSAttributedString 설정
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 6 // 행간 6pt
            paragraphStyle.alignment = .left

            let attributedTitle = NSAttributedString(
                string: title,
                attributes: [
                    .font: UIFont.systemFont(ofSize: 16),
                    .foregroundColor: UIColor.white,
                    .paragraphStyle: paragraphStyle
                ]
            )
            
            button.setAttributedTitle(attributedTitle, for: .normal)
            button.titleLabel?.numberOfLines = 4
            button.titleLabel?.textAlignment = .center
            button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
            button.layer.cornerRadius = 12
            suggestionStack.addArrangedSubview(button)
        }

        customNavigationBar.onBackButtonTapped = { [weak self] in
            self?.onBackButtonTapped?()
        }
        customNavigationBar.didTapMenuButton = { [weak self] in
            self?.didTapMenuButton?()
        }

        searchButton.setImage(UIImage(named: "ic_search"), for: .normal)
        searchButton.tintColor = .white
        searchButton.backgroundColor = .clear

        setupFadeLayer()
    }

    override func setupLayout() {
        super.setupLayout()

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.width.equalToSuperview()
            $0.bottom.equalTo(textField.snp.bottom).offset(20) // textField 아래까지가 content 영역
        }

        customNavigationBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        blurredImageView.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(120).priority(.high) // 우선순위를 high로 설정하여 압축 가능
        }

        blurEffectView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        greetingLabel.snp.makeConstraints {
            greetingTopConstraint = $0.top.equalTo(blurredImageView.snp.bottom).offset(32).constraint
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints {
            descriptionTopConstraint = $0.top.equalTo(greetingLabel.snp.bottom).offset(12).constraint
            $0.leading.trailing.equalTo(greetingLabel)
        }

        suggestionLabel.snp.makeConstraints {
            suggestionTopConstraint = $0.top.equalTo(descriptionLabel.snp.bottom).offset(160).priority(.high).constraint // 우선순위 설정
            $0.top.greaterThanOrEqualTo(descriptionLabel.snp.bottom).offset(40) // 최소 40 간격은 보장
            $0.leading.equalTo(greetingLabel)
        }

        suggestionStack.snp.makeConstraints {
            $0.top.equalTo(suggestionLabel.snp.bottom).offset(12)
            $0.height.equalTo(105).priority(.high) // 우선순위를 high로 설정하여 압축 가능
            $0.height.greaterThanOrEqualTo(80) // 최소 80 높이는 보장
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        textField.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(suggestionStack.snp.bottom).offset(26) // 최소 26 간격 유지
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(52) // 높이를 조금 더 여유있게 조정
            // 안전 영역을 고려하여 화면 하단에서 46px 위에 배치 (우선순위 설정)
            textFieldBottomConstraint = $0.bottom.equalTo(self.safeAreaLayoutGuide.snp.bottom).inset(46).priority(.required).constraint
        }

        searchButton.snp.makeConstraints {
            $0.trailing.equalTo(textField.snp.trailing).inset(16)
            $0.centerY.equalTo(textField.snp.centerY)
            $0.width.height.equalTo(24)  // 터치 영역을 조금 더 크게 조정
        }
        
        // bottomFadeView 제약조건 설정 - 화면 하단에 그라데이션 효과
        bottomFadeView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(60) // 그라데이션 효과 높이
        }
    }

    func updateSuggestionSpacing(shrink: Bool) {
        // 키보드 올라올 때는 더 작은 간격으로, 내려갈 때는 여유있는 간격으로
        suggestionTopConstraint?.update(offset: shrink ? 60 : 160)
    }

    private func setupFadeLayer() {
        bottomFadeView.isUserInteractionEnabled = false
        bottomFadeView.layer.addSublayer(gradientLayer)

        // 그라데이션 색상 설정: 하단은 완전한 배경색, 상단은 투명
        gradientLayer.colors = [
            UIColor(hex: "#281914").withAlphaComponent(0.0).cgColor, // 상단: 투명
            UIColor(hex: "#281914").cgColor  // 하단: 완전한 배경색
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0) // 상단에서 시작
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)   // 하단으로 끝
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // gradientLayer의 frame을 bottomFadeView에 맞춰 업데이트
        gradientLayer.frame = bottomFadeView.bounds
    }
}
