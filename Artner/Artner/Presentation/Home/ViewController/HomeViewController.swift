//
//  HomeViewController.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//
import UIKit

final class HomeViewController: BaseViewController<DocentListViewModel, AppCoordinator> {

    private let homeView = HomeView()

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
        viewModel.onDocentsUpdated = { [weak self] in
            guard let self else { return }
            self.homeView.tableView.reloadData()
        }
        viewModel.loadDocents()

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
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension HomeViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocentCell", for: indexPath) as? DocentTableViewCell else {
            return UITableViewCell()
        }

        let docent = viewModel.docent(at: indexPath.row)

        cell.configure(
            thumbnail: UIImage(named: docent.imageURL),
            title: docent.title,
            subtitle: docent.artist
        )

        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let docent = viewModel.docent(at: indexPath.row)
        coordinator.showPlayer(docent: docent)
    }
}
