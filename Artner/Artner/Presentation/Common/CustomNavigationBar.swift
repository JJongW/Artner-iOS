//
//  CustomNavigationBar.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import UIKit
import SnapKit

final class CustomNavigationBar: UIView {

    // MARK: - UI Components

    private let backButton: UIButton = {
        let button = UIButton()
        button.setTitle("←", for: .normal)
        button.layer.opacity = 0.2
        return button
    }()

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = AppColor.textPoint

        return label
    }()

    var onBackButtonTapped: (() -> Void)?

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

        addSubview(backButton)
        addSubview(titleLabel)

        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
    }

    @objc private func didTapBack() {
        onBackButtonTapped?()
    }

    // MARK: - Public Method

    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
