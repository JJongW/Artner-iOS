//
//  ChatViewController.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//

import UIKit
import Combine

final class ChatViewController: BaseViewController<ChatViewModel, AppCoordinator>, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {

    private let chatView = ChatView()
    private var cancellables = Set<AnyCancellable>()
    private var keyboardHeight: CGFloat = 0

    override func loadView() {
        self.view = chatView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        chatView.tableView.dataSource = self
        chatView.tableView.delegate = self
        chatView.chatInputBar.textField.delegate = self
        setupKeyboardNotifications()
        bindActions()
        bindViewModel()
        setupTextFieldSettings() // RTI 에러 방지를 위한 안전한 설정
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // 화면이 완전히 나타난 후 채팅 시퀀스 시작
        DispatchQueue.main.async { [weak self] in
            self?.viewModel.startChatSequence()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 화면을 떠나기 전 키보드 세션을 안전하게 종료 (RTI 에러 방지)
        chatView.chatInputBar.textField.resignFirstResponder()
        view.endEditing(true)
    }
    
    deinit {
        // 키보드 알림 제거 (RTI 에러 방지)
        NotificationCenter.default.removeObserver(self)
        
        // 텍스트 필드 delegate 해제하여 메모리 누수 방지
        chatView.chatInputBar.textField.delegate = nil
        
        print("🗑️ ChatViewController deinit - 리소스 정리 완료")
    }
    
    /// RTI 에러 방지를 위한 안전한 텍스트필드 설정 (viewDidLoad에서 호출)
    private func setupTextFieldSettings() {
        // 메인 스레드에서 확실히 실행되도록 보장
        assert(Thread.isMainThread, "setupTextFieldSettings는 메인 스레드에서만 실행되어야 합니다.")
        
        // 텍스트필드가 이미 초기화된 후 한번 더 안전하게 설정
        let textField = chatView.chatInputBar.textField
        
        // RTI 에러 방지를 위한 키보드 설정 재확인
        textField.keyboardType = .asciiCapable
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        textField.smartDashesType = .no
        textField.smartQuotesType = .no
        textField.smartInsertDeleteType = .no
        
        // 이모지 관련 RTI 에러 방지 설정 재확인
        textField.inputAssistantItem.leadingBarButtonGroups = []
        textField.inputAssistantItem.trailingBarButtonGroups = []
        textField.inputAssistantItem.allowsHidingShortcuts = true
        
        if #available(iOS 15.0, *) {
            textField.keyboardLayoutGuide.followsUndockedKeyboard = false
        }
        
        print("🔧 ChatViewController - 텍스트필드 RTI 안전 설정 완료")
    }
    
    private func setupKeyboardNotifications() {
        // 키보드 이벤트 알림 등록 (RTI 에러 방지를 위한 적절한 키보드 처리)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow(_:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide(_:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidShow(_:)),
            name: UIResponder.keyboardDidShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardDidHide(_:)),
            name: UIResponder.keyboardDidHideNotification,
            object: nil
        )
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        keyboardHeight = keyboardFrame.height
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.adjustTableViewForKeyboard(show: true)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) { [weak self] in
            self?.adjustTableViewForKeyboard(show: false)
        }
    }
    
    @objc private func keyboardDidShow(_ notification: Notification) {
        // 키보드가 완전히 표시된 후 스크롤 위치 조정
        scrollToBottom()
    }
    
    @objc private func keyboardDidHide(_ notification: Notification) {
        keyboardHeight = 0
    }
    
    private func adjustTableViewForKeyboard(show: Bool) {
        let bottomInset = show ? keyboardHeight : 0
        chatView.tableView.contentInset.bottom = bottomInset
        chatView.tableView.verticalScrollIndicatorInsets.bottom = bottomInset
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
    
    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Return 키를 눌렀을 때 메시지 전송 (RTI 에러 방지를 위한 적절한 처리)
        if textField == chatView.chatInputBar.textField {
            didTapSend()
        }
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // 이모지 검색 관련 RTI 에러 방지를 위한 입력 도구 재설정
        textField.reloadInputViews()
        
        // 이모지 검색 관련 RTI 에러 방지를 위한 추가 설정
        DispatchQueue.main.async {
            textField.inputAssistantItem.leadingBarButtonGroups = []
            textField.inputAssistantItem.trailingBarButtonGroups = []
        }
        
        // 편집 시작 시 스크롤을 최하단으로 이동
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.scrollToBottom()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 편집 종료 시 키보드 세션 정리 (RTI 에러 방지)
        textField.resignFirstResponder()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // RTI 에러 방지를 위한 추가 검증
        // null selector 에러 방지를 위한 안전한 텍스트 처리
        
        // 이모지나 특수 문자 입력 시 RTI 에러가 발생할 수 있으므로 안전하게 처리
        guard !string.isEmpty || range.length > 0 else { return true }
        
        // 입력 어시스턴트 아이템 재설정 (null selector 방지)
        DispatchQueue.main.async {
            textField.inputAssistantItem.leadingBarButtonGroups = []
            textField.inputAssistantItem.trailingBarButtonGroups = []
        }
        
        return true
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        // 텍스트 클리어 시에도 RTI 세션 안정화
        DispatchQueue.main.async {
            textField.reloadInputViews()
        }
        return true
    }
}
