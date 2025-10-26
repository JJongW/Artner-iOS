//
//  RecordItemModel.swift
//  Artner
//
//  Created by iOS Developer on 2025-01-16.
//  Copyright © 2025 Artner. All rights reserved.
//

import UIKit

/// 전시 기록 아이템 데이터 모델
struct RecordItemModel {
    let id: String
    let exhibitionName: String
    let museumName: String
    let visitDate: String
    let selectedImage: UIImage?
    let createdAt: Date
    
    init(id: String = UUID().uuidString, exhibitionName: String, museumName: String, visitDate: String, selectedImage: UIImage?, createdAt: Date = Date()) {
        self.id = id
        self.exhibitionName = exhibitionName
        self.museumName = museumName
        self.visitDate = visitDate
        self.selectedImage = selectedImage
        self.createdAt = createdAt
    }
}

// MARK: - Hashable
extension RecordItemModel: Hashable {
    static func == (lhs: RecordItemModel, rhs: RecordItemModel) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
