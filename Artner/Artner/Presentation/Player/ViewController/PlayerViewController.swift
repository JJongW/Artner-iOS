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
        playerView.playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
    }

    override func setupBinding() {
        super.setupBinding()
        bindData()
        bindAction()
    }

    private func bindData() {
        let docent = viewModel.getDocent()
        playerView.artnerPrimaryBar.setTitle(docent.title, subtitle: docent.artist)

        let scripts = viewModel.getScripts()
        playerView.setScripts(scripts)

        viewModel.onHighlightIndexChanged = { [weak self] index in
            DispatchQueue.main.async {
                self?.playerView.highlightScript(at: index)
            }
        }
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
}
