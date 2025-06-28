//
//  ChatViewModel.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//

import Foundation
import Combine

// 카카오톡 스타일: 한 셀 = 한 말풍선/버튼 구조로 변경
// Clean Architecture: UI/데이터 분리, 확장성/유지보수성 강화

enum ChatItem {
    case user(String)
    case bot(String, showProfile: Bool)
    case docentButton
}

final class ChatViewModel: ObservableObject {
    @Published private(set) var chatItems: [ChatItem] = []

    private let keyword: String
    private let docent: Docent
    private let botMessages: [String]
    var onAllMessagesDisplayed: (() -> Void)?

    init(keyword: String, docent: Docent) {
        self.keyword = keyword
        self.docent = docent
        self.botMessages = [
            "\(keyword)에 대해 설명할게요.",
            "\(docent.title)은 \(docent.artist)의 작품이에요.",
            "이제 도슨트를 들어보시겠어요?"
        ]
    }

    func startChatSequence() {
        userDidSend(message: keyword)
    }

    func userDidSend(message: String) {
        chatItems.append(.user(message))
        addBotMessages(botMessages)
    }

    func getDocent() -> Docent {
        return docent
    }

    // 카카오톡 스타일: 각 메시지/버튼을 하나의 row로 분리, 순차적으로 추가
    private func addBotMessages(_ messages: [String], current: Int = 0) {
        guard current < messages.count else {
            // 모든 메시지 추가 후 버튼만 마지막에 추가
            chatItems.append(.docentButton)
            onAllMessagesDisplayed?()
            return
        }
        chatItems.append(.bot(messages[current], showProfile: current == 0))
        // 1초 후 다음 메시지 추가
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            self.addBotMessages(messages, current: current + 1)
        }
    }
}
