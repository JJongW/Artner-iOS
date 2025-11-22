//
//  GetRecordsUseCase.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import Combine

/// 전시기록 목록 조회 UseCase 프로토콜
protocol GetRecordsUseCase {
    func execute() -> AnyPublisher<RecordList, NetworkError>
}

/// 전시기록 생성 UseCase 프로토콜
protocol CreateRecordUseCase {
    /// 전시기록 생성
    /// - Parameters:
    ///   - visitDate: 방문 날짜 (YYYY-MM-DD 형식, 필수)
    ///   - name: 전시 이름 (필수)
    ///   - museum: 미술관 이름 (필수)
    ///   - note: 메모 (선택사항)
    ///   - image: Base64 인코딩된 이미지 (선택사항)
    func execute(visitDate: String, name: String, museum: String, note: String?, image: String?) -> AnyPublisher<Record, NetworkError>
}

/// 전시기록 삭제 UseCase 프로토콜
protocol DeleteRecordUseCase {
    func execute(id: Int) -> AnyPublisher<Void, NetworkError>
}

/// 전시기록 목록 조회 UseCase 구현체
final class GetRecordsUseCaseImpl: GetRecordsUseCase {
    
    private let recordRepository: RecordRepository
    
    init(recordRepository: RecordRepository) {
        self.recordRepository = recordRepository
    }
    
    func execute() -> AnyPublisher<RecordList, NetworkError> {
        return recordRepository.getRecords()
    }
}

/// 전시기록 생성 UseCase 구현체
final class CreateRecordUseCaseImpl: CreateRecordUseCase {
    
    private let recordRepository: RecordRepository
    
    init(recordRepository: RecordRepository) {
        self.recordRepository = recordRepository
    }
    
    func execute(visitDate: String, name: String, museum: String, note: String?, image: String?) -> AnyPublisher<Record, NetworkError> {
        return recordRepository.createRecord(visitDate: visitDate, name: name, museum: museum, note: note, image: image)
    }
}

/// 전시기록 삭제 UseCase 구현체
final class DeleteRecordUseCaseImpl: DeleteRecordUseCase {
    
    private let recordRepository: RecordRepository
    
    init(recordRepository: RecordRepository) {
        self.recordRepository = recordRepository
    }
    
    func execute(id: Int) -> AnyPublisher<Void, NetworkError> {
        return recordRepository.deleteRecord(id: id)
    }
}
