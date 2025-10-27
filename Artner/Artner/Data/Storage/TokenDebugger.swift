//
//  TokenDebugger.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import Foundation

/// 토큰 디버깅을 위한 유틸리티
final class TokenDebugger {
    
    /// 토큰 상태를 콘솔에 출력
    static func checkTokenStatus() {
        print("🔍 [TokenDebugger] 토큰 상태 확인 시작")
        print("====================================")

        // 1. 환경변수 확인
        print("📋 환경변수 상태:")
        let envAccess = ProcessInfo.processInfo.environment["DEV_ACCESS_TOKEN"]
        let envRefresh = ProcessInfo.processInfo.environment["DEV_REFRESH_TOKEN"]
        
        print("   DEV_ACCESS_TOKEN: \(envAccess != nil ? "✅ 설정됨" : "❌ 없음")")
        print("   DEV_REFRESH_TOKEN: \(envRefresh != nil ? "✅ 설정됨" : "❌ 없음")")
        
        if let access = envAccess {
            print("   Access Token 길이: \(access.count) 문자")
            print("   Access Token 시작: \(String(access.prefix(20)))...")
        }
        
        if let refresh = envRefresh {
            print("   Refresh Token 길이: \(refresh.count) 문자")
            print("   Refresh Token 시작: \(String(refresh.prefix(20)))...")
        }
        
        print("")
        
        // 2. UserDefaults 확인
        print("💾 UserDefaults 상태:")
        let userDefaults = UserDefaults.standard
        let savedAccess = userDefaults.string(forKey: "access_token")
        let savedRefresh = userDefaults.string(forKey: "refresh_token")
        
        print("   저장된 Access Token: \(savedAccess != nil ? "✅ 있음" : "❌ 없음")")
        print("   저장된 Refresh Token: \(savedRefresh != nil ? "✅ 있음" : "❌ 없음")")
        
        if let access = savedAccess {
            print("   저장된 Access Token 길이: \(access.count) 문자")
        }
        
        if let refresh = savedRefresh {
            print("   저장된 Refresh Token 길이: \(refresh.count) 문자")
        }
        
        print("")
        
        // 3. TokenManager 상태 확인
        print("🔐 TokenManager 상태:")
        let tokenManager = TokenManager.shared
        print("   hasValidTokens: \(tokenManager.hasValidTokens)")
        print("   accessToken != nil: \(tokenManager.accessToken != nil)")
        print("   refreshToken != nil: \(tokenManager.refreshToken != nil)")
        
        print("")
        print("===========================================")
        print("🔍 [TokenDebugger] 토큰 상태 확인 완료")
    }
}
