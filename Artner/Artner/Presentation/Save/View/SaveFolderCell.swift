import UIKit
import SnapKit

// MARK: - Save Folder Cell
/// 폴더 형태의 저장 아이템을 표시하는 셀 컴포넌트
final class SaveFolderCell: UICollectionViewCell {
    static let identifier = "SaveFolderCell"
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#222222")
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let folderNameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 16, weight: .medium)
        label.numberOfLines = 2
        return label
    }()
    
    private let meatballButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = UIColor.white.withAlphaComponent(0.6)
        button.contentMode = .scaleAspectFit
        return button
    }()
    
    private let itemCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.6)
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    // MARK: - Properties
    var onMeatballTapped: (() -> Void)?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        backgroundColor = .clear
        
        addSubview(containerView)
        containerView.addSubview(folderNameLabel)
        containerView.addSubview(meatballButton)
        containerView.addSubview(itemCountLabel)
        containerView.addSubview(dateLabel)
        
        // 미트볼 버튼 액션 설정
        meatballButton.addTarget(self, action: #selector(meatballButtonTapped), for: .touchUpInside)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        folderNameLabel.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(16)
            make.trailing.equalTo(meatballButton.snp.leading).offset(-8)
        }
        
        meatballButton.snp.makeConstraints { make in
            make.top.trailing.equalToSuperview().inset(16)
            make.width.height.equalTo(20)
        }
        
        itemCountLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
        
        dateLabel.snp.makeConstraints { make in
            make.trailing.equalToSuperview().inset(16)
            make.bottom.equalToSuperview().inset(16)
        }
    }
    
    // MARK: - Configuration
    /// 폴더 데이터로 셀을 구성합니다
    func configure(with folder: SaveFolderModel) {
        folderNameLabel.text = folder.name
        itemCountLabel.text = "\(folder.itemCount)개"
        
        // 날짜 포맷팅 (YYYY.MM.DD)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        dateLabel.text = formatter.string(from: folder.createdDate)
    }
    
    // MARK: - Actions
    @objc private func meatballButtonTapped() {
        onMeatballTapped?()
    }
}

// MARK: - Add Folder Cell
/// 폴더 추가 버튼을 위한 셀
final class AddFolderCell: UICollectionViewCell {
    static let identifier = "AddFolderCell"
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        button.layer.cornerRadius = 30 // 원형 버튼
        return button
    }()
    
    var onAddButtonTapped: (() -> Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        
        addButton.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        addSubview(addButton)
    }
    
    private func setupLayout() {
        addButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(60)
        }
    }
    
    @objc private func addButtonTapped() {
        onAddButtonTapped?()
    }
}
