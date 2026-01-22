//
//  BotMessageCell.swift
//  Artner
//
//  Created by 신종원 on 6/1/25.
//

import UIKit
import SnapKit

final class BotMessageCell: UITableViewCell {

    // Clean Architecture: 뷰 계층을 명확하게 분리하고, 요구사항(프로필 비디오 아래에 말풍선 세로 쌓기)을 정확히 반영
    private lazy var profileVideoView: VideoPlayerView = {
        let videoView = VideoPlayerView()
        videoView.clipsToBounds = true
        videoView.layer.cornerRadius = 16
        // 비디오 로드
        videoView.loadVideo(fileName: "ai_video")
        return videoView
    }()

    private let bubbleLabel: PaddingLabel = {
        let label = PaddingLabel()
        label.textInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
        label.textColor = .white
        label.backgroundColor = AppColor.background
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textAlignment = .left
        label.numberOfLines = 0
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        return label
    }()

    private let verticalStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .leading
        stack.distribution = .fill
        return stack;
    }()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        // verticalStackView만 contentView에 추가
        contentView.addSubview(verticalStackView)
        verticalStackView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview()
            $0.leading.equalToSuperview().offset(16)
            $0.trailing.equalToSuperview().offset(-16)
        }
        
        // 프로필 비디오 크기 제약 설정 (기존 이미지와 유사한 크기)
        profileVideoView.snp.makeConstraints { make in
            make.width.height.equalTo(32) // 프로필 이미지 크기
        }
    }

    // MARK: - Public Method
    func configure(messages: [String], showProfile: Bool, showDocentButton: Bool) {
        verticalStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        // 프로필 비디오는 맨 위에, showProfile일 때만 add
        if showProfile {
            verticalStackView.addArrangedSubview(profileVideoView)
        }

        // 여러 줄 답변을 각각 bubbleLabel로 세로 쌓기
        for message in messages {
            let label = PaddingLabel()
            label.textInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
            label.textColor = .white
            label.backgroundColor = AppColor.background
            label.font = .systemFont(ofSize: 16, weight: .medium)
            label.textAlignment = .left
            label.numberOfLines = 0
            label.layer.cornerRadius = 16
            label.clipsToBounds = true
            label.text = message
            verticalStackView.addArrangedSubview(label)
        }

        // 아무것도 추가되지 않았다면 최소 높이 보장
        if verticalStackView.arrangedSubviews.isEmpty {
            let empty = UIView()
            empty.snp.makeConstraints { $0.height.greaterThanOrEqualTo(44) }
            verticalStackView.addArrangedSubview(empty)
        }
    }
}
