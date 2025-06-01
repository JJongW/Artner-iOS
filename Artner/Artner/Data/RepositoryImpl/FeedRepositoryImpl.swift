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
                title: "알폰스 무하 원화전 전시",
                location: "서울 종로구 | 마이아트 뮤지엄",
                period: "2025.04.15(화) ~ 05.26(수)",
                isOngoing: true,
                museumURL: URL(string: "https://map.naver.com")!,
                isLiked: false
            ))
        ]

        let artworks: [FeedItemType] = [
            .artwork(Artwork(
                id: 2,
                title: "The Marina at Argenteuil",
                artistName: "클로드 모네 Claude Monet",
                year: "1874"
            ))
        ]

        let artists: [FeedItemType] = [
            .artist(Artist(
                id: 3,
                name: "빈센트 반 고흐",
                lifeSpan: "1853–1890",
                representativeWorks: ["별이 빛나는 밤", "아를의 붉은 포도밭"]
            ))
        ]

        completion(exhibitions + artworks + artists)
    }
}
