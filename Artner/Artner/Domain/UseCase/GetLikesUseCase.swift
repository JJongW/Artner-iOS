//
//  GetLikesUseCase.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import Combine

/// 좋아요 목록 조회 UseCase 프로토콜
protocol GetLikesUseCase {
    func execute() -> AnyPublisher<LikeList, NetworkError>
}

/// 좋아요 목록 조회 UseCase 구현체
final class GetLikesUseCaseImpl: GetLikesUseCase {
    
    private let likeRepository: LikeRepository
    
    init(likeRepository: LikeRepository) {
        self.likeRepository = likeRepository
    }
    
    func execute() -> AnyPublisher<LikeList, NetworkError> {
        return likeRepository.getLikes()
    }
}

/// 좋아요 토글 UseCase 프로토콜
protocol ToggleLikeUseCase {
    func execute(type: LikeType, id: Int) -> AnyPublisher<Bool, NetworkError>
}

/// 좋아요 토글 UseCase 구현체
final class ToggleLikeUseCaseImpl: ToggleLikeUseCase {
    
    private let likeRepository: LikeRepository
    
    init(likeRepository: LikeRepository) {
        self.likeRepository = likeRepository
    }
    
    func execute(type: LikeType, id: Int) -> AnyPublisher<Bool, NetworkError> {
        switch type {
        case .exhibition:
            return likeRepository.toggleLikeExhibition(id: id)
        case .artwork:
            return likeRepository.toggleLikeArtwork(id: id)
        case .artist:
            return likeRepository.toggleLikeArtist(id: id)
        }
    }
}
