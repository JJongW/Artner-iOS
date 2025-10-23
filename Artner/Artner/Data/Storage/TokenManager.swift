//
//  TokenManager.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation

/// 토큰 관리 매니저
/// Clean Architecture: Data Layer에서 토큰 저장/관리 담당
final class TokenManager {
    
    // MARK: - Singleton
    static let shared = TokenManager()
    
    // MARK: - Constants
    private enum Keys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
    }
    
    // MARK: - Private Properties
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initialization
    private init() {
        // 개발용 하드코딩된 토큰 설정 (실제 로그인 구현 전까지)
        setupDevelopmentTokens()
    }
    
    // MARK: - Public Methods
    
    /// 액세스 토큰 가져오기
    var accessToken: String? {
        return userDefaults.string(forKey: Keys.accessToken)
    }
    
    /// 리프레시 토큰 가져오기
    var refreshToken: String? {
        return userDefaults.string(forKey: Keys.refreshToken)
    }
    
    /// 토큰 저장
    func saveTokens(access: String, refresh: String) {
        userDefaults.set(access, forKey: Keys.accessToken)
        userDefaults.set(refresh, forKey: Keys.refreshToken)
        
        #if DEBUG
        print("🔐 토큰 저장 완료")
        print("   Access Token: \(access.prefix(20))...")
        print("   Refresh Token: \(refresh.prefix(20))...")
        #endif
    }
    
    /// 토큰 삭제 (로그아웃 시)
    func clearTokens() {
        userDefaults.removeObject(forKey: Keys.accessToken)
        userDefaults.removeObject(forKey: Keys.refreshToken)
        
        #if DEBUG
        print("🔐 토큰 삭제 완료")
        #endif
    }
    
    /// 토큰 존재 여부 확인
    var hasValidTokens: Bool {
        return accessToken != nil && refreshToken != nil
    }
    
    // MARK: - Private Methods
    
    /// 개발용 하드코딩된 토큰 설정
    private func setupDevelopmentTokens() {
        // 실제 로그인 구현 전까지 하드코딩된 토큰 사용
        let accessToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoiYWNjZXNzIiwiZXhwIjoxNzYxMzA2NTU2LCJpYXQiOjE3NjEyMjAxNTYsImp0aSI6Ijg3MmIyNGI0MzA1ODRmMTRhZjgwY2ZkMGVkNTlkZjZmIiwidXNlcl9pZCI6MX0.dUq6G2Y0dN7m4yXkwzewzWhsa_P_UMkl7tiONlj2LNk"
        let refreshToken = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ0b2tlbl90eXBlIjoicmVmcmVzaCIsImV4cCI6MTc2MzgxMjE1NiwiaWF0IjoxNzYxMjIwMTU2LCJqdGkiOiJjN2Y4M2U2NGI1Zjk0MWE2ODVkYzc3ZmIyNThjNGI3ZiIsInVzZXJfaWQiOjF9.3vG6XymzUH2p2ew6cGHJ7Y3ioIgOGV351Ndd-j7TcRA"
        
        // 토큰이 없을 때만 설정 (기존 토큰 보존)
        if !hasValidTokens {
            saveTokens(access: accessToken, refresh: refreshToken)
        }
    }
}
