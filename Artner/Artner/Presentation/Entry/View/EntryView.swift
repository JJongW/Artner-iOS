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
    let blurredImageView = UIImageView()
    let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    let greetingLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.numberOfLines = 1
        label.text = "안녕하세요, 앤젤리너스 커피님!"
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        label.numberOfLines = 0
        label.text = "작가의 이름이나 작품 명, 제작년도 등을\n자세히 적으면 더 구체적으로 설명해 드릴게요."
        return label
    }()
    let suggestionLabel: UILabel = {
        let label = UILabel()
        label.text = "이런 주제는 어떤가요?"
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    let suggestionStack: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.distribution = .fillEqually
        return stackView
    }()
    let textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "작품 또는 작가를 입력하세요."
        textField.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.layer.cornerRadius = 12
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        textField.leftViewMode = .always
        return textField
    }()
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

        blurredImageView.contentMode = .scaleAspectFit
        blurredImageView.clipsToBounds = true
        blurredImageView.addSubview(blurEffectView)

        ["작품 표현\n방식에 대해", "인상주의에\n대해", "인상주의에\n대해"].forEach { title in
            let button = UIButton()
            button.setTitle(title, for: .normal)
            button.titleLabel?.numberOfLines = 2
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 16)
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

        searchButton.setImage(UIImage(systemName: "magnifyingglass"), for: .normal)

        setupFadeLayer()
    }

    override func setupLayout() {
        super.setupLayout()

        scrollView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        customNavigationBar.snp.makeConstraints {
            $0.top.equalToSuperview().offset(0)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        blurredImageView.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom).offset(20)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(CGSize(width: 120, height: 120))
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
            suggestionTopConstraint = $0.top.equalTo(descriptionLabel.snp.bottom).offset(160).constraint
            $0.leading.equalTo(greetingLabel)
        }

        suggestionStack.snp.makeConstraints {
            $0.top.equalTo(suggestionLabel.snp.bottom).offset(12)
            $0.height.equalTo(105)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        textField.snp.makeConstraints {
            $0.top.equalTo(suggestionStack.snp.bottom).offset(24)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
            textFieldBottomConstraint = $0.bottom.equalToSuperview().inset(40).constraint
        }

        searchButton.snp.makeConstraints {
            $0.trailing.equalTo(textField.snp.trailing).inset(12)
            $0.centerY.equalTo(textField.snp.centerY)
        }
    }

    func updateSuggestionSpacing(shrink: Bool) {
        suggestionTopConstraint?.update(offset: shrink ? 40 : 160)
    }

    private func setupFadeLayer() {
        bottomFadeView.isUserInteractionEnabled = false
        bottomFadeView.layer.addSublayer(gradientLayer)

        gradientLayer.colors = [
            UIColor(hex: "#281914").cgColor,
            UIColor(hex: "#281914").withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
    }
}
