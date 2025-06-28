//
//  BotMessageCell.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//

import UIKit
import SnapKit

final class BotMessageCell: UITableViewCell {

    // Clean Architecture: 뷰 계층을 명확하게 분리하고, 요구사항(프로필 이미지 아래에 말풍선 세로 쌓기)을 정확히 반영
    private let profileImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "ic_bot"))
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 16
        imageView.clipsToBounds = true
        return imageView
    }()

    private let bubbleLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.textInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        label.textColor = .white
        label.backgroundColor = AppColor.background
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        return label
    }()

    private let verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        stack.distribution = .fill
        return stack;
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // verticalStackView만 contentView에 추가
        contentView.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
    }

    // MARK: - Public Method
    func configure(messages: [String], showProfile: Bool, showDocentButton: Bool) {
        verticalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 프로필 이미지는 맨 위에, showProfile일 때만 add
        if showProfile {
            verticalStackView.addArrangedSubview(profileImageView)
        }

        // 여러 줄 답변을 각각 bubbleLabel로 세로 쌓기
        for message in messages {
            let label = PaddingLabel()
            label.textInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            label.textColor = .white
            label.backgroundColor = AppColor.background
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .left
            label.numberOfLines = 0
            label.layer.cornerRadius = 16
            label.clipsToBounds = true
            label.text = message
            verticalStackView.addArrangedSubview(label)
        }

        // 아무것도 추가되지 않았다면 최소 높이 보장
        if verticalStackView.arrangedSubviews.isEmpty {
            let empty = UIView()
            empty.snp.makeConstraints { $0.height.greaterThanOrEqualTo(44) }
            verticalStackView.addArrangedSubview(empty)
        }
    }
}
