//
//  HomeViewController.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//
import UIKit
import Combine

final class HomeViewController: BaseViewController<HomeViewModel, AppCoordinator> {

    private let homeView = HomeView()
    private var cancellables = Set<AnyCancellable>()  // ← 프로퍼티 위치 이동
    
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
    }

    override func setupBinding() {
        super.setupBinding()
        bindData()
        bindAction()
    }

    private func bindData() {
        viewModel.loadFeed()

        viewModel.$feedItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.homeView.tableView.reloadData()
            }
            .store(in: &cancellables)

        homeView.configureBanner(
            image: UIImage(named: "titleImage1"),
            title: "새로운 작품을 만나볼까요?",
            subtitle: "앤젤리너스 커피님을 위해 준비했어요!"
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

        switch item {
        case .exhibition(let exhibition):
            let thumbnailURL = exhibition.items.first?.image.isEmpty == false ? URL(string: exhibition.items[0].image) : nil
            let title = exhibition.items.first?.title ?? exhibition.title
            let subtitle = exhibition.items.first?.description ?? ""
            let period = exhibition.items.first?.startDate ?? ""

            cell.configure(
                thumbnail: thumbnailURL,
                title: title,
                subtitle: subtitle,
                period: period
            )
        case .artwork(let artwork):
            let title = artwork.title
            let subtitle = artwork.items.first?.name ?? "작가 정보 없음"
            let period = artwork.items.first?.lifePeriod ?? ""
            
            cell.configure(
                thumbnail: nil,
                title: title,
                subtitle: subtitle,
                period: period
            )
        case .artist(let artist):
            let title = artist.items.first?.title ?? artist.title
            let subtitle = artist.items.first?.artistName ?? "작가명 없음"
            let period = artist.items.first?.createdYear ?? ""
            
            cell.configure(
                thumbnail: nil,
                title: title,
                subtitle: subtitle,
                period: period
            )
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
