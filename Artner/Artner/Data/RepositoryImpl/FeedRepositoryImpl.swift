//
//  FeedRepositoryImpl.swift
//  Artner
//
//  Created by 신종원 on 5/17/25.
//

import Foundation
import Combine

/// Feed Repository 구현체 - API 서비스 사용
final class FeedRepositoryImpl: FeedRepository {
    
    // MARK: - Properties
    private let apiService: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init(apiService: APIServiceProtocol = APIService()) {
        self.apiService = apiService
    }
    
    // MARK: - Repository Methods
    
    /// Feed 아이템 목록 조회 (API 연동)
    func fetchFeedItems(completion: @escaping ([FeedItemType]) -> Void) {
        print("🌐 API를 통한 Feed 데이터 요청 시작")
        
        apiService.getFeedList()
            .sink(
                receiveCompletion: { completionResult in
                    switch completionResult {
                    case .finished:
                        print("✅ Feed 데이터 요청 완료")
                    case .failure(let error):
                        print("❌ Feed 데이터 요청 실패: \(error.localizedDescription)")
                        
                        // API 실패 시 더미 데이터 반환 (Fallback)
                        completion(self.getDummyData())
                    }
                },
                receiveValue: { feedItems in
                    print("📦 받은 Feed 데이터 개수: \(feedItems.count)")
                    completion(feedItems)
                }
            )
            .store(in: &cancellables)
    }
    
    // MARK: - Private Methods
    
    /// API 실패 시 사용할 더미 데이터 (Fallback)
    private func getDummyData() -> [FeedItemType] {
        print("🔄 더미 데이터 반환")
        
        let exhibitions: [FeedItemType] = [
            .exhibition(Exhibition(
                id: 1,
                type: "exhibitions",
                title: "전시회",
                items: [ExhibitionItems(
                    id: 9,
                    title: "우리는 우리의 밤을 떠나지 않는다",
                    description: "",
                    image: "/media/exhibitions/images/exhibition_18.jpg",
                    type: "exhibition",
                    likesCount: 0,
                    venue: "서울 용산구 원효로 13/지하2층",
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

        return exhibitions + artworks + artists
    }
}
