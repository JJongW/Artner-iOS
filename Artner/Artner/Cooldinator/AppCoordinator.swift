//
//  AppCoordinator.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

import UIKit
import Combine

final class AppCoordinator {
    private let window: UIWindow
    private let navigationController: UINavigationController

    // DI Container 사용
    private let container = DIContainer.shared

    private var sideMenu: SideMenuContainerView?

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()
        
        // 강제 로그아웃 노티피케이션 구독
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleForceLogout),
            name: NSNotification.Name("ForceLogout"),
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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

    /// 카메라를 닫고 Player 화면으로 이동
    func dismissCameraAndShowPlayer(docent: Docent) {
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true) { [weak self] in
                self?.showPlayer(docent: docent)
            }
        } else {
            showPlayer(docent: docent)
        }
    }

    func showCamera() {
        let cameraVC = CameraViewController(coordinator: self)
        cameraVC.modalPresentationStyle = .fullScreen
        navigationController.present(cameraVC, animated: true)
    }
    
    /// 카메라를 닫고 Entry 화면으로 이동
    func dismissCameraAndShowEntry(docent: Docent) {
        // CameraViewController가 present된 상태라면 먼저 dismiss
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true) { [weak self] in
                // dismiss 완료 후 Entry 화면으로 이동
                self?.showEntry(docent: docent)
            }
        } else {
            // 이미 dismiss된 경우 바로 Entry로 이동
            showEntry(docent: docent)
        }
    }

    func navigateToEntryFromCamera(with capturedImage: UIImage? = nil) {
        // 더미 도슨트 데이터
        let docents = container.playDocentUseCase.fetchDocents()
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
        
        let docent = docents.first ?? fallback
        
        // CameraViewController가 present되어 있으면 먼저 dismiss
        // (이 메서드는 검색창 탭 등에서 호출됨)
        // dismissCameraAndShowEntry와 동일한 로직 적용
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true) { [weak self] in
                self?.showEntry(docent: docent)
            }
        } else {
            showEntry(docent: docent)
        }
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
        let likeViewModel = DIContainer.shared.makeLikeViewModel()
        let likeVC = LikeViewController(viewModel: likeViewModel)
        likeVC.goToFeedHandler = { [weak self] in self?.popToHome() }
        navigationController.pushViewController(likeVC, animated: true)
    }
    func showSave() {
        let saveVC = SaveViewController()
        saveVC.goToFeedHandler = { [weak self] in self?.popToHome() }
        navigationController.pushViewController(saveVC, animated: true)
    }
    func showUnderline() {
        let underlineVM = DIContainer.shared.makeUnderlineViewModel()
        let underlineVC = UnderlineViewController(viewModel: underlineVM)
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
    
    func sidebarDidRequestLogout() {
        print("🚪 AppCoordinator: 로그아웃 처리 시작")
        
        // 로그아웃 UseCase 실행
        let logoutUseCase = LogoutUseCaseImpl()
        var cancellable: AnyCancellable?
        
        cancellable = logoutUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("❌ AppCoordinator: 로그아웃 실패 - \(error.localizedDescription)")
                        self?.showLogoutError()
                    }
                    cancellable?.cancel()
                },
                receiveValue: { [weak self] _ in
                    print("✅ AppCoordinator: 로그아웃 성공 - 로그인 화면으로 이동")
                    
                    // 로그아웃 성공 토스트 표시
                    ToastManager.shared.showSuccess("로그아웃되었습니다")
                    
                    // 사이드바 닫고 로그인 화면으로 이동 (토스트가 보이도록 약간 지연)
                    self?.sideMenu?.dismissMenu(completion: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self?.navigateToLaunch()
                        }
                    })
                }
            )
    }
    
    private func showLogoutError() {
        let alert = UIAlertController(
            title: "로그아웃 실패",
            message: "로그아웃 중 오류가 발생했습니다.\n다시 시도해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        navigationController.present(alert, animated: true)
    }
    
    /// 강제 로그아웃 처리 (토큰 만료 시)
    @objc private func handleForceLogout() {
        print("🚨 강제 로그아웃 - 토큰 만료")
        
        // 사이드 메뉴가 있으면 닫기
        if let sideMenu = sideMenu {
            sideMenu.dismissMenu(completion: { [weak self] in
                self?.navigateToLaunch()
            })
        } else {
            navigateToLaunch()
        }
    }
    
    private func navigateToLaunch() {
        // 모든 화면을 제거하고 LaunchViewController로 돌아가기
        let launchViewModel = LaunchViewModel()
        let launchVC = LaunchViewController(viewModel: launchViewModel)
        navigationController.setViewControllers([launchVC], animated: true)
    }
}
