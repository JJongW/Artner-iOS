//
//  TokenManager.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation

/// 토큰 관리 매니저
/// Clean Architecture: Data Layer에서 토큰 저장/관리 담당
/// Keychain을 사용하여 안전하게 토큰 저장
final class TokenManager {
    
    // MARK: - Singleton
    static let shared = TokenManager()

    // MARK: - Constants
    private enum Keys {
        static let accessToken = "access_token"
        static let refreshToken = "refresh_token"
    }
    
    // MARK: - Private Properties
    private let keychainManager = KeychainTokenManager.shared
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Initializer
    private init() {
        // 기존 UserDefaults에 저장된 토큰을 Keychain으로 마이그레이션
        migrateTokensToKeychain()
    }
    
    // MARK: - Public Methods
    
    /// 액세스 토큰 가져오기
    var accessToken: String? {
        return keychainManager.accessToken
    }
    
    /// 리프레시 토큰 가져오기
    var refreshToken: String? {
        return keychainManager.refreshToken
    }
    
    /// 토큰 저장
    func saveTokens(access: String, refresh: String) {
        let accessSaved = keychainManager.saveAccessToken(access)
        let refreshSaved = keychainManager.saveRefreshToken(refresh)
        
        #if DEBUG
        print("🔐 토큰 Keychain 저장 완료")
        print("   Access Token 저장: \(accessSaved ? "✅" : "❌") - \(maskToken(access))")
        print("   Refresh Token 저장: \(refreshSaved ? "✅" : "❌") - \(maskToken(refresh))")
        #endif
    }
    
    /// 토큰 삭제 (로그아웃 시)
    func clearTokens() {
        keychainManager.clearAllTokens()
        
        // 혹시 남아있을 수 있는 UserDefaults 토큰도 삭제
        userDefaults.removeObject(forKey: Keys.accessToken)
        userDefaults.removeObject(forKey: Keys.refreshToken)
        
        #if DEBUG
        print("🔐 토큰 삭제 완료 (Keychain + UserDefaults)")
        #endif
    }
    
    // MARK: - Private Methods
    
    /// UserDefaults에 저장된 토큰을 Keychain으로 마이그레이션
    private func migrateTokensToKeychain() {
        // 이미 Keychain에 토큰이 있으면 마이그레이션 불필요
        if keychainManager.accessToken != nil {
            #if DEBUG
            print("🔐 Keychain에 토큰이 이미 존재합니다. 마이그레이션 건너뜀.")
            #endif
            return
        }
        
        // UserDefaults에서 토큰 가져오기
        guard let oldAccess = userDefaults.string(forKey: Keys.accessToken),
              let oldRefresh = userDefaults.string(forKey: Keys.refreshToken) else {
            #if DEBUG
            print("🔐 마이그레이션할 토큰이 없습니다.")
            #endif
            return
        }
        
        // Keychain에 저장
        let accessSaved = keychainManager.saveAccessToken(oldAccess)
        let refreshSaved = keychainManager.saveRefreshToken(oldRefresh)
        
        if accessSaved && refreshSaved {
            // 마이그레이션 성공 시 UserDefaults에서 삭제
            userDefaults.removeObject(forKey: Keys.accessToken)
            userDefaults.removeObject(forKey: Keys.refreshToken)
            
            #if DEBUG
            print("🔐 ✅ 토큰 마이그레이션 완료: UserDefaults → Keychain")
            #endif
        } else {
            #if DEBUG
            print("🔐 ❌ 토큰 마이그레이션 실패")
            #endif
        }
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
