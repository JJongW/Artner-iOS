//
//  EntryViewController.swift
//  Artner
//
//  Created by 신종원 on 5/17/25.
//

import UIKit
import SnapKit

final class EntryViewController: BaseViewController<EntryViewModel, AppCoordinator> {

    private let entryView = EntryView()
    private var isKeyboardVisible = false

    override func loadView() {
        self.view = entryView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        setupKeyboardNotification()
        setupTapGestureToDismissKeyboard()
        setupTextFieldSettings() // RTI 에러 방지를 위한 안전한 설정
    }

    private func setupActions() {
        entryView.onBackButtonTapped = { [weak self] in
            self?.coordinator.popViewController(animated: true)
        }

        for case let button as UIButton in entryView.suggestionStack.arrangedSubviews {
            button.addTarget(self, action: #selector(didTapSuggestionButton(_:)), for: .touchUpInside)
        }

        entryView.searchButton.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
        
        // textField delegate 설정
        entryView.textField.delegate = self
        entryView.textField.returnKeyType = .search
    }

    @objc private func didTapSuggestionButton(_ sender: UIButton) {
        // 개행 문자 제거하여 텍스트 필드에 입력
        let cleanText = sender.currentTitle?.replacingOccurrences(of: "\n", with: " ") ?? ""
        entryView.textField.text = cleanText
    }

    @objc private func didTapSearchButton() {
        let keyword = entryView.textField.text?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        
        // 빈 문자열 검증
        guard !keyword.isEmpty else {
            print("⚠️ 검색어가 비어있습니다.")
            return
        }
        
        print("🔍 검색 요청: \(keyword)")
        
        // 검색 버튼 비활성화하여 중복 클릭 방지
        entryView.searchButton.isEnabled = false
        
        // 키보드를 먼저 내리고 UI 업데이트 완료 후 navigation 수행
        entryView.textField.resignFirstResponder()
        
        // 키보드 애니메이션이 완전히 끝나고 시스템이 안정화된 후 navigation 수행
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
            guard let self = self else { return }
            
            // Navigation 전에 한 번 더 Main Thread 안전성 확보
            DispatchQueue.main.async {
                self.coordinator.showChat(docent: self.viewModel.docent, keyword: keyword)
                // 검색 버튼 다시 활성화
                self.entryView.searchButton.isEnabled = true
            }
        }
    }

    private func setupKeyboardNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillChangeFrame(_:)),
            name: UIResponder.keyboardWillChangeFrameNotification,
            object: nil
        )
    }

    @objc private func keyboardWillChangeFrame(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrameEnd = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }

        let convertedFrame = view.convert(keyboardFrameEnd, from: nil)
        let keyboardHeight = view.bounds.height - convertedFrame.origin.y
        let bottomOffset: CGFloat = keyboardHeight > 0 ? keyboardHeight + 16 : 46 // 안전 영역 고려하여 46으로 조정

        entryView.textFieldBottomConstraint?.update(inset: bottomOffset)
        entryView.updateSuggestionSpacing(shrink: keyboardHeight > 0)
        updateBlurredImageView(shrink: keyboardHeight > 0)

        // 안전한 애니메이션 커브 처리
        let animationOptions: UIView.AnimationOptions = [.beginFromCurrentState, .allowUserInteraction]
        
        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: animationOptions,
                       animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func updateBlurredImageView(shrink: Bool) {
        let size: CGFloat = shrink ? 24 : 120
        let leadingOffset: CGFloat = shrink ? 20 : (view.bounds.width - size) / 2

        // 모든 제약조건을 다시 생성하여 SnapKit 에러 방지
        entryView.blurredImageView.snp.remakeConstraints {
            $0.top.equalTo(entryView.customNavigationBar.snp.bottom).offset(20)
            $0.width.height.equalTo(size).priority(.high)
            
            if shrink {
                // 키보드 올라올 때는 leading으로 이동
                $0.leading.equalToSuperview().offset(leadingOffset)
            } else {
                // 키보드 내려갈 때는 중앙으로
                $0.centerX.equalToSuperview()
            }
        }
    }

    private func setupTapGestureToDismissKeyboard() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }

    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    /// RTI 에러 방지를 위한 안전한 텍스트필드 설정 (viewDidLoad에서 호출)
    private func setupTextFieldSettings() {
        // 메인 스레드에서 확실히 실행되도록 보장
        assert(Thread.isMainThread, "setupTextFieldSettings는 메인 스레드에서만 실행되어야 합니다.")
        
        // 텍스트필드가 이미 초기화된 후 한번 더 안전하게 설정
        let textField = entryView.textField
        
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
        
        print("🔧 EntryViewController - 텍스트필드 RTI 안전 설정 완료")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // 화면을 떠나기 전 키보드 세션을 안전하게 종료 (RTI 에러 방지)
        entryView.textField.resignFirstResponder()
        view.endEditing(true)
    }
    
    deinit {
        // 키보드 알림 제거 (RTI 에러 방지)
        NotificationCenter.default.removeObserver(self)
        
        // 텍스트 필드 delegate 해제하여 메모리 누수 방지
        entryView.textField.delegate = nil
        
        print("🗑️ EntryViewController deinit - 리소스 정리 완료")
    }
}

// MARK: - UITextFieldDelegate
extension EntryViewController: UITextFieldDelegate {
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        // 입력 세션이 시작되기 전 안전성 확보
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        // RTI 세션 안정화를 위한 명시적 설정
        textField.reloadInputViews()
        
        // 이모지 검색 관련 RTI 에러 방지를 위한 추가 설정
        DispatchQueue.main.async {
            textField.inputAssistantItem.leadingBarButtonGroups = []
            textField.inputAssistantItem.trailingBarButtonGroups = []
        }
        
        print("📝 텍스트 필드 편집 시작")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Return 키를 누르면 검색 실행
        didTapSearchButton()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        // 입력 종료 시 세션 정리
        print("📝 텍스트 필드 편집 종료")
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // 안전한 입력 종료 허용
        return true
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
