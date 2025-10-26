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

    // DI Container 사용
    private let container = DIContainer.shared

    private var sideMenu: SideMenuContainerView?

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
    }

    func start() {
        // DI Container 설정
        container.configureForDevelopment()
        
        // DI Container를 통해 ViewModel 생성
        let homeViewModel = container.makeHomeViewModel()
        let homeVC = HomeViewController(viewModel: homeViewModel, coordinator: self)
        homeVC.onCameraTapped = { [weak self] in
            self?.showCamera()
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
        let playerViewModel = container.makePlayerViewModel(docent: docent)
        let playerVC = PlayerViewController(viewModel: playerViewModel, coordinator: self)
        navigationController.pushViewController(playerVC, animated: true)
    }

    func showCamera() {
        let cameraVC = CameraViewController(coordinator: self)
        cameraVC.modalPresentationStyle = .fullScreen
        navigationController.present(cameraVC, animated: true)
    }

    func navigateToEntryFromCamera(with capturedImage: UIImage? = nil) {
        // 카메라에서 촬영한 이미지를 기반으로 Entry로 진입
        // 실제로는 이미지 인식 API를 호출해서 작품 정보를 가져와야 함
        
        // 현재는 더미 도슨트 데이터 활용 (Clean Architecture: UseCase를 통해 접근)
        let docents = container.playDocentUseCase.fetchDocents()
        if let first = docents.first, !first.paragraphs.isEmpty {
            showEntry(docent: first)
            return
        }
        
        // 폴백: 촬영된 이미지를 기반으로 한 샘플 생성
        let fallback = Docent(
            id: 999,
            title: "카메라로 스캔한 작품",
            artist: "미지의 작가", 
            description: "이 작품은 이미지 인식을 통해 탐색된 결과입니다.",
            imageURL: "https://www.naver.com",
            audioURL: nil,
            paragraphs: [
                DocentParagraph(
                    id: "p-999-1",
                    startTime: 0.0,
                    endTime: 8.0,
                    sentences: [
                        DocentScript(startTime: 0.0, text: "카메라로 스캔한 작품에 대한 자동 생성 안내 문단입니다.")
                    ]
                )
            ]
        )
        showEntry(docent: fallback)
    }

    func showSidebar(from presentingVC: UIViewController) {
        // DI Container를 통해 SidebarViewModel 생성
        let sidebarViewModel = container.makeSidebarViewModel()
        let sidebarVC = SidebarViewController(viewModel: sidebarViewModel)
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
        recordVC.goToRecordHandler = { [weak self] in 
            self?.showRecordInput()
        }
        navigationController.pushViewController(recordVC, animated: true)
    }
    
    func showRecordInput() {
        let recordInputVC = RecordInputViewController()
        recordInputVC.onRecordSaved = { [weak self] recordItem in
            print("📝 [AppCoordinator] 전시 기록이 저장되었습니다: \(recordItem.exhibitionName)")
            // NotificationCenter를 통해 전시기록 목록 새로고침
            // RecordInputViewController에서 이미 NotificationCenter로 알림을 보내므로
            // 여기서는 추가 작업이 필요하지 않음
        }
        recordInputVC.onDismiss = { [weak self] in
            print("📝 [AppCoordinator] 전시 기록 입력 취소")
        }
        
        // Full screen 모달로 표시
        recordInputVC.modalPresentationStyle = .fullScreen
        navigationController.present(recordInputVC, animated: true)
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
