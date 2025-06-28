//
//  ChatInputBar.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//

import UIKit

final class ChatInputBar: UIView {

    let textField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "무엇이 궁금하신가요?"
        tf.font = UIFont.systemFont(ofSize: 14)
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        tf.textColor = .white
        tf.layer.cornerRadius = 16
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        tf.leftViewMode = .always
        return tf
    }()

    let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "arrow.up.circle.fill"), for: .normal)
        button.tintColor = .white
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = AppColor.background
        addSubview(textField)
        addSubview(sendButton)

        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(12)
            $0.bottom.equalToSuperview().inset(12)
        }

        sendButton.snp.makeConstraints {
            $0.leading.equalTo(textField.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(textField)
            $0.width.height.equalTo(24)
        }
    }
}
