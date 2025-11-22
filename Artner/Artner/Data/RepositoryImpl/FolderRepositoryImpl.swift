//
//  FolderRepositoryImpl.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import Combine

/// 폴더 Repository 구현체
final class FolderRepositoryImpl: FolderRepository {
    
    private let apiService: APIServiceProtocol
    
    init(apiService: APIServiceProtocol) {
        self.apiService = apiService
    }
    
    func getFolders() -> AnyPublisher<[Folder], NetworkError> {
        return apiService.getFolders()
    }
    
    func createFolder(name: String, description: String) -> AnyPublisher<Folder, NetworkError> {
        return apiService.createFolder(name: name, description: description)
    }
    
    func updateFolder(id: Int, name: String, description: String) -> AnyPublisher<Folder, NetworkError> {
        return apiService.updateFolder(id: id, name: name, description: description)
    }
    
    func deleteFolder(id: Int) -> AnyPublisher<Void, NetworkError> {
        return apiService.deleteFolder(id: id)
    }
    
    func getFolderDetail(id: Int) -> AnyPublisher<FolderDetailDTO, NetworkError> {
        return apiService.getFolderDetail(id: id)
    }
}
