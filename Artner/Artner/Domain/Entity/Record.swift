//
//  Record.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation

/// 전시기록 목록 Domain Entity
struct RecordList {
    let count: Int
    let next: String?
    let previous: String?
    let results: [Record]
}

/// 개별 전시기록 Domain Entity
struct Record {
    let id: Int
    let title: String?
    let content: String?
    let exhibitionName: String
    let artistName: String?
    let artworkName: String?
    let createdAt: String
    let updatedAt: String
    let images: [String]
    
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
    
    /// 전시기록 요약 (내용이 길면 잘라서 표시)
    var contentSummary: String {
        guard let content = content, !content.isEmpty else { return "내용 없음" }
        if content.count > 100 {
            return String(content.prefix(100)) + "..."
        }
        return content
    }
    
    /// 대표 이미지 URL (첫 번째 이미지)
    var thumbnailImageURL: String? {
        return images.first
    }
}

// MARK: - RecordItemModel 변환
extension Record {
    /// RecordItemModel로 변환
    func toRecordItemModel() -> RecordItemModel {
        return RecordItemModel(
            id: String(id),
            exhibitionName: exhibitionName,
            museumName: artistName ?? "미술관",
            visitDate: createdAtFormatted,
            selectedImage: nil, // TODO: 이미지 URL을 UIImage로 변환하는 로직 필요
            createdAt: createdAtDate ?? Date()
        )
    }
    
    /// 전시기록 제목 (title이 없으면 exhibitionName 사용)
    var displayTitle: String {
        return title ?? exhibitionName
    }
    
    /// 전시기록 내용 (content가 없으면 기본 메시지)
    var displayContent: String {
        return content ?? "전시기록이 등록되었습니다."
    }
}
