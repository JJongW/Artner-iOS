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
    var onCameraTapped: (() -> Void)?
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
        homeView.customNavigationBar.didTapMenuButton = {
            print("메뉴 눌렸당!")
        }
        homeView.cameraButton.addTarget(self, action: #selector(didTapCamera), for: .touchUpInside)
    }

    @objc private func didTapCamera() {
        onCameraTapped?()
    }

    private func setupNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()

        appearance.backgroundColor = .clear
        appearance.shadowColor = .clear
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.clear
        ]

        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
    }

    private var cancellables = Set<AnyCancellable>()
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
            cell.configure(
                thumbnail: UIImage(named: "exhibitionThumbnail"),
                title: exhibition.title,
                subtitle: exhibition.location
            )
        case .artwork(let artwork):
            cell.configure(
                thumbnail: UIImage(named: "artworkThumbnail"),
                title: artwork.title,
                subtitle: artwork.artistName
            )
        case .artist(let artist):
            cell.configure(
                thumbnail: UIImage(named: "artistThumbnail"),
                title: artist.name,
                subtitle: artist.lifeSpan
            )
        }

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = viewModel.feedItems[indexPath.row]
        print("")
    }
}
