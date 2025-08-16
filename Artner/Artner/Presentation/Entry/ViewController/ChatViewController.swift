//
//  ChatViewController.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//

import UIKit
import Combine

final class ChatViewController: BaseViewController<ChatViewModel, AppCoordinator>, UITableViewDataSource, UITableViewDelegate {

    private let chatView = ChatView()
    private var cancellables = Set<AnyCancellable>()

    override func loadView() {
        self.view = chatView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        chatView.tableView.dataSource = self
        chatView.tableView.delegate = self
        bindActions()
        bindViewModel()
        viewModel.startChatSequence()
    }
    private func bindViewModel() {
        viewModel.$chatItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.chatView.tableView.reloadData()
                self?.scrollToBottom()
            }
            .store(in: &cancellables)

        viewModel.onAllMessagesDisplayed = { [weak self] in
            self?.chatView.tableView.reloadData()
        }
    }

    private func bindActions() {
        chatView.chatInputBar.sendButton.addTarget(self, action: #selector(didTapSend), for: .touchUpInside)
        
        // CustomNavigationBar 뒤로가기 버튼 액션 연결
        chatView.onBackButtonTapped = { [weak self] in
            self?.coordinator.popViewController(animated: true)
        }
    }

    @objc private func didTapListen() {
        let docent = viewModel.getDocent()
        coordinator.showPlayer(docent: docent)
    }

    private func scrollToBottom() {
        let count = chatView.tableView.numberOfRows(inSection: 0)
        guard count > 0 else { return }
        let indexPath = IndexPath(row: count - 1, section: 0)
        chatView.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }

    @objc private func didTapSend() {
        guard let text = chatView.chatInputBar.textField.text, !text.isEmpty else { return }
        viewModel.userDidSend(message: text)
        chatView.chatInputBar.textField.text = nil
    }

    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.chatItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.chatItems[indexPath.row]
        switch item {
        case .user(let text):
            let cell = tableView.dequeueReusableCell(withIdentifier: "UserMessageCell", for: indexPath) as! UserMessageCell
            cell.setMessage(text)
            return cell
        case .bot(let text, let showProfile):
            let cell = tableView.dequeueReusableCell(withIdentifier: "BotMessageCell", for: indexPath) as! BotMessageCell
            cell.configure(messages: [text], showProfile: showProfile, showDocentButton: false)
            return cell
        case .docentButton:
            let cell = tableView.dequeueReusableCell(withIdentifier: "DocentButtonCell", for: indexPath) as! DocentButtonCell
            cell.docentButton.addTarget(self, action: #selector(didTapListen), for: .touchUpInside)
            return cell
        }
    }

    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 45
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.0001
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.0001
    }

    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.contentView.layoutMargins = UIEdgeInsets(top: 0, left: 0, bottom: 8, right: 0)
    }
}
