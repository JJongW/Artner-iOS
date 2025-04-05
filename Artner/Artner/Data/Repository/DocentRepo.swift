//
//  DocentRepo.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//


final class DocentRepository: PlayDocentUseCase {

    func fetchDocents() -> [Docent] {
        return DummyDocentData.sampleDocents
    }
}

