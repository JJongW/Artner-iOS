import UIKit
import Combine

final class LikeViewController: UIViewController {
    private let likeView = LikeView()
    private let viewModel: LikeViewModel
    private var cancellables = Set<AnyCancellable>()
    var goToFeedHandler: (() -> Void)?
    
    init(viewModel: LikeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

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
        likeView.tableView.register(DocentTableViewCell.self, forCellReuseIdentifier: "DocentCell")
        likeView.tableView.estimatedRowHeight = 112
        likeView.tableView.rowHeight = UITableView.automaticDimension
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
    private func updateButtonStates(selectedCategory: LikeType?) {
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
        
        // 선택된 버튼 스타일 적용 (#292929 텍스트, 80% opacity 흰색 배경)
        selectedButton.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        selectedButton.setTitleColor(UIColor(hex: "#292929"), for: .normal)
        selectedButton.layer.borderColor = UIColor.white.cgColor
    }
    
    /// 정렬 버튼 상태 업데이트
    /// - Parameter isDescending: 내림차순 여부 (true: 최신순, false: 오래된순)
    private func updateSortButton(isDescending: Bool) {
        if isDescending {
            // 최신순 (내림차순)
            likeView.sortButton.setTitle("최신순", for: .normal)
            // 위쪽 화살표 아이콘 찾아서 업데이트
            if let chevronImageView = likeView.sortButton.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                chevronImageView.image = UIImage(systemName: "chevron.up")
            }
        } else {
            // 오래된순 (오름차순)
            likeView.sortButton.setTitle("오래된순", for: .normal)
            // 아래쪽 화살표 아이콘 찾아서 업데이트
            if let chevronImageView = likeView.sortButton.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                chevronImageView.image = UIImage(systemName: "chevron.down")
            }
        }
    }
    
    @objc private func didTapSearch() {}
    @objc private func didTapAll() { 
        viewModel.selectCategory(nil)
        updateButtonStates(selectedCategory: nil)
    }
    @objc private func didTapExhibition() { 
        viewModel.selectCategory(.exhibition)
        updateButtonStates(selectedCategory: .exhibition)
    }
    @objc private func didTapArtist() { 
        viewModel.selectCategory(.artist)
        updateButtonStates(selectedCategory: .artist)
    }
    @objc private func didTapArtwork() { 
        viewModel.selectCategory(.artwork)
        updateButtonStates(selectedCategory: .artwork)
    }
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
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "DocentCell", for: indexPath) as? DocentTableViewCell else {
            return UITableViewCell()
        }
        
        // LikeItem을 DocentTableViewCell에 맞는 형태로 변환
        let thumbnailURL = item.imageURL
        let title = item.title
        let subtitle = getSubtitle(for: item)
        let period = getPeriod(for: item)
        
        cell.configure(
            thumbnail: thumbnailURL,
            title: title,
            subtitle: subtitle,
            period: period,
            isLiked: true // 좋아요 페이지이므로 항상 true
        )
        
        // 좋아요 버튼 액션 설정
        cell.onLikeTapped = { [weak self] in
            self?.handleLikeTapped(for: item, at: indexPath)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // TODO: 상세 화면으로 이동
    }
    
    // MARK: - Helper Methods
    private func getSubtitle(for item: LikeItem) -> String {
        switch item.type {
        case .exhibition:
            return item.displayVenue.isEmpty ? "전시" : item.displayVenue
        case .artwork:
            return "작품"
        case .artist:
            return "작가"
        }
    }
    
    private func getPeriod(for item: LikeItem) -> String {
        switch item.type {
        case .exhibition:
            return item.displayPeriod.isEmpty ? item.displayDate : item.displayPeriod
        case .artwork, .artist:
            return item.displayDate
        }
    }
    
    private func handleLikeTapped(for item: LikeItem, at indexPath: IndexPath) {
        print("❤️ 좋아요 페이지에서 좋아요 버튼 탭됨: \(item.title)")
        
        // 좋아요 취소 API 호출
        DIContainer.shared.toggleLikeUseCase.execute(type: item.type, id: item.id)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    if case .failure(let error) = completion {
                        print("❌ 좋아요 취소 API 호출 실패: \(error)")
                        // 실패 시 UI 상태를 원래대로 되돌림
                        if let cell = self?.likeView.tableView.cellForRow(at: indexPath) as? DocentTableViewCell {
                            cell.setLiked(true) // 다시 좋아요 상태로 되돌림
                        }
                    }
                },
                receiveValue: { [weak self] isLiked in
                    print("✅ 좋아요 상태 업데이트: \(isLiked)")
                    if !isLiked {
                        // 좋아요가 취소된 경우 목록에서 제거하고 새로고침
                        self?.viewModel.removeItem(at: indexPath.row)
                    }
                }
            )
            .store(in: &cancellables)
    }
} 
