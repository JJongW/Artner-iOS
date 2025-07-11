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
} 