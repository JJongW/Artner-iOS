import Foundation
import Combine

enum SaveItemType {
    case exhibition, artist, artwork
}

struct SaveItem {
    let id: String
    let type: SaveItemType
    let title: String
    let subtitle: String?
    let imageUrl: String?
    let isDocentAvailable: Bool
    let createdAt: Date // 추가된 날짜 (최근 순 정렬용)
}

final class SaveViewModel {
    @Published var items: [SaveItem] = []
    @Published var selectedCategory: SaveItemType? = nil
    @Published var isEmpty: Bool = false
    @Published var sortDescending: Bool = true

    private var allItems: [SaveItem] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        // 더미 데이터 세팅 (최근 추가된 순서로 정렬)
        let now = Date()
        allItems = [
            SaveItem(id: "3", type: .artist, title: "빈센트 반 고흐", subtitle: "1853-1890", imageUrl: nil, isDocentAvailable: false, createdAt: now.addingTimeInterval(-3600)), // 1시간 전
            SaveItem(id: "2", type: .artwork, title: "별이 빛나는 밤에", subtitle: "빈센트 반 고흐", imageUrl: nil, isDocentAvailable: true, createdAt: now.addingTimeInterval(-7200)), // 2시간 전
            SaveItem(id: "1", type: .exhibition, title: "세잔 특별전", subtitle: "서울시립미술관", imageUrl: nil, isDocentAvailable: false, createdAt: now.addingTimeInterval(-10800)) // 3시간 전
        ]
        bind()
        filterAndSort()
    }
    private func bind() {
        $selectedCategory
            .sink { [weak self] _ in self?.filterAndSort() }
            .store(in: &cancellables)
        $sortDescending
            .sink { [weak self] _ in self?.filterAndSort() }
            .store(in: &cancellables)
    }
    func filterAndSort() {
        var filtered = allItems
        if let category = selectedCategory {
            filtered = filtered.filter { $0.type == category }
        }
        
        // 최근 추가된 순서로 정렬 (createdAt 기준 내림차순)
        filtered = filtered.sorted { $0.createdAt > $1.createdAt }
        
        // 사용자가 정렬 순서를 변경한 경우에만 반전
        if !sortDescending {
            filtered = filtered.reversed()
        }
        
        items = filtered
        isEmpty = items.isEmpty
    }
    func selectCategory(_ type: SaveItemType?) {
        selectedCategory = type
    }
    func toggleSort() {
        sortDescending.toggle()
    }
    
    /// 새로운 아이템을 저장 목록에 추가
    /// - Parameter item: 저장할 아이템
    /// - Note: 저장 완료 후 Toast 표시 및 목록 업데이트
    func saveItem(_ item: SaveItem) {
        // 중복 저장 방지
        guard !allItems.contains(where: { $0.id == item.id }) else {
            // 이미 저장된 아이템인 경우 에러 Toast 표시
            ToastManager.shared.showError("이미 저장된 항목입니다")
            return
        }
        
        // 아이템을 목록에 추가 (최신 항목이 맨 위로)
        allItems.insert(item, at: 0)
        
        // UI 업데이트
        filterAndSort()
        
        // 저장 완료 Toast 표시
        showSaveCompletedToast(for: item)
        
        print("💾 [SaveViewModel] 아이템 저장 완료: \(item.title)")
    }
    
    /// 도슨트 관련 아이템을 저장하는 편의 메서드
    /// - Parameters:
    ///   - docentTitle: 도슨트 제목
    ///   - subtitle: 부제목 (작가명, 전시관 등)
    ///   - type: 저장 타입 (작품, 작가, 전시 등)
    func saveDocentItem(title: String, subtitle: String?, type: SaveItemType) {
        let newItem = SaveItem(
            id: UUID().uuidString,
            type: type,
            title: title,
            subtitle: subtitle,
            imageUrl: nil,
            isDocentAvailable: true,
            createdAt: Date()
        )
        
        saveItem(newItem)
    }
    
    /// 저장 완료 Toast 표시
    /// - Parameter item: 저장된 아이템
    private func showSaveCompletedToast(for item: SaveItem) {
        let typeText = getTypeDisplayName(for: item.type)
        let message = "\(typeText)이(가) 저장되었습니다"
        
        // 저장된 목록 보기 액션
        let viewAction = { [weak self] in
            // 해당 카테고리로 필터링하여 표시
            self?.selectCategory(item.type)
            print("💡 [Toast] 저장된 \(typeText) 보기 버튼 클릭됨")
        }
        
        ToastManager.shared.showSaved(message, viewAction: viewAction)
    }
    
    /// 저장 타입의 한국어 표시명 반환
    /// - Parameter type: 저장 타입
    /// - Returns: 한국어 표시명
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