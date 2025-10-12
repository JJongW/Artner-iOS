import UIKit
import SnapKit

final class LikeView: BaseView {
    let navigationBar = CustomNavigationBar()
    
    // Navigation 바 아래 divider (1px, #FFFFFF 10% opacity)
    let navigationDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return view
    }()
    
    // 선택바 컨테이너
    let selectionBarContainer = UIView()
    let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    // 카테고리 버튼들
    let allButton = UIButton(type: .system)
    let exhibitionButton = UIButton(type: .system)
    let artistButton = UIButton(type: .system)
    let artworkButton = UIButton(type: .system)
    
    // 정렬 옵션
    let sortButton = UIButton(type: .system)
    
    let tableView = UITableView()
    let emptyView = LikeEmptyView()

    override func setupUI() {
        backgroundColor = .black
        
        // 네비게이션 바 설정
        addSubview(navigationBar)
        navigationBar.backgroundColor = .black
        navigationBar.titleLabel.textColor = .white
        navigationBar.backButton.tintColor = .white
        navigationBar.rightButton.tintColor = .white
        
        // Navigation divider 추가
        addSubview(navigationDivider)
        
        // 선택바 컨테이너 설정
        addSubview(selectionBarContainer)
        selectionBarContainer.addSubview(categoryStackView)
        selectionBarContainer.addSubview(sortButton)
        
        // 카테고리 버튼들 설정
        [allButton, exhibitionButton, artistButton, artworkButton].forEach { button in
            // 기본 상태 스타일
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = .systemFont(ofSize: 14, weight: .medium)
            button.titleLabel?.textAlignment = .center
            button.layer.cornerRadius = 16
            button.layer.borderWidth = 1
            button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            button.backgroundColor = .clear
            
            // 버튼 내부 패딩 설정 (좌우 12.5, 상하 10)
            button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12.5, bottom: 10, right: 12.5)
            
            categoryStackView.addArrangedSubview(button)
        }
        
        allButton.setTitle("전체", for: .normal)
        exhibitionButton.setTitle("전시", for: .normal)
        artistButton.setTitle("작가", for: .normal)
        artworkButton.setTitle("작품", for: .normal)
        
        // 정렬 버튼 설정
        sortButton.setTitle("최신순", for: .normal)
        sortButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal) // #FFFFFF 50% opacity
        sortButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium) // 폰트 크기 16
        
        // 화살표 아이콘 추가 (8px 간격)
        let chevronImageView = UIImageView()
        chevronImageView.image = UIImage(systemName: "chevron.up") // 최신순일 때 위쪽 화살표
        chevronImageView.tintColor = UIColor.white.withAlphaComponent(0.5) // #FFFFFF 50% opacity
        chevronImageView.contentMode = .scaleAspectFit
        sortButton.addSubview(chevronImageView)
        
        // 정렬 버튼 내부 레이아웃 설정
        sortButton.semanticContentAttribute = .forceRightToLeft // 텍스트와 아이콘 순서 조정
        sortButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0) // 8px 간격
        sortButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        
        chevronImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16) // 16*16 크기
        }
        
        // 테이블뷰와 빈 뷰 설정
        addSubview(tableView)
        addSubview(emptyView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        emptyView.isHidden = true
    }
    override func setupLayout() {
        // 네비게이션 바
        navigationBar.snp.makeConstraints { 
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(56) 
        }
        
        // Navigation divider (1px 높이, 좌우 전체)
        navigationDivider.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // 선택바 컨테이너
        selectionBarContainer.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(32)
        }
        
        // 카테고리 스택뷰 (왼쪽)
        categoryStackView.snp.makeConstraints { 
            $0.leading.centerY.equalToSuperview()
            $0.height.equalTo(32)
        }
        
        // 정렬 버튼 (오른쪽, 38px 간격)
        sortButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.leading.greaterThanOrEqualTo(categoryStackView.snp.trailing).offset(38)
            $0.height.equalTo(32)
            $0.width.greaterThanOrEqualTo(80)
        }
        
        // 테이블뷰
        tableView.snp.makeConstraints { 
            $0.top.equalTo(selectionBarContainer.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview() 
        }
        
        // 빈 뷰 (전체 화면 중앙에 배치)
        emptyView.snp.makeConstraints { 
            $0.top.equalTo(selectionBarContainer.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
} 
