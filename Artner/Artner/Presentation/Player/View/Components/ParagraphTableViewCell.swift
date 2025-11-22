//
//  ParagraphTableViewCell.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//
import UIKit
import SnapKit

/// 문단을 표시하는 테이블뷰 셀
final class ParagraphTableViewCell: UITableViewCell {
    
    let paragraphTextView = NonEditableTextView()  // 커스텀 TextView 사용
    
    // 하이라이트 관련 프로퍼티
    private var paragraph: DocentParagraph?
    private var highlights: [TextHighlight] = []
    
    // 하이라이트 저장 콜백
    var onHighlightSaved: ((TextHighlight) -> Void)?
    var onHighlightDeleted: ((TextHighlight) -> Void)?
    
    // MARK: - UX 개선 프로퍼티 추가
    
    // 터치 상태 관리
    private var canHighlight: Bool = false
    private var isActiveCell: Bool = false
    
    // 시각적 피드백 뷰들
    private let touchIndicatorView = UIView()
    private let highlightPreviewView = UIView()
    private let highlightStatusBar = UIView()  // 상단 상태바로 변경
    
    // 터치 추적
    private var touchStartLocation: CGPoint = .zero
    private var currentTouchLocation: CGPoint = .zero
    private var isTrackingTouch: Bool = false
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        print("♻️ [Cell] prepareForReuse - 셀 상태 초기화")
        
        // 터치 상태 초기화
        isTrackingTouch = false
        canHighlight = false
        isActiveCell = false
        
        // 하이라이트 배열 초기화
        highlights = []
        
        // 시각적 피드백 초기화
        touchIndicatorView.isHidden = true
        highlightPreviewView.isHidden = true
        highlightStatusBar.isHidden = true
        
        // 텍스트뷰 초기화
        paragraphTextView.text = ""
        paragraphTextView.isHighlightEnabled = false
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        // 시각적 피드백 뷰들 추가
        setupVisualFeedbackViews()
        
        contentView.addSubview(paragraphTextView)
        
        // UITextView 기본 설정
        paragraphTextView.backgroundColor = .clear
        paragraphTextView.textAlignment = .left
        paragraphTextView.isScrollEnabled = false  // 스크롤 비활성화
        paragraphTextView.isSelectable = true      // 텍스트 선택 활성화
        paragraphTextView.isEditable = false      // 편집 비활성화
        paragraphTextView.isUserInteractionEnabled = true
        
        // 상호작용 요소 완전 비활성화 (Unknown interactable item 에러 방지)
        paragraphTextView.dataDetectorTypes = []    // 데이터 검출 비활성화
        paragraphTextView.linkTextAttributes = [:] // 링크 속성 제거
        
        // 키보드 관련 설정 (커스텀 클래스에서 처리되지만 명시적으로 설정)
        paragraphTextView.autocorrectionType = .no
        paragraphTextView.autocapitalizationType = .none
        paragraphTextView.spellCheckingType = .no
        paragraphTextView.smartQuotesType = .no
        paragraphTextView.smartDashesType = .no
        paragraphTextView.smartInsertDeleteType = .no
        
        // iOS 17+ 추가 설정
        if #available(iOS 17.0, *) {
            paragraphTextView.autocorrectionType = .no
            paragraphTextView.autocapitalizationType = .none
            paragraphTextView.spellCheckingType = .no
            paragraphTextView.smartQuotesType = .no
            paragraphTextView.smartDashesType = .no
            paragraphTextView.smartInsertDeleteType = .no
        }
        
        // 텍스트 스타일 기본 설정
        paragraphTextView.font = UIFont.systemFont(ofSize: 18)
        paragraphTextView.textColor = AppColor.textPrimary
        paragraphTextView.backgroundColor = .clear
        
        // 접근성 설정
        paragraphTextView.accessibilityLabel = "문단 텍스트"
        paragraphTextView.accessibilityHint = "텍스트를 길게 눌러서 하이라이트할 수 있습니다"
        paragraphTextView.accessibilityElementsHidden = false
        
        // 텍스트 선택 후 하이라이트 적용을 위한 메뉴 설정
        setupTextSelection()
        
        // 추가 설정: 텍스트가 잘리지 않도록
        paragraphTextView.setContentCompressionResistancePriority(.required, for: .vertical)
        paragraphTextView.setContentCompressionResistancePriority(.required, for: .horizontal)
        paragraphTextView.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        paragraphTextView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview().inset(20)
        }
        
        // 기본 iOS 텍스트 선택/편집 메뉴를 사용하므로 커스텀 제스처는 제거
    }
    
    // MARK: - 시각적 피드백 설정
    
    private func setupVisualFeedbackViews() {
        // 하이라이트 상태바 (상단에 표시되는 안내 바)
        setupHighlightStatusBar()
        
        // 터치 인디케이터 (현재 터치 위치 표시)
        touchIndicatorView.backgroundColor = AppColor.toastIcon.withAlphaComponent(0.8)
        touchIndicatorView.layer.cornerRadius = 8
        touchIndicatorView.isHidden = true
        contentView.addSubview(touchIndicatorView)
        
        touchIndicatorView.snp.makeConstraints {
            $0.width.height.equalTo(16)
        }
        
        // 하이라이트 프리뷰 (드래그 중 하이라이트 영역 미리보기)
        highlightPreviewView.backgroundColor = AppColor.highlightColor
        highlightPreviewView.layer.cornerRadius = 4
        highlightPreviewView.isHidden = true
        contentView.insertSubview(highlightPreviewView, belowSubview: paragraphTextView)
    }
    
    private func setupHighlightStatusBar() {
        // 상태바 컨테이너 설정
        highlightStatusBar.backgroundColor = AppColor.toastBackground.withAlphaComponent(0.95)
        highlightStatusBar.layer.cornerRadius = 8
        highlightStatusBar.isHidden = true
        contentView.addSubview(highlightStatusBar)
        
        // 상태바 레이블
        let statusLabel = UILabel()
        statusLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        statusLabel.textColor = AppColor.toastText
        statusLabel.text = "길게 눌러서 드래그하여 하이라이트 영역을 선택하세요"
        statusLabel.textAlignment = .center
        statusLabel.numberOfLines = 1
        statusLabel.tag = 999 // 나중에 찾기 위한 태그
        
        highlightStatusBar.addSubview(statusLabel)
        
        // 상태바 제약조건
        highlightStatusBar.snp.makeConstraints {
            $0.top.equalToSuperview().inset(4)
            $0.leading.trailing.equalToSuperview().inset(12)
            $0.height.equalTo(32)
        }
        
        // 레이블 제약조건
        statusLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(12)
        }
    }
    
    // 커스텀 제스처 제거: 시스템 텍스트 선택/메뉴만 사용
    
    private func setupTextSelection() {
        // UITextView 델리게이트 설정
        paragraphTextView.delegate = self
        
        // iOS 버전별 메뉴 시스템 설정
        setupTextMenu()
    }
    
    private func setupTextMenu() {
        // iOS 16+ 새로운 메뉴 시스템 지원
        if #available(iOS 16.0, *) {
            setupModernTextMenu()
        } else {
            setupLegacyTextMenu()
        }
    }
    
    @available(iOS 16.0, *)
    private func setupModernTextMenu() {
        // 시스템 기본 편집 메뉴 사용. 별도 설정 불필요
    }
    
    // Long Press 방식으로 변경되어 더 이상 필요 없음
    private func setupLegacyTextMenu() {
        // 시스템 기본 메뉴 사용
    }
    
    @objc func highlightSelectedText() {
        guard let paragraph = self.paragraph,
              let selectedRange = paragraphTextView.selectedTextRange,
              !selectedRange.isEmpty,
              paragraphTextView.isSelectable,
              !paragraphTextView.isEditable else { // 편집 불가능 상태 확인
            return 
        }
        
        // 추가 안전성 검사: 텍스트뷰 상태 확인
        guard paragraphTextView.text.count > 0 else {
            return
        }
        
        // 선택된 텍스트 범위를 NSRange로 변환
        let startIndex = paragraphTextView.offset(from: paragraphTextView.beginningOfDocument, to: selectedRange.start)
        let endIndex = paragraphTextView.offset(from: paragraphTextView.beginningOfDocument, to: selectedRange.end)
        
        // 범위 검증 강화
        guard startIndex >= 0, 
              endIndex > startIndex, 
              endIndex <= paragraphTextView.text.count,
              startIndex < paragraphTextView.text.count else {
            return
        }
        
        // 안전한 문자열 추출
        let text = paragraphTextView.text
        let startTextIndex = text?.index(text!.startIndex, offsetBy: startIndex)
        let endTextIndex = text?.index(text!.startIndex, offsetBy: endIndex)
        
        // 인덱스 범위 재검증
        guard startTextIndex! < text!.endIndex, endTextIndex! <= text!.endIndex else {
            return
        }
        
        let selectedText = String(text![startTextIndex!..<endTextIndex!])

        // 빈 텍스트 체크
        guard !selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        
        // 하이라이트 모델 생성
        let highlight = TextHighlight(
            paragraphId: paragraph.id,
            startIndex: startIndex,
            endIndex: endIndex,
            highlightedText: selectedText
        )
        
        // 하이라이트 추가
        highlights.append(highlight)
        
        // 하이라이트 적용 (현재 스타일 유지)
        applyHighlights(textColor: paragraphTextView.textColor, font: paragraphTextView.font)
        
        // 선택 해제
        paragraphTextView.selectedTextRange = nil
        
        // 하이라이트 저장 콜백 호출
        onHighlightSaved?(highlight)
    }

    @objc func deleteSelectedHighlight() {
        guard let selectedRange = paragraphTextView.selectedTextRange else { return }
        let startIndex = paragraphTextView.offset(from: paragraphTextView.beginningOfDocument, to: selectedRange.start)
        let endIndex = paragraphTextView.offset(from: paragraphTextView.beginningOfDocument, to: selectedRange.end)
        if let target = highlights.first(where: { $0.startIndex <= endIndex && $0.endIndex >= startIndex }) {
            onHighlightDeleted?(target)
        }
    }
    
    // 하이라이트 설정 (외부에서 저장된 하이라이트 로드 시 사용)
    func setHighlights(_ highlights: [TextHighlight]) {
        print("📝 [Cell] setHighlights 호출됨 - 문단: \(paragraph?.id ?? "nil"), 하이라이트 개수: \(highlights.count)")
        self.highlights = highlights
        
        // NonEditableTextView에 하이라이트 정보 전달 (삭제 감지용)
        paragraphTextView.updateHighlights(highlights)
        
        // 현재 텍스트 스타일 유지하며 하이라이트 적용
        applyHighlights(textColor: paragraphTextView.textColor, font: paragraphTextView.font)
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        print("🔧 [Cell] canPerformAction 호출: \(action)")
        
        // 하이라이트 액션 (텍스트 선택 시에만 표시)
        if action == #selector(highlightSelectedText) {
            let hasSelection = paragraphTextView.selectedTextRange != nil && 
                              !paragraphTextView.selectedTextRange!.isEmpty
            let isSelectable = paragraphTextView.isSelectable
            
            print("🔧 [Cell] 하이라이트 액션 조건: hasSelection=\(hasSelection), isSelectable=\(isSelectable)")
            return hasSelection && isSelectable
        }
        
        // 복사 액션 허용
        if action == #selector(copy(_:)) {
            let hasSelection = paragraphTextView.selectedTextRange != nil && 
                              !paragraphTextView.selectedTextRange!.isEmpty
            return hasSelection
        }
        
        // 선택 관련 액션 허용
        if action == #selector(selectAll(_:)) {
            return paragraphTextView.isSelectable
        }
        
        // 다른 모든 액션 차단
        return false
    }
    
    // iOS 15 이하에서 메뉴 표시를 위한 추가 메서드
    override var canBecomeFirstResponder: Bool {
        return false // 셀은 First Responder가 되지 않도록 설정
    }
    
    // 메뉴 표시 시 호출되는 메서드
    override func becomeFirstResponder() -> Bool {
        // 셀은 First Responder가 되지 않고, 텍스트뷰만 First Responder가 되도록
        return false
    }
    
    // 텍스트 선택 상태 제어
    func setTextSelectionEnabled(_ enabled: Bool) {
        paragraphTextView.isSelectable = enabled
        paragraphTextView.isUserInteractionEnabled = true // 항상 터치는 가능하게
        
        if enabled {
            // 선택 활성화 시 First Responder로 설정 (메뉴 표시를 위해)
            paragraphTextView.becomeFirstResponder()
        } else {
            // 선택 비활성화 시 선택 상태 정리
            paragraphTextView.selectedTextRange = nil
            
            // 메뉴 숨김 (iOS 15 이하)
            if #unavailable(iOS 16.0) {
                UIMenuController.shared.setMenuVisible(false, animated: false)
            }
        }
        
        // 접근성 업데이트
        paragraphTextView.accessibilityHint = enabled ? 
            "텍스트를 길게 눌러서 하이라이트할 수 있습니다" : 
            "재생 중에는 텍스트 선택이 불가능합니다"
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // UITextView는 자동으로 크기 조정되므로 별도 처리 불필요
        // preferredMaxLayoutWidth는 UILabel에만 있는 속성이므로 제거
    }
    
    func configure(with paragraph: DocentParagraph, isHighlighted: Bool, canHighlight: Bool = false) {
        print("🔧 [Cell] configure 호출 - 문단: \(paragraph.id), isHighlighted: \(isHighlighted), canHighlight: \(canHighlight)")
        
        self.paragraph = paragraph
        
        // UX 개선: 터치 상태 업데이트
        self.canHighlight = canHighlight
        self.isActiveCell = isHighlighted
        
        print("🔧 [Cell] 현재 상태 - isActiveCell: \(self.isActiveCell), canHighlight: \(self.canHighlight)")
        
        // NonEditableTextView에 문단 ID 설정 (하이라이트 저장용)
        paragraphTextView.paragraphId = paragraph.id
        
        // 하이라이트 활성화 상태 설정 (현재 재생 중인 문단에서만 활성화)
        paragraphTextView.isHighlightEnabled = canHighlight
        
        // 하이라이트 생성 콜백 연결
        paragraphTextView.onHighlightCreated = { [weak self] highlight in
            self?.onHighlightSaved?(highlight)
        }
        
        // 하이라이트 삭제 콜백 연결
        paragraphTextView.onHighlightDeleted = { [weak self] highlight in
            self?.onHighlightDeleted?(highlight)
        }
        
        // 현재 스타일 설정
        let textColor: UIColor
        let font: UIFont
        let alpha: CGFloat
        
        if isHighlighted {
            // 현재 재생 중인 문단 - 밝고 크게
            textColor = AppColor.textPrimary
            font = UIFont.systemFont(ofSize: 18, weight: .semibold)
            alpha = 1.0
        } else {
            // 다른 문단들 - 약간 작고 흐리게
            textColor = AppColor.textPrimary
            font = UIFont.systemFont(ofSize: 18, weight: .regular)
            alpha = 0.35
        }
        
        // 텍스트 스타일 적용
        paragraphTextView.textColor = textColor
        paragraphTextView.font = font
        paragraphTextView.alpha = alpha
        
        // 하이라이트가 있다면 적용, 없다면 기본 텍스트 설정
        if highlights.isEmpty {
            paragraphTextView.text = paragraph.fullText
        } else {
            // 하이라이트 적용 시 현재 스타일 정보 전달
            applyHighlights(textColor: textColor, font: font)
        }
        
        // iOS 15 이하에서 메뉴 아이템 설정 - 전역에서 이미 설정됨
        
        // 애니메이션
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
        
        // 텍스트 설정 후 레이아웃 강제 갱신
        paragraphTextView.setNeedsLayout()
        paragraphTextView.layoutIfNeeded()
        setNeedsLayout()
        layoutIfNeeded()
        
        // UX 개선: 시각적 피드백 업데이트
        updateCellVisualState()
    }
    
    // MARK: - UX 개선 메서드들
    
    /// 셀의 시각적 상태 업데이트
    private func updateCellVisualState() {
        // 상태바 방식으로 변경하여 별도의 시각적 인디케이터 불필요
        // 모든 셀에서 터치를 받아서 적절한 피드백을 제공
        contentView.isUserInteractionEnabled = true
    }
    
    private func applyHighlights(textColor: UIColor? = nil, font: UIFont? = nil) {
        guard let paragraph = self.paragraph,
              !paragraph.fullText.isEmpty else { 
            return 
        }
        
        // 기본 AttributedString 생성
        let attributedText = NSMutableAttributedString(string: paragraph.fullText)
        
        // 현재 스타일 또는 기본 스타일 사용
        let currentTextColor = textColor ?? paragraphTextView.textColor ?? AppColor.textPrimary
        let currentFont = font ?? paragraphTextView.font ?? UIFont.systemFont(ofSize: 18)
        
        // 기본 텍스트 스타일 적용
        let fullRange = NSRange(location: 0, length: attributedText.length)
        
        // 안전한 속성 적용
        do {
            attributedText.addAttribute(.font, value: currentFont, range: fullRange)
            attributedText.addAttribute(.foregroundColor, value: currentTextColor, range: fullRange)
            
            // 상호작용 관련 속성 명시적 제거
            attributedText.removeAttribute(.link, range: fullRange)
            attributedText.removeAttribute(.attachment, range: fullRange)
            
        } catch {
        }
        
        // 모든 하이라이트 적용
        for (index, highlight) in highlights.enumerated() {
            let range = NSRange(location: highlight.startIndex, length: highlight.endIndex - highlight.startIndex)
            
            // 범위 검증 강화
            guard range.location >= 0,
                  range.length > 0,
                  range.location < attributedText.length,
                  range.location + range.length <= attributedText.length else {
                continue
            }
            
            // 안전한 하이라이트 배경 적용
            do {
                attributedText.addAttribute(
                    .backgroundColor, 
                    value: AppColor.highlightColor, // #A0581D with 45% opacity
                    range: range
                )
            } catch {
            }
        }
        
        // UI 업데이트는 메인 스레드에서
        DispatchQueue.main.async { [weak self] in
            self?.paragraphTextView.attributedText = attributedText
        }
    }
}

// MARK: - UITextViewDelegate

extension ParagraphTableViewCell: UITextViewDelegate {
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        // 텍스트 선택 상태 추적 및 메뉴 업데이트
        if #unavailable(iOS 16.0) {
            // iOS 15 이하에서 선택 상태 변경 시 메뉴 업데이트
            if let selectedRange = textView.selectedTextRange, !selectedRange.isEmpty {
                print("🔧 [TextView] 텍스트 선택됨, 메뉴 표시 시도")
                
                // 동적으로 메뉴 아이템 추가
                let menuController = UIMenuController.shared
                var items: [UIMenuItem] = []
                // 선택 구간에 기존 하이라이트가 있는지 검사
                let start = textView.offset(from: textView.beginningOfDocument, to: selectedRange.start)
                let end = textView.offset(from: textView.beginningOfDocument, to: selectedRange.end)
                let hasExisting = highlights.contains { $0.startIndex <= end && $0.endIndex >= start }
                if hasExisting {
                    items.append(UIMenuItem(title: "삭제", action: #selector(deleteSelectedHighlight)))
                } else {
                    items.append(UIMenuItem(title: "저장", action: #selector(highlightSelectedText)))
                }
                menuController.menuItems = items
                
                // 선택이 있을 때 메뉴 표시
                UIMenuController.shared.setMenuVisible(true, animated: true)
                
                print("🔧 [TextView] 메뉴 아이템 동적 추가 완료: \(menuController.menuItems?.count ?? 0)개")
            }
        }
    }
    
    @available(iOS 16.0, *)
    func textView(_ textView: UITextView, editMenuForCharactersIn range: NSRange, suggestedActions: [UIMenuElement]) -> UIMenu? {
        // 안전한 기본 액션만 유지
        let safe = suggestedActions.compactMap { element -> UIMenuElement? in
            guard let action = element as? UIAction else { return nil }
            let title = action.title.lowercased()
            if title.contains("copy") || title.contains("select") || title.contains("복사") || title.contains("선택") {
                return action
            }
            return nil
        }
        // 선택 구간에 기존 하이라이트가 있는지 검사하여 저장/삭제 중 하나만 노출
        let hasExisting = highlights.contains { $0.startIndex <= (range.location + range.length) && $0.endIndex >= range.location }
        let action: UIAction
        if hasExisting {
            action = UIAction(title: "삭제") { [weak self] _ in self?.deleteSelectedHighlight() }
        } else {
            action = UIAction(title: "저장") { [weak self] _ in self?.highlightSelectedText() }
        }
        return UIMenu(children: safe + [action])
    }
    
    // 모든 상호작용 차단 (링크, 첨부파일 등)
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange) -> Bool {
        return false // 첨부파일 상호작용 차단
    }
    
    func textView(_ textView: UITextView, shouldInteractWith textAttachment: NSTextAttachment, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false // iOS 10+ 첨부파일 상호작용 차단
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        return false // URL 상호작용 차단
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        return false // iOS 10+ URL 상호작용 차단
    }
    
    // 편집 방지를 위한 추가 delegate 메서드들
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        // 편집 시작 방지 (선택만 가능)
        return false
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        // 텍스트 변경 방지
        return false
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        // 편집 시작 시 즉시 종료
        textView.resignFirstResponder()
    }
}

// MARK: - UIEditMenuInteractionDelegate (iOS 16+)

@available(iOS 16.0, *)
extension ParagraphTableViewCell: UIEditMenuInteractionDelegate {
    
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, menuFor configuration: UIEditMenuConfiguration, suggestedActions: [UIMenuElement]) -> UIMenu? {
        
        // 텍스트가 선택되어 있고, 선택 가능한 상태일 때만 하이라이트 메뉴 추가
        let hasSelection = paragraphTextView.selectedTextRange != nil && 
                          !paragraphTextView.selectedTextRange!.isEmpty
        let isSelectable = paragraphTextView.isSelectable
        
        guard hasSelection && isSelectable else {
            return UIMenu(children: []) // 빈 메뉴 반환
        }
        
        // 기본 제공되는 액션들 중 안전한 것들만 필터링
        let safeActions = suggestedActions.filter { element in
            if let action = element as? UIAction {
                let title = action.title.lowercased()
                // 복사, 선택 관련 액션만 허용
                return title.contains("copy") || 
                       title.contains("select") ||
                       title.contains("복사") ||
                       title.contains("선택")
            }
            return false
        }
        
        // 하이라이트 액션 생성
        let highlightAction = UIAction(
            title: "🖍️ 하이라이트",
            image: UIImage(systemName: "highlighter"),
            handler: { [weak self] _ in
                self?.highlightSelectedText()
            }
        )
        
        // 안전한 액션들과 하이라이트 액션만 반환
        var finalActions = safeActions
        finalActions.append(highlightAction)
        
        return UIMenu(children: finalActions)
    }
    
    func editMenuInteraction(_ interaction: UIEditMenuInteraction, targetRectFor configuration: UIEditMenuConfiguration) -> CGRect {
        // 선택된 텍스트 영역을 반환
        guard let selectedRange = paragraphTextView.selectedTextRange else {
            return .zero
        }
        
        return paragraphTextView.firstRect(for: selectedRange)
    }
    
}
