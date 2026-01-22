//
//  NonEditableTextView.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//  Refactored: iOS 네이티브 텍스트 선택 방식으로 변경
//
import UIKit

/// 편집 불가능한 텍스트뷰 (iOS 네이티브 선택 방식)
/// - 정지 상태에서만 텍스트 선택 가능
/// - 선택한 텍스트를 하이라이트로 저장
final class NonEditableTextView: UITextView, UITextViewDelegate {

    // MARK: - Callbacks

    /// 하이라이트 생성 콜백 (TextHighlight 객체 전달)
    var onHighlightCreated: ((TextHighlight) -> Void)?

    /// 하이라이트 삭제 콜백 (삭제할 하이라이트 정보 전달)
    var onHighlightDeleted: ((TextHighlight) -> Void)?

    // MARK: - Properties

    /// 문단 ID (하이라이트 저장 시 필요)
    var paragraphId: String = ""

    /// 현재 적용된 하이라이트 목록
    private var currentHighlights: [TextHighlight] = []

    /// 텍스트 선택 가능 여부 (정지 상태에서만 true)
    var isSelectionAllowed: Bool = false {
        didSet {
            updateSelectionState()
        }
    }

    /// 하이라이트 색상 (디자인: #FF7C27 오렌지)
    private let highlightColor = UIColor(red: 255/255, green: 124/255, blue: 39/255, alpha: 0.4)

    /// 선택 완료 감지용 타이머 (debounce)
    private var selectionTimer: Timer?

    /// 마지막 선택 범위 (드래그 완료 감지용)
    private var lastSelectedRange: UITextRange?

    /// 선택 중인지 여부
    private var isSelecting: Bool = false

    // MARK: - Initialization

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupTextView()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupTextView()
    }

    private func setupTextView() {
        // 기본 설정
        self.isEditable = false
        self.isSelectable = false // 초기에는 선택 불가
        self.dataDetectorTypes = []
        self.delegate = self

        // 키보드 관련 비활성화
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.spellCheckingType = .no

        // 선택 색상 커스텀 (iOS 네이티브 선택 바 색상)
        self.tintColor = UIColor(red: 255/255, green: 124/255, blue: 39/255, alpha: 1.0)

        // 탭 제스처 추가 (하이라이트 삭제용)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.delegate = self
        self.addGestureRecognizer(tapGesture)
    }

    // MARK: - Selection State

    private func updateSelectionState() {
        self.isSelectable = isSelectionAllowed

        if !isSelectionAllowed {
            // 선택 불가 상태로 전환 시 현재 선택 해제
            self.selectedTextRange = nil
            selectionTimer?.invalidate()
            selectionTimer = nil
            isSelecting = false
        }

        print("📝 [TextView] 선택 상태 변경: \(isSelectionAllowed ? "선택 가능" : "선택 불가")")
    }

    // MARK: - Tap Handler (하이라이트 삭제)

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        guard isSelectionAllowed else { return }

        // 현재 선택 중이면 탭 무시 (선택 완료 대기)
        if let selected = selectedTextRange, !selected.isEmpty {
            return
        }

        let point = gesture.location(in: self)
        let characterIndex = layoutManager.characterIndex(
            for: point,
            in: textContainer,
            fractionOfDistanceBetweenInsertionPoints: nil
        )

        // 터치한 지점에 하이라이트가 있는지 확인
        if let highlightToDelete = findHighlight(at: characterIndex) {
            // 하이라이트 삭제
            deleteHighlightWithConfirmation(highlightToDelete)
        }
    }

    private func deleteHighlightWithConfirmation(_ highlight: TextHighlight) {
        // 하이라이트 삭제
        removeHighlight(highlight)
        onHighlightDeleted?(highlight)

        // 토스트 표시
        ToastManager.shared.showSimple("하이라이트가 삭제되었습니다")
        print("🗑️ [Tap] 하이라이트 삭제: \(highlight.highlightedText)")
    }

    // MARK: - UITextViewDelegate

    func textViewDidChangeSelection(_ textView: UITextView) {
        guard isSelectionAllowed else { return }

        // 기존 타이머 취소 (debounce)
        selectionTimer?.invalidate()

        // 선택된 텍스트가 있는지 확인
        guard let selectedRange = textView.selectedTextRange,
              !selectedRange.isEmpty else {
            isSelecting = false
            lastSelectedRange = nil
            return
        }

        isSelecting = true
        lastSelectedRange = selectedRange

        let selectedText = textView.text(in: selectedRange) ?? ""

        // 선택된 텍스트가 의미 있는 길이일 때만 처리
        if selectedText.count >= 2 {
            // 선택이 1.5초 동안 변경되지 않으면 저장 (드래그 완료로 간주)
            selectionTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { [weak self] _ in
                guard let self = self else { return }

                // 현재 선택이 마지막 선택과 동일한지 확인
                guard let currentSelection = self.selectedTextRange,
                      let lastSelection = self.lastSelectedRange,
                      self.rangesAreEqual(currentSelection, lastSelection) else {
                    return
                }

                // 하이라이트 저장
                self.saveSelectionAsHighlight()
            }
        }
    }

    /// 두 UITextRange가 동일한지 비교
    private func rangesAreEqual(_ range1: UITextRange, _ range2: UITextRange) -> Bool {
        let start1 = offset(from: beginningOfDocument, to: range1.start)
        let end1 = offset(from: beginningOfDocument, to: range1.end)
        let start2 = offset(from: beginningOfDocument, to: range2.start)
        let end2 = offset(from: beginningOfDocument, to: range2.end)
        return start1 == start2 && end1 == end2
    }

    /// 현재 선택된 텍스트를 하이라이트로 저장
    private func saveSelectionAsHighlight() {
        guard let selectedRange = selectedTextRange,
              !selectedRange.isEmpty else { return }

        var startOffset = offset(from: beginningOfDocument, to: selectedRange.start)
        var endOffset = offset(from: beginningOfDocument, to: selectedRange.end)

        // 빈 텍스트나 공백만 있으면 무시
        guard let fullText = self.text,
              startOffset < fullText.count,
              endOffset <= fullText.count else { return }

        // 겹치는 기존 하이라이트 찾기 및 병합
        var overlappingHighlights: [TextHighlight] = []
        for highlight in currentHighlights {
            // 범위가 겹치는지 확인
            if highlight.startIndex <= endOffset && highlight.endIndex >= startOffset {
                overlappingHighlights.append(highlight)
                // 병합: 가장 작은 시작점과 가장 큰 끝점으로 확장
                startOffset = min(startOffset, highlight.startIndex)
                endOffset = max(endOffset, highlight.endIndex)
            }
        }

        // 병합된 범위의 텍스트 추출
        let startIndex = fullText.index(fullText.startIndex, offsetBy: startOffset)
        let endIndex = fullText.index(fullText.startIndex, offsetBy: min(endOffset, fullText.count))
        let mergedText = String(fullText[startIndex..<endIndex])

        // 빈 텍스트나 공백만 있으면 무시
        let trimmedText = mergedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedText.isEmpty else { return }

        // 완전히 동일한 범위면 무시 (이미 하이라이트된 상태)
        if overlappingHighlights.count == 1 {
            let existing = overlappingHighlights[0]
            if existing.startIndex == startOffset && existing.endIndex == endOffset {
                print("⚠️ [Selection] 이미 하이라이트된 영역입니다")
                self.selectedTextRange = nil
                return
            }
        }

        // 기존 겹치는 하이라이트들 제거
        for oldHighlight in overlappingHighlights {
            currentHighlights.removeAll { $0.id == oldHighlight.id }
            // 삭제 콜백 호출 (서버에서도 삭제)
            onHighlightDeleted?(oldHighlight)
            print("🔄 [Selection] 기존 하이라이트 병합을 위해 삭제: \"\(oldHighlight.highlightedText)\"")
        }

        // 새로운 병합된 하이라이트 생성
        let highlight = TextHighlight(
            paragraphId: paragraphId,
            startIndex: startOffset,
            endIndex: endOffset,
            highlightedText: mergedText
        )

        // 하이라이트 적용
        currentHighlights.append(highlight)
        applyAllHighlights()

        // 선택 해제
        self.selectedTextRange = nil
        isSelecting = false

        // 콜백 호출
        onHighlightCreated?(highlight)

        if overlappingHighlights.isEmpty {
            print("✅ [Selection] 하이라이트 저장: \"\(mergedText)\"")
        } else {
            print("✅ [Selection] 하이라이트 병합 저장: \"\(mergedText)\" (\(overlappingHighlights.count)개 병합)")
        }
    }

    // MARK: - Highlight Management

    /// 하이라이트 목록 업데이트 (외부에서 호출)
    func updateHighlights(_ highlights: [TextHighlight]) {
        currentHighlights = highlights
        applyAllHighlights()
    }

    /// 특정 위치의 하이라이트 찾기
    private func findHighlight(at characterIndex: Int) -> TextHighlight? {
        return currentHighlights.first { highlight in
            characterIndex >= highlight.startIndex && characterIndex < highlight.endIndex
        }
    }

    /// 하이라이트 삭제
    private func removeHighlight(_ highlight: TextHighlight) {
        currentHighlights.removeAll { $0.id == highlight.id }
        applyAllHighlights()
    }

    /// 모든 하이라이트 시각적 적용
    private func applyAllHighlights() {
        guard let originalText = attributedText?.mutableCopy() as? NSMutableAttributedString else { return }

        // 기존 배경색 제거
        let fullRange = NSRange(location: 0, length: originalText.length)
        originalText.removeAttribute(.backgroundColor, range: fullRange)

        // 하이라이트 색상 적용
        for highlight in currentHighlights {
            let range = NSRange(location: highlight.startIndex, length: highlight.endIndex - highlight.startIndex)

            // 범위 유효성 검사
            if range.location >= 0 && range.location + range.length <= originalText.length {
                originalText.addAttribute(.backgroundColor, value: highlightColor, range: range)
            }
        }

        // UI 업데이트
        let selectedRange = self.selectedTextRange
        self.attributedText = originalText
        self.selectedTextRange = selectedRange // 선택 상태 복원

        print("🎨 [Highlights] 하이라이트 적용: \(currentHighlights.count)개")
    }

    // MARK: - Menu Actions

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 복사, 붙여넣기 등 기본 메뉴 숨기기
        // 선택만 허용하고 다른 액션은 차단
        if action == #selector(select(_:)) || action == #selector(selectAll(_:)) {
            return isSelectionAllowed
        }
        return false
    }
}

// MARK: - UIGestureRecognizerDelegate

extension NonEditableTextView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 탭 제스처와 다른 제스처가 동시에 인식되도록 허용
        return true
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 롱프레스(선택)가 실패해야 탭이 인식됨
        if gestureRecognizer is UITapGestureRecognizer && otherGestureRecognizer is UILongPressGestureRecognizer {
            return true
        }
        return false
    }
}
