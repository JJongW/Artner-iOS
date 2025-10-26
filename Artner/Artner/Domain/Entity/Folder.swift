//
//  Folder.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation

/// 폴더 Domain Entity
struct Folder {
    let id: Int
    let name: String
    let description: String
    let createdAt: String
    let updatedAt: String
    let itemsCount: Int
    
    /// 생성 시간을 Date로 변환
    var createdAtDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: createdAt)
    }
    
    /// 수정 시간을 Date로 변환
    var updatedAtDate: Date? {
        let formatter = ISO8601DateFormatter()
        return formatter.date(from: updatedAt)
    }
    
    /// 생성 시간을 사용자 친화적 문자열로 변환
    var createdAtFormatted: String {
        guard let date = createdAtDate else { return createdAt }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
    
    /// 수정 시간을 사용자 친화적 문자열로 변환
    var updatedAtFormatted: String {
        guard let date = updatedAtDate else { return updatedAt }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "yyyy년 MM월 dd일"
        return formatter.string(from: date)
    }
}

// MARK: - SaveFolderModel 변환
extension Folder {
    /// SaveFolderModel로 변환
    func toSaveFolderModel() -> SaveFolderModel {
        return SaveFolderModel(
            id: String(id),
            name: name,
            itemCount: itemsCount,
            createdDate: createdAtDate ?? Date(),
            items: [] // TODO: 실제 아이템 데이터 연동 시 구현
        )
    }
}
