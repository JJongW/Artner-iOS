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
}
