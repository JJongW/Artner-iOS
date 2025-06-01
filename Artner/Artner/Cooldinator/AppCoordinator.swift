//
//  AppCoordinator.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController

    private let docentRepository = DocentRepositoryImpl()
    private lazy var playDocentUseCase: PlayDocentUseCase = PlayDocentUseCaseImpl(repository: docentRepository)

    private let feedRepository = FeedRepositoryImpl()
    private lazy var fetchFeedUseCase: FetchFeedUseCase = FetchFeedUseCaseImpl(repository: feedRepository)

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        let homeViewModel = HomeViewModel(fetchFeedUseCase: fetchFeedUseCase)
        let homeVC = HomeViewController(viewModel: homeViewModel, coordinator: self)
        homeVC.onCameraTapped = { [weak self] in
            self?.presentCameraEntry()
        }
        navigationController.viewControllers = [homeVC]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }

    func showEntry(docent: Docent) {
        let viewModel = EntryViewModel(docent: docent)
        let vc = EntryViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showPlayer(docent: Docent) {
        let playerViewModel = PlayerViewModel(docent: docent)
        let playerVC = PlayerViewController(viewModel: playerViewModel, coordinator: self)
        navigationController.pushViewController(playerVC, animated: true)
    }

    func presentCameraEntry() {
        // 샘플 Docent 생성 후 EntryViewController 진입
        let sample = Docent(
            id: 999,
            title: "카메라로 스캔한 작품",
            artist: "미지의 작가",
            description: "이 작품은 이미지 인식을 통해 탐색된 결과입니다.", imageURL: "https://www.naver.com",
            audioURL: nil
        )
        showEntry(docent: sample)
    }

    func popViewController(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }
}
