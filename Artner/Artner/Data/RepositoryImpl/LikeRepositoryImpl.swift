//
//  LikeRepositoryImpl.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import Combine

/// 좋아요 Repository 구현체
final class LikeRepositoryImpl: LikeRepository {
    
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func getLikes() -> AnyPublisher<LikeList, NetworkError> {
        return apiService.getLikes()
    }
    
    func toggleLikeExhibition(id: Int) -> AnyPublisher<Bool, NetworkError> {
        return apiService.likeExhibition(id: id)
    }
    
    func toggleLikeArtwork(id: Int) -> AnyPublisher<Bool, NetworkError> {
        return apiService.likeArtwork(id: id)
    }
    
    func toggleLikeArtist(id: Int) -> AnyPublisher<Bool, NetworkError> {
        return apiService.likeArtist(id: id)
    }
}
