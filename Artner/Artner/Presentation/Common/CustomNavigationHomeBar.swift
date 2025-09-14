//
//  CustomNavigationHomeBar.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

import UIKit
import SnapKit

final class CustomNavigationHomeBar: BaseView {

    // MARK: - UI Components

    let rightButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_side_tap"), for: .normal)
        return button
    }()

    var didTapMenuButton: (() -> Void)?

    // MARK: - Setup

    override func setupUI() {
        super.setupUI()
        backgroundColor = AppColor.background

        addSubview(rightButton)

        rightButton.addTarget(self, action: #selector(didTapMenu), for: .touchUpInside)
    }

    override func setupLayout() {
        super.setupLayout()

        rightButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24) // 다른 네비게이션 바와 일관성을 위해 24x24 설정
        }
    }

    @objc private func didTapMenu() {
        didTapMenuButton?()
    }
}
