//
//  AppCooldinator.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

// Coordinator/AppCoordinator.swift
import UIKit

final class AppCoordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController

    private let docentRepository = DocentRepositoryImpl()
    private lazy var playDocentUseCase: PlayDocentUseCase = PlayDocentUseCaseImpl(repository: docentRepository)

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        let homeViewModel = DocentListViewModel(useCase: playDocentUseCase)
        let homeVC = HomeViewController(viewModel: homeViewModel, coordinator: self)
        navigationController.viewControllers = [homeVC]
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    func showPlayer(docent: Docent) {
        let playerViewModel = PlayerViewModel(docent: docent)
        let playerVC = PlayerViewController(viewModel: playerViewModel, coordinator: self)
        navigationController.pushViewController(playerVC, animated: true)
    }
    func popViewController(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }
}
