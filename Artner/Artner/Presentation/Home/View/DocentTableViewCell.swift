import UIKit
import SnapKit

final class DocentTableViewCell: UITableViewCell {

    // MARK: - UI Components
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let periodLabel = UILabel()

    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Setup
    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear

        thumbnailImageView.contentMode = .scaleAspectFill
        thumbnailImageView.clipsToBounds = true
        thumbnailImageView.layer.cornerRadius = 12
        thumbnailImageView.backgroundColor = UIColor.white.withAlphaComponent(0.1)  // ← nil 이미지 대응용 배경색 추가

        titleLabel.font = UIFont.boldSystemFont(ofSize: 16)
        titleLabel.textColor = .white

        subtitleLabel.font = UIFont.systemFont(ofSize: 14)
        subtitleLabel.textColor = .white.withAlphaComponent(0.8)

        periodLabel.font = UIFont.systemFont(ofSize: 14)
        periodLabel.textColor = .white

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(periodLabel)
    }

    private func setupLayout() {
        thumbnailImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(CGSize(width: 105, height: 105))
            $0.bottom.lessThanOrEqualToSuperview().inset(16)
        }

        titleLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView.snp.top).offset(2)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(10)
            $0.trailing.equalToSuperview().inset(20)
        }

        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalTo(titleLabel)
        }

        periodLabel.snp.makeConstraints {
            $0.top.equalTo(subtitleLabel.snp.bottom).offset(6)
            $0.leading.trailing.equalTo(titleLabel)
        }
    }

    // MARK: - Public Configure Method
    func configure(thumbnail: URL?, title: String, subtitle: String, period: String) {
        thumbnailImageView.loadImage(from: thumbnail)  // ← 올바른 인스턴스 메서드 호출
        titleLabel.text = title
        subtitleLabel.text = subtitle
        periodLabel.text = period
    }
}
