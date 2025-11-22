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
    private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .systemUltraThinMaterialDark))
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
        // SidebarViewController delegate 연결 코드 제거
        // if let sidebarVC = menuViewController as? SidebarViewController {
        //     sidebarVC.delegate = self
        // }
    }
    required init?(coder: NSCoder) { fatalError() }

    private func setupUI() {
        // 블러 배경 (뒤쪽 화면을 은은하게 흐림 처리)
        blurView.alpha = 0
        addSubview(blurView)
        blurView.snp.makeConstraints { $0.edges.equalToSuperview() }
        
        // 오버레이(더 옅게 톤다운)
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.2)
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
        
        // 초기 위치: 우측 바깥 (trailing = menuWidth)
        menuViewTrailingConstraint?.update(offset: menuWidth)
        
        // 레이아웃을 먼저 완료시켜서 내부 뷰들이 모두 렌더링되도록 함
        layoutIfNeeded()
        
        // 내부 뷰의 레이아웃도 완료되도록 강제
        menuViewController.view.layoutIfNeeded()
        
        // 내부 요소들을 alpha 0으로 시작 (SidebarView에 메서드가 있다면 호출)
        if let sidebarView = menuViewController.view as? SidebarView {
            sidebarView.setContentAlpha(0)
        } else if let sidebarVC = menuViewController as? SidebarViewController {
            sidebarVC.sidebarView.setContentAlpha(0)
        }
        
        // 레이아웃 완료 후 다음 런루프에서 애니메이션 시작
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 사이드바 슬라이드 인 애니메이션
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut) {
                self.blurView.alpha = 0.8
                self.overlayView.alpha = 1
                self.menuViewTrailingConstraint?.update(offset: 0)
                self.layoutIfNeeded()
            } completion: { _ in
                // 사이드바가 완전히 열린 후 내부 요소들을 fade-in
                UIView.animate(withDuration: 0.2, delay: 0.05, options: .curveEaseOut) {
                    if let sidebarView = self.menuViewController.view as? SidebarView {
                        sidebarView.setContentAlpha(1)
                    } else if let sidebarVC = self.menuViewController as? SidebarViewController {
                        sidebarVC.sidebarView.setContentAlpha(1)
                    }
                }
            }
        }
    }

    @objc func dismissMenu(completion: (() -> Void)? = nil) {
        // 먼저 내부 요소들을 fade-out
        UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn) {
            if let sidebarView = self.menuViewController.view as? SidebarView {
                sidebarView.setContentAlpha(0)
            } else if let sidebarVC = self.menuViewController as? SidebarViewController {
                sidebarVC.sidebarView.setContentAlpha(0)
            }
        } completion: { _ in
            // 내부 요소들이 사라진 후 사이드바를 슬라이드 아웃
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn) {
                self.blurView.alpha = 0
                self.overlayView.alpha = 0
                self.menuViewTrailingConstraint?.update(offset: self.menuWidth)
                self.layoutIfNeeded()
            } completion: { _ in
                self.removeFromSuperview()
                completion?()
            }
        }
    }
} 
