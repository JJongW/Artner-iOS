import UIKit
import SnapKit

final class RecordEmptyView: UIView {
    let messageLabel = UILabel()
    let goRecordButton = UIButton(type: .system)
    
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
        addSubview(goRecordButton)
        
        // 메시지 라벨 설정
        messageLabel.text = "전시 기록이 없어요."
        messageLabel.textColor = .white
        messageLabel.font = .systemFont(ofSize: 16, weight: .regular)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 1
        
        // 전시 기록하러가기 버튼 설정
        goRecordButton.setTitle("전시 기록하러가기", for: .normal)
        goRecordButton.setTitleColor(UIColor(hex: "#FFFFFF"), for: .normal)
        goRecordButton.backgroundColor = UIColor(hex: "#FF7C27")
        goRecordButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        goRecordButton.layer.cornerRadius = 10
        
        // 버튼 내부 패딩 설정 (상하 10, 좌우 26)
        goRecordButton.contentEdgeInsets = UIEdgeInsets(top: 10, left: 26, bottom: 10, right: 26)
        
        // 레이아웃 설정 (화면 전체의 정 가운데 배치)
        messageLabel.snp.makeConstraints { 
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-50) // 버튼까지 포함한 전체를 중앙에 배치
        }
        
        goRecordButton.snp.makeConstraints { 
            $0.top.equalTo(messageLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.height.greaterThanOrEqualTo(40)
        }
    }
} 
