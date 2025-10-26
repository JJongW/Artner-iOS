//
//  LaunchViewController.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import UIKit
import SnapKit

/// 앱 시작 화면을 담당하는 ViewController
final class LaunchViewController: UIViewController {
    
    // MARK: - UI Components
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "artner"
        label.font = UIFont.poppinsMedium(size: 52)
        label.textColor = UIColor(hex: "#FFDB98")
        label.textAlignment = .center
        return label
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupLayout()
        setupActions()
        checkFontLoading()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 2초 후 메인 화면으로 전환
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.transitionToMainScreen()
        }
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.backgroundColor = UIColor(hex: "#000000")
        view.addSubview(titleLabel)
    }
    
    private func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(312)
        }
    }
    
    private func setupActions() {
        // 필요시 탭 제스처 추가 가능
    }
    
    private func checkFontLoading() {
        // Poppins 폰트가 제대로 로드되었는지 확인
        if let poppinsFont = UIFont(name: "Poppins-Medium", size: 52) {
            print("✅ Poppins-Medium 폰트 로드 성공: \(poppinsFont.fontName)")
            titleLabel.font = poppinsFont
        } else {
            print("❌ Poppins-Medium 폰트 로드 실패, 시스템 폰트 사용")
            titleLabel.font = UIFont.systemFont(ofSize: 52, weight: .medium)
        }
    }
    
    // MARK: - Navigation
    private func transitionToMainScreen() {
        // SceneDelegate에서 메인 화면으로 전환하도록 구현
        if let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate {
            sceneDelegate.showMainScreen()
        }
    }
}
