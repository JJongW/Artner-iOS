//
//  FolderRepository.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import Combine

/// 폴더 Repository 프로토콜
protocol FolderRepository {
    /// 폴더 목록 조회
    func getFolders() -> AnyPublisher<[Folder], NetworkError>
    
    /// 폴더 생성
    func createFolder(name: String, description: String) -> AnyPublisher<Folder, NetworkError>
    
    /// 폴더 수정
    func updateFolder(id: Int, name: String, description: String) -> AnyPublisher<Folder, NetworkError>
    
    /// 폴더 삭제
    func deleteFolder(id: Int) -> AnyPublisher<Void, NetworkError>
}
