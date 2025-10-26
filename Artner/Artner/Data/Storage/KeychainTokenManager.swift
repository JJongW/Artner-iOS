//
//  KeychainTokenManager.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation
import Security

/// Keychain을 사용한 더 안전한 토큰 관리자
/// 현재는 사용하지 않지만, 향후 보안 강화 시 사용 가능
final class KeychainTokenManager {
    
    // MARK: - Singleton
    static let shared = KeychainTokenManager()
    
    // MARK: - Constants
    private enum Keys {
        static let accessToken = "com.artner.access_token"
        static let refreshToken = "com.artner.refresh_token"
    }
    
    private init() {}
    
    // MARK: - Public Methods
    
    /// 액세스 토큰 저장
    func saveAccessToken(_ token: String) -> Bool {
        return saveToKeychain(token, forKey: Keys.accessToken)
    }
    
    /// 리프레시 토큰 저장
    func saveRefreshToken(_ token: String) -> Bool {
        return saveToKeychain(token, forKey: Keys.refreshToken)
    }
    
    /// 액세스 토큰 가져오기
    var accessToken: String? {
        return getFromKeychain(forKey: Keys.accessToken)
    }
    
    /// 리프레시 토큰 가져오기
    var refreshToken: String? {
        return getFromKeychain(forKey: Keys.refreshToken)
    }
    
    /// 모든 토큰 삭제
    func clearAllTokens() {
        deleteFromKeychain(forKey: Keys.accessToken)
        deleteFromKeychain(forKey: Keys.refreshToken)
    }
    
    // MARK: - Private Methods
    
    private func saveToKeychain(_ value: String, forKey key: String) -> Bool {
        let data = value.data(using: .utf8)!
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecValueData as String: data
        ]
        
        // 기존 항목 삭제
        SecItemDelete(query as CFDictionary)
        
        // 새 항목 추가
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    private func getFromKeychain(forKey key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    private func deleteFromKeychain(forKey key: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
