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
        setupTextFieldSettings()
        setupUserInfo()
    }
    
    /// 사용자 정보 설정
    private func setupUserInfo() {
        if let userName = TokenManager.shared.userName, !userName.isEmpty {
            entryView.updateUserName(userName)
        }
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
        
        // 키보드를 먼저 내리기
        entryView.textField.resignFirstResponder()
        
        // API 호출
        searchWithText(keyword: keyword)
    }
    
    /// 텍스트로 실시간 도슨트 API 호출
    private func searchWithText(keyword: String) {
        // APIService를 통해 API 호출
        APIService.shared.request(
            APITarget.realtimeDocent(inputText: keyword, inputImage: nil)
        ) { [weak self] (result: Result<RealtimeDocentResponseDTO, Error>) in
            guard let self = self else { return }
            
            // 검색 버튼 다시 활성화
            DispatchQueue.main.async {
                self.entryView.searchButton.isEnabled = true
            }
            
            switch result {
            case .success(let response):
                // 응답 데이터를 Docent 모델로 변환
                guard let docent = self.convertToDocent(from: response) else {
                    self.showErrorAlert(message: "검색 결과를 처리하는 데 실패했습니다.")
                    return
                }
                
                // 성공 토스트 표시
                ToastManager.shared.showSuccess("\(response.itemName) 정보를 가져왔습니다")
                
                // Chat 화면으로 이동
                DispatchQueue.main.async {
                    self.coordinator.showChat(docent: docent, keyword: keyword)
                }
                
            case .failure(let error):
                print("❌ 검색 API 실패: \(error.localizedDescription)")
                self.showErrorAlert(message: "검색에 실패했습니다.\n다시 시도해주세요.")
            }
        }
    }
    
    /// RealtimeDocentResponseDTO를 Docent 모델로 변환
    private func convertToDocent(from response: RealtimeDocentResponseDTO) -> Docent? {
        // 텍스트를 문장 단위로 분리 (마침표 기준)
        let sentences = response.text.components(separatedBy: ". ")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { sentence -> String in
                let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.hasSuffix(".") ? trimmed : trimmed + "."
            }
        
        // DocentScript 배열 생성 (각 문장에 시간 할당)
        let avgTimePerSentence: TimeInterval = 5.0 // 문장당 평균 5초
        var currentTime: TimeInterval = 0.0
        
        let docentScripts = sentences.map { sentence -> DocentScript in
            let script = DocentScript(startTime: currentTime, text: sentence)
            currentTime += avgTimePerSentence
            return script
        }
        
        // DocentParagraph 생성 (전체 텍스트를 하나의 문단으로)
        let paragraph = DocentParagraph(
            id: "p-\(response.audioJobId)",
            startTime: 0.0,
            endTime: currentTime,
            sentences: docentScripts
        )
        
        // Docent 생성
        let docent = Docent(
            id: response.audioJobId.hashValue, // audioJobId를 ID로 변환
            title: response.itemName,
            artist: response.itemType == "artist" ? response.itemName : "알 수 없음",
            description: String(response.text.prefix(200)) + "...", // 앞부분 200자만
            imageURL: "", // 이미지 URL은 아직 제공되지 않음
            audioURL: nil, // 오디오 URL은 나중에 audioJobId로 조회
            paragraphs: [paragraph]
        )
        
        return docent
    }
    
    /// 에러 알림 표시
    private func showErrorAlert(message: String) {
        DispatchQueue.main.async { [weak self] in
            let alert = UIAlertController(
                title: "오류",
                message: message,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self?.present(alert, animated: true)
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
        
        // Safe Area Bottom Inset을 고려하여 정확히 16pt 간격 유지
        let safeAreaBottom = view.safeAreaInsets.bottom
        let bottomOffset: CGFloat = keyboardHeight > 0 ? keyboardHeight - safeAreaBottom + 16 : 46

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
        let size: CGFloat = shrink ? 24 : 155
        let leadingOffset: CGFloat = 20

        // 모든 제약조건을 다시 생성하여 SnapKit 에러 방지
        entryView.blurredImageView.snp.remakeConstraints {
            $0.top.equalTo(entryView.customNavigationBar.snp.bottom).offset(20)
            $0.width.height.equalTo(size)
            
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
        
        textField.keyboardType = .default
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
