//
//  PlayerViewController.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import UIKit

final class PlayerViewController: UIViewController, UIScrollViewDelegate {

    private let playerView = PlayerView()
    private let viewModel: PlayerViewModel

    init(docent: Docent) {
        self.viewModel = PlayerViewModel(docent: docent)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() {
        self.view = playerView
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bindData()
        bindAction()
        playerView.scrollView.delegate = self
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
            self?.navigationController?.popViewController(animated: true)
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

    @objc private func didTapBack() {
        navigationController?.popViewController(animated: true)
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y

        let maxOffset: CGFloat = 60 // 네비게이션 바 높이
        let offset = min(max(offsetY, 0), maxOffset) // 0 ~ 44 사이로 제한

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
