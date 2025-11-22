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
    /// - Parameters:
    ///   - visitDate: 방문 날짜 (YYYY-MM-DD 형식)
    ///   - name: 전시 이름
    ///   - museum: 미술관 이름
    ///   - note: 메모 (선택사항)
    ///   - image: Base64 인코딩된 이미지 (선택사항)
    func createRecord(visitDate: String, name: String, museum: String, note: String?, image: String?) -> AnyPublisher<Record, NetworkError>
    
    /// 전시기록 삭제
    func deleteRecord(id: Int) -> AnyPublisher<Void, NetworkError>
}
