//
//  PlayerViewController.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import UIKit

final class PlayerViewController: UIViewController {

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
    }

    private func bindData() {
        let docent = viewModel.getDocent()
        playerView.titleLabel.text = docent.title
        playerView.artistLabel.text = docent.artist
        playerView.descriptionLabel.text = docent.description
        playerView.playButton.setTitle(viewModel.currentPlayButtonTitle(), for: .normal)
    }

    private func bindAction() {
        playerView.playButton.addTarget(self, action: #selector(didTapPlay), for: .touchUpInside)
        playerView.backButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
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

}
