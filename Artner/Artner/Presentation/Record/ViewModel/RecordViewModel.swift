import Foundation
import Combine
import UIKit

final class RecordViewModel: ObservableObject {
    
    @Published var allItems: [RecordItemModel] = []
    @Published var filteredItems: [RecordItemModel] = []
    @Published var sortDescending: Bool = true
    @Published var isLoading: Bool = true
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UseCase Dependencies
    private let getRecordsUseCase: GetRecordsUseCase
    
    init(getRecordsUseCase: GetRecordsUseCase) {
        self.getRecordsUseCase = getRecordsUseCase
        bind()
        loadRecords()
        setupNotificationObservers()
    }
    
    private func bind() {
        // 정렬 변경 감지
        $sortDescending
            .sink { [weak self] _ in
                self?.filterAndSort()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - API Methods
    
    /// 전시기록 목록 로드
    private func loadRecords() {
        isLoading = true
        
        getRecordsUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        print("❌ [RecordViewModel] 전시기록 목록 로드 실패: \(error)")
                        // Toast 에러 메시지 표시 (배경: #222222, 아이콘: #FC5959)
                        ToastManager.shared.showError("전시기록을 불러오는데 실패했습니다.")
                    }
                },
                receiveValue: { [weak self] recordList in
                    print("📝 [RecordViewModel] 전시기록 목록 로드 완료: \(recordList.results.count)개")
                    self?.allItems = recordList.results.map { $0.toRecordItemModel() }
                    self?.filterAndSort()
                }
            )
            .store(in: &cancellables)
    }
    
    /// NotificationCenter 옵저버 설정
    private func setupNotificationObservers() {
        NotificationCenter.default.publisher(for: .recordDidCreate)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                print("📝 [RecordViewModel] 새 전시기록 생성 알림 수신 - 목록 새로고침")
                self?.loadRecords()
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
        let deletedItemName = allItems.first { $0.id == id }?.exhibitionName ?? "전시기록"
        allItems.removeAll { $0.id == id }
        filterAndSort()
        print("📝 [RecordViewModel] 전시 기록 삭제됨: \(id)")
        // Toast 삭제 메시지 표시 (배경: #222222, 아이콘: #FC5959)
        ToastManager.shared.showDelete("'\(deletedItemName)' 전시기록이 삭제되었습니다.")
    }
    
    /// 빈 상태 확인
    var isEmpty: Bool {
        return filteredItems.isEmpty
    }
}
