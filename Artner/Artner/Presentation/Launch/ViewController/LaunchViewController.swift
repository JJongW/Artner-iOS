//
//  LaunchViewController.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import UIKit
import Combine

/// 앱 시작 화면을 담당하는 ViewController
/// - ViewModel을 통해 비즈니스 로직 실행
/// - View 관리만 담당 (LaunchView)
final class LaunchViewController: UIViewController {
    
    // MARK: - Properties
    
    /// ViewModel (비즈니스 로직 처리)
    private let viewModel: LaunchViewModel
    
    /// Combine 구독 관리
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - UI Components
    
    private let launchView = LaunchView()
    
    // MARK: - Initialization
    
    /// 의존성 주입을 통한 초기화
    /// - Parameter viewModel: LaunchViewModel (기본값: 새 인스턴스)
    init(viewModel: LaunchViewModel = LaunchViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        self.viewModel = LaunchViewModel()
        super.init(coder: coder)
    }
    
    // MARK: - Lifecycle
    
    override func loadView() {
        self.view = launchView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
        bindViewModel()
        checkFontLoading()
        
        // 자동 로그인 체크 (토큰이 있으면 바로 메인 화면으로)
        checkAutoLogin()
    }
    
    // MARK: - Setup Methods
    
    /// View → ViewModel 바인딩
    private func setupActions() {
        // 카카오 로그인 버튼 탭 → ViewModel에 이벤트 전달
        launchView.onKakaoLoginTapped = { [weak self] in
            self?.viewModel.kakaoLoginTapped.send()
        }
    }
    
    /// ViewModel → View 바인딩
    private func bindViewModel() {
        // 로그인 성공 → 메인 화면 전환 (자동 로그인 or 카카오 로그인)
        viewModel.loginSuccess
            .sink { [weak self] userInfo in
                print("✅ ViewController: 로그인 성공 - User ID: \(userInfo.id)")
                self?.transitionToMainScreen()
            }
            .store(in: &cancellables)
        
        // 로그인 실패 → 에러 알림 표시
        viewModel.loginFailure
            .sink { [weak self] errorMessage in
                print("❌ ViewController: 로그인 실패 - \(errorMessage)")
                self?.showErrorAlert(message: "로그인에 실패했습니다.\n다시 시도해주세요.")
            }
            .store(in: &cancellables)
        
        // 로딩 상태 → UI 업데이트 (필요 시)
        viewModel.isLoading
            .sink { isLoading in
                print("⏳ 로딩 상태: \(isLoading)")
                // TODO: 로딩 인디케이터 표시/숨김
            }
            .store(in: &cancellables)
        
        // 로그인 버튼 표시 여부 (토큰 없을 때만)
        viewModel.shouldShowLoginButton
            .sink { [weak self] _ in
                print("🔘 ViewController: 로그인 버튼 표시")
                self?.startLaunchSequence()
            }
            .store(in: &cancellables)
    }
    
    private func checkFontLoading() {
        // Poppins 폰트가 제대로 로드되었는지 확인
        if let poppinsFont = UIFont(name: "Poppins-Medium", size: 52) {
            print("✅ Poppins-Medium 폰트 로드 성공: \(poppinsFont.fontName)")
        } else {
            print("❌ Poppins-Medium 폰트 로드 실패, 시스템 폰트 사용")
        }
    }
    
    /// 자동 로그인 체크
    /// ViewModel을 통해 토큰 확인 → 있으면 자동 로그인, 없으면 로그인 버튼 표시
    private func checkAutoLogin() {
        print("🔍 ViewController: 자동 로그인 체크")
        
        // 로딩 화면 시작 (어떤 경우든 처음엔 로딩 표시)
        launchView.startLoading()
        
        // 0.5초 후 ViewModel에 자동 로그인 체크 요청
        // (사용자에게 앱 로고를 최소한 보여주기 위한 딜레이)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { [weak self] in
            self?.viewModel.checkAutoLogin()
        }
    }
    
    private func startLaunchSequence() {
        // 로딩이 이미 시작되어 있으므로 바로 로그인 버튼 표시
        // 2초 후 로그인 버튼 표시
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.launchView.showLoginButton()
        }
    }
    
    // MARK: - Private Methods
    
    /// 에러 알림 표시
    /// - Parameter message: 에러 메시지
    private func showErrorAlert(message: String) {
        let alert = UIAlertController(
            title: "로그인 실패",
            message: message,
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "확인", style: .default))
        present(alert, animated: true)
    }
    
    // MARK: - Navigation
    
    /// 메인 화면으로 전환
    private func transitionToMainScreen() {
        // SceneDelegate를 통해 메인 화면으로 전환
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.showMainScreen()
        }
    }
}
