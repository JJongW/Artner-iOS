//
//  DocentTableViewCell.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

import UIKit
import SnapKit

final class DocentTableViewCell: UITableViewCell {

    // MARK: - UI Components

    private let containerView = UIView()
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let listenButton = UIButton(type: .system)
    private let likeButton = UIButton(type: .system)

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboard를 사용하지 않습니다.")
    }

    // MARK: - Setup
    private func setupUI() {
        backgroundColor = AppColor.background
        selectionStyle = .none

        contentView.addSubview(containerView)

        containerView.addSubview(thumbnailImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)
        containerView.addSubview(listenButton)
        containerView.addSubview(likeButton)

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 5

        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = AppColor.textPrimary

        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = AppColor.textSecondary
        subtitleLabel.numberOfLines = 2

        listenButton.setImage(UIImage(named: "ic_headphones"), for: .normal)
        listenButton.tintColor = AppColor.accentColor

        likeButton.setImage(UIImage(named: "ic_good"), for: .normal)
        likeButton.tintColor = AppColor.accentColor
    }

    private func setupLayout() {
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-16)
        }

        thumbnailImageView.snp.makeConstraints {
            $0.top.equalTo(containerView.snp.top)
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(130)
            $0.height.equalTo(112)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.top)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().inset(16)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(4)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.trailing.equalTo(titleLabel.snp.trailing)
        }

        listenButton.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(10)
            $0.leading.equalTo(titleLabel.snp.leading)
            $0.bottom.lessThanOrEqualToSuperview().inset(12)
        }

        likeButton.snp.makeConstraints {
            $0.leading.equalTo(listenButton.snp.trailing).offset(16)
            $0.centerY.equalTo(listenButton)
        }
    }

    // MARK: - Public Method
    func configure(thumbnail: UIImage?, title: String, subtitle: String) {
        thumbnailImageView.image = thumbnail
        titleLabel.text = title
        subtitleLabel.text = subtitle
    }
}
