//
//  FeedRepository.swift
//  Artner
//
//  Created by 신종원 on 5/17/25.
//

// MARK: - Repository Protocol

protocol FeedRepository {
    func fetchFeedItems(completion: @escaping ([FeedItemType]) -> Void)
}
