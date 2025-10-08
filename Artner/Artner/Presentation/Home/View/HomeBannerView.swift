//
//  HomeBannerView.swift
//  Artner
//
//  Created by 신종원 on 4/27/25.
//

import UIKit
import SnapKit

final class HomeBannerView: BaseView {

    // MARK: - UI Components

    private let containerView = UIView()
    private let backgroundImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    // MARK: - Setup
    override func setupUI() {
        super.setupUI()
        backgroundColor = AppColor.background

        addSubview(containerView)

        containerView.addSubview(backgroundImageView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(subtitleLabel)

        backgroundImageView.contentMode = .scaleToFill
        backgroundImageView.clipsToBounds = true
        backgroundImageView.layer.cornerRadius = 16

        titleLabel.font = UIFont.boldSystemFont(ofSize: 20)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 2

        subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        subtitleLabel.textColor = UIColor.white.withAlphaComponent(0.5)
        subtitleLabel.numberOfLines = 1
    }

    override func setupLayout() {
        super.setupLayout()

        // containerView의 제약조건 - 좌우 여백은 고정, 상하는 우선순위를 낮춤
        containerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(16).priority(.high) // 우선순위 조정
        }

        titleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalToSuperview()
        }

        subtitleLabel.snp.makeConstraints {
            $0.leading.trailing.equalToSuperview()
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }

        backgroundImageView.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(26)
            $0.leading.equalToSuperview()
            $0.trailing.equalToSuperview()
            $0.height.equalTo(120)
            $0.bottom.equalToSuperview()
        }
        
        // HomeBannerView 자체에 최소 높이 제약조건 추가 (tableHeaderView 사용 시 안정성 확보)
        self.snp.makeConstraints {
            $0.height.greaterThanOrEqualTo(180).priority(.high) // 최소 높이 보장
        }
    }

    // MARK: - Public Methods
    func configure(image: UIImage?, title: String, subtitle: String) {
        backgroundImageView.image = image
        titleLabel.text = title
        subtitleLabel.text = subtitle
        
        // 텍스트 변경 시 크기 재계산 필요함을 알림
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Intrinsic Content Size
    
    /// HomeBannerView의 고유 크기를 계산
    /// tableHeaderView로 사용될 때 적절한 크기를 제공하기 위해 구현
    override var intrinsicContentSize: CGSize {
        // 내부 컨텐츠 크기를 기반으로 계산
        let width = UIView.noIntrinsicMetric
        
        // 높이 계산: 상하 여백 + 타이틀 + 간격 + 서브타이틀 + 간격 + 이미지 높이
        let topMargin: CGFloat = 0 // containerView top
        let titleHeight = titleLabel.intrinsicContentSize.height
        let titleToSubtitleSpacing: CGFloat = 8
        let subtitleHeight = subtitleLabel.intrinsicContentSize.height
        let subtitleToImageSpacing: CGFloat = 26
        let imageHeight: CGFloat = 120
        let bottomMargin: CGFloat = 16 // containerView bottom inset
        
        let totalHeight = topMargin + titleHeight + titleToSubtitleSpacing + 
                         subtitleHeight + subtitleToImageSpacing + imageHeight + bottomMargin
        
        return CGSize(width: width, height: totalHeight)
    }
}
