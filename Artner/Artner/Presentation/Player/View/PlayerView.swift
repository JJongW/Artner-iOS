//
//  PlayerView.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//
import UIKit
import SnapKit

final class PlayerView: UIView {

    // MARK: - UI Components

    let customNavigationBar = CustomNavigationBar()
    let artnerPrimaryBar = ArtnerPrimaryBar()
    let scrollView = UIScrollView()
    let contentView = UIView()
    let artistLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = AppColor.textPrimary
        label.textAlignment = .left
        return label
    }()
    let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = AppColor.textPrimary
        label.numberOfLines = 100
        label.textAlignment = .left
        return label
    }()
    let playButton = UIButton(type: .system)

    private let fadeView = UIView()
    private let fadeLayer = CAGradientLayer()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupFadeLayer()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = AppColor.background

        // 커스텀 네비게이션 바
        addSubview(customNavigationBar)

        customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        addSubview(artnerPrimaryBar)
        artnerPrimaryBar.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }

        // 스크롤뷰
        addSubview(scrollView)
        scrollView.snp.makeConstraints {
            $0.top.equalTo(artnerPrimaryBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        // 스크롤뷰 안에 contentView
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        // ContentView에 StackView 추가
        let stackView = UIStackView(arrangedSubviews: [
            artistLabel, descriptionLabel, playButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .leading

        contentView.addSubview(stackView)

        stackView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().offset(-16)
        }

        addSubview(fadeView)
        fadeView.isUserInteractionEnabled = false // 터치 막지 않게
        fadeView.backgroundColor = .clear

        fadeView.snp.makeConstraints {
            $0.top.equalTo(artnerPrimaryBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalToSuperview()
        }

        playButton.setTitle("▶️ 재생", for: .normal)
    }

    private func setupFadeLayer() {
        fadeLayer.colors = [
            AppColor.primary.withAlphaComponent(0.8).cgColor,
            AppColor.primary.withAlphaComponent(0.0).cgColor,
            AppColor.primary.withAlphaComponent(0.0).cgColor,
            AppColor.primary.withAlphaComponent(0.8).cgColor
        ]

        fadeLayer.locations = [0.0, 0.25, 0.75, 1.0]
        fadeLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        fadeLayer.endPoint = CGPoint(x: 0.5, y: 1.0)

        fadeView.layer.addSublayer(fadeLayer)
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        setGradientBackground(colors: [
            AppColor.primary, AppColor.secondary
        ])

        fadeLayer.frame = fadeView.bounds
    }
}
