//
//  NonEditableTextView.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//
import UIKit

/// 편집 불가능한 텍스트뷰 (선택만 가능)
final class NonEditableTextView: UITextView, UIGestureRecognizerDelegate {
    
    // 하이라이트 생성 콜백 (TextHighlight 객체 전달)
    var onHighlightCreated: ((TextHighlight) -> Void)?
    
    // 하이라이트 삭제 콜백 (삭제할 하이라이트 정보 전달)
    var onHighlightDeleted: ((TextHighlight) -> Void)?
    
    // 문단 ID (하이라이트 저장 시 필요)
    var paragraphId: String = ""
    
    // 현재 적용된 하이라이트 목록 (삭제 감지용)
    private var currentHighlights: [TextHighlight] = []
    
    // 하이라이트 활성화 상태 (현재 재생 중인 문단에서만 true)
    var isHighlightEnabled: Bool = false
    
    // 하이라이트 드래그 상태 추적
    private var isHighlightDragging = false
    private var dragStartIndex: Int = 0
    private var currentDragRange: NSRange?
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setupNonEditableConfiguration()
        addTapGestureRecognizer() // 제스처 인식기 추가
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupNonEditableConfiguration()
        addTapGestureRecognizer() // 제스처 인식기 추가
    }
    
    private func addTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        self.addGestureRecognizer(tapGesture)
    }

    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        // 하이라이트가 비활성화된 경우 무시
        guard isHighlightEnabled else {
            print("⚠️ [Tap] 하이라이트 비활성화 상태 - 터치 무시")
            return
        }
        
        let point = gesture.location(in: self)
        let characterIndex = characterIndex(at: point)
        
        // 터치한 지점에 하이라이트가 있는지 확인
        if let highlightToDelete = findHighlight(at: characterIndex) {
            removeHighlight(highlightToDelete)
            onHighlightDeleted?(highlightToDelete)
            print("🗑️ [Tap] 하이라이트 삭제: \(highlightToDelete)")
        }
    }
    
    private func setupNonEditableConfiguration() {
        // 데이터 검출 완전 비활성화 (링크, 전화번호 등)
        self.dataDetectorTypes = []
        
        // 텍스트 선택 완전 비활성화 (Long Press로 대체)
        self.isSelectable = false
        self.isEditable = false
        
        // 상호작용 가능한 요소들 비활성화
        self.linkTextAttributes = [:]  // 링크 스타일 제거
        
        // 키보드 관련 설정 비활성화
        self.autocorrectionType = .no
        self.autocapitalizationType = .none
        self.spellCheckingType = .no
        self.smartQuotesType = .no
        self.smartDashesType = .no
        self.smartInsertDeleteType = .no
        
        // Long Press Gesture 추가
        setupLongPressGesture()
    }
    
    private func setupLongPressGesture() {
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.3 // 0.3초 꾹 누르기
        longPressGesture.allowableMovement = CGFloat.greatestFiniteMagnitude // 무제한 드래그 허용
        longPressGesture.delegate = self
        addGestureRecognizer(longPressGesture)
        
        print("🔧 [Gesture] Long Press 설정 완료 - 드래그 허용")
    }
    
    // Long Press 방식으로 변경되어 First Responder 불필요
    override var canBecomeFirstResponder: Bool { false }
    
    // Long Press로 드래그 하이라이트 (연속 드래그 지원)
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: self)
        let characterIndex = characterIndex(at: point)
        
        switch gesture.state {
        case .began:
            // 하이라이트가 비활성화된 경우 무시
            guard isHighlightEnabled else {
                print("⚠️ [LongPress] 하이라이트 비활성화 상태 - 드래그 무시")
                return
            }
            
            // 드래그 모드 시작
            isHighlightDragging = true
            dragStartIndex = characterIndex
            
            // 정확한 문자 위치에서 시작
            let initialRange = NSRange(location: characterIndex, length: 1)
            currentDragRange = initialRange
            applyTemporaryHighlight(to: initialRange)
            print("🎯 [LongPress] 드래그 시작: 문자 \(characterIndex)에서 시작")
            
        case .changed:
            // 드래그 중 - 실시간 범위 업데이트 (핵심!)
            if isHighlightDragging {
                updateDragRange(to: characterIndex)
            }
            
        case .ended, .cancelled, .failed:
            // 드래그 종료 - 최종 하이라이트 적용
            if isHighlightDragging, let finalRange = currentDragRange {
                applyFinalHighlight(to: finalRange)
            }
            resetDragState()
            
        default:
            break
        }
    }
    
    private func characterIndex(at point: CGPoint) -> Int {
        // iOS 16+ TextKit 2 호환성을 위한 현대적 방법
        if #available(iOS 16.0, *) {
            let textPosition = closestPosition(to: point) ?? beginningOfDocument
            return offset(from: beginningOfDocument, to: textPosition)
        } else {
            // iOS 15 이하에서는 기존 방법 사용
            let layoutManager = self.layoutManager
            let textContainer = self.textContainer
            return layoutManager.characterIndex(for: point, in: textContainer, fractionOfDistanceBetweenInsertionPoints: nil)
        }
    }
    
    private func getWordRange(at characterIndex: Int) -> NSRange? {
        guard let text = self.text,
              characterIndex >= 0,
              characterIndex < text.count else { return nil }
        
        let nsText = text as NSString
        var wordRange = NSRange()
        var foundRange = false
        
        // 단어 경계 찾기 (공백, 줄바꿈, 문장부호 기준)
        nsText.enumerateSubstrings(in: NSRange(location: 0, length: nsText.length), 
                                  options: [.byWords, .localized]) { (substring, range, _, stop) in
            if range.contains(characterIndex) {
                wordRange = range
                foundRange = true
                stop.pointee = true // 찾으면 더 이상 순회하지 않음
            }
        }
        
        // 단어를 찾지 못한 경우, 최소한 현재 문자 하나라도 선택
        if !foundRange {
            wordRange = NSRange(location: characterIndex, length: 1)
            foundRange = true
        }
        
        return foundRange ? wordRange : nil
    }
    
    // MARK: - UIGestureRecognizerDelegate
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // Long Press가 드래그를 방해하지 않도록 동시 인식 허용
        return true
    }
    
    private func updateDragRange(to endIndex: Int) {
        let startIndex = dragStartIndex
        
        // 시작점과 끝점 사이의 전체 범위 계산
        let newRange = NSRange(
            location: min(startIndex, endIndex),
            length: abs(endIndex - startIndex)
        )
        
        // 최소 길이 보장 (적어도 1글자는 선택)
        let finalRange = newRange.length > 0 ? newRange : NSRange(location: startIndex, length: 1)
        
        // 텍스트 경계 검사
        let textLength = text?.count ?? 0
        let adjustedRange = NSRange(
            location: min(max(finalRange.location, 0), textLength - 1),
            length: min(finalRange.length, textLength - finalRange.location)
        )
        
        // 범위가 변경된 경우에만 업데이트
        if currentDragRange?.location != adjustedRange.location || 
           currentDragRange?.length != adjustedRange.length {
            currentDragRange = adjustedRange
            applyTemporaryHighlight(to: adjustedRange)
            print("🔄 [Drag] 범위 업데이트: \(adjustedRange) (시작:\(startIndex) → 끝:\(endIndex))")
        }
    }
    
    private func applyTemporaryHighlight(to range: NSRange) {
        guard let originalText = attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
        
        // 기존 임시 하이라이트 제거 (원본 텍스트 복원)
        clearTemporaryHighlights()
        
        // 새로운 임시 하이라이트 적용 (반투명한 노란색)
        originalText.addAttribute(.backgroundColor, 
                                value: UIColor.systemYellow.withAlphaComponent(0.2), 
                                range: range)
        
        attributedText = originalText
    }
    
    private func applyFinalHighlight(to range: NSRange) {
        guard let currentText = attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
        
        // 최종 하이라이트 배경색 적용 (진한 노란색)
        currentText.addAttribute(.backgroundColor, 
                                value: UIColor.systemYellow.withAlphaComponent(0.4), 
                                range: range)
        
        attributedText = currentText
        
        // TextHighlight 객체 생성 및 전달
        let highlightedText = (text as NSString).substring(with: range)
        let textHighlight = TextHighlight(
            paragraphId: paragraphId,
            startIndex: range.location,
            endIndex: range.location + range.length,
            highlightedText: highlightedText
        )
        
        print("🎨 [TextView] 최종 하이라이트 생성: \(textHighlight)")
        onHighlightCreated?(textHighlight)
    }
    
    private func clearTemporaryHighlights() {
        // 전체 텍스트에서 배경색 속성 제거
        guard let originalText = attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
        
        originalText.removeAttribute(.backgroundColor, range: NSRange(location: 0, length: originalText.length))
        attributedText = originalText
    }
    
    private func resetDragState() {
        isHighlightDragging = false
        currentDragRange = nil
        dragStartIndex = 0
        print("🔄 [Drag] 상태 리셋")
    }
    
    // MARK: - Highlight Management
    
    /// 현재 하이라이트 목록 업데이트 (외부에서 호출)
    func updateHighlights(_ highlights: [TextHighlight]) {
        currentHighlights = highlights
        applyAllHighlights()
    }
    
    /// 특정 위치의 하이라이트 찾기
    private func findHighlight(at characterIndex: Int) -> TextHighlight? {
        return currentHighlights.first { highlight in
            let range = NSRange(location: highlight.startIndex, length: highlight.endIndex - highlight.startIndex)
            return range.contains(characterIndex)
        }
    }
    
    /// 하이라이트 삭제 (시각적으로만)
    private func removeHighlight(_ highlight: TextHighlight) {
        // 현재 목록에서 제거
        currentHighlights.removeAll { $0.id == highlight.id }
        
        // 시각적으로 다시 적용
        applyAllHighlights()
    }
    
    /// 모든 하이라이트를 다시 적용
    private func applyAllHighlights() {
        guard let originalText = attributedText?.mutableCopy() as? NSMutableAttributedString else { return }
        
        // 모든 배경색 제거
        originalText.removeAttribute(.backgroundColor, range: NSRange(location: 0, length: originalText.length))
        
        // 현재 하이라이트들 다시 적용
        for highlight in currentHighlights {
            let range = NSRange(location: highlight.startIndex, length: highlight.endIndex - highlight.startIndex)
            
            // 범위 검사
            if range.location >= 0 && range.location + range.length <= originalText.length {
                originalText.addAttribute(.backgroundColor,
                                        value: UIColor.systemYellow.withAlphaComponent(0.4),
                                        range: range)
            }
        }
        
        attributedText = originalText
        print("🎨 [Highlights] 전체 하이라이트 재적용: \(currentHighlights.count)개")
    }
    
    // Long Press 방식으로 변경되어 메뉴 액션 불필요
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        // 텍스트 선택이 비활성화되었으므로 모든 메뉴 액션 차단
        return false
    }
}

