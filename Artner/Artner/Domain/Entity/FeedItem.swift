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

struct Categories: Identifiable {
    var id: Int
    let categories: [CategoryItem]
}

struct CategoryItem: Identifiable {
    let id: Int
    let exhibition: [Exhibition]
    let artwork: [Artwork]
    let artist: [Artist]
}

struct Exhibition: Identifiable {
    let id: Int
    let type: String
    let title: String
    let items: [ExhibitionItems]
}

struct Artwork: Identifiable {
    let id: Int
    let type: String
    let title: String
    let items: [ArtworkItems]
}

struct Artist: Identifiable {
    let id: Int
    let type: String
    let title: String
    let items: [ArtistItems]
}

struct ExhibitionItems: Identifiable {
    let id: Int
    let title: String
    let description: String
    let image: String
    let type: String
    let likesCount: Int
    let venue: String
    let startDate: String
    let endDate: String
    let status: String
}

struct ArtworkItems: Identifiable {
    let type: String
    let id: Int
    let title: String
    let name: String
    let lifePeriod: String
}

struct ArtistItems: Identifiable {
    let id: Int
    let type: String
    let title: String
    let artistName: String
    let createdYear: String
}
