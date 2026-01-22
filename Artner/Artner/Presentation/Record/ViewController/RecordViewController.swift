//
//  RecordViewController.swift
//  Artner
//
//  Feature Isolation Refactoring - RecordCoordinating 프로토콜 사용
//

import UIKit
import Combine

final class RecordViewController: UIViewController {
    private let recordView = RecordView()
    private let viewModel: RecordViewModel
    private var cancellables = Set<AnyCancellable>()
    private weak var coordinator: (any RecordCoordinating)?

    /// 기존 호환성을 위한 핸들러 (deprecated - coordinator 사용 권장)
    var goToRecordHandler: (() -> Void)?

    init(viewModel: RecordViewModel, coordinator: (any RecordCoordinating)? = nil) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    /// 기존 호환성을 위한 초기화 (DIContainer 직접 사용)
    convenience init() {
        self.init(viewModel: DIContainer.shared.makeRecordViewModel(), coordinator: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() { 
        self.view = recordView 
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        bindViewModel()
        setupActions()
    }
    
    private func setupNavigationBar() {
        recordView.navigationBar.setTitle("전시기록")
        recordView.navigationBar.onBackButtonTapped = { [weak self] in self?.navigationController?.popViewController(animated: true) }
        recordView.navigationBar.backButton.setImage(UIImage(named: "ic_left_arrow"), for: .normal)
        recordView.navigationBar.rightButton.setImage(UIImage(named: "ic_search"), for: .normal)
        recordView.navigationBar.didTapMenuButton = { [weak self] in self?.didTapSearch() }
    }
    
    private func setupCollectionView() {
        recordView.collectionView.dataSource = self
        recordView.collectionView.delegate = self
    }
    
    private func bindViewModel() {
        viewModel.$filteredItems
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in 
                self?.recordView.collectionView.reloadData()
                self?.updateEmptyState()
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
    
    private func updateEmptyState() {
        let isEmpty = viewModel.isEmpty
        recordView.emptyView.isHidden = !isEmpty
        recordView.collectionView.isHidden = isEmpty
    }
    
    private func setupActions() {
        recordView.sortButton.addTarget(self, action: #selector(didTapSort), for: .touchUpInside)
        recordView.emptyView.goRecordButton.addTarget(self, action: #selector(didTapGoRecord), for: .touchUpInside)
    }
    
    // MARK: - Sort Button Management
    
    /// 정렬 버튼 상태 업데이트
    /// - Parameter isDescending: 내림차순 여부 (true: 최신순, false: 오래된순)
    private func updateSortButton(isDescending: Bool) {
        if isDescending {
            // 최신순 (내림차순)
            recordView.sortButton.setTitle("최신순", for: .normal)
            // 위쪽 화살표 아이콘 찾아서 업데이트
            if let chevronImageView = recordView.sortButton.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                chevronImageView.image = UIImage(systemName: "chevron.up")
            }
        } else {
            // 오래된순 (오름차순)
            recordView.sortButton.setTitle("오래된순", for: .normal)
            // 아래쪽 화살표 아이콘 찾아서 업데이트
            if let chevronImageView = recordView.sortButton.subviews.first(where: { $0 is UIImageView }) as? UIImageView {
                chevronImageView.image = UIImage(systemName: "chevron.down")
            }
        }
    }
    
    @objc private func didTapSearch() {
        // 검색 기능 구현
        print("🔍 [RecordViewController] 검색 버튼 클릭")
    }
    
    @objc private func didTapSort() { 
        viewModel.toggleSort() 
    }
    
    @objc private func didTapGoRecord() {
        print("📝 [RecordViewController] 전시 기록하러가기 버튼 클릭")
        if let coordinator = coordinator {
            coordinator.showRecordInput()
        } else {
            goToRecordHandler?()
        }
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension RecordViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.filteredItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: RecordCollectionViewCell.identifier,
            for: indexPath
        ) as! RecordCollectionViewCell
        
        let recordItem = viewModel.filteredItems[indexPath.item]
        cell.configure(with: recordItem)
        
        // 삭제 버튼 액션 설정
        cell.onDelete = { [weak self] in
            self?.showDeleteAlert(for: recordItem)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: 145) // 105px 이미지 + 여백
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        // TODO: 아이템 선택 처리 (나중에 구현)
        print("📝 [RecordViewController] 아이템 선택: \(indexPath.item)")
    }
}

// MARK: - Delete Alert
extension RecordViewController {
    private func showDeleteAlert(for recordItem: RecordItemModel) {
        let alert = UIAlertController(
            title: "전시 기록 삭제",
            message: "'\(recordItem.exhibitionName)' 기록을 삭제하시겠습니까?",
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteRecordItem(with: recordItem.id)
            // Toast 표시
            ToastManager.shared.showDelete("전시 기록이 삭제되었습니다.")
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
