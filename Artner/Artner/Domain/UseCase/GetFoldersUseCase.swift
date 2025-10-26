//
//  GetFoldersUseCase.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import Combine

/// 폴더 목록 조회 UseCase 프로토콜
protocol GetFoldersUseCase {
    func execute() -> AnyPublisher<[Folder], NetworkError>
}

/// 폴더 생성 UseCase 프로토콜
protocol CreateFolderUseCase {
    func execute(name: String, description: String) -> AnyPublisher<Folder, NetworkError>
}

/// 폴더 수정 UseCase 프로토콜
protocol UpdateFolderUseCase {
    func execute(id: Int, name: String, description: String) -> AnyPublisher<Folder, NetworkError>
}

/// 폴더 삭제 UseCase 프로토콜
protocol DeleteFolderUseCase {
    func execute(id: Int) -> AnyPublisher<Void, NetworkError>
}
