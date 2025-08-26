//
//  DocentScript.swift
//  Artner
//
//  Created by 신종원 on 4/30/25.
//
import Foundation

struct DocentScript: Decodable {
    let startTime: TimeInterval
    let text: String
}

// MARK: - 문단 단위로 그룹화된 도슨트 스크립트
struct DocentParagraph {
    let id: String
    let startTime: TimeInterval
    let endTime: TimeInterval
    let sentences: [DocentScript]
    
    var fullText: String {
        return sentences.map { $0.text }.joined(separator: " ")
    }
    
    var isHighlighted: Bool = false
}

// MARK: - Highlight Model
struct TextHighlight: Codable {
    let id: String
    let paragraphId: String
    let startIndex: Int
    let endIndex: Int
    let highlightedText: String
    let createdAt: Date
    
    init(paragraphId: String, startIndex: Int, endIndex: Int, highlightedText: String) {
        self.id = UUID().uuidString
        self.paragraphId = paragraphId
        self.startIndex = startIndex
        self.endIndex = endIndex
        self.highlightedText = highlightedText
        self.createdAt = Date()
    }
}
