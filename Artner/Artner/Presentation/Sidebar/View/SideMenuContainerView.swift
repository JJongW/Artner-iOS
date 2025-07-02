//
//  SideMenuContainerView.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//
//  Clean Architecture: 오버레이+슬라이드 인/아웃 애니메이션 모듈화, 어디서든 재사용 가능

import UIKit
import SnapKit

final class SideMenuContainerView: UIView {
    private let menuWidth: CGFloat = 320
    private let overlayView = UIView()
    private let menuViewController: UIViewController
    private weak var parentVC: UIViewController?
    private var menuViewTrailingConstraint: Constraint? // SnapKit Constraint
    // SidebarViewController delegate 연결을 위한 프로퍼티

    init(menuViewController: UIViewController, parentViewController: UIViewController) {
        self.menuViewController = menuViewController
        self.parentVC = parentViewController
        super.init(frame: .zero)
        setupUI()
        // SidebarViewController라면 delegate 연결
        if let sidebarVC = menuViewController as? SidebarViewController {
            sidebarVC.delegate = self
        }
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        // 오버레이
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.6)
        overlayView.alpha = 0
        addSubview(overlayView)
        overlayView.snp.makeConstraints { $0.edges.equalToSuperview() }
        // 메뉴 뷰
        let menuView = menuViewController.view!
        addSubview(menuView)
        menuView.snp.makeConstraints { make in
            make.top.bottom.width.equalToSuperview()
            self.menuViewTrailingConstraint = make.trailing.equalToSuperview().offset(menuWidth).constraint
        }
        // 탭 제스처로 닫기
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissMenu))
        overlayView.addGestureRecognizer(tap)
    }

    func present(in parent: UIViewController) {
        parent.view.addSubview(self)
        self.snp.makeConstraints { $0.edges.equalToSuperview() }
        layoutIfNeeded()
        // 초기 위치: 우측 바깥 (trailing = menuWidth)
        menuViewTrailingConstraint?.update(offset: menuWidth)
        layoutIfNeeded()
        // 애니메이션: trailing = 0으로 변경
        UIView.animate(withDuration: 0.3) {
            self.overlayView.alpha = 1
            self.menuViewTrailingConstraint?.update(offset: 0)
            self.layoutIfNeeded()
        }
    }

    @objc private func dismissMenu() {
        UIView.animate(withDuration: 0.3, animations: {
            self.overlayView.alpha = 0
            self.menuViewTrailingConstraint?.update(offset: self.menuWidth)
            self.layoutIfNeeded()
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
}

// MARK: - SidebarViewControllerDelegate 구현
extension SideMenuContainerView: SidebarViewControllerDelegate {
    func sidebarDidRequestClose() {
        // 닫기 버튼에서 호출 시 애니메이션으로 사이드바 닫기
        dismissMenu()
    }
} 