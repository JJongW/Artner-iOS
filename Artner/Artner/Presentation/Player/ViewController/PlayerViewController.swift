//
//  PlayerViewController.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//
import UIKit
import UIKit

final class PlayerViewController: BaseViewController<PlayerViewModel, AppCoordinator>, UIScrollViewDelegate {

    private let playerView = PlayerView()

    override func loadView() {
        self.view = playerView
    }

    override func setupUI() {
        super.setupUI()
        playerView.scrollView.delegate = self
    }

    override func setupBinding() {
        super.setupBinding()
        bindData()
        bindAction()
    }

    private func bindData() {
        let docent = viewModel.getDocent()
        playerView.customNavigationBar.setTitle("artner")
        playerView.artnerPrimaryBar.setTitle("홀로페르네스의 목을 베는 유디트", subtitle: "아르테미시아 젠틸레스키")
        playerView.artistLabel.text = docent.artist
        playerView.descriptionLabel.text = docent.description
        playerView.playButton.setTitle(viewModel.currentPlayButtonTitle(), for: .normal)
    }

    private func bindAction() {
        playerView.playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        playerView.customNavigationBar.onBackButtonTapped = { [weak self] in
            self?.coordinator.popViewController(animated: true)
        }
    }

    @objc private func didTapPlay() {
        viewModel.togglePlayPause()
        playerView.playButton.setTitle(viewModel.currentPlayButtonTitle(), for: .normal)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        let maxOffset: CGFloat = 60
        let offset = min(max(offsetY, 0), maxOffset)

        playerView.customNavigationBar.transform = CGAffineTransform(translationX: 0, y: -offset)
        playerView.customNavigationBar.alpha = 1 - (offset / maxOffset * 0.8)
        playerView.artnerPrimaryBar.transform = CGAffineTransform(translationX: 0, y: -offset)
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let shouldHide = scrollView.contentOffset.y > 30

        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: [], animations: {
            self.playerView.customNavigationBar.transform = shouldHide ? CGAffineTransform(translationX: 0, y: -60) : .identity
            self.playerView.customNavigationBar.alpha = shouldHide ? 0 : 1
        }, completion: nil)
    }
}
