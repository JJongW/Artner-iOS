//
//  AIDocentSelectionView.swift
//  Artner
//
//  AI 도슨트 변경 모달의 UI 컴포넌트

import UIKit
import SnapKit

final class AIDocentSelectionView: UIView {

    // MARK: - UI Components

    let titleLabel = UILabel()
    let closeButton = UIButton(type: .system)
    let stackView = UIStackView()
    let saveButton = UIButton(type: .system)

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = UIColor(red: 0.17, green: 0.17, blue: 0.17, alpha: 1.0) // #2C2C2C
        layer.cornerRadius = 20
        layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        clipsToBounds = true

        // 타이틀
        titleLabel.text = "AI 도슨트 변경"
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textColor = .white

        // 닫기 버튼
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.tintColor = UIColor.white.withAlphaComponent(0.7)

        // AI 셀 스택
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.distribution = .fill

        // 저장하기 버튼
        saveButton.setTitle("저장하기", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17)
        saveButton.backgroundColor = UIColor(named: "MainOrange") ?? UIColor(red: 1.0, green: 0.486, blue: 0.153, alpha: 1.0)
        saveButton.layer.cornerRadius = 14
    }

    private func setupLayout() {
        addSubview(titleLabel)
        addSubview(closeButton)
        addSubview(stackView)
        addSubview(saveButton)

        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(24)
            $0.leading.equalToSuperview().offset(24)
        }

        closeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().offset(-20)
            $0.width.height.equalTo(32)
        }

        stackView.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        saveButton.snp.makeConstraints {
            $0.top.equalTo(stackView.snp.bottom).offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(54)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
        }
    }
}

// MARK: - AI 셀 뷰

final class AIDocentCellView: UIView {

    // MARK: - Properties
    let aiType: AIDocentSettingsViewModel.AIDocentType
    private(set) var isSelected: Bool = false

    // MARK: - UI
    private let profileImageView = UIImageView()
    private let nameLabel = UILabel()
    private let descLabel = UILabel()

    // MARK: - Init
    init(aiType: AIDocentSettingsViewModel.AIDocentType) {
        self.aiType = aiType
        super.init(frame: .zero)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.07)
        layer.cornerRadius = 14
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor

        // 프로필 이미지
        profileImageView.layer.cornerRadius = 18
        profileImageView.clipsToBounds = true
        profileImageView.backgroundColor = UIColor(red: 0.4, green: 0.3, blue: 0.2, alpha: 1.0)
        profileImageView.contentMode = .scaleAspectFill

        // 이름
        nameLabel.text = aiType.displayName
        nameLabel.font = UIFont.boldSystemFont(ofSize: 16)
        nameLabel.textColor = .white

        // 설명
        descLabel.text = aiType.description
        descLabel.font = UIFont.systemFont(ofSize: 13)
        descLabel.textColor = UIColor.white.withAlphaComponent(0.6)
        descLabel.numberOfLines = 2
    }

    private func setupLayout() {
        addSubview(profileImageView)
        addSubview(nameLabel)
        addSubview(descLabel)

        profileImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(16)
            $0.width.height.equalTo(36)
        }

        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(profileImageView.snp.trailing).offset(12)
            $0.top.equalTo(profileImageView)
            $0.trailing.equalToSuperview().offset(-16)
        }

        descLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(6)
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    // MARK: - Selection State

    func setSelected(_ selected: Bool) {
        isSelected = selected
        let orange = UIColor(named: "MainOrange") ?? UIColor(red: 1.0, green: 0.486, blue: 0.153, alpha: 1.0)
        layer.borderColor = selected ? orange.cgColor : UIColor.clear.cgColor
        backgroundColor = selected
            ? orange.withAlphaComponent(0.08)
            : UIColor.white.withAlphaComponent(0.07)
    }
}
