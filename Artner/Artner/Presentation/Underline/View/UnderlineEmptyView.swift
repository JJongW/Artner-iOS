import UIKit
import SnapKit

final class UnderlineEmptyView: UIView {
    let messageLabel = UILabel()
    let goFeedButton = UIButton(type: .system)
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        setupUI()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    private func setupUI() {
        addSubview(messageLabel)
        addSubview(goFeedButton)
        messageLabel.text = "밑줄 친 항목이 없어요."
        messageLabel.textColor = .white
        messageLabel.font = .systemFont(ofSize: 16)
        messageLabel.textAlignment = .center
        goFeedButton.setTitle("피드 둘러보러 가기", for: .normal)
        goFeedButton.setTitleColor(.white, for: .normal)
        goFeedButton.backgroundColor = UIColor.white.withAlphaComponent(0.15)
        goFeedButton.layer.cornerRadius = 10
        goFeedButton.titleLabel?.font = .systemFont(ofSize: 15)
        messageLabel.snp.makeConstraints { $0.centerX.equalToSuperview(); $0.centerY.equalToSuperview().offset(-20) }
        goFeedButton.snp.makeConstraints { $0.top.equalTo(messageLabel.snp.bottom).offset(24); $0.centerX.equalToSuperview(); $0.width.greaterThanOrEqualTo(160); $0.height.equalTo(40) }
    }
} 