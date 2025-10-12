import UIKit
import SnapKit

final class LikeEmptyView: UIView {
    let messageLabel = UILabel()
    let goFeedButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .black
        setupUI()
    }
    
    required init?(coder: NSCoder) { 
        fatalError("init(coder:) has not been implemented") 
    }
    
    private func setupUI() {
        addSubview(messageLabel)
        addSubview(goFeedButton)
        
        // 메시지 라벨 설정 (이미지와 동일한 스타일)
        messageLabel.text = "좋아요가 없어요."
        messageLabel.textColor = .white
        messageLabel.font = .systemFont(ofSize: 16, weight: .regular)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 1
        
        // 피드 보러가기 버튼 설정 (이미지와 동일한 스타일)
        goFeedButton.setTitle("피드 둘러보러 가기", for: .normal)
        goFeedButton.setTitleColor(.white, for: .normal)
        goFeedButton.backgroundColor = UIColor.white.withAlphaComponent(0.15) // 약간 더 진한 회색
        goFeedButton.layer.cornerRadius = 10
        goFeedButton.titleLabel?.font = .systemFont(ofSize: 15, weight: .medium)
        
        // 레이아웃 설정 (화면 중앙에 배치)
        messageLabel.snp.makeConstraints { 
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-20)
        }
        
        goFeedButton.snp.makeConstraints { 
            $0.top.equalTo(messageLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.width.greaterThanOrEqualTo(160)
            $0.height.equalTo(44) // 조금 더 높게 조정
        }
    }
} 