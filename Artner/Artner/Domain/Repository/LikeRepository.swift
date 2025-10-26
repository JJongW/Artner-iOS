//
//  LikeRepository.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import Combine

/// 좋아요 Repository 프로토콜
protocol LikeRepository {
    /// 좋아요 목록 조회
    func getLikes() -> AnyPublisher<LikeList, NetworkError>
    
    /// 전시 좋아요 토글
    func toggleLikeExhibition(id: Int) -> AnyPublisher<Bool, NetworkError>
    
    /// 작품 좋아요 토글
    func toggleLikeArtwork(id: Int) -> AnyPublisher<Bool, NetworkError>
    
    /// 작가 좋아요 토글
    func toggleLikeArtist(id: Int) -> AnyPublisher<Bool, NetworkError>
}
