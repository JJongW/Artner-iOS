//
//  PlayerControlsView.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import UIKit
import SnapKit

// MARK: - Player Control State
enum PlayerControlState {
    case idle      // 정지/시작 전 상태 (저장, 플레이, 리플레이)
    case playing   // 플레이 중 상태 (정지, 저장)
}

// MARK: - Player Controls View
final class PlayerControlsView: UIView {
    
    // MARK: - UI Components
    
    private let containerView = UIView()
    
    // 버튼들
    private let saveButton = UIButton(type: .system)
    private let playButton = UIButton(type: .system)
    private let pauseButton = UIButton(type: .system)
    private let replayButton = UIButton(type: .system)
    
    // 현재 상태
    private var currentState: PlayerControlState = .idle {
        didSet {
            updateButtonsForState()
        }
    }
    
    // MARK: - Design Constants
    
    private struct DesignConstants {
        static let containerRadius: CGFloat = 20
        static let containerColor = UIColor(hex: "#3D312C")
        static let verticalMargin: CGFloat = 16
        static let horizontalMargin: CGFloat = 26
        static let buttonSpacing: CGFloat = 42
        static let regularButtonSize: CGFloat = 24
        static let playButtonSize: CGFloat = 32
        
        // 계산된 컨테이너 크기
        static let containerHeight: CGFloat = verticalMargin * 2 + playButtonSize
        static let twoButtonWidth: CGFloat = horizontalMargin * 2 + regularButtonSize + buttonSpacing + playButtonSize
        static let threeButtonWidth: CGFloat = horizontalMargin * 2 + regularButtonSize + buttonSpacing + playButtonSize + buttonSpacing + regularButtonSize
    }
    
    // MARK: - Callbacks
    
    var onSaveButtonTapped: (() -> Void)?
    var onPlayButtonTapped: (() -> Void)?
    var onPauseButtonTapped: (() -> Void)?
    var onReplayButtonTapped: (() -> Void)?
    
    // MARK: - Init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupInitialLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        addSubview(containerView)

        // 컨테이너 설정 - 새로운 디자인 스펙 적용
        containerView.backgroundColor = DesignConstants.containerColor
        containerView.layer.cornerRadius = DesignConstants.containerRadius
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowRadius = 8
        containerView.layer.shadowOpacity = 0.3
        containerView.isUserInteractionEnabled = true
        containerView.clipsToBounds = false
        self.isUserInteractionEnabled = true
        self.clipsToBounds = false
        
        // 저장 버튼 (북마크)
        setupSaveButton()
        
        // 플레이 버튼
        setupPlayButton()
        
        // 정지 버튼
        setupPauseButton()
        
        // 리플레이 버튼
        setupReplayButton()
        
        // 초기 상태 설정
        updateButtonsForState()
    }
    
    private func setupSaveButton() {
        // 템플릿 렌더링 강제 적용하여 tintColor가 항상 반영되도록 처리
        let icon = UIImage(named: "ic_save")?.withRenderingMode(.alwaysTemplate)
        saveButton.setImage(icon, for: .normal)
        saveButton.tintColor = AppColor.textPrimary
        saveButton.imageView?.contentMode = .scaleAspectFit
        saveButton.isEnabled = true
        saveButton.isUserInteractionEnabled = true
        containerView.addSubview(saveButton)
    }
    
    private func setupPlayButton() {
        playButton.setImage(UIImage(named: "ic_play"), for: .normal)
        playButton.tintColor = AppColor.textPrimary
        playButton.imageView?.contentMode = .scaleAspectFit
        containerView.addSubview(playButton)
    }
    
    private func setupPauseButton() {
        pauseButton.setImage(UIImage(named: "ic_pause"), for: .normal)
        pauseButton.tintColor = AppColor.textPrimary
        pauseButton.imageView?.contentMode = .scaleAspectFit
        containerView.addSubview(pauseButton)
    }
    
    private func setupReplayButton() {
        replayButton.setImage(UIImage(named: "ic_replay"), for: .normal)
        replayButton.tintColor = AppColor.textPrimary
        replayButton.imageView?.contentMode = .scaleAspectFit
        containerView.addSubview(replayButton)
    }
    
    private func setupInitialLayout() {
        // 컨테이너를 가장 큰 크기로 고정 (3버튼 크기)
        containerView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.height.equalToSuperview() // Match the height of the containerView to its superview to resolve constraint conflict
            $0.width.equalTo(DesignConstants.threeButtonWidth) // 항상 3버튼 크기로 고정
            $0.top.greaterThanOrEqualToSuperview().offset(0) // Ensure top is not negative
        }
        
        // 버튼 크기 설정 (초기에는 모두 숨김)
        [saveButton, playButton, pauseButton, replayButton].forEach { button in
            button.snp.makeConstraints {
                $0.width.height.equalTo(DesignConstants.regularButtonSize)
                $0.centerY.equalToSuperview()
            }
            button.isHidden = true
        }
        
    }
    
    // MARK: - Intrinsic Content Size
    
    override var intrinsicContentSize: CGSize {
        // 항상 고정 크기 반환 (가장 큰 크기)
        return CGSize(width: DesignConstants.threeButtonWidth, height: DesignConstants.containerHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        playButton.addTarget(self, action: #selector(playButtonTapped), for: .touchUpInside)
        pauseButton.addTarget(self, action: #selector(pauseButtonTapped), for: .touchUpInside)
        replayButton.addTarget(self, action: #selector(replayButtonTapped), for: .touchUpInside)
        
    }
    
    // MARK: - State Management
    
    private func updateButtonsForState() {

        // 1단계: 현재 버튼들을 페이드 아웃
        UIView.animate(withDuration: 0.2, animations: {
            [self.saveButton, self.playButton, self.pauseButton, self.replayButton].forEach {
                $0.alpha = 0.0
            }
        }) { _ in
            // 2단계: 버튼 숨기기 및 레이아웃 변경
            [self.saveButton, self.playButton, self.pauseButton, self.replayButton].forEach {
                $0.isHidden = true
                $0.alpha = 1.0 // alpha 복원
            }

            // 새로운 상태에 따른 레이아웃 설정
            switch self.currentState {
            case .idle:
                self.setupIdleLayout()
            case .playing:
                self.setupPlayingLayout()
            }

            // 레이아웃 즉시 적용 (제약조건이 올바르게 반영되도록)
            self.containerView.layoutIfNeeded()

            // 새로운 버튼들을 보이게 하되 alpha 0으로 시작
            switch self.currentState {
            case .idle:
                self.saveButton.isHidden = false
                self.playButton.isHidden = false
                self.replayButton.isHidden = false
                self.saveButton.alpha = 1.0
                self.saveButton.isUserInteractionEnabled = true
                self.playButton.alpha = 0.0
                self.replayButton.alpha = 0.0
            case .playing:
                self.saveButton.isHidden = false
                self.pauseButton.isHidden = false
                self.saveButton.alpha = 1.0
                self.saveButton.isUserInteractionEnabled = true
                self.pauseButton.alpha = 0.0
            }

            // 3단계: 새 버튼들을 페이드 인
            UIView.animate(withDuration: 0.2, delay: 0.1, options: [.curveEaseOut]) {
                switch self.currentState {
                case .idle:
                    self.saveButton.alpha = 1.0
                    self.playButton.alpha = 1.0
                    self.replayButton.alpha = 1.0
                case .playing:
                    self.saveButton.alpha = 1.0
                    self.pauseButton.alpha = 1.0
                }
            }
        }
    }
    
    private func setupIdleLayout() {
        saveButton.isHidden = false
        playButton.isHidden = false
        replayButton.isHidden = false
        
        // 컨테이너 크기 변경
        containerView.snp.updateConstraints {
            $0.width.equalTo(DesignConstants.threeButtonWidth) // 3개 버튼을 위한 너비
        }
        
        saveButton.snp.remakeConstraints {
            $0.width.height.equalTo(DesignConstants.regularButtonSize)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(DesignConstants.horizontalMargin)
        }
        
        playButton.snp.remakeConstraints {
            $0.width.height.equalTo(DesignConstants.playButtonSize) // 플레이 버튼은 조금 더 크게
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(saveButton.snp.trailing).offset(DesignConstants.buttonSpacing)
        }
        
        replayButton.snp.remakeConstraints {
            $0.width.height.equalTo(DesignConstants.regularButtonSize)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(playButton.snp.trailing).offset(DesignConstants.buttonSpacing)
        }
    }
    
    private func setupPlayingLayout() {
        pauseButton.isHidden = false
        saveButton.isHidden = false
        
        // 컨테이너 크기 변경
        containerView.snp.updateConstraints {
            $0.width.equalTo(DesignConstants.twoButtonWidth) // 2개 버튼을 위한 너비
        }
        
        // 저장 버튼을 첫 번째로 배치
        saveButton.snp.remakeConstraints {
            $0.width.height.equalTo(DesignConstants.regularButtonSize)
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().offset(DesignConstants.horizontalMargin)
        }
        
        // 정지 버튼을 두 번째로 배치
        pauseButton.snp.remakeConstraints {
            $0.width.height.equalTo(DesignConstants.playButtonSize)
            $0.centerY.equalToSuperview()
            $0.leading.equalTo(saveButton.snp.trailing).offset(DesignConstants.buttonSpacing)
        }
    }
    
    // MARK: - Public Methods
    
    func setState(_ state: PlayerControlState) {
        currentState = state
    }
    
    func setEnabled(_ enabled: Bool) {
        // 저장 버튼은 항상 동작 가능하도록 유지 (요구사항)
        saveButton.isEnabled = true
        saveButton.isUserInteractionEnabled = true
        saveButton.alpha = 1.0
        // 나머지 컨트롤만 토글
        [playButton, pauseButton, replayButton].forEach {
            $0.isEnabled = enabled
            $0.isUserInteractionEnabled = enabled
            $0.alpha = enabled ? 1.0 : 0.5
        }
    }
    
    /// 저장 상태에 따라 저장 버튼 색을 변경
    /// - Parameter saved: true면 #FF7C27, false면 기본 색상
    func setSaved(_ saved: Bool) {
        // 아이콘 스왑 + 색상 변경
        let imageName = saved ? "ic_save_filled" : "ic_save"
        let icon = UIImage(named: imageName)?.withRenderingMode(.alwaysTemplate)
        saveButton.setImage(icon, for: .normal)
        saveButton.tintColor = saved ? UIColor(hex: "#FF7C27") : AppColor.textPrimary
    }
    
    // MARK: - Touch Debugging
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? { super.hitTest(point, with: event) }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool { super.point(inside: point, with: event) }
    
    func logButtonStates() {
        // Intentionally left minimal for on-demand debugging if needed.
    }
    
    // MARK: - Actions
    
    @objc private func saveButtonTapped() {
        print("💾 [PlayerControlsView] saveButtonTapped 호출됨 - state: \(currentState)")
        // 버튼 터치 피드백
        addTouchFeedback(to: saveButton)
        onSaveButtonTapped?()
    }
    
    @objc private func playButtonTapped() {
        addTouchFeedback(to: playButton)
        onPlayButtonTapped?()
    }
    
    @objc private func pauseButtonTapped() {
        addTouchFeedback(to: pauseButton)
        onPauseButtonTapped?()
    }
    
    @objc private func replayButtonTapped() {
        addTouchFeedback(to: replayButton)
        onReplayButtonTapped?()
    }
    
    // MARK: - Helper Methods
    
    private func addTouchFeedback(to button: UIButton) {
        UIView.animate(withDuration: 0.1, animations: {
            button.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        }) { _ in
            UIView.animate(withDuration: 0.1) {
                button.transform = .identity
            }
        }
    }
} 
