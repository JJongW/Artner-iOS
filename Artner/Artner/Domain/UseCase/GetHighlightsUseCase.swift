import Foundation
import Combine

protocol GetHighlightsUseCase {
    func execute(filter: String?, itemName: String?, itemType: String?, ordering: String?, page: Int?, search: String?) -> AnyPublisher<HighlightsResponseDTO, NetworkError>
}

final class GetHighlightsUseCaseImpl: GetHighlightsUseCase {
    private let highlightRepository: HighlightRepository
    
    init(highlightRepository: HighlightRepository) {
        self.highlightRepository = highlightRepository
    }
    
    func execute(filter: String?, itemName: String?, itemType: String?, ordering: String?, page: Int?, search: String?) -> AnyPublisher<HighlightsResponseDTO, NetworkError> {
        return highlightRepository.fetchHighlights(filter: filter, itemName: itemName, itemType: itemType, ordering: ordering, page: page, search: search)
    }
}


