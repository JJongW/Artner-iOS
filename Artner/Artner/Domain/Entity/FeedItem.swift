//
//  FeedItem.swift
//  Artner
//
//  Created by 신종원 on 5/17/25.
//

import Foundation

// MARK: - Domain Layer

enum FeedItemType {
    case exhibition(Exhibition)
    case artwork(Artwork)
    case artist(Artist)
}

struct Exhibition: Identifiable {
    let id: Int
    let title: String
    let location: String
    let period: String
    let isOngoing: Bool
    let museumURL: URL
    var isLiked: Bool
}

struct Artwork: Identifiable {
    let id: Int
    let title: String
    let artistName: String
    let year: String
}

struct Artist: Identifiable {
    let id: Int
    let name: String
    let lifeSpan: String
    let representativeWorks: [String]
}
