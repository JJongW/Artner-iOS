//
//  SaveViewController.swift
//  Artner
//
//  Feature Isolation Refactoring - SaveCoordinating 프로토콜 사용
//

import UIKit
import Combine

final class SaveViewController: UIViewController {
    private let saveView = SaveView()
    private let viewModel: SaveViewModel
    private var cancellables = Set<AnyCancellable>()
    private weak var coordinator: (any SaveCoordinating)?

    /// 기존 호환성을 위한 핸들러 (deprecated - coordinator 사용 권장)
    var goToFeedHandler: (() -> Void)?

    init(viewModel: SaveViewModel, coordinator: (any SaveCoordinating)? = nil) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    /// 기존 호환성을 위한 초기화 (DIContainer 직접 사용)
    convenience init() {
        self.init(viewModel: DIContainer.shared.makeSaveViewModel(), coordinator: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func loadView() { self.view = saveView }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupCollectionView()
        bindViewModel()
        setupActions()
    }
    
    // MARK: - Setup Methods
    
    private func setupNavigationBar() {
        saveView.navigationBar.setTitle("저장")
        saveView.navigationBar.onBackButtonTapped = { [weak self] in 
            self?.navigationController?.popViewController(animated: true) 
        }
        saveView.navigationBar.backButton.setImage(UIImage(named: "ic_left_arrow"), for: .normal)
        saveView.navigationBar.rightButton.setImage(UIImage(named: "ic_search"), for: .normal)
        saveView.navigationBar.didTapMenuButton = { [weak self] in self?.didTapSearch() }
    }
    
    private func setupCollectionView() {
        saveView.collectionView.dataSource = self
        saveView.collectionView.delegate = self
        
        // 폴더 셀 등록
        saveView.collectionView.register(SaveFolderCell.self, forCellWithReuseIdentifier: SaveFolderCell.identifier)
        
        // 추가 버튼 셀 등록
        saveView.collectionView.register(AddFolderCell.self, forCellWithReuseIdentifier: AddFolderCell.identifier)
    }
    
    private func bindViewModel() {
        // 폴더 목록 변경 시 컬렉션뷰 업데이트
        viewModel.$folders
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in 
                self?.saveView.collectionView.reloadData() 
            }
            .store(in: &cancellables)
        
        // 빈 상태 변경 시 뷰 표시/숨김
        viewModel.$isEmpty
            .receive(on: DispatchQueue.main)
            .sink { [weak self] isEmpty in
                self?.saveView.emptyView.isHidden = !isEmpty
                self?.saveView.collectionView.isHidden = isEmpty
            }
            .store(in: &cancellables)
    }
    
    private func setupActions() {
        // 빈 상태에서 폴더 생성하기 버튼
        saveView.emptyView.createFolderButton.addTarget(self, action: #selector(didTapCreateFolder), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func didTapSearch() {
        // 검색 기능 구현
        print("🔍 [SaveViewController] 검색 버튼 클릭")
    }
    
    @objc private func didTapCreateFolder() {
        showCreateFolderAlert()
    }
    
    // MARK: - Folder Management
    
    private func showCreateFolderAlert() {
        CreateFolderModalView.present(
            in: view,
            onCancel: {
                print("📁 [SaveViewController] 폴더 생성 취소")
            },
            onConfirm: { [weak self] folderName in
                print("📁 [SaveViewController] 새 폴더 생성: \(folderName)")
                self?.viewModel.createFolder(name: folderName)
            }
        )
    }
    
    private func showFolderOptions(for folder: SaveFolderModel) {
        let alert = UIAlertController(title: folder.name, message: nil, preferredStyle: .actionSheet)
        
        let renameAction = UIAlertAction(title: "이름 변경", style: .default) { [weak self] _ in
            self?.showRenameFolderAlert(for: folder)
        }
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.showDeleteFolderAlert(for: folder)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(renameAction)
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showRenameFolderAlert(for folder: SaveFolderModel) {
        let alert = UIAlertController(title: "폴더 이름 변경", message: nil, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.text = folder.name
            textField.autocapitalizationType = .words
        }
        
        let saveAction = UIAlertAction(title: "저장", style: .default) { [weak self] _ in
            guard let textField = alert.textFields?.first,
                  let newName = textField.text,
                  !newName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                ToastManager.shared.showError("폴더 이름을 입력해주세요")
                return
            }
            
            self?.viewModel.renameFolder(folderId: folder.id, newName: newName.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    private func showDeleteFolderAlert(for folder: SaveFolderModel) {
        let alert = UIAlertController(
            title: "폴더 삭제", 
            message: "'\(folder.name)' 폴더를 삭제하시겠습니까?\n폴더 안의 모든 항목도 함께 삭제됩니다.", 
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: "삭제", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteFolder(folderId: folder.id)
        }
        
        let cancelAction = UIAlertAction(title: "취소", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    /// 특정 폴더로 이동하는 메서드
    /// - Parameter folderId: 이동할 폴더 ID
    func navigateToFolder(folderId: Int) {
        let folderIdString = String(folderId)
        
        // 폴더 목록에서 해당 폴더 찾기
        if let folder = viewModel.folders.first(where: { $0.id == folderIdString }) {
            print("📁 [SaveViewController] 특정 폴더로 이동: \(folder.name)")
            let detailVC = SaveFolderDetailViewController(folder: folder)
            navigationController?.pushViewController(detailVC, animated: true)
        } else {
            print("⚠️ [SaveViewController] 폴더를 찾을 수 없음: \(folderId)")
            // 폴더 목록이 아직 로드되지 않았을 수 있으므로, 폴더 목록 로드 후 재시도
            // viewModel의 폴더 목록이 업데이트될 때까지 대기
            viewModel.$folders
                .dropFirst() // 초기값 제외
                .sink { [weak self] folders in
                    if let folder = folders.first(where: { $0.id == folderIdString }) {
                        print("📁 [SaveViewController] 폴더 목록 로드 후 이동: \(folder.name)")
                        let detailVC = SaveFolderDetailViewController(folder: folder)
                        self?.navigationController?.pushViewController(detailVC, animated: true)
                    }
                }
                .store(in: &cancellables)
        }
    }
}

// MARK: - UICollectionViewDataSource

extension SaveViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 폴더 개수 + 추가 버튼 1개
        return viewModel.folders.count + 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.item < viewModel.folders.count {
            // 폴더 셀
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SaveFolderCell.identifier, for: indexPath) as! SaveFolderCell
            let folder = viewModel.folders[indexPath.item]
            cell.configure(with: folder)
            cell.onMeatballTapped = { [weak self] in
                self?.showFolderOptions(for: folder)
            }
            return cell
        } else {
            // 추가 버튼 셀
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AddFolderCell.identifier, for: indexPath) as! AddFolderCell
            cell.onAddButtonTapped = { [weak self] in
                self?.showCreateFolderAlert()
            }
            return cell
        }
    }
}

// MARK: - UICollectionViewDelegate

extension SaveViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if indexPath.item < viewModel.folders.count {
            let folder = viewModel.folders[indexPath.item]
            print("📁 [SaveViewController] 폴더 선택: \(folder.name)")
            let detailVC = SaveFolderDetailViewController(folder: folder)
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SaveViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 모든 셀은 동일한 크기 (2열 그리드)
        let layout = collectionViewLayout as! UICollectionViewFlowLayout
        let totalSpacing = layout.minimumInteritemSpacing + layout.sectionInset.left + layout.sectionInset.right
        let width = (collectionView.bounds.width - totalSpacing) / 2
        return CGSize(width: width, height: 120)
    }
} 
