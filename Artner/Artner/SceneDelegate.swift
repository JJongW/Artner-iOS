//
//  SceneDelegate.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

// SceneDelegate.swift
import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        let appCoordinator = AppCoordinator(window: window)
        self.appCoordinator = appCoordinator

        appCoordinator.start()
        
        // 토큰 상태 확인 (개발용)
        #if DEBUG
        // 임시로 테스트 토큰 설정 (환경변수 설정 전까지)
        TokenDebugger.setTestTokens()
        #endif
        
        // RTI 에러 방지를 위한 전역 키보드 설정 (메인 스레드에서 실행)
        DispatchQueue.main.async { [weak self] in
            self?.setupGlobalKeyboardSettings()
        }
    }
    
    // MARK: - Keyboard Setup
    
    /// RTI 에러 방지를 위한 최소한의 전역 설정 (안전 버전)
    private func setupGlobalKeyboardSettings() {
        // 반드시 메인 스레드에서 실행되도록 보장
        assert(Thread.isMainThread, "setupGlobalKeyboardSettings는 메인 스레드에서만 실행되어야 합니다.")
        
        // ⚠️ 모든 UITextField.appearance() 설정을 제거하여 메인 스레드 충돌 방지
        // 대신 개별 텍스트필드에서 직접 설정하도록 변경
        
        print("🔧 RTI 에러 방지를 위한 최소한의 전역 설정 완료 (안전 모드)")
    }
}
