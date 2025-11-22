import UIKit
import SnapKit

/// 폴더 선택 모달 (기존 CreateFolderModalView 기반)
final class SelectFolderModalView: UIView {
    // MARK: - UI
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#1A1A1A")
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "저장 폴더를 선택해주세요"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(hex: "#FFFFFF")
        label.textAlignment = .left
        return label
    }()
    
    private let folderSelectButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("폴더를 선택해주세요", for: .normal)
        // 텍스트: 16, regular, #FFFFFF 30%
        button.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .regular)
        button.contentHorizontalAlignment = .left
        button.backgroundColor = UIColor(hex: "#333333")
        button.layer.cornerRadius = 6
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        // 내부 패딩: leading 16
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 40)
        return button
    }()
    
    // 우측 화살표 아이콘 (꼬리 없는 하단 방향)
    private let arrowImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "chevron.down"))
        iv.tintColor = UIColor.white.withAlphaComponent(0.3)
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    private let buttonContainerView = UIView()
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.backgroundColor = UIColor(hex: "#4c4c4c")
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 10
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 53, bottom: 10, right: 53)
        return button
    }()
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.backgroundColor = UIColor(hex: "#A75825")
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 10
        button.isEnabled = false
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 53, bottom: 10, right: 53)
        return button
    }()
    
    // MARK: - State
    private var folders: [Folder] = []
    private var selectedFolder: Folder? { didSet { updateConfirmState() } }
    
    // MARK: - Callbacks
    var onCancelTapped: (() -> Void)?
    var onConfirmTapped: ((Folder) -> Void)?
    
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
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(folderSelectButton)
        containerView.addSubview(buttonContainerView)
        
        // 버튼 우측 화살표 배치
        folderSelectButton.addSubview(arrowImageView)
        buttonContainerView.addSubview(cancelButton)
        buttonContainerView.addSubview(confirmButton)
    }
    
    private func setupLayout() {
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(22)
        }
        folderSelectButton.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(48)
        }
        arrowImageView.snp.makeConstraints { make in
            make.centerY.equalTo(folderSelectButton)
            make.trailing.equalTo(folderSelectButton.snp.trailing).inset(16)
            make.width.height.equalTo(16)
        }
        buttonContainerView.snp.makeConstraints { make in
            make.top.equalTo(folderSelectButton.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24)
            make.height.equalTo(50)
        }
        cancelButton.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.equalTo(confirmButton.snp.leading).offset(-10)
        }
        confirmButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.equalTo(cancelButton.snp.width)
        }
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmTapped), for: .touchUpInside)
        folderSelectButton.addTarget(self, action: #selector(selectFolderTapped), for: .touchUpInside)
    }
    
    private func updateConfirmState() {
        let enabled = (selectedFolder != nil)
        confirmButton.isEnabled = enabled
        UIView.animate(withDuration: 0.2) {
            self.confirmButton.backgroundColor = enabled ? UIColor(hex: "#FF7C27") : UIColor(hex: "#A75825")
            self.confirmButton.setTitleColor(enabled ? UIColor.white : UIColor(hex: "#CCCCCC"), for: .normal)
        }
        if let folder = selectedFolder {
            folderSelectButton.setTitle(folder.name, for: .normal)
            // 선택 후에도 폰트/사이즈 동일, 색은 요구사항 유지
            folderSelectButton.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .normal)
        }
    }
    
    // MARK: - Actions
    @objc private func cancelTapped() { onCancelTapped?() }
    @objc private func confirmTapped() { if let f = selectedFolder { onConfirmTapped?(f) } }
    
    @objc private func selectFolderTapped() {
        // 커스텀 바텀시트 표시
        let bottomSheet = FolderSelectBottomSheet(folders: folders)
        bottomSheet.onDismiss = { [weak bottomSheet] in bottomSheet?.removeFromSuperview() }
        bottomSheet.onSelect = { [weak self, weak bottomSheet] folder in
            self?.selectedFolder = folder
            bottomSheet?.dismiss()
        }
        guard let container = UIApplication.shared.keyWindowInConnectedScenes else { return }
        container.addSubview(bottomSheet)
        bottomSheet.snp.makeConstraints { $0.edges.equalToSuperview() }
        bottomSheet.present()
    }
}

// MARK: - UIWindow / TopVC Helpers
private extension UIApplication {
    var activeWindow: UIWindow? {
        (connectedScenes.first as? UIWindowScene)?.windows.first { $0.isKeyWindow }
    }
    var keyWindowInConnectedScenes: UIWindow? { activeWindow }
}

private extension UIWindow {
    func topViewController(base: UIViewController? = nil) -> UIViewController? {
        let baseVC = base ?? rootViewController
        if let nav = baseVC as? UINavigationController { return topViewController(base: nav.visibleViewController) }
        if let tab = baseVC as? UITabBarController { return topViewController(base: tab.selectedViewController) }
        if let presented = baseVC?.presentedViewController { return topViewController(base: presented) }
        return baseVC
    }
}


