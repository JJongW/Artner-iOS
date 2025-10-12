import UIKit
import SnapKit

final class SaveEmptyView: UIView {
    let messageLabel = UILabel()
    let createFolderButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    private func setupUI() {
        addSubview(messageLabel)
        addSubview(createFolderButton)
        
        // 폴더가 없을 때 메시지
        messageLabel.text = "폴더가 없어요."
        messageLabel.textColor = .white
        messageLabel.font = .systemFont(ofSize: 18, weight: .medium)
        messageLabel.textAlignment = .center
        
        // 폴더 생성하기 버튼
        createFolderButton.setTitle("폴더 생성하기", for: .normal)
        createFolderButton.setTitleColor(.white, for: .normal)
        createFolderButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        createFolderButton.layer.cornerRadius = 12
        createFolderButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        // 레이아웃 설정 - 화면 정 가운데 정렬
        messageLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-30)
        }
        
        createFolderButton.snp.makeConstraints { make in
            make.top.equalTo(messageLabel.snp.bottom).offset(24)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(160)
            make.height.equalTo(44)
        }
    }
} 