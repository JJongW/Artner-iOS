//
//  FetchFeedUseCaseImpl.swift
//  Artner
//
//  Created by 신종원 on 5/17/25.
//


// MARK: - UseCase Implementation

final class FetchFeedUseCaseImpl: FetchFeedUseCase {
    private let repository: FeedRepository

    init(repository: FeedRepository) {
        self.repository = repository
    }

    func execute(completion: @escaping ([FeedItemType]) -> Void) {
        repository.fetchFeedItems(completion: completion)
    }
}
