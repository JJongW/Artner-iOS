//
//  PlayerView.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//
import UIKit
import SnapKit

final class PlayerView: BaseView {

    // MARK: - UI Components

    let customNavigationBar = CustomNavigationBar()
    let artnerPrimaryBar = ArtnerPrimaryBar()
    let scrollView = UIScrollView()
    private let stackView = UIStackView()
    let playButton = UIButton(type: .system)

    // MARK: - Setup

    override func setupUI() {
        super.setupUI()

        backgroundColor = AppColor.background

        addSubview(customNavigationBar)
        addSubview(artnerPrimaryBar)
        addSubview(scrollView)
        addSubview(playButton)

        scrollView.addSubview(stackView)

        scrollView.showsVerticalScrollIndicator = false
        scrollView.alwaysBounceVertical = true

        stackView.axis = .vertical
        stackView.spacing = 16
        stackView.alignment = .leading
        stackView.distribution = .equalSpacing

        playButton.setTitle("▶️ 재생", for: .normal)
        playButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
    }

    override func setupLayout() {
        super.setupLayout()

        customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        artnerPrimaryBar.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }

        scrollView.snp.makeConstraints {
            $0.top.equalTo(artnerPrimaryBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(playButton.snp.top).offset(-16)
        }

        stackView.snp.makeConstraints {
            $0.top.bottom.leading.trailing.equalToSuperview().inset(20)
            $0.width.equalTo(scrollView.snp.width).offset(-40)
        }

        playButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-20)
            $0.centerX.equalToSuperview()
        }
    }

    // MARK: - Public

    private var labelList: [UILabel] = []

    func setScripts(_ scripts: [DocentScript]) {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        labelList.removeAll()

        for script in scripts {
            let label = UILabel()
            label.text = script.text
            label.numberOfLines = 0
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = AppColor.textPrimary
            label.alpha = 0.5 // 기본은 반투명
            stackView.addArrangedSubview(label)
            labelList.append(label)
        }
    }

    func highlightScript(at index: Int) {
        for (i, label) in labelList.enumerated() {
            label.alpha = (i == index) ? 1.0 : 0.5
        }

        guard index < labelList.count else { return }
        let label = labelList[index]

        // 중앙으로 스크롤
        let targetOffset = label.frame.origin.y - (scrollView.frame.height / 2) + (label.frame.height / 2)
        let clampedOffset = max(0, min(targetOffset, scrollView.contentSize.height - scrollView.frame.height))

        scrollView.setContentOffset(CGPoint(x: 0, y: clampedOffset), animated: true)
    }
}
