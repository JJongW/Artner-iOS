import Foundation
import Combine

// MARK: - Save Folder ViewModel
/// 폴더 형태의 저장 화면을 관리하는 ViewModel
final class SaveViewModel: ObservableObject {
    @Published var folders: [SaveFolderModel] = []
    @Published var isEmpty: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupDummyData()
        bind()
    }
    
    private func bind() {
        $folders
            .map { $0.isEmpty }
            .assign(to: &$isEmpty)
    }
    
    /// 더미 데이터 설정 (개발용)
    private func setupDummyData() {
        let now = Date()
        let calendar = Calendar.current
        
        folders = [
            SaveFolderModel(
                name: "짱 좋은 작품",
                itemCount: 112,
                createdDate: calendar.date(byAdding: .day, value: -5, to: now) ?? now,
                items: []
            ),
            SaveFolderModel(
                name: "내가 좋아하는\n작가",
                itemCount: 45,
                createdDate: calendar.date(byAdding: .day, value: -10, to: now) ?? now,
                items: []
            ),
            SaveFolderModel(
                name: "폴더 명이 길면\n이렇게 해주세요",
                itemCount: 23,
                createdDate: calendar.date(byAdding: .day, value: -15, to: now) ?? now,
                items: []
            )
        ]
    }
    
    // MARK: - Folder Management
    
    /// 새로운 폴더 생성
    /// - Parameter name: 폴더 이름
    func createFolder(name: String) {
        let newFolder = SaveFolderModel(name: name)
        folders.append(newFolder)
        
        // 폴더 생성 완료 Toast 표시
        ToastManager.shared.showSuccess("폴더가 추가되었습니다.")
        
        print("📁 [SaveViewModel] 새 폴더 생성: \(name)")
    }
    
    /// 폴더 삭제
    /// - Parameter folderId: 삭제할 폴더 ID
    func deleteFolder(folderId: String) {
        // 삭제할 폴더 이름 저장 (Toast 표시용)
        let deletedFolderName = folders.first { $0.id == folderId }?.name ?? "폴더"
        
        folders.removeAll { $0.id == folderId }
        
        // 폴더 삭제 완료 Toast 표시 (빨간색 아이콘)
        ToastManager.shared.showDelete("'\(deletedFolderName)' 폴더가 삭제되었습니다.")
        
        print("🗑️ [SaveViewModel] 폴더 삭제: \(folderId)")
    }
    
    /// 폴더 이름 변경
    /// - Parameters:
    ///   - folderId: 변경할 폴더 ID
    ///   - newName: 새로운 폴더 이름
    func renameFolder(folderId: String, newName: String) {
        if let index = folders.firstIndex(where: { $0.id == folderId }) {
            let folder = folders[index]
            let updatedFolder = SaveFolderModel(
                id: folder.id,
                name: newName,
                itemCount: folder.itemCount,
                createdDate: folder.createdDate,
                items: folder.items
            )
            folders[index] = updatedFolder
            
            // 폴더 이름 변경 완료 Toast 표시 (초록색 아이콘)
            ToastManager.shared.showUpdate("폴더 이름이 '\(newName)'으로 변경되었습니다.")
            
            print("📝 [SaveViewModel] 폴더 이름 변경: \(newName)")
        }
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