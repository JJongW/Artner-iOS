import Foundation
import Combine

enum RecordItemType {
    case exhibition, artist, artwork
}

struct RecordItem {
    let id: String
    let type: RecordItemType
    let title: String
    let subtitle: String?
    let imageUrl: String?
    let isDocentAvailable: Bool
    let createdAt: Date // 추가된 날짜 (최근 순 정렬용)
}

final class RecordViewModel {
    @Published var items: [RecordItem] = []
    @Published var selectedCategory: RecordItemType? = nil
    @Published var isEmpty: Bool = false
    @Published var sortDescending: Bool = true

    private var allItems: [RecordItem] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        // 더미 데이터 세팅 (최근 추가된 순서로 정렬)
        let now = Date()
        allItems = [
            RecordItem(id: "2", type: .artwork, title: "관람한 작품", subtitle: "작가 미상", imageUrl: nil, isDocentAvailable: false, createdAt: now.addingTimeInterval(-3600)), // 1시간 전
            RecordItem(id: "1", type: .exhibition, title: "2024 아트페어 방문기록", subtitle: "코엑스 A홀", imageUrl: nil, isDocentAvailable: false, createdAt: now.addingTimeInterval(-7200)) // 2시간 전
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
    func selectCategory(_ type: RecordItemType?) {
        selectedCategory = type
    }
    func toggleSort() {
        sortDescending.toggle()
    }
} 