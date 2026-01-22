//
//  BaseView.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//

import UIKit

/// 모든 커스텀 뷰가 상속받는 기본 뷰
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
        setupUI()
        setupLayout()
    }

    /// 서브클래스에서 UI 컴포넌트 추가
    func setupUI() { }

    /// 서브클래스에서 레이아웃 제약 추가 (SnapKit)
    func setupLayout() { }
}
