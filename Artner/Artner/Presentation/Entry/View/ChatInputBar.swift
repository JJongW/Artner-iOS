//
//  ChatInputBar.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//

import UIKit

final class ChatInputBar: UIView {

    private var _textField: UITextField?
    var textField: UITextField {
        if let textField = _textField {
            return textField
        }
        
        // 메인 스레드에서만 UITextField 초기화 (스레드 안전성 보장)
        assert(Thread.isMainThread, "UITextField는 메인 스레드에서만 초기화되어야 합니다.")
        
        let tf = UITextField()
        
        // 기본 텍스트 설정
        tf.placeholder = "무엇이 궁금하신가요?"
        tf.font = UIFont.systemFont(ofSize: 15) // 높이에 맞춰 폰트 크기 조정
        tf.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        tf.textColor = .white
        tf.layer.cornerRadius = 20 // 높이에 맞춰 조정 (40의 절반)
        
        // placeholder 색상 설정
        tf.attributedPlaceholder = NSAttributedString(
            string: "무엇이 궁금하신가요?",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.6)]
        )
        
        // 패딩 설정
        tf.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.leftViewMode = .always
        tf.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        tf.rightViewMode = .always
        
        // 자동완성 패널 관련 문제 방지
        tf.textContentType = .none
        
        // RTI 에러 방지를 위한 키보드 속성 설정 (직접 설정)
        tf.keyboardType = .asciiCapable  // 이모지 키보드 완전 비활성화
        tf.returnKeyType = .send
        tf.autocapitalizationType = .sentences
        tf.autocorrectionType = .no      // 자동완성 완전 비활성화
        tf.spellCheckingType = .no       // 맞춤법 검사 비활성화
        tf.smartDashesType = .no         // 스마트 대시 비활성화
        tf.smartQuotesType = .no         // 스마트 따옴표 비활성화
        tf.smartInsertDeleteType = .no   // 스마트 삽입/삭제 비활성화
        
        // 이모지 관련 RTI 에러 방지 설정
        if #available(iOS 15.0, *) {
            tf.keyboardLayoutGuide.followsUndockedKeyboard = false
        }
        
        // 이모지 검색 기능으로 인한 RTI 에러 방지
        tf.inputAssistantItem.leadingBarButtonGroups = []
        tf.inputAssistantItem.trailingBarButtonGroups = []
        tf.inputAssistantItem.allowsHidingShortcuts = true
        
        _textField = tf
        return tf
    }

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
            $0.top.equalToSuperview().offset(10)
            $0.bottom.equalToSuperview().inset(10)
            $0.height.equalTo(40) // 높이 명시적 지정
        }

        sendButton.snp.makeConstraints {
            $0.leading.equalTo(textField.snp.trailing).offset(8)
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalTo(textField)
            $0.width.height.equalTo(24)
        }
    }
}
