import Foundation
import Combine

enum UnderlineItemType {
    case exhibition, artist, artwork
}

struct UnderlineItem {
    let id: String
    let type: UnderlineItemType
    let title: String
    let subtitle: String?
    let imageUrl: String?
    let isDocentAvailable: Bool
    let highlightCount: Int // 해당 항목의 하이라이트 개수
    let createdAt: Date // 추가된 날짜 (최근 순 정렬용)
}

final class UnderlineViewModel {
    @Published var items: [UnderlineItem] = []
    @Published var selectedCategory: UnderlineItemType? = nil
    @Published var isEmpty: Bool = false
    @Published var sortDescending: Bool = true

    private var allItems: [UnderlineItem] = []
    private var cancellables = Set<AnyCancellable>()
    private let getHighlightsUseCase: GetHighlightsUseCase

    init(getHighlightsUseCase: GetHighlightsUseCase) {
        self.getHighlightsUseCase = getHighlightsUseCase
        bind()
        fetchHighlights()
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
    func selectCategory(_ type: UnderlineItemType?) {
        selectedCategory = type
        // 서버 정렬/필터 반영을 위해 다시 불러올 수도 있음. 현재는 클라이언트 필터 후 필요 시 재요청.
    }
    func toggleSort() {
        sortDescending.toggle()
    }
    
    // MARK: - Networking
    func fetchHighlights(filter: String? = nil, itemName: String? = nil, itemType: String? = nil, ordering: String? = "latest", page: Int? = 1, search: String? = nil) {
        getHighlightsUseCase
            .execute(filter: filter, itemName: itemName, itemType: itemType, ordering: ordering, page: page, search: search)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure = completion { self.items = []; self.isEmpty = true }
            }, receiveValue: { [weak self] response in
                guard let self = self else { return }
                // Map DTO -> UI Model
                let dateFormatter = ISO8601DateFormatter()
                dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
                let mapped: [UnderlineItem] = response.results.map { dto in
                    let type: UnderlineItemType
                    switch dto.itemType {
                    case "artist": type = .artist
                    case "artwork": type = .artwork
                    default: type = .exhibition
                    }
                    let created = dto.latestDate.flatMap { dateFormatter.date(from: $0) } ?? Date()
                    // id가 없으므로 itemType + itemName으로 고유 식별자 생성
                    let uniqueId = "\(dto.itemType)_\(dto.itemName)"
                    return UnderlineItem(
                        id: uniqueId,
                        type: type,
                        title: dto.itemName,
                        subtitle: dto.subtitle,
                        imageUrl: dto.thumbnailUrl,
                        isDocentAvailable: false,
                        highlightCount: dto.highlightCount,
                        createdAt: created
                    )
                }
                self.allItems = mapped
                self.filterAndSort()
            })
            .store(in: &cancellables)
    }
} 