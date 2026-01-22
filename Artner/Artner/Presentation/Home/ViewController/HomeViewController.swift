//
//  HomeViewController.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//  Feature Isolation Refactoring - HomeCoordinating 프로토콜 사용
//

import UIKit
import Combine

final class HomeViewController: BaseViewController<HomeViewModel, any HomeCoordinating> {

    private let homeView = HomeView()
    private var cancellables = Set<AnyCancellable>()
    private let refreshControl = UIRefreshControl()

    var onCameraTapped: (() -> Void)?
    var onShowSidebar: (() -> Void)?
    override func loadView() {
        self.view = homeView
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func setupUI() {
        super.setupUI()

        homeView.tableView.dataSource = self
        homeView.tableView.delegate = self
        homeView.tableView.estimatedRowHeight = 112
        homeView.tableView.rowHeight = UITableView.automaticDimension
        
        // Pull-to-Refresh 설정
        refreshControl.tintColor = .white
        refreshControl.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        homeView.tableView.refreshControl = refreshControl
        
        // 좋아요 상태 변경 알림 구독
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLikeStatusChanged),
            name: .likeStatusChanged,
            object: nil
        )
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func setupBinding() {
        super.setupBinding()
        bindData()
        bindAction()
    }

    private func bindData() {
        // 좋아요 목록 먼저 로드
        viewModel.loadLikes()
        
        // Feed 로드
        viewModel.loadFeed()

        viewModel.$feedItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.homeView.tableView.reloadData()
                
                // Pull-to-Refresh 종료
                if self?.refreshControl.isRefreshing == true {
                    self?.refreshControl.endRefreshing()
                }
            }
            .store(in: &cancellables)
        
        // 좋아요 목록이 업데이트되면 테이블뷰 리로드
        viewModel.$likedItemIds
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.homeView.tableView.reloadData()
            }
            .store(in: &cancellables)

        // 사용자 이름 가져오기
        let userName = TokenManager.shared.userName ?? "사용자"
        
        homeView.configureBanner(
            image: UIImage(named: "banner2"),
            title: "새로운 작품을 만나볼까요?",
            subtitle: "\(userName)님을 위해 준비했어요!"
        )
    }

    private func bindAction() {
        homeView.customNavigationBar.didTapMenuButton = { [weak self] in
            self?.onShowSidebar?()
        }
        homeView.cameraButton.addTarget(self, action: #selector(didTapCamera), for: .touchUpInside)
    }

    @objc private func didTapCamera() {
        onCameraTapped?()
    }
    
    @objc private func handleRefresh() {
        print("🔄 홈 화면 새로고침 시작")
        
        // 좋아요 목록과 피드 데이터 다시 로드
        viewModel.loadLikes()
        viewModel.loadFeed()
    }
    
    @objc private func handleLikeStatusChanged(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let id = userInfo["id"] as? Int,
              let isLiked = userInfo["isLiked"] as? Bool else {
            return
        }
        
        print("📢 좋아요 상태 변경 알림 수신: id=\(id), isLiked=\(isLiked)")
        
        // ViewModel의 좋아요 목록 업데이트
        if isLiked {
            viewModel.likedItemIds.insert(id)
        } else {
            viewModel.likedItemIds.remove(id)
        }
        
        // UI 업데이트
        homeView.tableView.reloadData()
    }
    
    private func handleLikeTapped(for item: FeedItemType, at indexPath: IndexPath) {
        print("❤️ 좋아요 버튼 탭됨: \(item)")
        
        // 좋아요 타입과 ID 추출
        let (likeType, id) = extractLikeInfo(from: item)
        
        // 좋아요 API 호출 (Coordinator를 통해)
        coordinator.toggleLike(type: likeType, id: id) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let isLiked):
                print("✅ 좋아요 상태 업데이트: \(isLiked)")

                // ViewModel의 좋아요 목록 업데이트
                if isLiked {
                    self.viewModel.likedItemIds.insert(id)
                } else {
                    self.viewModel.likedItemIds.remove(id)
                }

                // 좋아요 상태 변경을 다른 화면에 알림
                NotificationCenter.default.post(
                    name: .likeStatusChanged,
                    object: nil,
                    userInfo: ["id": id, "isLiked": isLiked]
                )

                // UI 상태를 서버의 최종 상태로 업데이트
                if let cell = self.homeView.tableView.cellForRow(at: indexPath) as? DocentTableViewCell {
                    cell.setLiked(isLiked)
                }

            case .failure(let error):
                print("❌ 좋아요 API 호출 실패: \(error)")
                ToastManager.shared.showError("좋아요 처리에 실패했습니다")
            }
        }
    }
    
    private func extractLikeInfo(from item: FeedItemType) -> (LikeType, Int) {
        switch item {
        case .exhibition(let exhibition):
            return (.exhibition, exhibition.id)
        case .artwork(let artwork):
            return (.artwork, artwork.id)
        case .artist(let artist):
            return (.artist, artist.id)
        }
    }

}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.feedItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.feedItems[indexPath.row]

        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocentCell", for: indexPath) as? DocentTableViewCell else {
            return UITableViewCell()
        }

        // 실제 좋아요 상태 확인
        let (_, itemId) = extractLikeInfo(from: item)
        let isLiked = viewModel.isLiked(id: itemId)
        
        switch item {
        case .exhibition(let exhibition):
            let thumbnailURL = exhibition.items.first?.image.isEmpty == false ? URL(string: "https://artner.shop/"+"\(exhibition.items[0].image)") : nil
            let title = exhibition.items.first?.title ?? exhibition.title
            let subtitle = exhibition.items.first?.venue ?? ""
            let period = exhibition.items.first?.startDate ?? ""

            cell.configure(
                thumbnail: thumbnailURL,
                title: title,
                subtitle: subtitle,
                period: period,
                isLiked: isLiked
            )
        case .artwork(let artwork):
            let title = artwork.title
            let subtitle = artwork.items.first?.name ?? "작가 정보 없음"
            let period = artwork.items.first?.lifePeriod ?? ""
            
            cell.configure(
                thumbnail: nil,
                title: title,
                subtitle: subtitle,
                period: period,
                isLiked: isLiked
            )
        case .artist(let artist):
            let title = artist.items.first?.title ?? artist.title
            let subtitle = artist.items.first?.artistName ?? "작가명 없음"
            let period = artist.items.first?.createdYear ?? ""
            
            cell.configure(
                thumbnail: nil,
                title: title,
                subtitle: subtitle,
                period: period,
                isLiked: isLiked
            )
        }
        
        // 좋아요 버튼 액션 설정
        cell.onLikeTapped = { [weak self] in
            self?.handleLikeTapped(for: item, at: indexPath)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = viewModel.feedItems[indexPath.row]
        
        // TODO: 선택된 아이템에 따른 네비게이션 로직 추가 필요
        switch item {
        case .exhibition(let exhibition):
            print("📍 전시 선택됨: \(exhibition.title)")
        case .artwork(let artwork):
            print("🎨 작품 선택됨: \(artwork.title)")
        case .artist(let artist):
            print("👨 작가 선택됨: \(artist.title)")
        }
    }
}
