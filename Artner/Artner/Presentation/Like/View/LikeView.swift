import UIKit
import SnapKit

final class LikeView: BaseView {
    let navigationBar = CustomNavigationBar()
    let categoryStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 10
        stackView.distribution = .fillEqually
        return stackView
    }()
    let allButton = UIButton(type: .system)
    let exhibitionButton = UIButton(type: .system)
    let artistButton = UIButton(type: .system)
    let artworkButton = UIButton(type: .system)
    let tableView = UITableView()
    let emptyView = LikeEmptyView()

    override func setupUI() {
        backgroundColor = .black
        addSubview(navigationBar)
        navigationBar.backgroundColor = .black
        navigationBar.titleLabel.textColor = .white
        navigationBar.backButton.tintColor = .white
        navigationBar.rightButton.tintColor = .white
        addSubview(categoryStackView)
        [allButton, exhibitionButton, artistButton, artworkButton].forEach {
            $0.setTitleColor(.white, for: .normal)
            $0.titleLabel?.font = .systemFont(ofSize: 14)
            $0.layer.cornerRadius = 16
            $0.layer.borderWidth = 1
            $0.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
            categoryStackView.addArrangedSubview($0)
        }
        allButton.setTitle("전체", for: .normal)
        exhibitionButton.setTitle("전시", for: .normal)
        artistButton.setTitle("작가", for: .normal)
        artworkButton.setTitle("작품", for: .normal)
        addSubview(tableView)
        addSubview(emptyView)
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        emptyView.isHidden = true
    }
    override func setupLayout() {
        navigationBar.snp.makeConstraints { 
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(56) 
        }
        categoryStackView.snp.makeConstraints { 
            $0.top.equalTo(navigationBar.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(32) 
        }
        tableView.snp.makeConstraints { 
            $0.top.equalTo(categoryStackView.snp.bottom).offset(16)
            $0.leading.trailing.bottom.equalToSuperview() 
        }
        emptyView.snp.makeConstraints { 
            $0.edges.equalTo(tableView) 
        }
    }
} 
