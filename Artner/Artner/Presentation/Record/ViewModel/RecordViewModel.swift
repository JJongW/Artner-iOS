import Foundation
import Combine
import UIKit

final class RecordViewModel: ObservableObject {
    
    // MARK: - Singleton
    static let shared = RecordViewModel()
    @Published var allItems: [RecordItemModel] = []
    @Published var filteredItems: [RecordItemModel] = []
    @Published var sortDescending: Bool = true
    
    private init() {
        allItems = [] // Start with empty array for empty state testing
        bind()
        filterAndSort()
    }
    
    private func bind() {
        // 정렬 변경 감지
        $sortDescending
            .sink { [weak self] _ in
                self?.filterAndSort()
            }
            .store(in: &cancellables)
    }
    
    private func filterAndSort() {
        filteredItems = allItems.sorted { item1, item2 in
            if sortDescending {
                return item1.createdAt > item2.createdAt
            } else {
                return item1.createdAt < item2.createdAt
            }
        }
    }
    
    func toggleSort() {
        sortDescending.toggle()
    }
    
    /// 새로운 전시 기록 추가
    func addRecordItem(_ item: RecordItemModel) {
        allItems.append(item)
        filterAndSort()
        print("📝 [RecordViewModel] 새로운 전시 기록 추가됨: \(item.exhibitionName)")
    }
    
    /// 전시 기록 삭제
    func deleteRecordItem(with id: String) {
        allItems.removeAll { $0.id == id }
        filterAndSort()
        print("📝 [RecordViewModel] 전시 기록 삭제됨: \(id)")
    }
    
    /// 빈 상태 확인
    var isEmpty: Bool {
        return filteredItems.isEmpty
    }
    
    private var cancellables = Set<AnyCancellable>()
}