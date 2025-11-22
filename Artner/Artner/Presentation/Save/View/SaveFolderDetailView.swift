import UIKit
import SnapKit

/// LikeView 레이아웃을 그대로 따르는 저장 폴더 상세 뷰
final class SaveFolderDetailView: BaseView {
    let navigationBar = CustomNavigationBar()
    let navigationDivider: UIView = {
        let v = UIView(); v.backgroundColor = UIColor.white.withAlphaComponent(0.1); return v
    }()
    
    // 선택바 영역 (카테고리 + 정렬)
    let selectionBarContainer = UIView()
    let categoryStackView: UIStackView = {
        let s = UIStackView(); s.axis = .horizontal; s.spacing = 8; s.distribution = .fillEqually; return s
    }()
    
    // 카테고리 버튼: 전체/작가/작품 (전시 제외 - 요구에 맞춰 3버튼)
    let allButton = UIButton(type: .system)
    let artistButton = UIButton(type: .system)
    let artworkButton = UIButton(type: .system)
    
    // 정렬 버튼 (최신순/오래된순)
    let sortButton = UIButton(type: .system)
    
    let tableView = UITableView()
    
    override func setupUI() {
        backgroundColor = .black
        addSubview(navigationBar)
        navigationBar.backgroundColor = .black
        navigationBar.titleLabel.textColor = .white
        navigationBar.backButton.tintColor = .white
        navigationBar.rightButton.tintColor = .white
        addSubview(navigationDivider)
        
        // 선택바 컨테이너
        addSubview(selectionBarContainer)
        selectionBarContainer.addSubview(categoryStackView)
        selectionBarContainer.addSubview(sortButton)
        
        // 카테고리 버튼 기본 스타일 (LikeView 준용)
        [allButton, artistButton, artworkButton].forEach { b in
            b.setTitleColor(.white, for: .normal)
            b.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            b.titleLabel?.textAlignment = .center
            b.layer.cornerRadius = 16
            b.layer.borderWidth = 1
            b.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            b.backgroundColor = .clear
            b.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12.5, bottom: 10, right: 12.5)
            categoryStackView.addArrangedSubview(b)
        }
        allButton.setTitle("전체", for: .normal)
        artistButton.setTitle("작가", for: .normal)
        artworkButton.setTitle("작품", for: .normal)
        
        // 정렬 버튼 스타일 (LikeView 준용)
        sortButton.setTitle("최신순", for: .normal)
        sortButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        sortButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        let chevronImageView = UIImageView(image: UIImage(systemName: "chevron.up"))
        chevronImageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        chevronImageView.contentMode = .scaleAspectFit
        sortButton.addSubview(chevronImageView)
        sortButton.semanticContentAttribute = .forceRightToLeft
        sortButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        sortButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        chevronImageView.snp.makeConstraints { m in
            m.leading.centerY.equalToSuperview(); m.width.height.equalTo(16)
        }
        
        addSubview(tableView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
    }
    
    override func setupLayout() {
        navigationBar.snp.makeConstraints { m in
            m.top.leading.trailing.equalTo(safeAreaLayoutGuide); m.height.equalTo(56)
        }
        navigationDivider.snp.makeConstraints { m in
            m.top.equalTo(navigationBar.snp.bottom); m.leading.trailing.equalToSuperview(); m.height.equalTo(1)
        }
        selectionBarContainer.snp.makeConstraints { m in
            m.top.equalTo(navigationBar.snp.bottom).offset(16)
            m.leading.trailing.equalToSuperview().inset(16)
            m.height.equalTo(32)
        }
        categoryStackView.snp.makeConstraints { m in
            m.leading.centerY.equalToSuperview(); m.height.equalTo(32)
        }
        sortButton.snp.makeConstraints { m in
            m.trailing.centerY.equalToSuperview()
            m.leading.greaterThanOrEqualTo(categoryStackView.snp.trailing).offset(38)
            m.height.equalTo(32); m.width.greaterThanOrEqualTo(80)
        }
        // 리스트는 선택바로부터 26px
        tableView.snp.makeConstraints { m in
            m.top.equalTo(selectionBarContainer.snp.bottom).offset(26)
            m.leading.trailing.bottom.equalToSuperview()
        }
    }
}


