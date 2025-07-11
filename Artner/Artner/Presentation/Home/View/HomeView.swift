//
//  HomeView.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//
import UIKit
import SnapKit

final class HomeView: BaseView {

    // MARK: - UI Components
    let customNavigationBar = CustomNavigationHomeBar()
    let tableView = UITableView()
    private let bannerView = HomeBannerView()
    private let bottomFadeView = UIView()
    private let gradientLayer = CAGradientLayer()
    let cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_camera"), for: .normal)
        button.tintColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.5)
        button.backgroundColor = UIColor(hex: "#3D312C")
        button.layer.cornerRadius = 35 
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor(hex: "#FDA55C").withAlphaComponent(0.2).cgColor
        button.clipsToBounds = true
        return button
    }()

    // MARK: - Setup
    override func setupUI() {
        super.setupUI()

        backgroundColor = AppColor.background
        addSubview(customNavigationBar)
        addSubview(tableView)
        addSubview(bottomFadeView)
        addSubview(cameraButton)

        tableView.backgroundColor = AppColor.background
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(DocentTableViewCell.self, forCellReuseIdentifier: "DocentCell")
        tableView.tableHeaderView = bannerView

        setupFadeLayer()
    }

    override func setupLayout() {
        super.setupLayout()

        customNavigationBar.snp.makeConstraints {
            $0.top.equalTo(safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }

        tableView.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom)
            $0.leading.trailing.bottom.equalToSuperview()
        }

        bottomFadeView.snp.makeConstraints {
            $0.leading.trailing.bottom.equalToSuperview()
            $0.height.equalTo(135)
        }

        cameraButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.bottom).inset(42)
            $0.size.equalTo(70)
        }
    }

    private func setupFadeLayer() {
        bottomFadeView.isUserInteractionEnabled = false
        bottomFadeView.layer.addSublayer(gradientLayer)

        gradientLayer.colors = [
            UIColor(hex: "#281914").cgColor,
            UIColor(hex: "#281914").withAlphaComponent(0.0).cgColor
        ]
        gradientLayer.locations = [0.0, 1.0]
        gradientLayer.startPoint = CGPoint(x: 0.5, y: 1.0)
        gradientLayer.endPoint = CGPoint(x: 0.5, y: 0.0)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bottomFadeView.bounds

        if let header = tableView.tableHeaderView {
            let width = tableView.bounds.width
            let height = bannerView.systemLayoutSizeFitting(
                CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
                withHorizontalFittingPriority: .required,
                verticalFittingPriority: .fittingSizeLevel
            ).height

            if header.frame.size.height != height {
                header.frame = CGRect(x: 0, y: 0, width: width, height: height)
                tableView.tableHeaderView = header
            }
        }
    }

    // MARK: - Public Method
    func configureBanner(image: UIImage?, title: String, subtitle: String) {
        bannerView.configure(image: image, title: title, subtitle: subtitle)
    }
}
