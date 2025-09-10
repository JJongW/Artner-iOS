//
//  BaseViewController.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

import UIKit

class BaseViewController<ViewModelType, CoordinatorType>: UIViewController {

    // MARK: - Properties

    let viewModel: ViewModelType
    let coordinator: CoordinatorType

    // MARK: - Init

    init(viewModel: ViewModelType, coordinator: CoordinatorType) {
        self.viewModel = viewModel
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("Storyboard를 사용하지 않습니다.")
    }

    // MARK: - LifeCycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupBinding()
    }

    // MARK: - LifeCycle Override
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 뷰가 나타나기 전에 키보드 관련 뷰들의 스냅샷 문제 방지
        preventKeyboardSnapshotWarnings()
    }
    
    // MARK: - Methods (Override Points)

    func setupUI() { }
    func setupBinding() { }
    
    // MARK: - Snapshot Warning Prevention
    
    /// 키보드 관련 스냅샷 경고를 방지하는 메서드
    private func preventKeyboardSnapshotWarnings() {
        // 뷰가 완전히 로드된 후에 실행
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // 키보드 관련 뷰들이 있는지 확인하고 안전하게 처리
            if self.view.isVisibleInWindow {
                self.checkAndFixKeyboardViews(in: self.view)
            }
        }
    }
    
    /// 뷰 계층구조에서 키보드 관련 뷰들을 찾아 안전하게 처리하는 메서드
    private func checkAndFixKeyboardViews(in view: UIView) {
        // 현재 뷰가 키보드 관련 뷰이고 화면에 보이지 않으면 경고 방지 처리
        if view.isKeyboardRelated && !view.isVisibleInWindow {
            // 스냅샷이 발생할 수 있는 상황을 미리 방지
            view.layer.shouldRasterize = false
        }
        
        // 하위 뷰들에 대해서도 재귀적으로 확인
        for subview in view.subviews {
            checkAndFixKeyboardViews(in: subview)
        }
    }
    
    /// 안전한 뷰 스냅샷을 위한 헬퍼 메서드
    func safeCreateSnapshot(of view: UIView) -> UIImage? {
        // 뷰가 화면에 보이는지 확인
        guard view.isVisibleInWindow else {
            print("⚠️ 뷰가 화면에 보이지 않아 스냅샷 생성을 건너뜁니다.")
            return nil
        }
        
        return view.safeSnapshot()
    }
}
