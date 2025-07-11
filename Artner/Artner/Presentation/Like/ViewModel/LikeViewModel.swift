import Foundation
import Combine

// 좋아요 항목 타입
enum LikeItemType {
    case exhibition, artist, artwork
}

// 좋아요 항목 모델
struct LikeItem {
    let id: String
    let type: LikeItemType
    let title: String
    let subtitle: String?
    let imageUrl: String?
    let isDocentAvailable: Bool
    let createdAt: Date // 추가된 날짜 (최근 순 정렬용)
}

final class LikeViewModel {
    // Published 프로퍼티로 뷰와 바인딩
    @Published var items: [LikeItem] = []
    @Published var selectedCategory: LikeItemType? = nil // nil이면 전체
    @Published var isEmpty: Bool = false
    @Published var sortDescending: Bool = true

    private var allItems: [LikeItem] = []
    private var cancellables = Set<AnyCancellable>()

    init() {
        // 더미 데이터 세팅 (최근 추가된 순서로 정렬)
        let now = Date()
        allItems = [
            LikeItem(id: "4", type: .artist, title: "자코모 카베도네", subtitle: "1870-1926", imageUrl: nil, isDocentAvailable: false, createdAt: now.addingTimeInterval(-3600)), // 1시간 전
            LikeItem(id: "3", type: .artwork, title: "The Marina at Argenteuil", subtitle: "클로드 모네 Claude Monet", imageUrl: nil, isDocentAvailable: true, createdAt: now.addingTimeInterval(-7200)), // 2시간 전
            LikeItem(id: "2", type: .artwork, title: "Ascension of Christ Ascension of Christ", subtitle: "자코모 카베도네", imageUrl: nil, isDocentAvailable: true, createdAt: now.addingTimeInterval(-10800)), // 3시간 전
            LikeItem(id: "1", type: .exhibition, title: "알폰스 무하 원화전 전시", subtitle: "서울 종로구 | 마이아트 뮤지엄", imageUrl: nil, isDocentAvailable: false, createdAt: now.addingTimeInterval(-14400)) // 4시간 전
        ]
        bind()
        filterAndSort()
    }

    private func bind() {
        // 카테고리/정렬 변경 시 필터링
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

    func selectCategory(_ type: LikeItemType?) {
        selectedCategory = type
    }
    func toggleSort() {
        sortDescending.toggle()
    }
} 