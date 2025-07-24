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

    let backButton: UIButton = {
        let button = UIButton()
        button.layer.opacity = 0.8
        button.setImage(UIImage(named: "ic_home"), for: .normal)
        return button
    }()

    let rightButton: UIButton = {
        let button = UIButton()
        button.layer.opacity = 0.8
        button.setImage(UIImage(named: "ic_side_tap"), for: .normal)
        return button
    }()

    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = AppColor.textPoint

        return label
    }()

    var onBackButtonTapped: (() -> Void)?
    var didTapMenuButton: (() -> Void)?

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
        addSubview(rightButton)

        rightButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)

        backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)

        backButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
        }

        titleLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }

        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
        }
    }

    @objc func didTapBack() {
        onBackButtonTapped?()
    }
    @objc private func didTapMenu() {
        didTapMenuButton?()
    }

    // MARK: - Public Method

    func setTitle(_ title: String) {
        titleLabel.text = title
    }
}
