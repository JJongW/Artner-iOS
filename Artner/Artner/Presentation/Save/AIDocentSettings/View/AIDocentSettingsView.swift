//
//  AIDocentSettingsView.swift
//  Artner
//
//  AI 도슨트 설정 화면 UI — AI 유형 + 슬라이더 말하기 설정

import UIKit
import SnapKit

final class AIDocentSettingsView: UIView {

    // MARK: - 네비게이션
    let backButton  = UIButton(type: .system)
    let titleLabel  = UILabel()

    // MARK: - 스크롤
    let scrollView  = UIScrollView()
    let contentView = UIView()

    // MARK: - AI 유형 셀
    let aiCellContainer    = UIView()
    let aiProfileImageView = UIImageView()
    let aiNameLabel        = UILabel()
    let aiArrowImage       = UIImageView(image: UIImage(systemName: "chevron.down"))
    let aiCellButton       = UIButton(type: .system)

    // MARK: - 구분선 (AI셀 하단 + 슬라이더 행 사이)
    let separatorLine    = UIView()   // AI셀 아래
    private let sliderSeparator1 = UIView()   // 길이 ↔ 속도
    private let sliderSeparator2 = UIView()   // 속도 ↔ 난이도

    // MARK: - 말하기 설정 헤더
    let speakingSectionLabel = UILabel()
    let resetButton          = UIButton(type: .system)

    // MARK: - 슬라이더 행 (길이 / 속도 / 난이도)
    let lengthRow     = SpeakingSliderRowView(
        title: "길이",
        iconName: nil,
        description: "도슨트의 분량을 설정합니다.\nN분의 분량의 설명을 들을 수 있습니다.",
        stepCount: 5
    )
    let speedRow      = SpeakingSliderRowView(
        title: "속도",
        iconName: "speaker.wave.1.fill",
        description: "도슨트가 말하는 속도입니다.",
        stepCount: 5
    )
    let difficultyRow = SpeakingSliderRowView(
        title: "난이도",
        iconName: nil,
        description: "사용자가 원하는 난이도로 설명합니다.",
        stepCount: 3
    )

    // MARK: - 저장하기 버튼 (스크롤 밖, 하단 고정)
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
        backgroundColor = .black

        // 뒤로가기
        backButton.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        backButton.tintColor = .white

        // 화면 제목
        titleLabel.text = "AI 도슨트 설정"
        titleLabel.font = .boldSystemFont(ofSize: 17)
        titleLabel.textColor = .white

        // 스크롤뷰
        scrollView.showsVerticalScrollIndicator = false

        // AI 셀 컨테이너
        aiCellContainer.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        aiCellContainer.layer.cornerRadius = 16

        // 프로필 이미지
        aiProfileImageView.layer.cornerRadius = 18
        aiProfileImageView.clipsToBounds = true
        aiProfileImageView.backgroundColor = UIColor(red: 0.55, green: 0.35, blue: 0.15, alpha: 1.0)
        aiProfileImageView.contentMode = .scaleAspectFill

        // AI 이름
        aiNameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        aiNameLabel.textColor = .white

        // 화살표
        aiArrowImage.tintColor = UIColor.white.withAlphaComponent(0.7)
        aiArrowImage.contentMode = .scaleAspectFit

        // 탭 투명 버튼
        aiCellButton.backgroundColor = .clear

        // 구분선 공통 스타일
        let separatorColor = UIColor.white.withAlphaComponent(0.15)
        separatorLine.backgroundColor    = separatorColor
        sliderSeparator1.backgroundColor = separatorColor
        sliderSeparator2.backgroundColor = separatorColor

        // 말하기 설정 헤더
        speakingSectionLabel.text = "말하기 설정"
        speakingSectionLabel.font = .boldSystemFont(ofSize: 16)
        speakingSectionLabel.textColor = .white

        // 초기화 버튼 — background:#222222, 텍스트/아이콘 흰색, 75×26, pill, 12px regular
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: "ic_refresh")
        config.imagePlacement = .trailing
        config.imagePadding = 4
        config.baseForegroundColor = .white
        config.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 10, bottom: 5, trailing: 10)
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { attrs in
            var out = attrs
            out.font = UIFont.systemFont(ofSize: 12, weight: .regular)
            return out
        }
        config.attributedTitle = AttributedString("초기화")
        var bg = UIBackgroundConfiguration.clear()
        bg.backgroundColor = UIColor(red: 0x22/255.0, green: 0x22/255.0, blue: 0x22/255.0, alpha: 1.0)
        bg.cornerRadius = 13
        config.background = bg
        resetButton.configuration = config

        // 저장하기 버튼
        saveButton.setTitle("저장하기", for: .normal)
        saveButton.setTitleColor(.white, for: .normal)
        saveButton.titleLabel?.font = .boldSystemFont(ofSize: 17)
        saveButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        saveButton.layer.cornerRadius = 14
    }

    private func setupLayout() {
        addSubview(backButton)
        addSubview(titleLabel)
        addSubview(scrollView)
        addSubview(saveButton)
        scrollView.addSubview(contentView)

        contentView.addSubview(aiCellContainer)
        aiCellContainer.addSubview(aiProfileImageView)
        aiCellContainer.addSubview(aiNameLabel)
        aiCellContainer.addSubview(aiArrowImage)
        aiCellContainer.addSubview(aiCellButton)

        contentView.addSubview(separatorLine)
        contentView.addSubview(speakingSectionLabel)
        contentView.addSubview(resetButton)
        contentView.addSubview(lengthRow)
        contentView.addSubview(sliderSeparator1)
        contentView.addSubview(speedRow)
        contentView.addSubview(sliderSeparator2)
        contentView.addSubview(difficultyRow)

        // 네비게이션
        backButton.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide).offset(12)
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(44)
        }
        titleLabel.snp.makeConstraints {
            $0.centerY.equalTo(backButton)
            $0.centerX.equalToSuperview()
        }

        // 저장하기 버튼 (하단 고정)
        saveButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-16)
            $0.height.equalTo(54)
        }

        // 스크롤뷰
        scrollView.snp.makeConstraints {
            $0.top.equalTo(backButton.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(saveButton.snp.top).offset(-12)
        }
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // AI 셀
        aiCellContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(64)
        }
        aiProfileImageView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.width.height.equalTo(36)
        }
        aiNameLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(aiProfileImageView.snp.trailing).offset(12)
        }
        aiArrowImage.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.height.equalTo(20)
        }
        aiCellButton.snp.makeConstraints { $0.edges.equalToSuperview() }

        // AI셀 하단 구분선 — aiCellContainer 하단에서 26pt
        separatorLine.snp.makeConstraints {
            $0.top.equalTo(aiCellContainer.snp.bottom).offset(26)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        // 말하기 설정 헤더 — separatorLine 하단에서 26pt
        speakingSectionLabel.snp.makeConstraints {
            $0.top.equalTo(separatorLine.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(20)
        }
        resetButton.snp.makeConstraints {
            $0.centerY.equalTo(speakingSectionLabel)
            $0.trailing.equalToSuperview().offset(-16)
            $0.width.equalTo(75)
            $0.height.equalTo(26)
        }

        // 길이 행 — speakingSectionLabel 하단에서 42pt
        lengthRow.snp.makeConstraints {
            $0.top.equalTo(speakingSectionLabel.snp.bottom).offset(42)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // 구분선1 — lengthRow 슬라이더 하단에서 26pt
        sliderSeparator1.snp.makeConstraints {
            $0.top.equalTo(lengthRow.slider.snp.bottom).offset(26)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        // 속도 행 — sliderSeparator1 하단에서 26pt
        speedRow.snp.makeConstraints {
            $0.top.equalTo(sliderSeparator1.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }

        // 구분선2 — speedRow 슬라이더 하단에서 26pt
        sliderSeparator2.snp.makeConstraints {
            $0.top.equalTo(speedRow.slider.snp.bottom).offset(26)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }

        // 난이도 행 — sliderSeparator2 하단에서 26pt
        difficultyRow.snp.makeConstraints {
            $0.top.equalTo(sliderSeparator2.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-32)
        }
    }
}

// MARK: - 슬라이더 행 컴포넌트

final class SpeakingSliderRowView: UIView {

    // MARK: - UI
    private let titleLabel   = UILabel()
    private let iconView     = UIImageView()
    let valueLabel           = UILabel()   // 오렌지 현재값 (VC에서 업데이트)
    private let descLabel    = UILabel()
    let slider               = UISlider()

    private let stepCount: Int

    // MARK: - Init
    init(title: String, iconName: String?, description: String, stepCount: Int) {
        self.stepCount = stepCount
        super.init(frame: .zero)
        titleLabel.text = title
        descLabel.text = description
        if let name = iconName {
            iconView.image = UIImage(systemName: name)
        }
        setupUI()
        setupLayout(hasIcon: iconName != nil)
    }
    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Setup

    private func setupUI() {
        let orange = UIColor(named: "MainOrange") ?? UIColor(red: 1.0, green: 0.486, blue: 0.153, alpha: 1.0)

        titleLabel.font = .boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white

        iconView.tintColor = UIColor.white.withAlphaComponent(0.8)
        iconView.contentMode = .scaleAspectFit

        valueLabel.font = .systemFont(ofSize: 15, weight: .medium)
        valueLabel.textColor = orange
        valueLabel.textAlignment = .right

        descLabel.font = .systemFont(ofSize: 13)
        descLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        descLabel.numberOfLines = 0

        slider.minimumValue = 0
        slider.maximumValue = Float(stepCount - 1)
        slider.tintColor = orange
        // 트랙 색상
        slider.minimumTrackTintColor = orange
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.2)
        // 커스텀 썸 — 28×28 원형, 오렌지 fill, 2.1px #FFFFFF80 border
        let thumbImage = makeSliderThumb(size: 28, fillColor: orange)
        slider.setThumbImage(thumbImage, for: .normal)
        slider.setThumbImage(thumbImage, for: .highlighted)
    }

    // MARK: - Helpers

    /// width/height이 `size`pt인 원형 슬라이더 썸 이미지 생성
    private func makeSliderThumb(size: CGFloat, fillColor: UIColor) -> UIImage {
        let dimension = CGSize(width: size, height: size)
        let renderer = UIGraphicsImageRenderer(size: dimension)
        return renderer.image { ctx in
            let rect = CGRect(origin: .zero, size: dimension)
            // 오렌지 fill
            fillColor.setFill()
            ctx.cgContext.fillEllipse(in: rect)
            // 2.1px #FFFFFF80 border
            let borderWidth: CGFloat = 2.1
            UIColor.white.withAlphaComponent(0.502).setStroke()
            ctx.cgContext.setLineWidth(borderWidth)
            let inset = borderWidth / 2
            ctx.cgContext.strokeEllipse(in: rect.insetBy(dx: inset, dy: inset))
        }
    }

    private func setupLayout(hasIcon: Bool) {
        addSubview(titleLabel)
        addSubview(iconView)
        addSubview(valueLabel)
        addSubview(descLabel)
        addSubview(slider)

        if hasIcon {
            iconView.snp.makeConstraints {
                $0.top.equalToSuperview()
                $0.leading.equalTo(titleLabel.snp.trailing).offset(6)
                $0.width.height.equalTo(18)
                $0.centerY.equalTo(titleLabel)
            }
        }

        titleLabel.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        valueLabel.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(hasIcon ? iconView.snp.trailing : titleLabel.snp.trailing).offset(8)
        }
        descLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalToSuperview()
        }
        slider.snp.makeConstraints {
            $0.top.equalTo(descLabel.snp.bottom).offset(12)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
    }
}
