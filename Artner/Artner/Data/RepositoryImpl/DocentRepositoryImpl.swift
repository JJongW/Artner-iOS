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
}