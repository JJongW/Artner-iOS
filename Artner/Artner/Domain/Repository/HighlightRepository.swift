import Foundation
import Combine

protocol HighlightRepository {
    func fetchHighlights(filter: String?, itemName: String?, itemType: String?, ordering: String?, page: Int?, search: String?) -> AnyPublisher<HighlightsResponseDTO, NetworkError>
}


