//
//  RecordRepository.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import Combine

/// 전시기록 Repository 프로토콜
protocol RecordRepository {
    /// 전시기록 목록 조회
    func getRecords() -> AnyPublisher<RecordList, NetworkError>
    
    /// 전시기록 생성
    func createRecord(visitDate: String, name: String, museum: String, note: String, image: String) -> AnyPublisher<Record, NetworkError>
}
