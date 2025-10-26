//
//  RecordRepositoryImpl.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import Combine

/// 전시기록 Repository 구현체
final class RecordRepositoryImpl: RecordRepository {
    
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func getRecords() -> AnyPublisher<RecordList, NetworkError> {
        return apiService.getRecords()
    }
    
    func createRecord(visitDate: String, name: String, museum: String, note: String, image: String?) -> AnyPublisher<Record, NetworkError> {
        return apiService.createRecord(visitDate: visitDate, name: name, museum: museum, note: note, image: image)
    }
    
    func deleteRecord(id: Int) -> AnyPublisher<Void, NetworkError> {
        return apiService.deleteRecord(id: id)
    }
}
