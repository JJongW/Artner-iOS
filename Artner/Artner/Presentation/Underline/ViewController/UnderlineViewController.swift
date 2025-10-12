import UIKit
import Combine

final class UnderlineViewController: UIViewController {
    private let underlineView = UnderlineView()
    private let viewModel = UnderlineViewModel()
    private var cancellables = Set<AnyCancellable>()
    var goToFeedHandler: (() -> Void)?
    override func loadView() { self.view = underlineView }
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
        underlineView.navigationBar.setTitle("밑줄")
        underlineView.navigationBar.onBackButtonTapped = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        underlineView.navigationBar.backButton.setImage(UIImage(named: "ic_left_arrow"), for: .normal)
        underlineView.navigationBar.rightButton.setImage(UIImage(named: "ic_search"), for: .normal)
        underlineView.navigationBar.didTapMenuButton = { [weak self] in self?.didTapSearch() }
    }
    private func setupTableView() {
        underlineView.tableView.dataSource = self
        underlineView.tableView.delegate = self
        underlineView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    private func bindViewModel() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.underlineView.tableView.reloadData() }
            .store(in: &cancellables)
        viewModel.$isEmpty
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                self?.underlineView.emptyView.isHidden = !isEmpty
                self?.underlineView.tableView.isHidden = isEmpty
            }
            .store(in: &cancellables)
        
        // 선택된 카테고리 변경 시 버튼 상태 업데이트
        viewModel.$selectedCategory
            .receive(on: DispatchQueue.main)
            .sink { [weak self] category in
                self?.updateButtonStates(selectedCategory: category)
            }
            .store(in: &cancellables)
        
        // 정렬 상태 변경 시 정렬 버튼 업데이트
        viewModel.$sortDescending
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isDescending in
                self?.updateSortButton(isDescending: isDescending)
            }
            .store(in: &cancellables)
    }
    private func setupActions() {
        underlineView.allButton.addTarget(self, action: #selector(didTapAll), for: .touchUpInside)
        underlineView.exhibitionButton.addTarget(self, action: #selector(didTapExhibition), for: .touchUpInside)
        underlineView.artistButton.addTarget(self, action: #selector(didTapArtist), for: .touchUpInside)
        underlineView.artworkButton.addTarget(self, action: #selector(didTapArtwork), for: .touchUpInside)
        underlineView.sortButton.addTarget(self, action: #selector(didTapSort), for: .touchUpInside)
        underlineView.emptyView.goFeedButton.addTarget(self, action: #selector(didTapGoFeed), for: .touchUpInside)
    }
    // MARK: - Button State Management
    private func updateButtonStates(selectedCategory: UnderlineItemType?) {
        // 모든 버튼을 기본 상태로 초기화
        let allButtons = [underlineView.allButton, underlineView.exhibitionButton, underlineView.artistButton, underlineView.artworkButton]
        allButtons.forEach { button in
            button.backgroundColor = .clear
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        }
        
        // 선택된 카테고리에 따라 해당 버튼을 활성화 상태로 변경
        let selectedButton: UIButton
        switch selectedCategory {
        case nil:
            selectedButton = underlineView.allButton
        case .exhibition:
            selectedButton = underlineView.exhibitionButton
        case .artist:
            selectedButton = underlineView.artistButton
        case .artwork:
            selectedButton = underlineView.artworkButton
        }
        
        // 선택된 버튼 스타일 적용
        selectedButton.backgroundColor = UIColor.white.withAlphaComponent(0.8) // #FFFFFF 80% 투명도
        selectedButton.setTitleColor(UIColor(hex: "#292929"), for: .normal) // #292929 글자색
        selectedButton.layer.borderColor = UIColor.white.cgColor
    }
    
    /// 정렬 버튼 상태 업데이트
    /// - Parameter isDescending: 내림차순 여부 (true: 최신순, false: 오래된순)
    private func updateSortButton(isDescending: Bool) {
        if isDescending {
            // 최신순 (내림차순)
            underlineView.sortButton.setTitle("최신순", for: .normal)
            // 위쪽 화살표 아이콘 찾아서 업데이트
            if let chevronImageView = underlineView.sortButton.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                chevronImageView.image = UIImage(systemName: "chevron.up")
            }
        } else {
            // 오래된순 (오름차순)
            underlineView.sortButton.setTitle("오래된순", for: .normal)
            // 아래쪽 화살표 아이콘 찾아서 업데이트
            if let chevronImageView = underlineView.sortButton.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                chevronImageView.image = UIImage(systemName: "chevron.down")
            }
        }
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
extension UnderlineViewController: UITableViewDataSource, UITableViewDelegate {
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
