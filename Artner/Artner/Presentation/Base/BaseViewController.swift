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

    // MARK: - Methods (Override Points)

    func setupUI() { }
    func setupBinding() { }
}
