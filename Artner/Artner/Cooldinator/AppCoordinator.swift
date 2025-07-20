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
        // 임시로 EntryViewController로 바로 이동 (카메라 권한 테스트 완료 후 CameraViewController로 변경 예정)
        let sample = Docent(
            id: 999,
            title: "카메라로 스캔한 작품",
            artist: "미지의 작가",
            description: "이 작품은 이미지 인식을 통해 탐색된 결과입니다.", 
            imageURL: "https://www.naver.com",
            audioURL: nil
        )
        showEntry(docent: sample)
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
