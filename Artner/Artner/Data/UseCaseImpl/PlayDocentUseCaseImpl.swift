//
//  PlayDocentUseCaseImpl.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

// Data/UseCaseImpl/PlayDocentUseCaseImpl.swift
final class PlayDocentUseCaseImpl: PlayDocentUseCase {
    private let repository: DocentRepository

    init(repository: DocentRepository) {
        self.repository = repository
    }

    func fetchDocents() -> [Docent] {
        return repository.fetchDocents()
    }
}
