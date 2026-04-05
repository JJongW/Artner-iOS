//
//  AppCoordinator.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//  Feature Isolation Refactoring - 모든 Feature Coordinator 프로토콜 구현
//

import UIKit
import Combine

final class AppCoordinator:
    Coordinator,
    LaunchCoordinating,
    HomeCoordinating,
    EntryCoordinating,
    PlayerCoordinating,
    CameraCoordinating,
    SaveCoordinating,
    SidebarCoordinating,
    LikeCoordinating,
    RecordCoordinating,
    UnderlineCoordinating,
    SidebarViewControllerDelegate
{
    private let window: UIWindow
    private let navigationController: UINavigationController

    // DI Container 사용
    private let container = DIContainer.shared

    private var sideMenu: SideMenuContainerView?
    private var cancellables = Set<AnyCancellable>()
    /// 사이드바 ViewModel 참조 — AI 도슨트 설정 화면에 현재 값 전달 및 저장 후 업데이트용
    private var currentSidebarViewModel: SidebarViewModel?

    init(window: UIWindow) {
        self.window = window
        self.navigationController = UINavigationController()

        // 강제 로그아웃 노티피케이션 구독
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleForceLogout),
            name: .forceLogout,
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

    // MARK: - Coordinator Protocol

    func popViewController(animated: Bool) {
        navigationController.popViewController(animated: animated)
    }

    // MARK: - LaunchCoordinating

    func showMainScreen() {
        let homeViewModel = container.makeHomeViewModel()
        let homeVC = HomeViewController(viewModel: homeViewModel, coordinator: self)
        homeVC.onCameraTapped = { [weak self] in
            self?.showCamera()
        }
        homeVC.onShowSidebar = { [weak self, weak homeVC] in
            guard let self = self, let homeVC = homeVC else { return }
            self.showSidebar(from: homeVC)
        }
        navigationController.setViewControllers([homeVC], animated: true)
    }

    // MARK: - HomeCoordinating

    func showEntry(docent: Docent) {
        let viewModel = EntryViewModel(docent: docent)
        let vc = EntryViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showCamera() {
        let cameraVC = CameraViewController(coordinator: self)
        cameraVC.modalPresentationStyle = .fullScreen
        navigationController.present(cameraVC, animated: true)
    }

    func showSidebar(from viewController: UIViewController) {
        let sidebarViewModel = container.makeSidebarViewModel()
        currentSidebarViewModel = sidebarViewModel
        let sidebarVC = SidebarViewController(viewModel: sidebarViewModel, coordinator: self)
        sidebarVC.delegate = self
        let sideMenu = SideMenuContainerView(menuViewController: sidebarVC, parentViewController: viewController)
        self.sideMenu = sideMenu
        sideMenu.present(in: viewController)
    }

    func toggleLike(type: LikeType, id: Int, completion: @escaping (Result<Bool, any Error>) -> Void) {
        container.toggleLikeUseCase.execute(type: type, id: id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        completion(.failure(error))
                    }
                },
                receiveValue: { isLiked in
                    completion(.success(isLiked))
                }
            )
            .store(in: &cancellables)
    }

    // MARK: - EntryCoordinating

    func showChat(docent: Docent, keyword: String) {
        let viewModel = ChatViewModel(keyword: keyword, docent: docent)
        let vc = ChatViewController(viewModel: viewModel, coordinator: self)
        navigationController.pushViewController(vc, animated: true)
    }

    func showPlayer(docent: Docent) {
        print("🎬 [AppCoordinator] showPlayer 호출됨")
        print("🎬 [AppCoordinator] audioURL: \(docent.audioURL?.absoluteString ?? "nil")")
        print("🎬 [AppCoordinator] audioJobId: \(docent.audioJobId ?? "nil")")

        if docent.audioURL == nil, let audioJobId = docent.audioJobId {
            print("🎬 [AppCoordinator] streamAudio 호출 필요 - jobId: \(audioJobId)")
            ToastManager.shared.showLoading("오디오 불러오는 중")
            APIService.shared.streamAudio(jobId: audioJobId)
                .receive(on: DispatchQueue.main)
                .sink(
                    receiveCompletion: { completion in
                        ToastManager.shared.hideCurrentToast()
                        if case .failure(let error) = completion {
                            print("❌ [AppCoordinator] streamAudio 실패: \(error)")
                            ToastManager.shared.showError("오디오를 불러오는데 실패했습니다")
                        }
                    },
                    receiveValue: { [weak self] fileURL in
                        guard let self = self else { return }
                        ToastManager.shared.hideCurrentToast()
                        let docentWithAudio = Docent(
                            id: docent.id,
                            title: docent.title,
                            artist: docent.artist,
                            description: docent.description,
                            imageURL: docent.imageURL,
                            audioURL: fileURL,
                            audioJobId: docent.audioJobId,
                            paragraphs: docent.paragraphs
                        )
                        let playerViewModel = self.container.makePlayerViewModel(docent: docentWithAudio)
                        let playerVC = PlayerViewController(viewModel: playerViewModel, coordinator: self)
                        self.navigationController.pushViewController(playerVC, animated: true)
                    }
                )
                .store(in: &cancellables)
        } else {
            let playerViewModel = container.makePlayerViewModel(docent: docent)
            let playerVC = PlayerViewController(viewModel: playerViewModel, coordinator: self)
            navigationController.pushViewController(playerVC, animated: true)
        }
    }

    // MARK: - PlayerCoordinating

    func showSave(folderId: Int?) {
        let saveVC = SaveViewController()
        saveVC.goToFeedHandler = { [weak self] in self?.popToHome() }
        navigationController.pushViewController(saveVC, animated: true)

        if let folderId = folderId {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                saveVC.navigateToFolder(folderId: folderId)
            }
        }
    }

    func getFolders() -> AnyPublisher<[Folder], any Error> {
        return container.getFoldersUseCase.execute()
            .mapError { $0 as any Error }
            .eraseToAnyPublisher()
    }

    // MARK: - CameraCoordinating

    func dismissCameraAndShowEntry(docent: Docent) {
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true) { [weak self] in
                self?.showEntry(docent: docent)
            }
        } else {
            showEntry(docent: docent)
        }
    }

    func dismissCameraAndShowPlayer(docent: Docent) {
        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true) { [weak self] in
                self?.showPlayer(docent: docent)
            }
        } else {
            showPlayer(docent: docent)
        }
    }

    func navigateToEntryFromCamera(with capturedImage: UIImage?) {
        let docents = container.playDocentUseCase.fetchDocents()
        let fallback = Docent(
            id: 999,
            title: "카메라로 스캔한 작품",
            artist: "미지의 작가",
            description: "이 작품은 이미지 인식을 통해 탐색된 결과입니다.",
            imageURL: "https://www.naver.com",
            audioURL: nil,
            audioJobId: "f2ec47d2-bd1f-42e2-b70d-aeefc237f12e",
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

        if navigationController.presentedViewController != nil {
            navigationController.dismiss(animated: true) { [weak self] in
                self?.showEntry(docent: docent)
            }
        } else {
            showEntry(docent: docent)
        }
    }

    // MARK: - SaveCoordinating (showEntry, popToHome already defined)

    // MARK: - SidebarCoordinating

    func closeSidebar() {
        sideMenu?.dismissMenu()
    }

    func showLike() {
        sideMenu?.dismissMenu(completion: { [weak self] in
            guard let self = self else { return }
            let likeViewModel = self.container.makeLikeViewModel()
            let likeVC = LikeViewController(viewModel: likeViewModel, coordinator: self)
            likeVC.goToFeedHandler = { [weak self] in self?.popToHome() }
            self.navigationController.pushViewController(likeVC, animated: true)
        })
    }

    func showSave() {
        sideMenu?.dismissMenu(completion: { [weak self] in
            self?.showSave(folderId: nil)
        })
    }

    func showUnderline() {
        sideMenu?.dismissMenu(completion: { [weak self] in
            guard let self = self else { return }
            let underlineVM = self.container.makeUnderlineViewModel()
            let underlineVC = UnderlineViewController(viewModel: underlineVM, coordinator: self)
            underlineVC.goToFeedHandler = { [weak self] in self?.popToHome() }
            self.navigationController.pushViewController(underlineVC, animated: true)
        })
    }

    func showUnderlineFromPlayer() {
        // Player에서 직접 Underline 화면으로 이동 (사이드 메뉴 없이)
        let underlineVM = container.makeUnderlineViewModel()
        let underlineVC = UnderlineViewController(viewModel: underlineVM, coordinator: self)
        underlineVC.goToFeedHandler = { [weak self] in self?.popToHome() }
        navigationController.pushViewController(underlineVC, animated: true)
    }

    func showRecord() {
        sideMenu?.dismissMenu(completion: { [weak self] in
            guard let self = self else { return }
            let recordVM = self.container.makeRecordViewModel()
            let recordVC = RecordViewController(viewModel: recordVM, coordinator: self)
            recordVC.goToRecordHandler = { [weak self] in
                self?.showRecordInput()
            }
            self.navigationController.pushViewController(recordVC, animated: true)
        })
    }

    func showAIDocentSettings(currentPersonal: String) {
        // 사이드바 VM에서 현재 말하기 설정 값을 가져옴 (없으면 기본값)
        let vm = container.makeAIDocentSettingsViewModel(
            currentPersonal: currentPersonal,
            currentLength:     currentSidebarViewModel?.aiDocentSettings?.length     ?? "medium",
            currentSpeed:      currentSidebarViewModel?.aiDocentSettings?.speed      ?? "medium",
            currentDifficulty: currentSidebarViewModel?.aiDocentSettings?.difficulty ?? "beginner"
        )
        let settingsVC = AIDocentSettingsViewController(viewModel: vm)
        settingsVC.onSave = { [weak self] personal, length, speed, difficulty in
            // 사이드바 말하기 설정값 갱신
            self?.currentSidebarViewModel?.updateSpeakingDisplayValues(
                length: length, speed: speed, difficulty: difficulty
            )
            // 사이드바 AI 아이콘/이름 갱신
            self?.currentSidebarViewModel?.updateAIDocent(personal: personal)
        }

        sideMenu?.dismissMenu(completion: { [weak self] in
            self?.navigationController.pushViewController(settingsVC, animated: true)
        })
    }

    func logout() {
        print("🚪 AppCoordinator: 로그아웃 처리 시작")

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
                    ToastManager.shared.showSuccess("로그아웃되었습니다")
                    self?.sideMenu?.dismissMenu(completion: {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self?.navigateToLaunch()
                        }
                    })
                }
            )
    }

    // MARK: - LikeCoordinating (showEntry already defined)

    // MARK: - RecordCoordinating

    func showRecordInput() {
        let recordInputVC = RecordInputViewController()
        recordInputVC.onRecordSaved = { (recordItem: RecordItemModel) in
            print("📝 [AppCoordinator] 전시 기록이 저장되었습니다: \(recordItem.exhibitionName)")
        }
        recordInputVC.onDismiss = {
            print("📝 [AppCoordinator] 전시 기록 입력 취소")
        }
        recordInputVC.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        navigationController.present(recordInputVC, animated: true)
    }

    func popToHome() {
        navigationController.popToRootViewController(animated: true)
    }

    // MARK: - UnderlineCoordinating (showPlayer, popToHome already defined)

    // MARK: - SidebarViewControllerDelegate

    func sidebarDidRequestClose() {
        closeSidebar()
    }

    func sidebarDidRequestShowLike() {
        showLike()
    }

    func sidebarDidRequestShowSave() {
        showSave()
    }

    func sidebarDidRequestShowUnderline() {
        showUnderline()
    }

    func sidebarDidRequestShowRecord() {
        showRecord()
    }

    func sidebarDidRequestLogout() {
        logout()
    }

    // MARK: - Private Helper Methods

    private func showLogoutError() {
        let alert = UIAlertController(
            title: "로그아웃 실패",
            message: "로그아웃 중 오류가 발생했습니다.\n다시 시도해주세요.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        navigationController.present(alert, animated: true)
    }

    @objc private func handleForceLogout() {
        print("🚨 강제 로그아웃 - 토큰 만료")

        if let sideMenu = sideMenu {
            sideMenu.dismissMenu(completion: { [weak self] in
                self?.navigateToLaunch()
            })
        } else {
            navigateToLaunch()
        }
    }

    private func navigateToLaunch() {
        let launchViewModel = LaunchViewModel()
        let launchVC = LaunchViewController(viewModel: launchViewModel, coordinator: self)
        navigationController.setViewControllers([launchVC], animated: true)
    }
}
