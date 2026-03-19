# ios.uikit.create_cell

## 설명
UITableViewCell 또는 UICollectionViewCell을 프로젝트 패턴에 맞게 생성한다.

## 파라미터
- `cellName` (String, 필수): 셀 이름 (PascalCase, 예: Docent)
- `cellType` (String, 필수): UITableViewCell | UICollectionViewCell
- `components` (Array, 선택): 내부 UI 컴포넌트 목록

## 생성 파일
- `Artner/Artner/Presentation/{Feature}/View/{CellName}{Type}.swift`

## 핵심 패턴

### TableViewCell
```swift
import UIKit
import SnapKit

final class {CellName}TableViewCell: UITableViewCell {
    // MARK: - UI 컴포넌트
    private let thumbnailImageView = UIImageView()
    private let titleLabel = UILabel()

    // MARK: - 액션 클로저
    var onActionTapped: (() -> Void)?

    // MARK: - 초기화
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI 설정
    private func setupUI() {
        selectionStyle = .none
        contentView.addSubview(thumbnailImageView)
        contentView.addSubview(titleLabel)
    }

    private func setupLayout() {
        thumbnailImageView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(16)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(CGSize(width: 105, height: 105))
        }
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(thumbnailImageView)
            $0.leading.equalTo(thumbnailImageView.snp.trailing).offset(12)
            $0.trailing.equalToSuperview().offset(-20)
        }
    }

    // MARK: - 데이터 주입
    func configure(title: String, thumbnail: URL?) {
        titleLabel.text = title
        thumbnailImageView.loadImage(from: thumbnail)
    }
}
```

### CollectionViewCell
```swift
final class {CellName}CollectionViewCell: UICollectionViewCell {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
```

## 체크리스트
- [ ] SnapKit으로 레이아웃 구성
- [ ] `setupUI()` + `setupLayout()` 분리
- [ ] `configure()` 메서드로 데이터 주입
- [ ] 클로저 기반 액션 전달 (`onXxxTapped`)
- [ ] Storyboard/Xib 미사용
- [ ] contentView에 서브뷰 추가 (cell.contentView.addSubview)
- [ ] selectionStyle 설정
