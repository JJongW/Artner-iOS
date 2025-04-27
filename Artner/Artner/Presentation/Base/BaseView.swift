//
//  BaseVIew.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

import UIKit

class BaseView: UIView {

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }

    // MARK: - Setup Methods
    private func setup() {
        backgroundColor = .white
        setupUI()
        setupLayout()
    }

    /// 서브클래스에서 UI 컴포넌트 추가
    func setupUI() { }

    /// 서브클래스에서 레이아웃 제약 추가 (SnapKit)
    func setupLayout() { }
}
