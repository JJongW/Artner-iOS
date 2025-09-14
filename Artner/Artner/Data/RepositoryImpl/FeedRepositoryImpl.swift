//
//  FeedRepositoryImpl.swift
//  Artner
//
//  Created by 신종원 on 5/17/25.
//

import Foundation

// MARK: - Repository Implementation (Dummy)

final class FeedRepositoryImpl: FeedRepository {
    func fetchFeedItems(completion: @escaping ([FeedItemType]) -> Void) {
        let exhibitions: [FeedItemType] = [
            .exhibition(Exhibition(
                id: 1,
                type: "exhibitions",
                title: "전시회",
                items: [ExhibitionItems(
                    id: 9,
                    title: "우리는 우리의 밤을 떠나지 않는다",
                    description: "",
                    image: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSyPkxMuo6NOHcNx-aO-wOo3eyVnB2oTq-ZwA&s",
                    type: "exhibition",
                    likesCount: 0,
                    venue: "서울 용산구 원효로 13/지하2층",
                    startDate: "2025-08-29",
                    endDate: "2025-09-07",
                    status: "")]
            ))
        ]

        let artworks: [FeedItemType] = [
            .artwork(Artwork(
                id: 2,
                type: "artwork",
                title: "별이 빛나는 밤",
                items: [ArtworkItems(type: "", id: 18, title: "", name: "", lifePeriod: "")]
            ))
        ]

        let artists: [FeedItemType] = [
            .artist(Artist(
                id: 3,
                type: "artists",
                title: "작가",
                items: [ArtistItems(id: 20, type: "", title: "", artistName: "", createdYear: "")]
            ))
        ]

        completion(exhibitions + artworks + artists)
    }
}
