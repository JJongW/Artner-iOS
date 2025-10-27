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
        print("   Access Token: \(maskToken(access))")
        print("   Refresh Token: \(maskToken(refresh))")
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
    
    /// 토큰 상태 디버깅 (개발용)
    func debugTokenStatus() {
        #if DEBUG
        print("🔐 [TokenManager] 토큰 상태 확인:")
        print("   Access Token 존재: \(accessToken != nil)")
        print("   Refresh Token 존재: \(refreshToken != nil)")
        print("   유효한 토큰: \(hasValidTokens)")
        
        if let access = accessToken {
            print("   Access Token: \(maskToken(access))")
        }
        
        if let refresh = refreshToken {
            print("   Refresh Token: \(maskToken(refresh))")
        }
        
        // 환경변수 상태 확인
        let envAccess = ProcessInfo.processInfo.environment["DEV_ACCESS_TOKEN"]
        let envRefresh = ProcessInfo.processInfo.environment["DEV_REFRESH_TOKEN"]
        print("   환경변수 DEV_ACCESS_TOKEN: \(envAccess != nil ? "설정됨" : "없음")")
        print("   환경변수 DEV_REFRESH_TOKEN: \(envRefresh != nil ? "설정됨" : "없음")")
        #endif
    }
    
    // MARK: - Private Methods
    /// 토큰 마스킹 처리 (보안을 위해)
    private func maskToken(_ token: String) -> String {
        guard token.count > 20 else { return "***" }
        let prefix = String(token.prefix(10))
        let suffix = String(token.suffix(10))
        let middle = String(repeating: "*", count: token.count - 20)
        return "\(prefix)\(middle)\(suffix)"
    }
}
