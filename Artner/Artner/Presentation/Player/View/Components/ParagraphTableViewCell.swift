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
        paragraphTextView.isSelectionAllowed = false
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
        // isSelectable은 NonEditableTextView의 isSelectionAllowed로 관리됨
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
        paragraphTextView.accessibilityHint = "정지 상태에서 텍스트를 길게 눌러 드래그하여 하이라이트할 수 있습니다"
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
    
    // iOS 네이티브 텍스트 선택 방식 사용
    // NonEditableTextView가 자체적으로 delegate를 관리하므로 별도 설정 불필요

    private func setupTextSelection() {
        // NonEditableTextView 내부에서 선택 및 하이라이트 로직 처리
        // 콜백 연결은 configure()에서 수행
    }
    
    // MARK: - 하이라이트 관리 (NonEditableTextView가 선택/저장 처리)

    // 하이라이트 설정 (외부에서 저장된 하이라이트 로드 시 사용)
    func setHighlights(_ highlights: [TextHighlight]) {
        print("📝 [Cell] setHighlights 호출됨 - 문단: \(paragraph?.id ?? "nil"), 하이라이트 개수: \(highlights.count)")
        self.highlights = highlights
        
        // NonEditableTextView에 하이라이트 정보 전달 (삭제 감지용)
        paragraphTextView.updateHighlights(highlights)
        
        // 현재 텍스트 스타일 유지하며 하이라이트 적용
        applyHighlights(textColor: paragraphTextView.textColor, font: paragraphTextView.font)
    }
    
    // canPerformAction은 NonEditableTextView 내부에서 처리
    // 셀은 First Responder가 되지 않고 텍스트뷰만 First Responder가 됨
    
    // 텍스트 선택 상태 제어 (정지 상태에서만 활성화)
    func setTextSelectionEnabled(_ enabled: Bool) {
        // NonEditableTextView의 isSelectionAllowed 사용
        paragraphTextView.isSelectionAllowed = enabled
        paragraphTextView.isUserInteractionEnabled = true // 항상 터치는 가능하게

        // 접근성 업데이트
        paragraphTextView.accessibilityHint = enabled ?
            "텍스트를 길게 눌러서 드래그하여 하이라이트할 수 있습니다" :
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
        
        // 텍스트 선택 활성화 상태 설정 (정지 상태에서만 활성화)
        paragraphTextView.isSelectionAllowed = canHighlight
        
        // 하이라이트 생성 콜백 연결
        paragraphTextView.onHighlightCreated = { [weak self] highlight in
            self?.onHighlightSaved?(highlight)
        }
        
        // 하이라이트 삭제 콜백 연결
        paragraphTextView.onHighlightDeleted = { [weak self] highlight in
            self?.onHighlightDeleted?(highlight)
        }
        
        // 현재 스타일 설정 (ViewerSettingsManager에서 동적 폰트 크기 가져오기)
        let textColor: UIColor
        let font: UIFont
        let alpha: CGFloat
        let dynamicFontSize = ViewerSettingsManager.shared.actualFontSize

        if isHighlighted {
            // 현재 재생 중인 문단 - 밝고 크게
            textColor = AppColor.textPrimary
            font = UIFont.systemFont(ofSize: dynamicFontSize, weight: .semibold)
            alpha = 1.0
        } else {
            // 다른 문단들 - 약간 작고 흐리게
            textColor = AppColor.textPrimary
            font = UIFont.systemFont(ofSize: dynamicFontSize, weight: .regular)
            alpha = 0.35
        }
        
        // 텍스트 스타일 적용
        paragraphTextView.textColor = textColor
        paragraphTextView.font = font
        paragraphTextView.alpha = alpha
        
        // 항상 applyHighlights를 사용하여 줄 간격이 적용되도록 함
        applyHighlights(textColor: textColor, font: font)
        
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
        let currentFont = font ?? paragraphTextView.font ?? UIFont.systemFont(ofSize: ViewerSettingsManager.shared.actualFontSize)

        // 줄 간격 설정
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = ViewerSettingsManager.shared.actualLineSpacing

        // 기본 텍스트 스타일 적용
        let fullRange = NSRange(location: 0, length: attributedText.length)

        // 안전한 속성 적용
        do {
            attributedText.addAttribute(.font, value: currentFont, range: fullRange)
            attributedText.addAttribute(.foregroundColor, value: currentTextColor, range: fullRange)
            attributedText.addAttribute(.paragraphStyle, value: paragraphStyle, range: fullRange)

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

// MARK: - Note
// UITextViewDelegate 및 UIEditMenuInteractionDelegate는 NonEditableTextView 내부에서 처리됨
// NonEditableTextView가 자체적으로 delegate를 설정하고 선택/하이라이트 로직을 관리
