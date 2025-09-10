//
//  UserMessageCell.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//

import UIKit
import SnapKit

final class UserMessageCell: UITableViewCell {

    private let messageLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.textInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        label.backgroundColor = UIColor(hex: "#FF7A00")
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .left
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        return label
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        selectionStyle = .none

        contentView.addSubview(messageLabel)
        messageLabel.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(8)
            $0.trailing.equalToSuperview().inset(20)
            $0.width.lessThanOrEqualTo(250)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setMessage(_ text: String) {
        messageLabel.text = text
    }
}
