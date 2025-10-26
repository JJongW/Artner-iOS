//
//  GetFoldersUseCaseImpl.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import Combine

/// 폴더 목록 조회 UseCase 구현체
final class GetFoldersUseCaseImpl: GetFoldersUseCase {
    
    private let folderRepository: FolderRepository
    
    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }
    
    func execute() -> AnyPublisher<[Folder], NetworkError> {
        return folderRepository.getFolders()
    }
}

/// 폴더 생성 UseCase 구현체
final class CreateFolderUseCaseImpl: CreateFolderUseCase {
    
    private let folderRepository: FolderRepository
    
    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }
    
    func execute(name: String, description: String) -> AnyPublisher<Folder, NetworkError> {
        return folderRepository.createFolder(name: name, description: description)
    }
}

/// 폴더 수정 UseCase 구현체
final class UpdateFolderUseCaseImpl: UpdateFolderUseCase {
    
    private let folderRepository: FolderRepository
    
    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }
    
    func execute(id: Int, name: String, description: String) -> AnyPublisher<Folder, NetworkError> {
        return folderRepository.updateFolder(id: id, name: name, description: description)
    }
}

/// 폴더 삭제 UseCase 구현체
final class DeleteFolderUseCaseImpl: DeleteFolderUseCase {
    
    private let folderRepository: FolderRepository
    
    init(folderRepository: FolderRepository) {
        self.folderRepository = folderRepository
    }
    
    func execute(id: Int) -> AnyPublisher<Void, NetworkError> {
        return folderRepository.deleteFolder(id: id)
    }
}
