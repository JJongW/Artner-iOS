//
//  DocentRepositoryImpl.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

final class DocentRepositoryImpl: DocentRepository {
    func fetchDocents() -> [Docent] {
        return DummyDocentData().sampleDocents
    }
}
