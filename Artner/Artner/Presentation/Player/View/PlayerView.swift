//
//  PlayerView.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//
import UIKit
import SnapKit
import UIKit
import SnapKit

final class PlayerView: BaseView {

    // MARK: - UI Components

    let customNavigationBar = CustomNavigationBar()
    let artnerPrimaryBar = ArtnerPrimaryBar()
    let scrollView = UIScrollView()
    let contentView = UIView()
    let artistLabel = UILabel()
    let descriptionLabel = UILabel()
    let playButton = UIButton(type: .system)

    private let fadeView = UIView()
    private let fadeLayer = CAGradientLayer()

    // MARK: - Setup
    override func setupUI() {
        super.setupUI()

        backgroundColor = AppColor.background

        addSubview(customNavigationBar)
        addSubview(artnerPrimaryBar)
        addSubview(scrollView)
        addSubview(fadeView)

        scrollView.addSubview(contentView)
        contentView.addSubview(artistLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(playButton)

        scrollView.showsVerticalScrollIndicator = false
        fadeView.isUserInteractionEnabled = false

        artistLabel.font = UIFont.systemFont(ofSize: 18)
        artistLabel.textColor = AppColor.textPrimary
        artistLabel.textAlignment = .left

        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = AppColor.textPrimary
        descriptionLabel.numberOfLines = 100
        descriptionLabel.textAlignment = .left

        playButton.setTitle("▶️ 재생", for: .normal)
        playButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)

        setupFadeLayer()
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
            $0.leading.trailing.bottom.equalToSuperview()
        }

        fadeView.snp.makeConstraints {
            $0.top.equalTo(artnerPrimaryBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        contentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
        }

        artistLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(30)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(artistLabel.snp.bottom).offset(20)
            $0.leading.trailing.equalToSuperview().inset(20)
        }

        playButton.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-30)
        }
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
        fadeLayer.frame = fadeView.bounds
    }
}
