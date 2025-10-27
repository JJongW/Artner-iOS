//
//  LaunchViewController.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import UIKit

/// 앱 시작 화면을 담당하는 ViewController
final class LaunchViewController: UIViewController {
    
    // MARK: - UI Components
    private let launchView = LaunchView()
    
    // MARK: - Lifecycle
    override func loadView() {
        self.view = launchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        checkFontLoading()
        startLaunchSequence()
    }
    
    // MARK: - Setup Methods
    private func setupActions() {
        // 카카오 로그인 버튼 콜백 연결
        launchView.onKakaoLoginTapped = { [weak self] in
            self?.handleKakaoLogin()
        }
    }
    
    private func checkFontLoading() {
        // Poppins 폰트가 제대로 로드되었는지 확인
        if let poppinsFont = UIFont(name: "Poppins-Medium", size: 52) {
            print("✅ Poppins-Medium 폰트 로드 성공: \(poppinsFont.fontName)")
        } else {
            print("❌ Poppins-Medium 폰트 로드 실패, 시스템 폰트 사용")
        }
    }
    
    private func startLaunchSequence() {
        // 로딩 시작
        launchView.startLoading()
        
        // 2초 후 로그인 버튼 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.launchView.showLoginButton()
        }
    }
    
    // MARK: - Actions
    private func handleKakaoLogin() {
        print("🔐 카카오 로그인 버튼 탭됨")
        // TODO: 카카오 로그인 구현
        // 임시로 메인 화면으로 전환
        transitionToMainScreen()
    }
    
    // MARK: - Navigation
    private func transitionToMainScreen() {
        // SceneDelegate에서 메인 화면으로 전환하도록 구현
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.showMainScreen()
        }
    }
}
