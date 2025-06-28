//
//  ChatView.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//

import UIKit
import SnapKit
import Combine

final class ChatView: BaseView {

    // MARK: - UI Components
    let customNavigationBar = CustomNavigationBar()

    let tableView: UITableView = {
        let tableView = UITableView()
        tableView.estimatedRowHeight = 60
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.backgroundColor = .clear
        tableView.contentInset = UIEdgeInsets(top: 12, left: 0, bottom: 12, right: 0)
        tableView.showsVerticalScrollIndicator = false
        tableView.register(UserMessageCell.self, forCellReuseIdentifier: "UserMessageCell")
        tableView.register(BotMessageCell.self, forCellReuseIdentifier: "BotMessageCell")
        tableView.register(DocentButtonCell.self, forCellReuseIdentifier: "DocentButtonCell")
        tableView.allowsSelection = false
        tableView.keyboardDismissMode = .interactive
        return tableView
    }()

    let chatInputBar = ChatInputBar()

    // MARK: - Callbacks
    var onBackButtonTapped: (() -> Void)?
    var didTapMenuButton: (() -> Void)?

    // MARK: - Setup
    override func setupUI() {
        backgroundColor = AppColor.background
        
        addSubview(tableView)
        addSubview(chatInputBar)
        addSubview(customNavigationBar)

        customNavigationBar.onBackButtonTapped = { [weak self] in
            self?.onBackButtonTapped?()
        }
        customNavigationBar.didTapMenuButton = { [weak self] in
            self?.didTapMenuButton?()
        }
    }

    override func setupLayout() {
        customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(chatInputBar.snp.top)
        }

        chatInputBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(60)
        }
    }
}
