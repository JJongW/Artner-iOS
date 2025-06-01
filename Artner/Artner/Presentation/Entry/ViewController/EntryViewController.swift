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
    }

    private func setupActions() {
        entryView.onBackButtonTapped = { [weak self] in
            self?.coordinator.popViewController(animated: true)
        }

        for case let button as UIButton in entryView.suggestionStack.arrangedSubviews {
            button.addTarget(self, action: #selector(didTapSuggestionButton(_:)), for: .touchUpInside)
        }

        entryView.searchButton.addTarget(self, action: #selector(didTapSearchButton), for: .touchUpInside)
    }

    @objc private func didTapSuggestionButton(_ sender: UIButton) {
        entryView.textField.text = sender.currentTitle
    }

    @objc private func didTapSearchButton() {
        let keyword = entryView.textField.text ?? ""
        print("🔍 검색 요청: \(keyword)")
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
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval,
              let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else { return }

        let convertedFrame = view.convert(keyboardFrameEnd, from: nil)
        let keyboardHeight = view.bounds.height - convertedFrame.origin.y
        let bottomOffset: CGFloat = keyboardHeight > 0 ? keyboardHeight + 16 : 40

        entryView.textFieldBottomConstraint?.update(inset: bottomOffset)
        entryView.updateSuggestionSpacing(shrink: keyboardHeight > 0)
        updateBlurredImageView(shrink: keyboardHeight > 0)

        UIView.animate(withDuration: duration,
                       delay: 0,
                       options: UIView.AnimationOptions(rawValue: curve << 16),
                       animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }

    private func updateBlurredImageView(shrink: Bool) {
        let size: CGFloat = shrink ? 24 : 120
        let leadingOffset: CGFloat = shrink ? 20 : (view.bounds.width - size) / 2

        entryView.blurredImageView.snp.remakeConstraints {
            $0.top.equalTo(entryView.customNavigationBar.snp.bottom).offset(20)
            $0.size.equalTo(CGSize(width: size, height: size))
            if shrink {
                $0.leading.equalToSuperview().offset(leadingOffset)
            } else {
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

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
