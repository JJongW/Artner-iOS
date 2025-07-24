//
//  SidebarStatButton.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//
//  Clean Architecture: 통계 버튼(좋아요/저장/밑줄/전시기록) 역할 분리, 재사용성 강화

import UIKit
import SnapKit

final class SidebarStatButton: UIControl {
    let iconView = UIImageView()
    let titleLabel = UILabel()
    let countLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        iconView.contentMode = .scaleAspectFit
        iconView.tintColor = UIColor.white.withAlphaComponent(0.7)
        titleLabel.font = UIFont.systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = UIColor.white.withAlphaComponent(0.7)
        countLabel.font = UIFont.boldSystemFont(ofSize: 15)
        countLabel.textColor = UIColor.white
        addSubview(iconView)
        addSubview(titleLabel)
        addSubview(countLabel)
    }
    private func setupLayout() {
        iconView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.centerX.equalToSuperview()
            $0.width.height.equalTo(24)
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(iconView.snp.bottom).offset(4)
            $0.centerX.equalToSuperview()
        }
        countLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-8)
        }
    }
    func configure(icon: UIImage?, title: String, count: Int) {
        iconView.image = icon
        titleLabel.text = title
        countLabel.text = "\(count)"
    }
} 