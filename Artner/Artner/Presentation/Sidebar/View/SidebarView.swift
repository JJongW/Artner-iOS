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
    let aiSettingsStack = UIStackView()
    let aiDocentSeparator = UIView()
    // 쉬운 말 모드
    let easyModeTitleLabel = UILabel()
    let easyModeDescLabel = UILabel()
    let easyModeSwitch = UISwitch()
    // 뷰어 설정
    let viewerTitleLabel = UILabel()
    let fontSizeSlider = UISlider()
    let lineSpacingSlider = UISlider()
    let bottomMenuStackView = UIStackView()
    let bottomMenuSeparator = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.75)
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
        aiProfileImageView.layer.cornerRadius = 18
        aiProfileImageView.clipsToBounds = true
        aiProfileImageView.backgroundColor = .gray
        aiNameLabel.text = "친절한 애나"
        aiNameLabel.font = UIFont.systemFont(ofSize: 15, weight: .medium)
        aiNameLabel.textColor = .white
        aiArrow.tintColor = UIColor.white.withAlphaComponent(0.7)
        aiSettingsStack.axis = .horizontal
        aiSettingsStack.spacing = 16
        aiSettingsStack.distribution = .fillEqually
        aiDocentSeparator.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        // 쉬운 말 모드
        easyModeTitleLabel.text = "쉬운 말 모드"
        easyModeTitleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        easyModeTitleLabel.textColor = .white
        easyModeDescLabel.text = "단어와 표현을 쉽게 풀어서 이야기 해줍니다."
        easyModeDescLabel.font = UIFont.systemFont(ofSize: 12)
        easyModeDescLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        // 뷰어 설정
        viewerTitleLabel.text = "뷰어 설정"
        viewerTitleLabel.font = UIFont.boldSystemFont(ofSize: 15)
        viewerTitleLabel.textColor = .white
        bottomMenuSeparator.backgroundColor = UIColor.white.withAlphaComponent(0.2)

        // 하단 메뉴 스택
        bottomMenuStackView.axis = .vertical
        bottomMenuStackView.spacing = 16
    }
    private func setupLayout() {
        addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(closeButton)
        contentView.addSubview(nameLabel)
        contentView.addSubview(statContainerView)
        statContainerView.addSubview(statStackView)
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
        aiDocentContainer.addSubview(aiSettingsStack)
        aiDocentContainer.addSubview(aiDocentSeparator)
        // 쉬운 말 모드
        contentView.addSubview(easyModeTitleLabel)
        contentView.addSubview(easyModeSwitch)
        contentView.addSubview(easyModeDescLabel)
        // 뷰어 설정
        contentView.addSubview(viewerTitleLabel)
        contentView.addSubview(fontSizeSlider)
        contentView.addSubview(lineSpacingSlider)
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
        statContainerView.snp.makeConstraints {
            $0.top.equalTo(nameLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        statStackView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(14)
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
        aiSettingsStack.snp.makeConstraints {
            $0.top.equalTo(aiDocentSeparator.snp.bottom).offset(12)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-12)
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
        // 뷰어 설정
        viewerTitleLabel.snp.makeConstraints {
            $0.top.equalTo(easyModeDescLabel.snp.bottom).offset(24)
            $0.leading.equalToSuperview().offset(20)
        }
        fontSizeSlider.snp.makeConstraints {
            $0.top.equalTo(viewerTitleLabel.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        lineSpacingSlider.snp.makeConstraints {
            $0.top.equalTo(fontSizeSlider.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
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
            $0.bottom.equalToSuperview().offset(-20)
        }
    }
} 