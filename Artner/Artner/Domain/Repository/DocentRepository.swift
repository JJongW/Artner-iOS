//
//  DocentRepository.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

// Domain/Repository/DocentRepository.swift
protocol DocentRepository {
    func fetchDocents() -> [Docent]
}
