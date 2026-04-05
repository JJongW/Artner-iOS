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
    /// MP4 루프 재생 뷰 (56×56)
    let videoView = VideoLoopPlayerView()
    private let nameLabel = UILabel()
    private let descLabel = UILabel()

    // MARK: - Init
    init(aiType: AIDocentSettingsViewModel.AIDocentType) {
        self.aiType = aiType
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        configureVideo()
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = UIColor.white.withAlphaComponent(0.07)
        layer.cornerRadius = 14
        layer.borderWidth = 2
        layer.borderColor = UIColor.clear.cgColor

        // 비디오 뷰 — 둥근 모서리
        videoView.layer.cornerRadius = 12
        videoView.clipsToBounds = true
        videoView.backgroundColor = UIColor.white.withAlphaComponent(0.12)

        // AI 이름 — Bold 700, 20px, letter-spacing 5%
        let nameAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 20, weight: .bold),
            .foregroundColor: UIColor.white,
            .kern: 20.0 * 0.05   // 5%
        ]
        nameLabel.attributedText = NSAttributedString(string: aiType.displayName, attributes: nameAttrs)

        // 설명 — Regular 400, 16px, line-height 164%, letter-spacing -0.5%
        let para = NSMutableParagraphStyle()
        para.lineHeightMultiple = 1.64
        let descAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 16, weight: .regular),
            .foregroundColor: UIColor.white.withAlphaComponent(0.7),
            .kern: 16.0 * (-0.005),   // -0.5%
            .paragraphStyle: para
        ]
        descLabel.attributedText = NSAttributedString(string: aiType.description, attributes: descAttrs)
        descLabel.numberOfLines = 0
    }

    private func setupLayout() {
        addSubview(videoView)
        addSubview(nameLabel)
        addSubview(descLabel)

        // 비디오 — 56×56, 좌측 상단 고정
        videoView.snp.makeConstraints {
            $0.top.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(56)
        }

        // AI 이름 — videoView와 centerY, videoView trailing 기준
        nameLabel.snp.makeConstraints {
            $0.centerY.equalTo(videoView)
            $0.leading.equalTo(videoView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-16)
        }

        // 설명 — nameLabel 하단 10px, leading = videoView leading
        descLabel.snp.makeConstraints {
            $0.top.equalTo(videoView.snp.bottom).offset(10)
            $0.leading.equalTo(videoView)        // icon과 동일 leading
            $0.trailing.equalToSuperview().offset(-16)
            $0.bottom.equalToSuperview().offset(-16)
        }
    }

    private func configureVideo() {
        let resource = AIDocentSettingsViewModel.videoResource(for: aiType.personal)
        videoView.configure(resourceName: resource.name, fileExtension: resource.ext)
    }

    // MARK: - Selection State

    func setSelected(_ selected: Bool) {
        isSelected = selected
        let orange = UIColor(named: "MainOrange") ?? UIColor(red: 1.0, green: 0.486, blue: 0.153, alpha: 1.0)
        // border만 변경, 배경색은 고정
        layer.borderColor = selected ? orange.cgColor : UIColor.clear.cgColor
    }
}
