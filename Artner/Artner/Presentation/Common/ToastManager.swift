//
//  ToastManager.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import UIKit

final class ToastManager {
    
    // MARK: - Singleton
    
    static let shared = ToastManager()
    
    private init() {}
    
    // MARK: - Properties
    
    private var currentToast: ToastView?
    private var hideTimer: Timer?
    
    // MARK: - Public Methods
    
    /// Toast를 화면에 표시
    /// - Parameters:
    ///   - configuration: Toast 구성 정보
    ///   - in: Toast를 표시할 뷰 (기본값: 현재 최상위 뷰컨트롤러의 뷰)
    func show(_ configuration: ToastConfiguration, in parentView: UIView? = nil) {
        // 기존 Toast가 있다면 제거
        hideCurrentToast()
        
        // 부모 뷰 결정
        let targetView = parentView ?? getTopViewController()?.view
        guard let containerView = targetView else {
            print("⚠️ [ToastManager] Toast를 표시할 뷰를 찾을 수 없습니다.")
            return
        }
        
        // 새로운 Toast 생성 및 설정
        let toastView = ToastView()
        toastView.configure(with: configuration)
        toastView.alpha = 0
        
        // Toast를 화면에 추가
        containerView.addSubview(toastView)
        
        // AutoLayout 설정 - 하단에서 20px 위, 가운데 정렬
        toastView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(containerView.safeAreaLayoutGuide).inset(20)
            $0.leading.greaterThanOrEqualToSuperview().inset(16)
            $0.trailing.lessThanOrEqualToSuperview().inset(16)
        }
        
        currentToast = toastView
        
        // 초기 위치를 아래쪽으로 설정 (애니메이션용)
        toastView.transform = CGAffineTransform(translationX: 0, y: 50)
        
        // 애니메이션으로 Toast 표시 (아래에서 위로 슬라이드)
        UIView.animate(
            withDuration: 0.4,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.2,
            options: [.curveEaseOut],
            animations: {
                toastView.alpha = 1.0
                toastView.transform = CGAffineTransform.identity
            }
        )
        
        // 자동 숨김 타이머 설정
        setupHideTimer(duration: configuration.duration)
    }
    
    /// 현재 표시 중인 Toast를 즉시 숨김
    func hideCurrentToast() {
        hideTimer?.invalidate()
        hideTimer = nil
        
        guard let toast = currentToast else { return }
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: [.curveEaseIn],
            animations: {
                toast.alpha = 0
                toast.transform = CGAffineTransform(translationX: 0, y: 30)
            },
            completion: { _ in
                toast.removeFromSuperview()
            }
        )
        
        currentToast = nil
    }
    
    // MARK: - Convenience Methods
    
    /// 기본 Toast 표시 (아이콘 없음, 버튼 없음)
    /// - Parameter message: 표시할 메시지
    func showSimple(_ message: String) {
        let configuration = ToastConfiguration(message: message)
        show(configuration)
    }
    
    /// 성공 Toast 표시 (체크 아이콘 포함)
    /// - Parameter message: 표시할 메시지
    func showSuccess(_ message: String) {
        // 커스텀 성공 아이콘 생성 (오렌지 배경에 체크표시)
        let successIcon = createSuccessIcon()
        let configuration = ToastConfiguration(
            message: message,
            leftIcon: successIcon,
            backgroundColor: UIColor(hex: "#222222"), 
            textColor: UIColor(hex: "#FFFFFF")
        )
        show(configuration)
    }
    
    /// 삭제 Toast 표시 (빨간색 아이콘 포함)
    /// - Parameter message: 표시할 메시지
    func showDelete(_ message: String) {
        // 커스텀 삭제 아이콘 생성 (빨간색 배경에 체크표시)
        let deleteIcon = createDeleteIcon()
        let configuration = ToastConfiguration(
            message: message,
            leftIcon: deleteIcon,
            backgroundColor: UIColor(hex: "#222222"),
            textColor: UIColor(hex: "#FFFFFF")
        )
        show(configuration)
    }
    
    /// 수정 Toast 표시 (초록색 아이콘 포함)
    /// - Parameter message: 표시할 메시지
    func showUpdate(_ message: String) {
        // 커스텀 수정 아이콘 생성 (초록색 배경에 체크표시)
        let updateIcon = createUpdateIcon()
        let configuration = ToastConfiguration(
            message: message,
            leftIcon: updateIcon,
            backgroundColor: UIColor(hex: "#222222"), 
            textColor: UIColor(hex: "#FFFFFF")
        )
        show(configuration)
    }
    
    /// 성공 Toast용 커스텀 아이콘 생성
    /// - Returns: 오렌지 배경에 체크표시가 있는 이미지
    private func createSuccessIcon() -> UIImage? {
        return createCustomIcon(backgroundColor: "#FF7c27")
    }
    
    /// 삭제 Toast용 커스텀 아이콘 생성
    /// - Returns: 빨간색 배경에 체크표시가 있는 이미지
    private func createDeleteIcon() -> UIImage? {
        return createCustomIcon(backgroundColor: "#ec6868")
    }
    
    /// 수정 Toast용 커스텀 아이콘 생성
    /// - Returns: 초록색 배경에 체크표시가 있는 이미지
    private func createUpdateIcon() -> UIImage? {
        return createCustomIcon(backgroundColor: "#FF7c27")
    }
    
    /// 에러 Toast용 커스텀 아이콘 생성
    /// - Returns: 빨간색 배경에 체크표시가 있는 이미지
    private func createErrorIcon() -> UIImage? {
        return createCustomIcon(backgroundColor: "#FC5959")
    }
    
    /// 커스텀 아이콘 생성 헬퍼 메서드
    /// - Parameter backgroundColor: 아이콘 배경색 (hex 코드)
    /// - Returns: 지정된 배경색에 체크표시가 있는 이미지
    private func createCustomIcon(backgroundColor: String) -> UIImage? {
        let size = CGSize(width: 24, height: 24)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        return renderer.image { context in
            let cgContext = context.cgContext
            
            // 지정된 색상의 원 배경 그리기
            let iconColor = UIColor(hex: backgroundColor).cgColor
            cgContext.setFillColor(iconColor)
            cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
            
            // 체크표시 그리기 (배경색과 동일한 색상)
            let checkmarkColor = UIColor(hex: "#222222").cgColor
            cgContext.setStrokeColor(checkmarkColor)
            cgContext.setLineWidth(2.5)
            cgContext.setLineCap(.round)
            cgContext.setLineJoin(.round)
            
            // 체크표시 경로
            let checkmarkPath = UIBezierPath()
            checkmarkPath.move(to: CGPoint(x: 7, y: 12))
            checkmarkPath.addLine(to: CGPoint(x: 10.5, y: 15.5))
            checkmarkPath.addLine(to: CGPoint(x: 17, y: 9))
            
            cgContext.addPath(checkmarkPath.cgPath)
            cgContext.strokePath()
        }
    }
    
    /// 에러 Toast 표시 (경고 아이콘 포함)
    /// - Parameter message: 표시할 메시지
    func showError(_ message: String) {
        // 커스텀 에러 아이콘 생성 (빨간색 배경에 체크표시)
        let errorIcon = createErrorIcon()
        let configuration = ToastConfiguration(
            message: message,
            leftIcon: errorIcon,
            backgroundColor: UIColor(hex: "#222222"), // 어두운 배경
            textColor: UIColor(hex: "#FFFFFF") // 흰색 글자
        )
        show(configuration)
    }
    
    /// 저장 완료 Toast 표시 (저장 아이콘과 확인 버튼 포함)
    /// - Parameters:
    ///   - message: 표시할 메시지
    ///   - viewAction: "보기" 버튼 클릭 시 실행할 액션
    func showSaved(_ message: String, viewAction: (() -> Void)? = nil) {
        let saveIcon = UIImage(named: "ic_save") // 프로젝트의 저장 아이콘 사용
        let configuration = ToastConfiguration(
            message: message,
            leftIcon: saveIcon,
            rightButtonTitle: viewAction != nil ? "보기" : nil,
            rightButtonAction: viewAction,
            backgroundColor: AppColor.toastBackground,
            textColor: AppColor.toastText,
            duration: 4.0 // 저장 Toast는 조금 더 오래 표시
        )
        show(configuration)
    }
    
    // MARK: - Private Methods
    
    /// 자동 숨김 타이머 설정
    /// - Parameter duration: Toast 표시 시간
    private func setupHideTimer(duration: TimeInterval) {
        hideTimer = Timer.scheduledTimer(withTimeInterval: duration, repeats: false) { [weak self] _ in
            self?.hideCurrentToast()
        }
    }
    
    /// 현재 최상위 뷰컨트롤러 반환
    /// - Returns: 최상위 뷰컨트롤러 또는 nil
    private func getTopViewController() -> UIViewController? {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            return nil
        }
        
        var topViewController = window.rootViewController
        
        while let presentedViewController = topViewController?.presentedViewController {
            topViewController = presentedViewController
        }
        
        if let navigationController = topViewController as? UINavigationController {
            topViewController = navigationController.visibleViewController
        }
        
        if let tabBarController = topViewController as? UITabBarController {
            topViewController = tabBarController.selectedViewController
        }
        
        return topViewController
    }
}
