//
//  RecordCollectionViewCell.swift
//  Artner
//
//  Created by iOS Developer on 2025-01-16.
//  Copyright © 2025 Artner. All rights reserved.
//

import UIKit
import SnapKit

/// 전시 기록 컬렉션뷰 셀
final class RecordCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Components
    
    /// 전시 이미지 (105x105)
    private let exhibitionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(hex: "#222222")
        imageView.layer.cornerRadius = 8
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    /// 전시명 라벨
    private let exhibitionNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor.white // #FFFFFF 100%
        label.numberOfLines = 2
        return label
    }()
    
    /// 방문 날짜 라벨
    private let visitDateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = UIColor.white.withAlphaComponent(0.5) // #FFFFFF 50%
        return label
    }()
    
    /// 텍스트 스택뷰
    private let textStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 6
        stackView.alignment = .leading
        return stackView
    }()
    
    /// 카드 배경 뷰 (콘텐츠를 감싸는 배경)
    private let cardBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1) // #FFFFFF 10%
        return view
    }()
    
    /// 삭제 버튼 (스와이프시 표시)
    private let deleteButton: UIButton = {
        var config = UIButton.Configuration.plain()

        config.image = UIImage(named: "ic_delete")
        config.baseForegroundColor = .white

        config.title = "삭제"
        config.attributedTitle?.font = .systemFont(ofSize: 12, weight: .medium)

        config.imagePlacement = .top
        config.imagePadding = 8

        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        let button = UIButton(configuration: config)
        button.backgroundColor = UIColor(hex: "#FF5959")
        button.layer.cornerRadius = 0
        button.alpha = 0
        button.isHidden = true
        
        return button
    }()
    
    /// 메인 컨테이너뷰
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // MARK: - Properties
    
    /// 삭제 버튼 액션 클로저
    var onDelete: (() -> Void)?
    
    /// 스와이프 상태
    private var isSwipeRevealed = false
    
    /// 팬 제스처 시작 시점의 컨테이너 위치
    private var startingTrailingConstraint: CGFloat = 0
    
    /// 삭제 버튼 너비
    private let deleteButtonWidth: CGFloat = 80
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGestures()
    }
    
    // MARK: - Setup
    
    private func setupUI() {
        backgroundColor = .clear
        
        // 메인 컨테이너뷰 추가
        addSubview(containerView)
        addSubview(deleteButton)
        
        // 카드 배경 뷰 추가 (콘텐츠를 감싸는 배경)
        containerView.addSubview(cardBackgroundView)
        
        // 카드 배경 뷰에 콘텐츠 추가
        cardBackgroundView.addSubview(exhibitionImageView)
        cardBackgroundView.addSubview(textStackView)
        
        // 텍스트 스택뷰에 라벨들 추가
        textStackView.addArrangedSubview(exhibitionNameLabel)
        textStackView.addArrangedSubview(visitDateLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // 메인 컨테이너뷰
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 카드 배경 뷰 (컨테이너 전체를 차지)
        cardBackgroundView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 전시 이미지 (105x105, 카드 배경 뷰로부터 좌측 20px, 상하 20px 마진)
        exhibitionImageView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.top.equalToSuperview().offset(20)
            $0.bottom.equalToSuperview().offset(-20)
            $0.width.height.equalTo(105)
        }
        
        // 텍스트 스택뷰 (이미지에서 10px 마진, 우측 20px 마진)
        textStackView.snp.makeConstraints {
            $0.leading.equalTo(exhibitionImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalToSuperview()
        }
        
        // 삭제 버튼 (우측에 숨겨져 있다가 스와이프시 나타남)
        deleteButton.snp.makeConstraints {
            $0.top.bottom.trailing.equalToSuperview()
            $0.width.equalTo(deleteButtonWidth)
        }
        
        // 삭제 버튼 액션 등록
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    private func setupGestures() {
        // 팬 제스처로 인터랙티브한 스와이프 구현 (손가락을 따라 움직임)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        panGesture.delegate = self
        addGestureRecognizer(panGesture)
        
        // 탭 제스처로 스와이프 취소
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Public Methods
    
    /// 셀 데이터 설정
    func configure(with recordItem: RecordItemModel) {
        exhibitionNameLabel.text = recordItem.exhibitionName
        visitDateLabel.text = recordItem.visitDate
        
        if let image = recordItem.selectedImage {
            exhibitionImageView.image = image
        } else {
            // 기본 이미지 또는 플레이스홀더
            exhibitionImageView.image = UIImage(systemName: "photo")?.withTintColor(.white.withAlphaComponent(0.3))
        }
    }
    
    /// 스와이프 상태 초기화
    func resetSwipeState() {
        isSwipeRevealed = false
        
        UIView.animate(withDuration: 0.3) {
            // Transform 초기화 (원위치로)
            self.containerView.transform = .identity
            // 삭제 버튼 서서히 페이드아웃
            self.deleteButton.alpha = 0
        } completion: { _ in
            self.deleteButton.isHidden = true
        }
    }
    
    // MARK: - Actions
    
    /// 팬 제스처 핸들러 - 손가락을 따라 자연스럽게 움직임
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self)
        let velocity = gesture.velocity(in: self)
        
        switch gesture.state {
        case .began:
            // 제스처 시작 시 현재 위치 저장
            startingTrailingConstraint = isSwipeRevealed ? -deleteButtonWidth : 0
            
        case .changed:
            // 드래그에 따라 실시간으로 위치 변경
            let newOffset = startingTrailingConstraint + translation.x
            
            // 오른쪽으로는 못 넘어가고, 왼쪽으로는 삭제 버튼 너비까지만
            let clampedOffset = min(0, max(-deleteButtonWidth, newOffset))
            
            // 삭제 버튼 표시 여부와 alpha 값 결정 (드래그 진행도에 따라 서서히 나타남)
            if clampedOffset < 0 {
                deleteButton.isHidden = false
                // 드래그 진행도에 따라 alpha 조절 (0 ~ 1)
                let progress = abs(clampedOffset) / deleteButtonWidth
                deleteButton.alpha = progress
            }
            
            // Transform을 사용하여 부드럽게 이동 (constraint 업데이트보다 성능 좋음)
            containerView.transform = CGAffineTransform(translationX: clampedOffset, y: 0)
            
        case .ended, .cancelled:
            // 제스처 종료 시 velocity와 위치에 따라 최종 상태 결정
            let currentOffset = startingTrailingConstraint + translation.x
            
            // 빠르게 스와이프했거나, 절반 이상 넘어간 경우 삭제 버튼 표시
            let shouldReveal = velocity.x < -500 || currentOffset < -deleteButtonWidth / 2
            
            if shouldReveal {
                // 삭제 버튼 완전히 표시
                revealDeleteButton()
            } else {
                // 원위치로 복귀
                resetSwipeState()
            }
            
        default:
            break
        }
    }
    
    /// 삭제 버튼을 완전히 드러냄
    private func revealDeleteButton() {
        isSwipeRevealed = true
        deleteButton.isHidden = false
        
        // 스프링 애니메이션으로 자연스럽게
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.5,
            options: .curveEaseOut
        ) {
            // Transform으로 삭제 버튼만큼 왼쪽으로 이동
            self.containerView.transform = CGAffineTransform(translationX: -self.deleteButtonWidth, y: 0)
            // 삭제 버튼 완전히 불투명하게
            self.deleteButton.alpha = 1.0
        }
    }
    
    @objc private func handleTap() {
        guard isSwipeRevealed else { return }
        resetSwipeState()
    }
    
    @objc private func deleteButtonTapped() {
        onDelete?()
    }
}

// MARK: - UIGestureRecognizerDelegate
extension RecordCollectionViewCell: UIGestureRecognizerDelegate {
    /// 팬 제스처가 시작될 수 있는지 판단 (수평 스와이프일 때만 제스처 시작, 수직 스크롤 방해하지 않음)
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let panGesture = gestureRecognizer as? UIPanGestureRecognizer {
            let velocity = panGesture.velocity(in: self)
            return abs(velocity.x) > abs(velocity.y)
        }
        return true
    }
}

// MARK: - ReuseIdentifier
extension RecordCollectionViewCell {
    static let identifier = "RecordCollectionViewCell"
}
