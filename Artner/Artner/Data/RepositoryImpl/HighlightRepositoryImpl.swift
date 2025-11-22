import Foundation
import Combine

final class HighlightRepositoryImpl: HighlightRepository {
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func fetchHighlights(filter: String?, itemName: String?, itemType: String?, ordering: String?, page: Int?, search: String?) -> AnyPublisher<HighlightsResponseDTO, NetworkError> {
        return apiService.getHighlights(filter: filter, itemName: itemName, itemType: itemType, ordering: ordering, page: page, search: search)
    }
}


