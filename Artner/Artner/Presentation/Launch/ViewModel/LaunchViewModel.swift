//
//  LaunchViewModel.swift
//  Artner
//
//  Created by AI Assistant
//

import Foundation
import Combine

/// Launch 화면의 ViewModel
/// - UseCase를 통해 비즈니스 로직 수행
/// - View(ViewController)와 Domain Layer를 연결
final class LaunchViewModel {
    
    // MARK: - Input (View → ViewModel)
    
    /// 카카오 로그인 버튼 탭 이벤트
    let kakaoLoginTapped = PassthroughSubject<Void, Never>()
    
    // MARK: - Output (ViewModel → View)
    
    /// 로그인 성공 여부 (카카오 로그인 or 자동 로그인)
    let loginSuccess = PassthroughSubject<UserInfo, Never>()
    
    /// 로그인 실패 에러
    let loginFailure = PassthroughSubject<String, Never>()
    
    /// 로딩 상태
    let isLoading = CurrentValueSubject<Bool, Never>(false)
    
    /// 자동 로그인 결과 (토큰 있음 → true, 없음 → false)
    let shouldShowLoginButton = PassthroughSubject<Bool, Never>()
    
    // MARK: - Properties
    
    private let kakaoLoginUseCase: KakaoLoginUseCase
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// 의존성 주입을 통한 초기화
    /// - Parameter kakaoLoginUseCase: 카카오 로그인 UseCase (기본값: KakaoLoginUseCaseImpl)
    init(kakaoLoginUseCase: KakaoLoginUseCase = KakaoLoginUseCaseImpl()) {
        self.kakaoLoginUseCase = kakaoLoginUseCase
        bind()
    }
    
    // MARK: - Binding
    
    /// Input과 Output을 연결
    private func bind() {
        // 카카오 로그인 버튼 탭 → UseCase 실행
        kakaoLoginTapped
            .sink { [weak self] _ in
                self?.performKakaoLogin()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// 자동 로그인 체크
    /// 저장된 토큰이 있으면 자동으로 로그인 처리
    func checkAutoLogin() {
        print("🔍 ViewModel: 자동 로그인 체크 시작")
        
        // 디버깅: 토큰 상태 확인
        TokenManager.shared.debugTokenStatus()
        
        // TokenManager에서 accessToken 확인
        if let accessToken = TokenManager.shared.accessToken, !accessToken.isEmpty {
            print("✅ ViewModel: 저장된 토큰 발견")
            print("   토큰 길이: \(accessToken.count) 문자")
            print("   토큰 시작: \(String(accessToken.prefix(20)))...")
            
            // ⚠️ 경고: 현재는 토큰 유효성 검증을 하지 않음
            // 실제로는 백엔드에 토큰 유효성 검증 API를 호출해야 함
            // TODO: 토큰 유효성 검증 API 추가
            print("⚠️ 경고: 토큰 유효성 검증 없이 자동 로그인 처리")
            
            // 임시 UserInfo 생성 (실제로는 백엔드에서 사용자 정보 가져와야 함)
            let userInfo = UserInfo(
                id: 0,  // 실제 사용자 정보는 메인 화면에서 다시 로드
                username: "",
                nickname: "",
                email: ""
            )
            
            // 메인 화면으로 전환 신호
            DispatchQueue.main.async { [weak self] in
                self?.loginSuccess.send(userInfo)
            }
        } else {
            print("ℹ️ ViewModel: 저장된 토큰 없음 - 로그인 버튼 표시")
            
            // 로그인 버튼 표시 신호
            DispatchQueue.main.async { [weak self] in
                self?.shouldShowLoginButton.send(true)
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// 카카오 로그인 수행
    private func performKakaoLogin() {
        print("🔐 ViewModel: 카카오 로그인 시작")
        
        // 로딩 시작
        isLoading.send(true)
        
        // UseCase 실행
        kakaoLoginUseCase.execute()
            .receive(on: DispatchQueue.main)  // 메인 스레드에서 결과 처리
            .sink(
                receiveCompletion: { [weak self] completion in
                    // 로딩 종료
                    self?.isLoading.send(false)
                    
                    if case .failure(let error) = completion {
                        print("❌ ViewModel: 카카오 로그인 실패")
                        self?.loginFailure.send(error.localizedDescription)
                    }
                },
                receiveValue: { [weak self] userInfo in
                    print("✅ ViewModel: 카카오 로그인 성공 - User ID: \(userInfo.id)")
                    self?.loginSuccess.send(userInfo)
                }
            )
            .store(in: &cancellables)
    }
}

