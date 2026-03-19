//
//  PlayerView.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//
import UIKit
import SnapKit
import Combine

/// 플레이어 메인 뷰 - 전체 플레이어 UI를 관리
final class PlayerView: BaseView {

    // MARK: - UI Components

    // 상단 네비게이션 바 + 제목 영역
    let navigationBar = CustomNavigationBar()
    let artnerPrimaryBar = ArtnerPrimaryBar()
    
    // 상단 radial 그라데이션 (SafeArea부터 ArtnerPrimaryBar + 42px까지)
    private let fadeoutGradientView = UIView()
    private let fadeoutGradientLayer = CAGradientLayer()
    
    // 컨텐츠 영역
    private let lyricsContainerView = UIView()
    private let lyricsTableView = UITableView()
    
    // 스켈레톤 로딩 뷰
    private let skeletonView = SkeletonView()
    
    // 그라데이션 마스크를 위한 뷰들 (위아래 흐림 처리)
    private let topGradientView = UIView()
    private let bottomGradientView = UIView()
    

    
    // 컨트롤 영역
    private let controlsContainerView = UIView()
    
    // 시간 표시
    private let timeStackView = UIStackView()
    private let currentTimeLabel = UILabel()
    private let totalTimeLabel = UILabel()
    private let progressView = GradientProgressView() // UIProgressView 대신 커스텀 뷰 사용
    private let playerControls = PlayerControlsView()
    
    // 데이터 - 문단 단위로 변경
    private var paragraphs: [DocentParagraph] = []
    private var currentHighlightIndex: Int = 0
    
    // 하이라이트 저장 콜백 (ViewModel로 전달용)
    var onHighlightCreated: ((TextHighlight) -> Void)?
    var onHighlightDeleted: ((TextHighlight) -> Void)?
    
    // ViewModel에서 하이라이트를 가져오기 위한 콜백
    var onGetHighlightsForParagraph: ((String) -> [TextHighlight])?
    
    // 프로그레스 바 터치 콜백 (진행률 0.0 ~ 1.0)
    var onProgressTapped: ((Float) -> Void)?
    
    // 로딩 상태
    private var isLoading = true {
        didSet {
            updateLoadingState()
        }
    }
    
    // 뷰어 설정 구독
    private var settingsCancellables = Set<AnyCancellable>()

    // 플레이어 상태
    private var isPlaying = false {
        didSet {
            updateTextSelectionEnabled(!isPlaying)
        }
    }
    
    // 네비게이션 바 상단 슬라이드 관련
    private let navHideHeight: CGFloat = 56
    private var navigationBarTopConstraint: Constraint?

    // MARK: - Setup

    override func setupUI() {
        super.setupUI()

        backgroundColor = AppColor.background

        setupHierarchy()
        setupTableView()
        setupControlsArea()
        setupGradientViews()
        bindViewerSettings()

        // 초기 로딩 상태 설정
        showLoadingState()
    }
    
    private func setupHierarchy() {
        // 기본 컨텐츠들을 추가
        addSubview(navigationBar)
        addSubview(artnerPrimaryBar)
        addSubview(fadeoutGradientView)
        addSubview(lyricsContainerView)
        addSubview(controlsContainerView)
        
        lyricsContainerView.addSubview(skeletonView)
        lyricsContainerView.addSubview(lyricsTableView)
        lyricsContainerView.addSubview(topGradientView)
        lyricsContainerView.addSubview(bottomGradientView)
        
        // 컨트롤 영역 구성
        controlsContainerView.addSubview(timeStackView)
        controlsContainerView.addSubview(progressView)
        controlsContainerView.addSubview(playerControls)
        
        timeStackView.addArrangedSubview(currentTimeLabel)
        timeStackView.addArrangedSubview(totalTimeLabel)
        
        // 네비게이션 바 설정
        navigationBar.backgroundColor = AppColor.background
        navigationBar.setTitle("artner")
        navigationBar.titleLabel.font = UIFont.poppinsMedium(size: 16)
        navigationBar.titleLabel.textColor = UIColor(hex: "#D0AE86")
        navigationBar.backButton.tintColor = AppColor.textPrimary
        navigationBar.rightButton.tintColor = AppColor.textPrimary
        navigationBar.onBackButtonTapped = { [weak self] in self?.didTapBack() }
    }
    
    private func setupTableView() {
        lyricsTableView.backgroundColor = .clear
        lyricsTableView.separatorStyle = .none
        lyricsTableView.showsVerticalScrollIndicator = false
        lyricsTableView.showsHorizontalScrollIndicator = false
        
        // 셀 등록
        lyricsTableView.register(ParagraphTableViewCell.self, forCellReuseIdentifier: "ParagraphCell")
        
        // 델리게이트 설정
        lyricsTableView.dataSource = self
        lyricsTableView.delegate = self
        
        // 스크롤 동작 설정
        lyricsTableView.contentInsetAdjustmentBehavior = .never
    }
    
    private func setupControlsArea() {
        // 컨트롤 영역이 터치를 제대로 전달하도록 설정
        controlsContainerView.clipsToBounds = false
        controlsContainerView.isUserInteractionEnabled = true

        // 시간 표시 스택뷰 설정
        timeStackView.axis = .horizontal
        timeStackView.distribution = .equalSpacing
        timeStackView.alignment = .center
        timeStackView.spacing = 0

        // 시간 라벨 설정
        currentTimeLabel.textColor = AppColor.textSecondary
        currentTimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        currentTimeLabel.text = "0:00"

        totalTimeLabel.textColor = AppColor.textSecondary
        totalTimeLabel.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        totalTimeLabel.text = "0:00"

        // 플레이어 컨트롤 초기 비활성화
        playerControls.setEnabled(false)

        // 프로그레스 바 터치 이벤트 설정
        progressView.onProgressTapped = { [weak self] progress in
            self?.onProgressTapped?(progress)
        }
    }
    
    private func setupGradientViews() {
        // 상단 텍스트 페이드 그라디언트 (항상 표시 - 텍스트 서서히 안보이게)
        topGradientView.backgroundColor = .clear
        let topGradientLayer = CAGradientLayer()
        topGradientLayer.colors = [
            AppColor.background.cgColor,                      // 완전한 배경색
            AppColor.background.withAlphaComponent(0.0).cgColor  // 투명
        ]
        topGradientLayer.locations = [0.0, 1.0]
        topGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        topGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        topGradientView.layer.addSublayer(topGradientLayer)
        
        // 하단 텍스트 페이드 그라디언트 (항상 표시 - 텍스트 서서히 안보이게)
        bottomGradientView.backgroundColor = .clear
        let bottomGradientLayer = CAGradientLayer()
        bottomGradientLayer.colors = [
            AppColor.background.withAlphaComponent(0.0).cgColor,  // 투명
            AppColor.background.cgColor                           // 완전한 배경색
        ]
        bottomGradientLayer.locations = [0.0, 1.0]
        bottomGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        bottomGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        bottomGradientView.layer.addSublayer(bottomGradientLayer)
        
        // 상단 골든 그라디언트 설정 (radial 느낌, SafeArea보다 위에서부터)
        fadeoutGradientView.backgroundColor = .clear
        fadeoutGradientLayer.colors = [
            UIColor(hex: "#FFE489", alpha: 0.4).cgColor,  // 밝은 골든 (상단)
            UIColor(hex: "#CD9567", alpha: 0.3).cgColor,  // 미디엄 골든 (중간)
            UIColor(hex: "#9A5648", alpha: 0.2).cgColor,  // 다크 브라운 (하단)
            UIColor(hex: "#9A5648", alpha: 0.0).cgColor   // 투명 (페이드아웃)
        ]
        fadeoutGradientLayer.locations = [0.0, 0.4, 0.7, 1.0]
        fadeoutGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)  // 위에서부터
        fadeoutGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)    // 아래로
        fadeoutGradientView.layer.addSublayer(fadeoutGradientLayer)
        fadeoutGradientView.alpha = 0.0 // 초기에는 숨김
    }

    /// 뷰어 설정(글자 크기/줄 간격) 변경 구독 → 테이블 새로고침
    private func bindViewerSettings() {
        let manager = ViewerSettingsManager.shared
        Publishers.CombineLatest(manager.$fontSize, manager.$lineSpacing)
            .dropFirst() // 초기 구독 시 불필요한 리로드 방지
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _, _ in
                guard let self = self, !self.isLoading else { return }
                self.lyricsTableView.reloadData()
            }
            .store(in: &settingsCancellables)
    }

    override func setupLayout() {
        super.setupLayout()
        
        // 상단 네비게이션 바 (SafeArea 최상단)
        navigationBar.snp.makeConstraints {
            self.navigationBarTopConstraint = $0.top.equalTo(safeAreaLayoutGuide).constraint
            $0.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }
        
        // 제목 바 (네비게이션 바 아래로 분리 배치)
        artnerPrimaryBar.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60)
        }
        
        // 페이드아웃 그라데이션 (상단에서 제목바까지)
        fadeoutGradientView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(artnerPrimaryBar.snp.bottom)
        }
        
        // 컨트롤 영역 (SafeArea 내에서 끝, 높이 170px)
        controlsContainerView.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom)
            $0.height.equalTo(170)
        }
        
        // 컨텐츠 영역 (제목 바 아래부터 컨트롤 영역 위까지)
        lyricsContainerView.snp.makeConstraints {
            $0.top.equalTo(fadeoutGradientView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(controlsContainerView.snp.top)
        }
        
        // 스켈레톤 뷰
        skeletonView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 테이블뷰
        lyricsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 상단 그라데이션
        topGradientView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        // 하단 그라데이션
        bottomGradientView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        // 플레이어 컨트롤 (위쪽에 배치)
        // PlayerControlsView가 intrinsicContentSize로 자체 크기 결정
        // 3버튼 레이아웃: 216px, 2버튼 레이아웃: 150px
        playerControls.snp.makeConstraints {
            $0.top.equalToSuperview().offset(12)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(64) // 충분한 높이 확보
        }
        playerControls.setContentHuggingPriority(.required, for: .horizontal)
        playerControls.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        // 진행 바 (컨트롤 아래에 배치)
        progressView.snp.makeConstraints {
            $0.top.equalTo(playerControls.snp.bottom).offset(34)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(4)
        }
        
        // 시간 표시 (진행 바 아래에 배치)
        timeStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(20)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 모든 그라디언트 레이어 크기 업데이트
        if let topGradientLayer = topGradientView.layer.sublayers?.first as? CAGradientLayer {
            topGradientLayer.frame = topGradientView.bounds
        }
        
        if let bottomGradientLayer = bottomGradientView.layer.sublayers?.first as? CAGradientLayer {
            bottomGradientLayer.frame = bottomGradientView.bounds
        }
        
        fadeoutGradientLayer.frame = fadeoutGradientView.bounds
    }

    // MARK: - Public Interface

    /// 문단 데이터 설정
    func setParagraphs(_ paragraphs: [DocentParagraph]) {
        self.paragraphs = paragraphs
        lyricsTableView.reloadData() // 테이블 뷰를 새로고침하여 문단 데이터를 반영
        
        // 실제 도슨트 길이 계산하여 총 시간 표시 업데이트
        let totalDuration = calculateTotalDuration(from: paragraphs)
        updateTotalTimeLabel(totalDuration)
    }
    
    /// 문단 배열에서 총 재생 시간 계산
    private func calculateTotalDuration(from paragraphs: [DocentParagraph]) -> TimeInterval {
        guard let lastParagraph = paragraphs.last else { return 0.0 }
        // 마지막 문단의 endTime이 총 재생 시간
        return lastParagraph.endTime
    }
    
    /// 총 시간 라벨 업데이트
    private func updateTotalTimeLabel(_ totalTime: TimeInterval) {
        // formatTime 헬퍼 메서드 사용
        totalTimeLabel.text = formatTime(totalTime)
    }

    // MARK: - Actions
    @objc private func didTapBack() {
        onBackButtonTapped?()
    }

    // MARK: - Callback
    var onBackButtonTapped: (() -> Void)?
    
    /// 로딩 상태 표시
    func showLoadingState() {
        isLoading = true
        skeletonView.startLoading()
        skeletonView.isHidden = false
        lyricsTableView.isHidden = true
    }
    
    /// 컨텐츠 상태 표시
    func showContentState() {
        isLoading = false
        skeletonView.stopLoading()
        skeletonView.isHidden = true
        lyricsTableView.isHidden = false
        
        // 레이아웃 강제 갱신으로 셀 높이 올바르게 계산
        lyricsTableView.layoutIfNeeded()
        
        // TableView 높이 재계산 강제 실행
        DispatchQueue.main.async {
            self.lyricsTableView.beginUpdates()
            self.lyricsTableView.endUpdates()
        }
        
        // 플레이어 컨트롤 활성화
        UIView.animate(withDuration: 0.3) {
            self.playerControls.setEnabled(true)
        }
    }
    
    /// 저장 상태 UI 반영 (저장 버튼 색상)
    func setSaved(_ saved: Bool) {
        playerControls.setSaved(saved)
    }
    
    /// 문단 하이라이트
    func highlightParagraph(at index: Int) {
        guard index >= 0 && index < paragraphs.count && !isLoading else { return }
        
        currentHighlightIndex = index
        
        // 테이블뷰 새로고침 (하이라이트 변경을 위해)
        lyricsTableView.reloadData()
        
        // 중앙으로 스크롤 (애니메이션과 함께)
        let indexPath = IndexPath(row: index, section: 0)
        lyricsTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    /// 진행률 업데이트
    func updateProgress(_ currentTime: TimeInterval, totalTime: TimeInterval) {
        guard !isLoading else { return }
        
        // 현재 시간 표시 업데이트 (초 단위를 분:초 형식으로 변환)
        currentTimeLabel.text = formatTime(currentTime)
        
        // 총 시간 표시 업데이트 (초 단위를 분:초 형식으로 변환)
        totalTimeLabel.text = formatTime(totalTime)
        
        // 진행 바 업데이트
        if totalTime > 0 {
            progressView.setProgress(Float(currentTime / totalTime), animated: true)
        }
    }
    
    /// 시간을 "분:초" 형식으로 변환하는 헬퍼 메서드
    /// - Parameter time: 초 단위 시간 (TimeInterval)
    /// - Returns: "분:초" 형식의 문자열 (예: "2:33", "10:05")
    private func formatTime(_ time: TimeInterval) -> String {
        // TimeInterval은 초 단위이므로, 분과 초로 변환
        let totalSeconds = Int(time)
        let minutes = totalSeconds / 60
        let seconds = totalSeconds % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    /// 플레이 상태 업데이트
    func updatePlayState(_ isPlaying: Bool) {
        self.isPlaying = isPlaying
        
        // PlayerControlsView의 상태 업데이트
        let state: PlayerControlState = isPlaying ? .playing : .idle
        playerControls.setState(state)
        
        // 플레이 상태에 따른 그라데이션 표시/숨김 (fadeoutGradientView만 사용)
        showFadeoutGradient(isPlaying)
        
        // ArtnerPrimaryBar 그라디언트는 비활성화 (중복 방지)
        // artnerPrimaryBar.setGradientVisible(isPlaying, animated: true)
    }
    
    /// 하이라이트 UI 업데이트 (외부에서 호출)
    func updateHighlights(_ highlightsByParagraph: [String: [TextHighlight]]) {
        print("🎨 [PlayerView] 하이라이트 업데이트 시작: \(highlightsByParagraph.count)개 문단")
        
        // 모든 보이는 셀에 하이라이트 적용
        for cell in lyricsTableView.visibleCells {
            guard let paragraphCell = cell as? ParagraphTableViewCell,
                  let indexPath = lyricsTableView.indexPath(for: cell),
                  indexPath.row < paragraphs.count else { continue }
            
            let paragraph = paragraphs[indexPath.row]
            let highlights = highlightsByParagraph[paragraph.id] ?? []
            
            print("🎨 [PlayerView] 문단 '\(paragraph.id)'에 \(highlights.count)개 하이라이트 적용")
            paragraphCell.setHighlights(highlights)
        }
        
        // 테이블뷰 새로고침으로 하이라이트 시각적 업데이트 강제
        DispatchQueue.main.async {
            self.lyricsTableView.reloadData()
        }
    }
    
    /// 텍스트 선택 상태 업데이트 (외부에서 호출)
    func updateTextSelectionEnabled(_ enabled: Bool) {
        // 모든 보이는 셀의 텍스트 선택 상태 업데이트
        for cell in lyricsTableView.visibleCells {
            if let paragraphCell = cell as? ParagraphTableViewCell {
                paragraphCell.setTextSelectionEnabled(enabled)
            }
        }
    }
    
    /// 플레이어 컨트롤 액션 설정
    func setupPlayerControlsActions(
        onSave: @escaping () -> Void,
        onPlay: @escaping () -> Void,
        onPause: @escaping () -> Void,
        onReplay: @escaping () -> Void
    ) {
        playerControls.onSaveButtonTapped = onSave
        playerControls.onPlayButtonTapped = onPlay
        playerControls.onPauseButtonTapped = onPause
        playerControls.onReplayButtonTapped = onReplay
    }

    // MARK: - Private Methods
    
    private func updateLoadingState() {
        // 로딩 상태 변경에 따른 추가 UI 업데이트가 필요하면 여기에
    }
    
    
    /// 플레이 상태에 따른 하단 페이드아웃 그라데이션 표시/숨김
    private func showFadeoutGradient(_ isPlaying: Bool) {
        let targetAlpha: CGFloat = isPlaying ? 1.0 : 0.0
        
        UIView.animate(withDuration: 0.5, animations: {
            self.fadeoutGradientView.alpha = targetAlpha
        })
    }
}

// MARK: - UITableViewDataSource

extension PlayerView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return paragraphs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ParagraphCell", for: indexPath) as? ParagraphTableViewCell else {
            return UITableViewCell()
        }
        
        let paragraph = paragraphs[indexPath.row]
        let isHighlighted = indexPath.row == currentHighlightIndex

        // 하이라이트 가능 조건: 정지 상태일 때만 모든 문단에서 텍스트 선택 가능
        // iOS 네이티브 텍스트 선택 방식 사용 (길게 누르고 드래그)
        let canHighlight = !isPlaying

        // 하이라이트 저장 콜백 설정 (ViewModel로 전달)
        cell.onHighlightSaved = { [weak self] highlight in
            self?.onHighlightCreated?(highlight)
        }

        // 하이라이트 삭제 콜백 설정 (ViewModel로 전달)
        cell.onHighlightDeleted = { [weak self] highlight in
            self?.onHighlightDeleted?(highlight)
        }

        // configure에서 하이라이트 활성화 조건을 전달 (정지 상태에서만 활성화)
        cell.configure(with: paragraph, isHighlighted: isHighlighted, canHighlight: canHighlight)
        
        // 저장된 하이라이트 로드 (ViewModel에서 가져와서 적용)
        let savedHighlights = onGetHighlightsForParagraph?(paragraph.id) ?? []
        cell.setHighlights(savedHighlights)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension PlayerView: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        guard indexPath.row < paragraphs.count else { return 120 }
        
        let paragraph = paragraphs[indexPath.row]
        let textLength = paragraph.fullText.count
        
        // 텍스트 길이에 따른 추정 높이 계산
        let estimatedLineCount = max(1, textLength / 30)  // 대략 30자당 1줄
        let estimatedHeight = CGFloat(estimatedLineCount) * 25 + 40  // 줄 높이 25px + 여백 40px
        
        return max(80, estimatedHeight)
    }
    
        // 스크롤에 따른 최상단 네비게이션 바 상단으로 밀어 올리기
        func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = max(0, scrollView.contentOffset.y)
        let hide = min(offsetY, navHideHeight)
        navigationBarTopConstraint?.update(offset: -hide)
        // 살짝 시각적 자연스러움 위해 alpha도 같이 처리(옵션)
        let alpha = max(0, 1 - (hide / navHideHeight))
        navigationBar.alpha = alpha
        navigationBar.isUserInteractionEnabled = alpha > 0.05
        layoutIfNeeded()
    }
}
