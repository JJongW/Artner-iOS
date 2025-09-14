//
//  HomeBannerView.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

import UIKit
import SnapKit

final class HomeBannerView: BaseView {

    // MARK: - UI Components

    private let containerView = UIView()
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // MARK: - Setup
    override func setupUI() {
        super.setupUI()
        backgroundColor = AppColor.background

        addSubview(containerView)

        containerView.addSubview(backgroundImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)

        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.clipsToBounds = true

        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        subtitleLabel.numberOfLines = 1
    }

    override func setupLayout() {
        super.setupLayout()

        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(16)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }

        backgroundImageView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(26)
            $0.leading.trailing.equalToSuperview()  // ← 빠진 좌우 제약 조건 추가
            $0.height.equalTo(120)
            $0.bottom.equalToSuperview()
        }
    }

    // MARK: - Public Methods
    func configure(image: UIImage?, title: String, subtitle: String) {
        backgroundImageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
