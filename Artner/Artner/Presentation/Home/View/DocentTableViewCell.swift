import UIKit
import SnapKit

final class DocentTableViewCell: UITableViewCell {

    // MARK: - UI Components
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let periodLabel = UILabel()
    private let likeButton = UIButton()
    private let likeImageView = UIImageView()
    
    // MARK: - Properties
    private var isLiked: Bool = false
    var onLikeTapped: (() -> Void)?
    
    // 현재 좋아요 상태를 외부에서 확인할 수 있도록 하는 computed property
    var currentLikeStatus: Bool {
        return isLiked
    }

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
        periodLabel.textColor = UIColor(hex: "#FF7C27")

        // 좋아요 버튼 설정
        likeButton.backgroundColor = .clear
        likeButton.addTarget(self, action: #selector(likeButtonTapped), for: .touchUpInside)
        
        // 좋아요 아이콘 설정
        likeImageView.contentMode = .scaleAspectFit
        likeImageView.image = UIImage(named: "ic_heart")
        likeImageView.tintColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.2)

        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(periodLabel)
        contentView.addSubview(likeButton)
        likeButton.addSubview(likeImageView)
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
            $0.trailing.equalTo(likeButton.snp.leading).offset(-8)
        }
        
        likeButton.snp.makeConstraints {
            $0.centerY.equalTo(titleLabel)
            $0.trailing.equalToSuperview().inset(20)
            $0.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        likeImageView.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(CGSize(width: 24, height: 24))
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

    // MARK: - Actions
    @objc private func likeButtonTapped() {
        isLiked.toggle()
        updateLikeButtonAppearance()
        onLikeTapped?()
    }
    
    // MARK: - Private Methods
    private func updateLikeButtonAppearance() {
        if isLiked {
            likeImageView.image = resizeImage(UIImage(named: "ic_heart_filled"), to: CGSize(width: 24, height: 24))
            likeImageView.tintColor = UIColor(hex: "#FF7C27")
        } else {
            likeImageView.image = resizeImage(UIImage(named: "ic_heart"), to: CGSize(width: 24, height: 24))
            likeImageView.tintColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.2)
        }
    }
    
    private func resizeImage(_ image: UIImage?, to size: CGSize) -> UIImage? {
        guard let image = image else { return nil }
        
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    // MARK: - Public Configure Method
    func configure(thumbnail: URL?, title: String, subtitle: String, period: String, isLiked: Bool = false) {
        thumbnailImageView.loadImage(from: thumbnail)
        titleLabel.text = title
        subtitleLabel.text = subtitle
        periodLabel.text = period
        self.isLiked = isLiked
        updateLikeButtonAppearance()
    }
    
    func setLiked(_ liked: Bool) {
        isLiked = liked
        updateLikeButtonAppearance()
    }
}
