import Foundation

// MARK: - Save Folder Model
/// 저장된 도슨트를 폴더 형태로 관리하는 모델
struct SaveFolderModel {
    let id: String
    let name: String
    let itemCount: Int
    let createdDate: Date
    let items: [SavedItem]
    
    init(id: String = UUID().uuidString, name: String, itemCount: Int = 0, createdDate: Date = Date(), items: [SavedItem] = []) {
        self.id = id
        self.name = name
        self.itemCount = itemCount
        self.createdDate = createdDate
        self.items = items
    }
}

// MARK: - Saved Item Model
/// 폴더에 저장된 개별 아이템 모델
struct SavedItem {
    let id: String
    let jobId: String?
    let title: String
    let artistName: String?
    let script: String?
    let type: SaveItemType
    let savedDate: Date
    let thumbnailURL: String?
    
    init(id: String = UUID().uuidString, jobId: String? = nil, title: String, artistName: String? = nil, script: String? = nil, type: SaveItemType, savedDate: Date = Date(), thumbnailURL: String? = nil) {
        self.id = id
        self.jobId = jobId
        self.title = title
        self.artistName = artistName
        self.script = script
        self.type = type
        self.savedDate = savedDate
        self.thumbnailURL = thumbnailURL
    }
}

// MARK: - Save Item Type
/// 저장 가능한 아이템 타입
enum SaveItemType: String, CaseIterable {
    case exhibition = "전시"
    case artist = "작가"
    case artwork = "작품"
}
