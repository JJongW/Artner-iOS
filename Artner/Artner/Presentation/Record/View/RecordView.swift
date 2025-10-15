import UIKit
import SnapKit

final class RecordView: BaseView {
    let navigationBar = CustomNavigationBar()
    
    // Navigation 바 아래 divider (1px, #FFFFFF 10% opacity)
    let navigationDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return view
    }()
    
    // 정렬 버튼 컨테이너
    let sortContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    // 정렬 옵션
    let sortButton: UIButton = {
        let button = UIButton(type: .system)
        return button
    }()
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = true
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceVertical = true
        
        // RecordCollectionViewCell 등록
        collectionView.register(RecordCollectionViewCell.self, forCellWithReuseIdentifier: RecordCollectionViewCell.identifier)
        
        return collectionView
    }()
    
    let emptyView = RecordEmptyView()

    override func setupUI() {
        backgroundColor = .black
        
        // 네비게이션 바 설정
        addSubview(navigationBar)
        navigationBar.backgroundColor = .black
        navigationBar.setTitle("전시기록")
        navigationBar.titleLabel.textColor = .white
        navigationBar.backButton.tintColor = .white
        navigationBar.rightButton.tintColor = .white
        
        // Navigation divider 추가
        addSubview(navigationDivider)
        
        // 정렬 버튼 컨테이너 설정
        addSubview(sortContainerView)
        sortContainerView.addSubview(sortButton)
        
        // 정렬 버튼 설정
        sortButton.setTitle("최신순", for: .normal)
        sortButton.setTitleColor(UIColor.white.withAlphaComponent(0.5), for: .normal)
        sortButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        
        // 화살표 아이콘 추가
        let chevronImageView = UIImageView()
        chevronImageView.image = UIImage(systemName: "chevron.up")
        chevronImageView.tintColor = UIColor.white.withAlphaComponent(0.5)
        chevronImageView.contentMode = .scaleAspectFit
        sortButton.addSubview(chevronImageView)
        
        // 정렬 버튼 내부 레이아웃 설정
        sortButton.semanticContentAttribute = .forceRightToLeft
        sortButton.imageEdgeInsets = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 0)
        sortButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 8)
        
        chevronImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.height.equalTo(16)
        }
        
        // 컬렉션뷰와 빈 뷰 설정
        addSubview(collectionView)
        addSubview(emptyView)
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
        
        // 정렬 버튼 컨테이너 (오른쪽 정렬)
        sortContainerView.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(32)
        }
        
        // 정렬 버튼 (오른쪽 정렬)
        sortButton.snp.makeConstraints {
            $0.trailing.centerY.equalToSuperview()
            $0.height.equalTo(32)
            $0.width.greaterThanOrEqualTo(80)
        }
        
        // 컬렉션뷰
        collectionView.snp.makeConstraints { 
            $0.top.equalTo(sortContainerView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview() 
        }
        
        // 빈 뷰
        emptyView.snp.makeConstraints { 
            $0.top.equalTo(sortContainerView.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide)
        }
    }
} 
