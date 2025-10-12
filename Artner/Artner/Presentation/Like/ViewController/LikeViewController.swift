import UIKit
import Combine

final class LikeViewController: UIViewController {
    private let likeView = LikeView()
    private let viewModel = LikeViewModel()
    private var cancellables = Set<AnyCancellable>()
    var goToFeedHandler: (() -> Void)?

    override func loadView() { self.view = likeView }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupTableView()
        bindViewModel()
        setupActions()
        updateButtonStates(selectedCategory: nil)
        
        // 초기 정렬 버튼 설정
        updateSortButtonAppearance()
    }
    
    private func setupNavigationBar() {
        likeView.navigationBar.setTitle("좋아요")
        likeView.navigationBar.onBackButtonTapped = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        likeView.navigationBar.backButton.setImage(UIImage(named: "ic_left_arrow"), for: .normal)
        likeView.navigationBar.rightButton.setImage(UIImage(named: "ic_search"), for: .normal)
        likeView.navigationBar.didTapMenuButton = { [weak self] in self?.didTapSearch() }
    }
    
    private func setupTableView() {
        likeView.tableView.dataSource = self
        likeView.tableView.delegate = self
        likeView.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    }
    
    private func bindViewModel() {
        viewModel.$items
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in self?.likeView.tableView.reloadData() }
            .store(in: &cancellables)
        
        viewModel.$isEmpty
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                self?.likeView.emptyView.isHidden = !isEmpty
                self?.likeView.tableView.isHidden = isEmpty
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
        // 카테고리 버튼 액션
        likeView.allButton.addTarget(self, action: #selector(didTapAll), for: .touchUpInside)
        likeView.exhibitionButton.addTarget(self, action: #selector(didTapExhibition), for: .touchUpInside)
        likeView.artistButton.addTarget(self, action: #selector(didTapArtist), for: .touchUpInside)
        likeView.artworkButton.addTarget(self, action: #selector(didTapArtwork), for: .touchUpInside)
        
        // 정렬 버튼 액션 추가
        likeView.sortButton.addTarget(self, action: #selector(didTapSort), for: .touchUpInside)
        
        // 빈 뷰 버튼 액션
        likeView.emptyView.goFeedButton.addTarget(self, action: #selector(didTapGoFeed), for: .touchUpInside)
    }
    
    // MARK: - Button State Management
    private func updateButtonStates(selectedCategory: LikeItemType?) {
        // 모든 카테고리 버튼을 기본 상태로 초기화
        let categoryButtons = [likeView.allButton, likeView.exhibitionButton, likeView.artistButton, likeView.artworkButton]
        categoryButtons.forEach { button in
            // 기본 상태: 투명 배경, 흰색 텍스트, 30% opacity 스트로크
            button.backgroundColor = .clear
            button.setTitleColor(.white, for: .normal)
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        }
        
        // 선택된 카테고리에 따라 해당 버튼을 활성화 상태로 변경
        let selectedButton: UIButton
        switch selectedCategory {
        case .exhibition:
            selectedButton = likeView.exhibitionButton
        case .artist:
            selectedButton = likeView.artistButton
        case .artwork:
            selectedButton = likeView.artworkButton
        case nil:
            selectedButton = likeView.allButton // 전체 선택 시 allButton 활성화
        }
        
        // 선택된 버튼 스타일 적용 (검은색 텍스트, 80% opacity 흰색 배경)
        selectedButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        selectedButton.setTitleColor(.black, for: .normal)
        selectedButton.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
    }
    
    @objc private func didTapSearch() {}
    @objc private func didTapAll() { viewModel.selectCategory(nil) }
    @objc private func didTapExhibition() { viewModel.selectCategory(.exhibition) }
    @objc private func didTapArtist() { viewModel.selectCategory(.artist) }
    @objc private func didTapArtwork() { viewModel.selectCategory(.artwork) }
    @objc private func didTapSort() { 
        viewModel.toggleSort()
        updateSortButtonAppearance()
    }
    
    private func updateSortButtonAppearance() {
        // 정렬 버튼 텍스트 및 화살표 방향 업데이트
        let sortText = viewModel.sortDescending ? "최신순" : "오래된순"
        likeView.sortButton.setTitle(sortText, for: .normal)
        likeView.sortButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        
        // 화살표 아이콘 방향 및 색상 업데이트
        if let chevronImageView = likeView.sortButton.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
            let arrowImage = viewModel.sortDescending ? "chevron.up" : "chevron.down"
            chevronImageView.image = UIImage(systemName: arrowImage)
            chevronImageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        }
    }
    @objc private func didTapGoFeed() { 
        // 홈 화면으로 돌아가는 액션
        goToFeedHandler?()
    }
}

extension LikeViewController: UITableViewDataSource, UITableViewDelegate {
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
