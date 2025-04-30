//
//  DocentListViewModel.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import Foundation

final class DocentListViewModel {

    private let useCase: PlayDocentUseCase
    private var docents: [Docent] = []

    // ViewController가 bind할 수 있도록 클로저 제공
    var onDocentsUpdated: (() -> Void)?

    // MARK: - Init
    init(useCase: PlayDocentUseCase) {
        self.useCase = useCase
    }

    // MARK: - Public Methods
    func loadDocents() {
        docents = useCase.fetchDocents()
        onDocentsUpdated?()
    }

    func numberOfItems() -> Int {
        return docents.count
    }

    func docent(at index: Int) -> Docent {
        return docents[index]
    }
}
