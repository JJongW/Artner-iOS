import UIKit
import Combine

final class SaveViewController: UIViewController {
    private let saveView = SaveView()
    private let viewModel = SaveViewModel()
    private var cancellables = Set<AnyCancellable>()
    var goToFeedHandler: (() -> Void)?

    override func loadView() { self.view = saveView }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        bindViewModel()
        setupActions()
        // 초기 로딩 시 "전체" 카테고리 선택 상태로 설정
        updateButtonStates(selectedCategory: nil)
    }
    private func setupNavigationBar() {
        saveView.navigationBar.setTitle("저장")
        saveView.navigationBar.onBackButtonTapped = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        saveView.navigationBar.backButton.setImage(UIImage(named: "ic_left_arrow"), for: .normal)
        saveView.navigationBar.rightButton.setImage(UIImage(named: "ic_search"), for: .normal)
        saveView.navigationBar.didTapMenuButton = { [weak self] in self?.didTapSearch() }
    }
    private func setupTableView() {
        saveView.tableView.dataSource = self
        saveView.tableView.delegate = self
        saveView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    private func bindViewModel() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.saveView.tableView.reloadData() }
            .store(in: &cancellables)
        viewModel.$isEmpty
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                self?.saveView.emptyView.isHidden = !isEmpty
                self?.saveView.tableView.isHidden = isEmpty
            }
            .store(in: &cancellables)
        
        // 선택된 카테고리 변경 시 버튼 상태 업데이트
        viewModel.$selectedCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                self?.updateButtonStates(selectedCategory: category)
            }
            .store(in: &cancellables)
    }
    private func setupActions() {
        saveView.allButton.addTarget(self, action: #selector(didTapAll), for: .touchUpInside)
        saveView.exhibitionButton.addTarget(self, action: #selector(didTapExhibition), for: .touchUpInside)
        saveView.artistButton.addTarget(self, action: #selector(didTapArtist), for: .touchUpInside)
        saveView.artworkButton.addTarget(self, action: #selector(didTapArtwork), for: .touchUpInside)
        saveView.emptyView.goFeedButton.addTarget(self, action: #selector(didTapGoFeed), for: .touchUpInside)
    }
    // MARK: - Button State Management
    private func updateButtonStates(selectedCategory: SaveItemType?) {
        // 모든 버튼을 기본 상태로 초기화
        let allButtons = [saveView.allButton, saveView.exhibitionButton, saveView.artistButton, saveView.artworkButton]
        allButtons.forEach { button in
            button.backgroundColor = .clear
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        }
        
        // 선택된 카테고리에 따라 해당 버튼을 활성화 상태로 변경
        let selectedButton: UIButton
        switch selectedCategory {
        case nil:
            selectedButton = saveView.allButton
        case .exhibition:
            selectedButton = saveView.exhibitionButton
        case .artist:
            selectedButton = saveView.artistButton
        case .artwork:
            selectedButton = saveView.artworkButton
        }
        
        // 선택된 버튼 스타일 적용
        selectedButton.backgroundColor = UIColor.white.withAlphaComponent(0.2)
        selectedButton.setTitleColor(.white, for: .normal)
        selectedButton.layer.borderColor = UIColor.white.cgColor
    }
    
    @objc private func didTapBack() { navigationController?.popViewController(animated: true) }
    @objc private func didTapSearch() {}
    @objc private func didTapAll() { viewModel.selectCategory(nil) }
    @objc private func didTapExhibition() { viewModel.selectCategory(.exhibition) }
    @objc private func didTapArtist() { viewModel.selectCategory(.artist) }
    @objc private func didTapArtwork() { viewModel.selectCategory(.artwork) }
    @objc private func didTapSort() { viewModel.toggleSort() }
    @objc private func didTapGoFeed() { goToFeedHandler?() }
}
extension SaveViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.items.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = viewModel.items[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .clear
        cell.textLabel?.textColor = .white
        cell.textLabel?.text = item.title
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
} 
