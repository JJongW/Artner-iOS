import UIKit
import SnapKit

/// 저장 폴더 선택용 커스텀 바텀시트
final class FolderSelectBottomSheet: UIView, UITableViewDataSource, UITableViewDelegate {
    // MARK: - Callbacks
    var onDismiss: (() -> Void)?
    var onSelect: ((Folder) -> Void)?

    // MARK: - Data
    private let folders: [Folder]
    private var selectedIndex: Int? { didSet { updateSelectButtonState() } }

    // MARK: - UI
    private let dimView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor.black.withAlphaComponent(0.0)
        return v
    }()

    private let containerView: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(hex: "#1A1A1A")
        v.layer.cornerRadius = 16
        v.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        v.clipsToBounds = true
        return v
    }()

    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "저장 폴더"
        lb.font = .systemFont(ofSize: 15, weight: .bold)
        lb.textColor = UIColor(hex: "#FF7C27")
        return lb
    }()

    private let tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .plain)
        tv.separatorStyle = .none
        tv.backgroundColor = .clear
        tv.showsVerticalScrollIndicator = false
        return tv
    }()

    private let buttonContainer = UIView()
    private let closeButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("닫기", for: .normal)
        b.backgroundColor = UIColor(hex: "#4c4c4c")
        b.setTitleColor(.white, for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        b.layer.cornerRadius = 10
        b.contentEdgeInsets = UIEdgeInsets(top: 10, left: 53, bottom: 10, right: 53)
        return b
    }()
    private let selectButton: UIButton = {
        let b = UIButton(type: .system)
        b.setTitle("선택", for: .normal)
        b.backgroundColor = UIColor(hex: "#A75825")
        b.setTitleColor(UIColor(hex: "#CCCCCC"), for: .normal)
        b.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        b.layer.cornerRadius = 10
        b.isEnabled = false
        b.contentEdgeInsets = UIEdgeInsets(top: 10, left: 53, bottom: 10, right: 53)
        return b
    }()

    // 레이아웃 제약 저장
    private var containerBottomConstraint: Constraint?

    // MARK: - Init
    init(folders: [Folder]) {
        self.folders = folders
        super.init(frame: .zero)
        setupUI()
        setupLayout()
        setupActions()
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    private func setupUI() {
        addSubview(dimView)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(tableView)
        containerView.addSubview(buttonContainer)
        buttonContainer.addSubview(closeButton)
        buttonContainer.addSubview(selectButton)

        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(FolderRowCell.self, forCellReuseIdentifier: "FolderRowCell")
    }

    private func setupLayout() {
        dimView.snp.makeConstraints { $0.edges.equalToSuperview() }

        containerView.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview()
            containerBottomConstraint = make.bottom.equalTo(self.snp.bottom).offset(400).constraint // 시작: 화면 아래
        }

        // 상단 여백 48, 타이틀 좌측 28
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(48)
            make.leading.equalToSuperview().offset(28)
        }

        // 버튼 영역 (하단 16)
        buttonContainer.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(16)
            make.height.equalTo(50)
        }
        closeButton.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.equalTo(selectButton.snp.leading).offset(-10)
        }
        selectButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.equalTo(closeButton.snp.width)
        }

        // 리스트: 제목 아래 8, 좌측 28, 우측 28, 버튼 위까지
        tableView.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(8)
            make.leading.equalToSuperview().offset(28)
            make.trailing.equalToSuperview().inset(28)
            make.bottom.equalTo(buttonContainer.snp.top).offset(-16)
            make.height.greaterThanOrEqualTo(80)
        }
    }

    private func setupActions() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(dimTapped))
        dimView.addGestureRecognizer(tap)
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        selectButton.addTarget(self, action: #selector(selectTapped), for: .touchUpInside)
    }

    private func updateSelectButtonState() {
        let enabled = selectedIndex != nil
        selectButton.isEnabled = enabled
        UIView.animate(withDuration: 0.2) {
            self.selectButton.backgroundColor = enabled ? UIColor(hex: "#FF7C27") : UIColor(hex: "#A75825")
            self.selectButton.setTitleColor(enabled ? UIColor.white : UIColor(hex: "#CCCCCC"), for: .normal)
        }
    }

    // MARK: - Present / Dismiss
    func present() {
        layoutIfNeeded()
        // 바닥에서 올라오는 애니메이션 + 백그라운드 딤
        containerBottomConstraint?.update(offset: 0)
        UIView.animate(withDuration: 0.3) {
            self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            self.layoutIfNeeded()
        }
    }

    func dismiss() {
        containerBottomConstraint?.update(offset: 400)
        UIView.animate(withDuration: 0.25, animations: {
            self.dimView.backgroundColor = UIColor.black.withAlphaComponent(0.0)
            self.layoutIfNeeded()
        }) { _ in
            self.onDismiss?()
        }
    }

    // MARK: - Actions
    @objc private func dimTapped() { dismiss() }
    @objc private func closeTapped() { dismiss() }
    @objc private func selectTapped() {
        guard let idx = selectedIndex else { return }
        onSelect?(folders[idx])
    }

    // MARK: - TableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { folders.count }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FolderRowCell", for: indexPath) as! FolderRowCell
        let isSelected = indexPath.row == selectedIndex
        cell.configure(name: folders[indexPath.row].name, selected: isSelected)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
    }
    
    // 간격 20 (셀 내부 컨텐츠 상하 10 + 기본 높이로 20 느낌)
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { UITableView.automaticDimension }
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat { 44 }
}

// MARK: - Folder Row Cell
private final class FolderRowCell: UITableViewCell {
    private let nameLabel: UILabel = {
        let lb = UILabel()
        lb.font = .systemFont(ofSize: 16, weight: .medium)
        lb.textColor = UIColor.white.withAlphaComponent(0.7)
        lb.numberOfLines = 1
        lb.lineBreakMode = .byTruncatingTail // 길면 ... 처리
        return lb
    }()
    private let checkImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "checkmark"))
        iv.tintColor = UIColor.white
        iv.isHidden = true
        return iv
    }()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        contentView.addSubview(nameLabel)
        contentView.addSubview(checkImageView)
        nameLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().inset(10)
            make.leading.equalToSuperview()
            make.trailing.lessThanOrEqualTo(checkImageView.snp.leading).offset(-8)
        }
        checkImageView.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalToSuperview()
            make.width.height.equalTo(16)
        }
    }
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

    func configure(name: String, selected: Bool) {
        nameLabel.text = name
        nameLabel.font = .systemFont(ofSize: 16, weight: selected ? .bold : .medium)
        nameLabel.textColor = selected ? UIColor.white : UIColor.white.withAlphaComponent(0.7)
        checkImageView.isHidden = !selected
    }
}


