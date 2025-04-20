//
//  ArtnerPrimaryBar.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//


import UIKit
import SnapKit

final class ArtnerPrimaryBar: UIView {

    // MARK: - UI Components

    private let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 4
        stack.alignment = .leading
        return stack
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.textColor = AppColor.textPrimary

        return label
    }()

    private let subtitlteLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .left
        label.textColor = AppColor.textPrimary
        label.layer.opacity = 0.7
        return label
    }()

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = AppColor.background

        addSubview(stackView)
        stackView.addArrangedSubview(titleLabel)
        stackView.addArrangedSubview(subtitlteLabel)

        stackView.snp.makeConstraints {
            $0.width.equalToSuperview()
            $0.top.bottom.equalToSuperview().offset(16)
        }

        titleLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
        }
        subtitlteLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
        }
    }

    // MARK: - Public Method

    func setTitle(_ title: String, subtitle: String) {
        titleLabel.text = title
        subtitlteLabel.text = subtitle
    }
}
