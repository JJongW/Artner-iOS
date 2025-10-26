import Foundation
import Combine

// MARK: - Save Folder ViewModel
/// 폴더 형태의 저장 화면을 관리하는 ViewModel
final class SaveViewModel: ObservableObject {
    @Published var folders: [SaveFolderModel] = []
    @Published var isEmpty: Bool = true
    @Published var isLoading: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UseCase Dependencies
    private let getFoldersUseCase: GetFoldersUseCase
    private let createFolderUseCase: CreateFolderUseCase
    private let updateFolderUseCase: UpdateFolderUseCase
    private let deleteFolderUseCase: DeleteFolderUseCase
    
    init(
        getFoldersUseCase: GetFoldersUseCase,
        createFolderUseCase: CreateFolderUseCase,
        updateFolderUseCase: UpdateFolderUseCase,
        deleteFolderUseCase: DeleteFolderUseCase
    ) {
        self.getFoldersUseCase = getFoldersUseCase
        self.createFolderUseCase = createFolderUseCase
        self.updateFolderUseCase = updateFolderUseCase
        self.deleteFolderUseCase = deleteFolderUseCase
        
        bind()
        loadFolders()
    }
    
    private func bind() {
        $folders
            .map { $0.isEmpty }
            .assign(to: &$isEmpty)
    }
    
    // MARK: - API Methods
    
    /// 폴더 목록 로드
    private func loadFolders() {
        isLoading = true
        
        getFoldersUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ [SaveViewModel] 폴더 목록 로드 실패: \(error)")
                        ToastManager.shared.showError("폴더를 불러오는데 실패했습니다.")
                    }
                },
                receiveValue: { [weak self] folders in
                    print("📁 [SaveViewModel] 폴더 목록 로드 완료: \(folders.count)개")
                    self?.folders = folders.map { $0.toSaveFolderModel() }
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Folder Management
    
    /// 새로운 폴더 생성
    /// - Parameter name: 폴더 이름
    func createFolder(name: String) {
        let currentTime = DateFormatter().string(from: Date())
        let description = "\(currentTime)에 생성됨"
        
        createFolderUseCase.execute(name: name, description: description)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ [SaveViewModel] 폴더 생성 실패: \(error)")
                        ToastManager.shared.showError("폴더 생성에 실패했습니다.")
                    }
                },
                receiveValue: { [weak self] folder in
                    print("📁 [SaveViewModel] 새 폴더 생성 완료: \(folder.name)")
                    self?.folders.append(folder.toSaveFolderModel())
                    ToastManager.shared.showSuccess("폴더가 추가되었습니다.")
                }
            )
            .store(in: &cancellables)
    }
    
    /// 폴더 삭제
    /// - Parameter folderId: 삭제할 폴더 ID
    func deleteFolder(folderId: String) {
        guard let folderIdInt = Int(folderId) else {
            print("❌ [SaveViewModel] 잘못된 폴더 ID: \(folderId)")
            return
        }
        
        let deletedFolderName = folders.first { $0.id == folderId }?.name ?? "폴더"
        
        deleteFolderUseCase.execute(id: folderIdInt)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ [SaveViewModel] 폴더 삭제 실패: \(error)")
                        ToastManager.shared.showError("폴더 삭제에 실패했습니다.")
                    }
                },
                receiveValue: { [weak self] _ in
                    print("🗑️ [SaveViewModel] 폴더 삭제 완료: \(folderId)")
                    self?.folders.removeAll { $0.id == folderId }
                    ToastManager.shared.showDelete("'\(deletedFolderName)' 폴더가 삭제되었습니다.")
                }
            )
            .store(in: &cancellables)
    }
    
    /// 폴더 이름 변경
    /// - Parameters:
    ///   - folderId: 변경할 폴더 ID
    ///   - newName: 새로운 폴더 이름
    func renameFolder(folderId: String, newName: String) {
        guard let folderIdInt = Int(folderId) else {
            print("❌ [SaveViewModel] 잘못된 폴더 ID: \(folderId)")
            return
        }
        
        let currentTime = DateFormatter().string(from: Date())
        let description = "\(currentTime)에 수정됨"
        
        updateFolderUseCase.execute(id: folderIdInt, name: newName, description: description)
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ [SaveViewModel] 폴더 이름 변경 실패: \(error)")
                        ToastManager.shared.showError("폴더 이름 변경에 실패했습니다.")
                    }
                },
                receiveValue: { [weak self] updatedFolder in
                    print("📝 [SaveViewModel] 폴더 이름 변경 완료: \(newName)")
                    if let index = self?.folders.firstIndex(where: { $0.id == folderId }) {
                        self?.folders[index] = updatedFolder.toSaveFolderModel()
                    }
                    ToastManager.shared.showUpdate("폴더 이름이 '\(newName)'으로 변경되었습니다.")
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Item Management
    
    /// 아이템을 특정 폴더에 저장
    /// - Parameters:
    ///   - item: 저장할 아이템
    ///   - folderId: 저장할 폴더 ID
    func saveItemToFolder(_ item: SavedItem, folderId: String) {
        if let index = folders.firstIndex(where: { $0.id == folderId }) {
            var folder = folders[index]
            var items = folder.items
            
            // 중복 저장 방지
            guard !items.contains(where: { $0.id == item.id }) else {
                ToastManager.shared.showError("이미 저장된 항목입니다")
                return
            }
            
            items.append(item)
            
            let updatedFolder = SaveFolderModel(
                id: folder.id,
                name: folder.name,
                itemCount: items.count,
                createdDate: folder.createdDate,
                items: items
            )
            
            folders[index] = updatedFolder
            
            print("💾 [SaveViewModel] 아이템 저장: \(item.title) -> \(folder.name)")
        }
    }
    
    /// 기본 폴더에 아이템 저장 (첫 번째 폴더 또는 새로 생성)
    /// - Parameter item: 저장할 아이템
    func saveItemToDefaultFolder(_ item: SavedItem) {
        if folders.isEmpty {
            // 폴더가 없으면 기본 폴더 생성
            createFolder(name: "저장된 항목")
        }
        
        // 첫 번째 폴더에 저장
        if let firstFolder = folders.first {
            saveItemToFolder(item, folderId: firstFolder.id)
        }
    }
    
    // MARK: - Public Methods
    
    /// 도슨트 아이템을 저장하는 편의 메서드
    /// - Parameters:
    ///   - title: 도슨트 제목
    ///   - type: 저장 타입
    ///   - folderId: 저장할 폴더 ID (nil이면 기본 폴더)
    func saveDocentItem(title: String, type: SaveItemType, folderId: String? = nil) {
        let item = SavedItem(
            title: title,
            type: type,
            savedDate: Date()
        )
        
        if let folderId = folderId {
            saveItemToFolder(item, folderId: folderId)
        } else {
            saveItemToDefaultFolder(item)
        }
        
        // 저장 완료 Toast 표시
        showSaveCompletedToast(for: item)
    }
    
    /// 저장 완료 Toast 표시
    private func showSaveCompletedToast(for item: SavedItem) {
        let typeText = getTypeDisplayName(for: item.type)
        let message = "\(typeText)이(가) 저장되었습니다"
        
        ToastManager.shared.showSaved(message, viewAction: nil)
    }
    
    /// 저장 타입의 한국어 표시명 반환
    private func getTypeDisplayName(for type: SaveItemType) -> String {
        switch type {
        case .exhibition:
            return "전시"
        case .artist:
            return "작가"
        case .artwork:
            return "작품"
        }
    }
} 