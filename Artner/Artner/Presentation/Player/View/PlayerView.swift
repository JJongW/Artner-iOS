//
//  PlayerView.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//
import UIKit
import SnapKit

final class PlayerView: BaseView {

    // MARK: - UI Components

    // 네비게이션 영역 (숨김 처리)
    let customNavigationBar = CustomNavigationBar()
    
    // 제목 영역 (SafeArea 위부터 시작)
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
    
    // 중앙 하이라이트 영역 표시용 (디버깅/가이드용)
    private let centerHighlightView = UIView()
    
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
    
    // 로딩 상태
    private var isLoading = true {
        didSet {
            updateLoadingState()
        }
    }

    // MARK: - Setup

    override func setupUI() {
        super.setupUI()

        backgroundColor = AppColor.background

        setupHierarchy()
        setupTableView()
        setupControlsArea()
        setupGradientViews()
        
        // 초기 로딩 상태 설정
        showLoadingState()
    }
    
    private func setupHierarchy() {
        // 기본 컨텐츠들을 추가
        addSubview(artnerPrimaryBar)
        addSubview(lyricsContainerView)
        addSubview(controlsContainerView)
        
        lyricsContainerView.addSubview(skeletonView)
        lyricsContainerView.addSubview(lyricsTableView)
        lyricsContainerView.addSubview(topGradientView)
        lyricsContainerView.addSubview(bottomGradientView)
        lyricsContainerView.addSubview(centerHighlightView)
        
        controlsContainerView.addSubview(timeStackView)
        controlsContainerView.addSubview(progressView)
        controlsContainerView.addSubview(playerControls)
        
        timeStackView.addArrangedSubview(currentTimeLabel)
        timeStackView.addArrangedSubview(totalTimeLabel)
        
        // 하단 페이드아웃 그라데이션을 가장 마지막에 추가
        addSubview(fadeoutGradientView)
    }
    
    private func setupTableView() {
        lyricsTableView.backgroundColor = .clear
        lyricsTableView.separatorStyle = .none
        lyricsTableView.showsVerticalScrollIndicator = false
        lyricsTableView.isScrollEnabled = false // 자동 스크롤만 허용
        lyricsTableView.register(ParagraphTableViewCell.self, forCellReuseIdentifier: "ParagraphCell")
        lyricsTableView.dataSource = self
        lyricsTableView.delegate = self
        
        // 자동 높이 계산 설정
        lyricsTableView.estimatedRowHeight = 120  // 더 큰 예상 높이로 조정
        lyricsTableView.rowHeight = UITableView.automaticDimension
        
        // 중앙 정렬을 위한 여백 추가
        lyricsTableView.contentInset = UIEdgeInsets(top: 150, left: 0, bottom: 150, right: 0)
        
        // 초기에는 숨김
        lyricsTableView.isHidden = true
    }
    
    private func setupControlsArea() {
        // 시간 표시 스택뷰
        timeStackView.axis = .horizontal
        timeStackView.distribution = .equalSpacing
        timeStackView.alignment = .center
        
        // 시간 레이블 설정
        [currentTimeLabel, totalTimeLabel].forEach {
            $0.font = .systemFont(ofSize: 14, weight: .regular)
            $0.textColor = AppColor.textSecondary
        }
        
        timeStackView.addArrangedSubview(currentTimeLabel)
        timeStackView.addArrangedSubview(totalTimeLabel)
        
        currentTimeLabel.text = "00:00"
        totalTimeLabel.text = "00:00"
        
        // 프로그레스 뷰는 자체적으로 스타일링됨 (GradientProgressView)
        // UIProgressView 설정 제거
        
        // 플레이어 컨트롤 초기 설정
        setupPlayerControls()
    }
    
    private func setupPlayerControls() {
        // 초기 상태는 idle (정지/시작 전)
        playerControls.setState(.idle)
        
        // 로딩 중에는 비활성화
        playerControls.setEnabled(false)
    }
    
    private func setupGradientViews() {
        // 컨텐츠 영역 상단 그라데이션 (범위 축소 및 시작점 조정)
        topGradientView.isUserInteractionEnabled = false
        let topGradient = CAGradientLayer()
        topGradient.colors = [
            AppColor.background.withAlphaComponent(1.0).cgColor,
            AppColor.background.withAlphaComponent(0.0).cgColor,
            UIColor.clear.cgColor
        ]
        topGradient.locations = [0.0, 0.5, 1.0]
        topGradientView.layer.addSublayer(topGradient)
        
        // 하단 그라데이션 (더 부드럽게 조정)
        bottomGradientView.isUserInteractionEnabled = false
        let bottomGradient = CAGradientLayer()
        bottomGradient.colors = [
            UIColor.clear.cgColor,
            AppColor.background.withAlphaComponent(0.3).cgColor,
            AppColor.background.withAlphaComponent(0.7).cgColor,
            AppColor.background.cgColor
        ]
        bottomGradient.locations = [0.0, 0.4, 0.8, 1.0]
        bottomGradientView.layer.addSublayer(bottomGradient)
        
        // 중앙 하이라이트 영역 (보이지 않는 가이드)
        centerHighlightView.backgroundColor = .clear
        centerHighlightView.isUserInteractionEnabled = false
        
        // 상단 radial 그라데이션 설정 (초기에는 숨김)
        setupFadeoutGradient()
    }
    
    private func setupFadeoutGradient() {
        fadeoutGradientView.isUserInteractionEnabled = false
        fadeoutGradientView.alpha = 0.0
        
        fadeoutGradientLayer.colors = [
            UIColor(hex: "#9A5648", alpha: 0.2).cgColor,  // ArtnerPrimaryBar 하단과 연결
            UIColor(hex: "#9A5648", alpha: 0.1).cgColor,  // 중간
            UIColor(hex: "#9A5648", alpha: 0.0).cgColor   // 투명으로 페이드아웃
        ]
        fadeoutGradientLayer.locations = [0.0, 0.5, 1.0]
        fadeoutGradientLayer.startPoint = CGPoint(x: 0.5, y: 0.0)
        fadeoutGradientLayer.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        fadeoutGradientView.layer.addSublayer(fadeoutGradientLayer)
    }
    
    override func setupLayout() {
        super.setupLayout()

        // 페이드아웃 그라데이션 (ArtnerPrimaryBar 바로 아래 42px 영역)
        fadeoutGradientView.snp.makeConstraints {
            $0.top.equalTo(artnerPrimaryBar.snp.bottom)  // ArtnerPrimaryBar 바로 아래부터 시작
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(42)  // 42px 높이로 고정
        }

        // customNavigationBar는 숨김 처리됨
        
        // artnerPrimaryBar를 화면 최상단에 배치
        artnerPrimaryBar.snp.makeConstraints {
            $0.top.equalToSuperview()  // SafeArea가 아닌 화면 최상단
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top).offset(80) // SafeArea + 내용 높이
        }

        lyricsContainerView.snp.makeConstraints {
            $0.top.equalTo(artnerPrimaryBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(controlsContainerView.snp.top)
        }
        
        skeletonView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        lyricsTableView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 컨텐츠 영역 상단 그라데이션 (높이 축소)
        topGradientView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(60) // 높이 축소
        }
        
        bottomGradientView.snp.makeConstraints {
            $0.bottom.leading.trailing.equalToSuperview()
            $0.height.equalTo(100)
        }
        
        centerHighlightView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }

        controlsContainerView.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).offset(-10)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(160) // 높이 증가 (플레이버튼이 위로 이동)
        }
        
        // 플레이 컨트롤을 맨 위에 배치
        playerControls.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview()
        }
        
        // 진행 바를 플레이 컨트롤 아래 34px에 배치
        progressView.snp.makeConstraints {
            $0.top.equalTo(playerControls.snp.bottom).offset(34)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(2) // 4px → 2px로 변경
        }
        
        // 시간 텍스트를 진행 바 아래 8px에 배치 (바닥에서 42px)
        timeStackView.snp.makeConstraints {
            $0.top.equalTo(progressView.snp.bottom).offset(8)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(20)
            $0.bottom.equalToSuperview().offset(-42) // 바닥에서 42px
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 컨텐츠 영역 그라데이션 레이어 크기 업데이트
        if let topGradient = topGradientView.layer.sublayers?.first as? CAGradientLayer {
            topGradient.frame = topGradientView.bounds
        }
        
        if let bottomGradient = bottomGradientView.layer.sublayers?.first as? CAGradientLayer {
            bottomGradient.frame = bottomGradientView.bounds
        }
        
        // 페이드아웃 그라데이션 레이어 크기 업데이트
        fadeoutGradientLayer.frame = fadeoutGradientView.bounds
    }
    
    // MARK: - Public Methods

    func setParagraphs(_ paragraphs: [DocentParagraph]) {
        self.paragraphs = paragraphs
        
        // 간단한 디버깅 정보만 유지
        print("📚 문단 데이터 설정 완료: \(paragraphs.count)개 문단")
        
        // 로딩 완료 시뮬레이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.showContentState()
        }
        
        // 총 재생 시간 계산
        if let lastParagraph = paragraphs.last {
            let totalSeconds = Int(lastParagraph.endTime + 2)
            let minutes = totalSeconds / 60
            let seconds = totalSeconds % 60
            totalTimeLabel.text = String(format: "%d:%02d", minutes, seconds)
        }
    }
    
    // MARK: - Player Controls Actions Setup
    
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
    
    private func showLoadingState() {
        isLoading = true
        skeletonView.startLoading()
        lyricsTableView.isHidden = true
        playerControls.setEnabled(false)
    }
    
    private func showContentState() {
        isLoading = false
        skeletonView.stopLoading()
        lyricsTableView.isHidden = false
        lyricsTableView.reloadData()
        
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
    
    private func updateLoadingState() {
        // 로딩 상태 변경에 따른 추가 UI 업데이트가 필요하면 여기에
    }

    func highlightParagraph(at index: Int) {
        guard index >= 0 && index < paragraphs.count && !isLoading else { return }
        
        currentHighlightIndex = index
        
        // 테이블뷰 새로고침 (하이라이트 변경을 위해)
        lyricsTableView.reloadData()
        
        // 중앙으로 스크롤 (애니메이션과 함께)
        let indexPath = IndexPath(row: index, section: 0)
        lyricsTableView.scrollToRow(at: indexPath, at: .middle, animated: true)
    }
    
    func updateProgress(_ currentTime: TimeInterval, totalTime: TimeInterval) {
        guard !isLoading else { return }
        
        // 현재 시간 표시 업데이트
        let currentMinutes = Int(currentTime) / 60
        let currentSeconds = Int(currentTime) % 60
        currentTimeLabel.text = String(format: "%d:%02d", currentMinutes, currentSeconds)
        
        // 진행 바 업데이트
        if totalTime > 0 {
            progressView.setProgress(Float(currentTime / totalTime), animated: true)
        }
    }
    
    func updatePlayerState(_ isPlaying: Bool) {
        let state: PlayerControlState = isPlaying ? .playing : .idle
        playerControls.setState(state)
        
        // 플레이 상태에 따른 그라데이션 표시/숨김
        showFadeoutGradient(isPlaying)
        
        // ArtnerPrimaryBar 그라데이션도 플레이 상태에 따라 제어
        artnerPrimaryBar.setGradientVisible(isPlaying)
    }
    
    // MARK: - Gradient Control Methods
    
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
        
        cell.configure(with: paragraph, isHighlighted: isHighlighted)
        
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
        
        print("📏 문단 \(indexPath.row) 추정 높이: \(estimatedHeight) (텍스트 길이: \(textLength))")
        
        return max(80, estimatedHeight)
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        // 셀이 표시될 때 레이아웃 강제 갱신
        cell.layoutIfNeeded()
    }
}

// MARK: - Custom Cell for Paragraphs

final class ParagraphTableViewCell: UITableViewCell {
    
    private let paragraphLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(paragraphLabel)
        
        paragraphLabel.textAlignment = .left
        paragraphLabel.numberOfLines = 0  // 무제한 줄
        paragraphLabel.lineBreakMode = .byWordWrapping
        paragraphLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        
        // 추가 설정: 텍스트가 잘리지 않도록
        paragraphLabel.adjustsFontSizeToFitWidth = false  // 폰트 크기 자동 조정 끄기
        paragraphLabel.minimumScaleFactor = 1.0  // 최소 스케일 팩터
        
        // 텍스트가 잘리지 않도록 Content Priority 설정
        paragraphLabel.setContentCompressionResistancePriority(.required, for: .vertical)
        paragraphLabel.setContentCompressionResistancePriority(.required, for: .horizontal)  // 수평도 추가
        paragraphLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        paragraphLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.top.bottom.equalToSuperview().inset(20)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 여러 줄 텍스트의 올바른 높이 계산을 위해 preferredMaxLayoutWidth 설정
        let availableWidth = contentView.bounds.width - 40  // 좌우 여백 20px씩 제외
        if availableWidth > 0 && paragraphLabel.preferredMaxLayoutWidth != availableWidth {
            paragraphLabel.preferredMaxLayoutWidth = availableWidth
            print("🔧 preferredMaxLayoutWidth 업데이트: \(availableWidth)")
        }
    }
    
    func configure(with paragraph: DocentParagraph, isHighlighted: Bool) {
        // 실제 fullText 사용
        paragraphLabel.text = paragraph.fullText
        
        // 핵심 디버깅만 유지
        if isHighlighted {
            print("🎯 하이라이트 문단: \(paragraph.id) - 길이: \(paragraph.fullText.count)자")
        }
        
        if isHighlighted {
            // 현재 재생 중인 문단 - 밝고 크게
            paragraphLabel.textColor = AppColor.textPrimary
            paragraphLabel.font = UIFont.systemFont(ofSize: 18, weight: .medium)
            paragraphLabel.alpha = 0.9
            
            // 부드러운 확대 애니메이션
            UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.3, options: .curveEaseOut) {
                self.transform = CGAffineTransform(scaleX: 1.02, y: 1.02)
            }
        } else {
            // 다른 문단들 - #ffffff로 변경
            paragraphLabel.textColor = AppColor.textPrimary
            paragraphLabel.font = UIFont.systemFont(ofSize: 18, weight: .regular)
            paragraphLabel.alpha = 0.35
            
            // 원래 크기로 복원
            UIView.animate(withDuration: 0.3) {
                self.transform = .identity
            }
        }
        
        // 텍스트 설정 후 레이아웃 강제 갱신
        paragraphLabel.setNeedsLayout()
        paragraphLabel.layoutIfNeeded()
        setNeedsLayout()
        layoutIfNeeded()
    }
}
