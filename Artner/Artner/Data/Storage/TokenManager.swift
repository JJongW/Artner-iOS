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
    
    // MARK: - Private Methods
    
    /// 개발용 토큰 설정 (환경변수 또는 설정 파일에서 로드)
    private func setupDevelopmentTokens() {
        // 실제 로그인 구현 전까지 환경변수에서 토큰 로드
        // 보안을 위해 하드코딩된 토큰 제거
        
        #if DEBUG
        // 개발 환경에서만 환경변수에서 토큰 로드
        if let accessToken = ProcessInfo.processInfo.environment["DEV_ACCESS_TOKEN"],
           let refreshToken = ProcessInfo.processInfo.environment["DEV_REFRESH_TOKEN"] {
            
            // 토큰이 없을 때만 설정 (기존 토큰 보존)
            if !hasValidTokens {
                saveTokens(access: accessToken, refresh: refreshToken)
            }
        } else {
            print("⚠️ 개발용 토큰이 설정되지 않았습니다.")
            print("   환경변수 DEV_ACCESS_TOKEN, DEV_REFRESH_TOKEN을 설정해주세요.")
        }
        #endif
    }
    
    /// 토큰 마스킹 처리 (보안을 위해)
    private func maskToken(_ token: String) -> String {
        guard token.count > 20 else { return "***" }
        let prefix = String(token.prefix(10))
        let suffix = String(token.suffix(10))
        let middle = String(repeating: "*", count: token.count - 20)
        return "\(prefix)\(middle)\(suffix)"
    }
}
