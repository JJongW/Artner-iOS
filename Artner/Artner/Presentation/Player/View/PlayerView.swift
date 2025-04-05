//
//  PlayerView.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//
import UIKit
import SnapKit

final class PlayerView: UIView {

    // MARK: - UI Components

    let customNavigationBar = UIView()
    let backButton = UIButton(type: .system)
    let titleLabel = UILabel()
    let artistLabel = UILabel()
    let descriptionLabel = UILabel()
    let playButton = UIButton(type: .system)

    // MARK: - Init

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup

    private func setupUI() {
        backgroundColor = .white

        // Custom Navigation Bar
        customNavigationBar.backgroundColor = .white
        addSubview(customNavigationBar)

        customNavigationBar.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(44) // 일반 네비게이션바 높이
        }

        backButton.setTitle("←", for: .normal)
        customNavigationBar.addSubview(backButton)

        backButton.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(16)
            make.centerY.equalToSuperview()
        }

        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.text = "도슨트 플레이어"
        titleLabel.textAlignment = .center

        customNavigationBar.addSubview(titleLabel)

        titleLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }

        // Main Content Stack
        let stackView = UIStackView(arrangedSubviews: [
            self.artistLabel, self.descriptionLabel, self.playButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.alignment = .center

        artistLabel.font = UIFont.systemFont(ofSize: 18)
        artistLabel.textColor = .gray
        artistLabel.textAlignment = .center

        descriptionLabel.font = UIFont.systemFont(ofSize: 16)
        descriptionLabel.textColor = .darkGray
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .center

        playButton.setTitle("▶️ 재생", for: .normal)

        addSubview(stackView)

        stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
        }
    }
}
