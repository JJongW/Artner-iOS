//
//  UIView+Extension.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import UIKit

extension UIView {

    func setGradientBackground(colors: [UIColor], startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = bounds
        gradientLayer.zPosition = -1 // 가장 뒤로 보내기

        layer.insertSublayer(gradientLayer, at: 0)
    }
    
    /// 뷰가 화면에 표시되어 있는지 확인하는 메서드 (스냅샷 경고 방지)
    var isVisibleInWindow: Bool {
        // window가 nil이면 화면에 표시되지 않음
        guard let window = window else { return false }
        
        // 뷰가 hidden 상태이면 화면에 표시되지 않음
        guard !isHidden else { return false }
        
        // alpha가 0이면 화면에 표시되지 않음
        guard alpha > 0 else { return false }
        
        // 슈퍼뷰가 없으면 화면에 표시되지 않음
        guard superview != nil else { return false }
        
        // 뷰의 frame이 window 영역과 교차하는지 확인
        let viewFrame = convert(bounds, to: window)
        return viewFrame.intersects(window.bounds)
    }
    
    /// 안전한 스냅샷 생성 메서드 (afterScreenUpdates 자동 처리)
    func safeSnapshot(afterScreenUpdates: Bool = true) -> UIImage? {
        // 뷰가 화면에 보이지 않으면 afterScreenUpdates를 true로 강제 설정
        let shouldWaitForUpdates = afterScreenUpdates || !isVisibleInWindow
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, UIScreen.main.scale)
        defer { UIGraphicsEndImageContext() }
        
        // drawHierarchy 메서드는 afterScreenUpdates 파라미터를 적절히 처리
        if drawHierarchy(in: bounds, afterScreenUpdates: shouldWaitForUpdates) {
            return UIGraphicsGetImageFromCurrentImageContext()
        }
        
        return nil
    }
    
    /// 키보드 관련 뷰인지 확인하는 메서드
    var isKeyboardRelated: Bool {
        // 클래스 이름에서 키보드 관련 뷰인지 확인
        let className = String(describing: type(of: self))
        return className.contains("UIKeyboard") ||
               className.contains("UIInputView") ||
               className.contains("UITextInput") ||
               className.contains("_UIKeyboard")
    }
}
