//
//  HomeViewModel.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

// Presentation/Home/HomeViewModel.swift

import Foundation

final class HomeViewModel {
    private let fetchFeedUseCase: FetchFeedUseCase

    @Published private(set) var feedItems: [FeedItemType] = []

    init(fetchFeedUseCase: FetchFeedUseCase) {
        self.fetchFeedUseCase = fetchFeedUseCase
    }

    func loadFeed() {
        fetchFeedUseCase.execute { [weak self] items in
            self?.feedItems = items
        }
    }
}
