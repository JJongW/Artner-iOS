//
//  HomeViewModel.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

// Presentation/Home/HomeViewModel.swift

import Foundation
import Combine

final class HomeViewModel {
    private let fetchFeedUseCase: FetchFeedUseCase
    private let getLikesUseCase: GetLikesUseCase
    private var cancellables = Set<AnyCancellable>()

    @Published private(set) var feedItems: [FeedItemType] = []
    @Published var likedItemIds: Set<Int> = []

    init(fetchFeedUseCase: FetchFeedUseCase, getLikesUseCase: GetLikesUseCase) {
        self.fetchFeedUseCase = fetchFeedUseCase
        self.getLikesUseCase = getLikesUseCase
    }

    func loadFeed() {
        fetchFeedUseCase.execute { [weak self] items in
            self?.feedItems = items
        }
    }
    
    func loadLikes() {
        getLikesUseCase.execute()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure(let error) = completion {
                        print("❌ 좋아요 목록 로드 실패: \(error)")
                    }
                },
                receiveValue: { [weak self] likeList in
                    // 좋아요한 항목들의 ID를 Set으로 저장
                    let ids = Set(likeList.items.map { $0.id })
                    self?.likedItemIds = ids
                    print("✅ 좋아요 목록 로드 완료: \(ids.count)개 항목")
                }
            )
            .store(in: &cancellables)
    }
    
    /// 특정 항목이 좋아요 되어있는지 확인
    func isLiked(id: Int) -> Bool {
        return likedItemIds.contains(id)
    }
}
