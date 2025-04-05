//
//  DocentListViewController.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import UIKit

final class DocentListViewController: UIViewController {

    private let viewModel = DocentListViewModel()
    private let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = .white
        navigationItem.title = "도슨트 목록"

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DocentCell")

        view.addSubview(tableView)

        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension DocentListViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfItems()
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DocentCell", for: indexPath)
        let docent = viewModel.docent(at: indexPath.row)
        cell.textLabel?.text = docent.title
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let docent = viewModel.docent(at: indexPath.row)
        let playerVC = PlayerViewController(docent: docent)
        navigationController?.pushViewController(playerVC, animated: true)
    }
}
