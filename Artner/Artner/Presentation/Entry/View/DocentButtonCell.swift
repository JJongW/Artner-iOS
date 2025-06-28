//
//  DocentButtonCell.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//

import UIKit
import SnapKit

final class DocentButtonCell: UITableViewCell {

    // MARK: - UI Components
    let docentButton: UIButton = {
        let button = UIButton(type: .system)
        var config = UIButton.Configuration.filled()
        config.title = "도슨트 듣기"
        config.image = UIImage(named: "ic_headphones")
        config.imagePlacement = .leading
        config.imagePadding = 10
        config.contentInsets = NSDirectionalEdgeInsets(top: 11, leading: 16, bottom: 11, trailing: 16)
        config.baseBackgroundColor = UIColor.white.withAlphaComponent(0.1)
        config.baseForegroundColor = .white
        button.configuration = config
        button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 18
        button.clipsToBounds = true
        return button
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(docentButton)
        docentButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(8)
            $0.bottom.equalToSuperview().offset(-8)
            $0.leading.equalToSuperview().offset(16)
            $0.width.greaterThanOrEqualTo(120)
        }

        if let imageView = docentButton.imageView {
            imageView.snp.makeConstraints {
                $0.width.height.equalTo(24)
                $0.leading.equalToSuperview().offset(16)
                $0.top.equalToSuperview().offset(11)
            }
            imageView.alpha = 0.2
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
} 
