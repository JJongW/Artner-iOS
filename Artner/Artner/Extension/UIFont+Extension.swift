//
//  UIFont+Extension.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import UIKit

extension UIFont {
    
    // MARK: - Poppins Fonts
    
    /// Poppins Regular 폰트
    static func poppinsRegular(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Regular", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    /// Poppins Medium 폰트
    static func poppinsMedium(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Medium", size: size) ?? UIFont.systemFont(ofSize: size, weight: .medium)
    }
    
    /// Poppins SemiBold 폰트
    static func poppinsSemiBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-SemiBold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .semibold)
    }
    
    /// Poppins Bold 폰트
    static func poppinsBold(size: CGFloat) -> UIFont {
        return UIFont(name: "Poppins-Bold", size: size) ?? UIFont.systemFont(ofSize: size, weight: .bold)
    }
    
    // MARK: - Convenience Methods
    
    /// 앱에서 사용하는 기본 폰트 (Poppins Medium)
    static func appFont(size: CGFloat) -> UIFont {
        return poppinsMedium(size: size)
    }
    
    /// 앱에서 사용하는 제목 폰트 (Poppins Bold)
    static func appTitleFont(size: CGFloat) -> UIFont {
        return poppinsBold(size: size)
    }
    
    /// 앱에서 사용하는 본문 폰트 (Poppins Regular)
    static func appBodyFont(size: CGFloat) -> UIFont {
        return poppinsRegular(size: size)
    }
}
