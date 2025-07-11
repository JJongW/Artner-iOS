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

    private var sideMenu: SideMenuContainerView?

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
        homeVC.onShowSidebar = { [weak self, weak homeVC] in
            guard let self = self, let homeVC = homeVC else { return }
            self.showSidebar(from: homeVC)
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

    func showChat(docent: Docent, keyword: String) {
        let viewModel = ChatViewModel(keyword: keyword, docent: docent)
        let vc = ChatViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showPlayer(docent: Docent) {
        let playerViewModel = PlayerViewModel(docent: docent)
        let playerVC = PlayerViewController(viewModel: playerViewModel, coordinator: self)
        navigationController.pushViewController(playerVC, animated: true)
    }

    func presentCameraEntry() {
        // 카메라 촬영 화면으로 이동
        let cameraVC = CameraViewController()
        cameraVC.modalPresentationStyle = .fullScreen
        navigationController.present(cameraVC, animated: true)
    }

    func showSidebar(from presentingVC: UIViewController) {
        let sidebarVC = SidebarViewController()
        sidebarVC.delegate = self // delegate 연결
        let sideMenu = SideMenuContainerView(menuViewController: sidebarVC, parentViewController: presentingVC)
        self.sideMenu = sideMenu
        sideMenu.present(in: presentingVC)
    }

    func popViewController(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }

    // MARK: - 좋아요/저장/밑줄/전시기록 화면 이동
    func showLike() {
        let likeVC = LikeViewController()
        likeVC.goToFeedHandler = { [weak self] in self?.popToHome() }
        navigationController.pushViewController(likeVC, animated: true)
    }
    func showSave() {
        let saveVC = SaveViewController()
        saveVC.goToFeedHandler = { [weak self] in self?.popToHome() }
        navigationController.pushViewController(saveVC, animated: true)
    }
    func showUnderline() {
        let underlineVC = UnderlineViewController()
        underlineVC.goToFeedHandler = { [weak self] in self?.popToHome() }
        navigationController.pushViewController(underlineVC, animated: true)
    }
    func showRecord() {
        let recordVC = RecordViewController()
        recordVC.goToFeedHandler = { [weak self] in self?.popToHome() }
        navigationController.pushViewController(recordVC, animated: true)
    }
    // 홈으로 이동 (예시)
    private func popToHome() {
        navigationController.popToRootViewController(animated: true)
    }
}

// MARK: - SidebarViewControllerDelegate 구현
extension AppCoordinator: SidebarViewControllerDelegate {
    func sidebarDidRequestClose() {
        sideMenu?.dismissMenu()
    }
    func sidebarDidRequestShowLike() {
        sideMenu?.dismissMenu(completion: { [weak self] in self?.showLike() })
    }
    func sidebarDidRequestShowSave() {
        sideMenu?.dismissMenu(completion: { [weak self] in self?.showSave() })
    }
    func sidebarDidRequestShowUnderline() {
        sideMenu?.dismissMenu(completion: { [weak self] in self?.showUnderline() })
    }
    func sidebarDidRequestShowRecord() {
        sideMenu?.dismissMenu(completion: { [weak self] in self?.showRecord() })
    }
}
