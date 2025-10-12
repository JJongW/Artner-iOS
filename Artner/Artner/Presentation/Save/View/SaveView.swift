import UIKit
import SnapKit

final class SaveView: BaseView {
    let navigationBar = CustomNavigationBar()
    
    // Navigation 바 아래 divider (1px, #FFFFFF 10% opacity)
    let navigationDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return view
    }()
    
    // 폴더 컬렉션뷰 (2열 그리드 레이아웃)
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 10 // 가로 간격 10px
        layout.minimumLineSpacing = 10 // 세로 간격 10px
        layout.sectionInset = UIEdgeInsets(top: 32, left: 16, bottom: 32, right: 16) // divider로부터 32px, 좌우 16px
        layout.itemSize = CGSize(width: (UIScreen.main.bounds.width - 52) / 2, height: 120) // 2열 그리드, 적절한 높이
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    // 빈 상태 뷰 (폴더가 없을 때)
    let emptyView = SaveEmptyView()

    override func setupUI() {
        backgroundColor = .black
        
        // 네비게이션 바 설정
        addSubview(navigationBar)
        navigationBar.backgroundColor = .black
        navigationBar.titleLabel.textColor = .white
        navigationBar.backButton.tintColor = .white
        navigationBar.rightButton.tintColor = .white
        navigationBar.rightButton.setImage(UIImage(named: "ic_search"), for: .normal)
        
        // Navigation divider 추가
        addSubview(navigationDivider)
        
        // 컬렉션뷰 설정
        addSubview(collectionView)
        
        // 빈 상태 뷰 설정
        addSubview(emptyView)
        emptyView.isHidden = true
    }
    
    override func setupLayout() {
        // 네비게이션 바
        navigationBar.snp.makeConstraints { make in
            make.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            make.height.equalTo(56)
        }
        
        // Navigation divider (1px 높이, 좌우 전체)
        navigationDivider.snp.makeConstraints { make in
            make.top.equalTo(navigationBar.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(1)
        }
        
        // 컬렉션뷰 (divider 아래부터 시작)
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(navigationDivider.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
        // 빈 상태 뷰 (컬렉션뷰와 동일한 영역)
        emptyView.snp.makeConstraints { make in
            make.edges.equalTo(collectionView)
        }
    }
} 
