//
//  PlayerViewController.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//
import UIKit

final class PlayerViewController: BaseViewController<PlayerViewModel, AppCoordinator> {

    private let playerView = PlayerView()

    override func loadView() {
        self.view = playerView
    }

    override func setupUI() {
        super.setupUI()
        setupSwipeGesture()
    }
    
    private func setupSwipeGesture() {
        // 좌→우 스와이프 제스처 추가
        let swipeGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        view.addGestureRecognizer(swipeGesture)
        
        print("👆 스와이프 제스처 설정 완료 - 좌→우 스와이프로 뒤로가기")
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: view)
        let velocity = gesture.velocity(in: view)
        
        switch gesture.state {
        case .began:
            print("👆 스와이프 시작")
            
        case .changed:
            // 좌→우 스와이프만 허용 (x > 0이고 수평 움직임이 수직보다 클 때)
            if translation.x > 0 && abs(translation.x) > abs(translation.y) {
                // 스와이프 진행에 따른 시각적 피드백 (선택사항)
                let progress = min(translation.x / view.frame.width, 1.0)
                view.alpha = 1.0 - (progress * 0.3) // 살짝 투명해지는 효과
            }
            
        case .ended, .cancelled:
            // 충분한 거리나 속도로 스와이프했을 때 뒤로가기
            let shouldDismiss = translation.x > 100 || velocity.x > 800
            
            if shouldDismiss {
                print("👆 스와이프 완료 - 뒤로가기 실행")
                dismissPlayer()
            } else {
                // 원래 상태로 복원
                UIView.animate(withDuration: 0.3) {
                    self.view.alpha = 1.0
                    self.view.transform = .identity
                }
            }
            
        default:
            break
        }
    }
    
    private func dismissPlayer() {
        // 뒤로가기 애니메이션
        UIView.animate(withDuration: 0.3, animations: {
            self.view.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
            self.view.alpha = 0.7
        }) { _ in
            // 네비게이션으로 뒤로가기
            self.navigationController?.popViewController(animated: false)
        }
    }

    override func setupBinding() {
        super.setupBinding()
        print("🔧 PlayerViewController setupBinding 시작")
        bindData()
        bindAction()
        print("🔧 PlayerViewController setupBinding 완료")
    }

    private func bindData() {
        print("📊 PlayerViewController bindData 시작")
        
        // 도슨트 정보 설정
        let docent = viewModel.getDocent()
        playerView.artnerPrimaryBar.setTitle(docent.title, subtitle: docent.artist)

        // 문단 데이터 설정
        let paragraphs = viewModel.getParagraphs()
        playerView.setParagraphs(paragraphs)

        // 하이라이트 인덱스 변경 감지 (문단 단위)
        viewModel.onHighlightIndexChanged = { [weak self] index in
            DispatchQueue.main.async {
                self?.playerView.highlightParagraph(at: index)
            }
        }
        
        // 진행률 업데이트 감지
        viewModel.onProgressChanged = { [weak self] currentTime, totalTime in
            DispatchQueue.main.async {
                self?.playerView.updateProgress(currentTime, totalTime: totalTime)
            }
        }
        
        // 재생 상태 변경 감지
        viewModel.onPlayStateChanged = { [weak self] isPlaying in
            DispatchQueue.main.async {
                print("🎵 재생 상태 변경: \(isPlaying)")
                self?.playerView.updatePlayerState(isPlaying)
            }
        }
        
        // 로딩 상태 변경 감지
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                print("🔄 로딩 상태 변경: \(isLoading ? "로딩 중" : "로딩 완료")")
                // PlayerView 내부에서 로딩 상태를 자동 처리하므로 추가 작업 불필요
            }
        }
        
        print("📊 PlayerViewController bindData 완료")
    }

    private func bindAction() {
        print("🎯 PlayerViewController bindAction 시작")
        
        // 플레이어 컨트롤 액션들
        setupPlayerControlActions()
        
        // 네비게이션 뒤로가기 버튼 액션
        playerView.customNavigationBar.onBackButtonTapped = { [weak self] in
            self?.coordinator.popViewController(animated: true)
        }
        
        print("🎯 PlayerViewController bindAction 완료")
    }
    
    private func setupPlayerControlActions() {
        print("🎮 PlayerViewController setupPlayerControlActions 시작")
        
        // 플레이어 컨트롤 액션들을 PlayerView를 통해 설정
        playerView.setupPlayerControlsActions(
            onSave: { [weak self] in
                print("💾 저장 액션 콜백 실행됨")
                self?.handleSaveAction()
            },
            onPlay: { [weak self] in
                print("▶️ 플레이 액션 콜백 실행됨")
                self?.handlePlayAction()
            },
            onPause: { [weak self] in
                print("⏸️ 정지 액션 콜백 실행됨")
                self?.handlePauseAction()
            },
            onReplay: { [weak self] in
                print("🔄 리플레이 액션 콜백 실행됨")
                self?.handleReplayAction()
            }
        )
        
        print("🎮 PlayerViewController setupPlayerControlActions 완료")
    }
    
    // MARK: - Action Handlers
    
    private func handleSaveAction() {
        print("💾 저장 버튼 클릭")
        // TODO: 현재 문단이나 전체 도슨트를 저장하는 로직 구현
        showSaveConfirmation()
    }
    
    private func handlePlayAction() {
        print("▶️ 플레이 버튼 클릭")
        viewModel.togglePlayPause()
    }
    
    private func handlePauseAction() {
        print("⏸️ 정지 버튼 클릭")
        viewModel.togglePlayPause()
    }
    
    private func handleReplayAction() {
        print("🔄 리플레이 버튼 클릭")
        viewModel.replay()
    }
    
    // MARK: - Helper Methods
    
    private func showSaveConfirmation() {
        let alert = UIAlertController(
            title: "저장 완료",
            message: "도슨트가 저장되었습니다.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
}
