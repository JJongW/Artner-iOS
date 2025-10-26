//
//  LikeViewModel.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import Combine

/// 좋아요 ViewModel
final class LikeViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var items: [LikeItem] = []
    @Published var selectedCategory: LikeType? = nil // nil이면 전체
    @Published var isEmpty: Bool = false
    @Published var sortDescending: Bool = true
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // MARK: - Private Properties
    private var allItems: [LikeItem] = []
    private var cancellables = Set<AnyCancellable>()
    private let getLikesUseCase: GetLikesUseCase
    
    // MARK: - Init
    init(getLikesUseCase: GetLikesUseCase) {
        self.getLikesUseCase = getLikesUseCase
        bind()
        loadLikes()
    }
    
    // MARK: - Private Methods
    private func bind() {
        // 카테고리/정렬 변경 시 필터링
        $selectedCategory
            .sink { [weak self] _ in self?.filterAndSort() }
            .store(in: &cancellables)
        $sortDescending
            .sink { [weak self] _ in self?.filterAndSort() }
            .store(in: &cancellables)
    }
    
    private func loadLikes() {
        isLoading = true
        errorMessage = nil
        
        getLikesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { [weak self] completion in
                    self?.isLoading = false
                    if case .failure(let error) = completion {
                        self?.errorMessage = "좋아요 목록을 불러오는데 실패했습니다."
                        print("❌ 좋아요 목록 로드 실패: \(error)")
                    }
                },
                receiveValue: { [weak self] likeList in
                    self?.allItems = likeList.items
                    self?.filterAndSort()
                }
            )
            .store(in: &cancellables)
    }
    
    private func filterAndSort() {
        var filtered = allItems
        
        // 카테고리 필터링
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
    
    // MARK: - Public Methods
    func selectCategory(_ type: LikeType?) {
        selectedCategory = type
        filterAndSort() // 카테고리 선택 시 즉시 필터링 적용
    }
    
    func toggleSort() {
        sortDescending.toggle()
    }
    
    func refresh() {
        loadLikes()
    }
    
    func removeItem(at index: Int) {
        guard index < allItems.count else { return }
        allItems.remove(at: index)
        filterAndSort()
    }
}
