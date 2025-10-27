//
//  SceneDelegate.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

// SceneDelegate.swift
import UIKit
import KakaoSDKAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var appCoordinator: AppCoordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {

        guard let windowScene = (scene as? UIWindowScene) else { return }

        let window = UIWindow(windowScene: windowScene)
        self.window = window

        // Launch Screen을 먼저 표시
        showLaunchScreen()
        
        // RTI 에러 방지를 위한 전역 키보드 설정 (메인 스레드에서 실행)
        DispatchQueue.main.async { [weak self] in
            self?.setupGlobalKeyboardSettings()
        }
    }
    
    // MARK: - Navigation Methods
    
    /// Launch Screen 표시
    private func showLaunchScreen() {
        let launchViewController = LaunchViewController()
        window?.rootViewController = launchViewController
        window?.makeKeyAndVisible()
    }
    
    /// 메인 화면으로 전환
    func showMainScreen() {
        let appCoordinator = AppCoordinator(window: window!)
        self.appCoordinator = appCoordinator
        appCoordinator.start()
    }
    
    // MARK: - URL Handling
    
    /// 카카오 로그인 URL 처리
    /// 카카오톡에서 앱으로 돌아올 때 호출됨
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            if (AuthApi.isKakaoTalkLoginUrl(url)) {
                _ = AuthController.handleOpenUrl(url: url)
            }
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
