//
//  FetchFeedUseCase.swift
//  Artner
//
//  Created by 신종원 on 5/17/25.
//


// MARK: - UseCase Protocol

protocol FetchFeedUseCase {
    func execute(completion: @escaping ([FeedItemType]) -> Void)
}
