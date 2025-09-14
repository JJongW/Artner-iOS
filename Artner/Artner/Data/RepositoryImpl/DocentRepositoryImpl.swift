//
//  DocentRepositoryImpl.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

import Foundation

/// Docent Repository 구현체 - Dummy 데이터 사용 (API 준비 전까지)
final class DocentRepositoryImpl: DocentRepository {
    
    // MARK: - Repository Methods
    
    /// Docent 목록 조회 (Dummy 데이터)
    func fetchDocents() -> [Docent] {
        print("📦 Dummy Docent 데이터 반환")
        return DummyDocentData().sampleDocents
    }
    
    // MARK: - Future: API 연동 준비
    
    /// TODO: 향후 API가 준비되면 APIService를 통한 비동기 방식으로 변경
    /*
    private let apiService: APIServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    
    func fetchDocentsAsync(completion: @escaping ([Docent]) -> Void) {
        apiService.getDocentList()
            .sink(
                receiveCompletion: { result in
                    if case .failure(let error) = result {
                        print("❌ Docent API 실패: \(error.localizedDescription)")
                        completion(DummyDocentData().sampleDocents) // Fallback
                    }
                },
                receiveValue: { docents in
                    completion(docents)
                }
            )
            .store(in: &cancellables)
    }
    */
}