//
//  DocentListViewModel.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

final class DocentListViewModel {

    private let useCase: PlayDocentUseCase
    private var docents: [Docent] = []

    init(useCase: PlayDocentUseCase = DocentRepository()) {
        self.useCase = useCase
        loadDocents()
    }

    private func loadDocents() {
        docents = useCase.fetchDocents()
    }

    func numberOfItems() -> Int {
        return docents.count
    }

    func docent(at index: Int) -> Docent {
        return docents[index]
    }
}
