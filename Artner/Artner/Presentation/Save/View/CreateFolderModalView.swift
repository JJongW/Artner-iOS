import UIKit
import SnapKit

// MARK: - Create Folder Modal View
/// 새 폴더 생성용 커스텀 모달 뷰
final class CreateFolderModalView: UIView {
    
    // MARK: - UI Components
    
    // 전체 컨테이너 뷰
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#1A1A1A")
        view.layer.cornerRadius = 16
        return view
    }()
    
    // 제목 라벨
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "새 폴더"
        label.font = .systemFont(ofSize: 18, weight: .bold)
        label.textColor = UIColor(hex: "#FFFFFF")
        label.textAlignment = .left
        return label
    }()
    
    // 폴더명 입력 필드
    let folderNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "폴더명을 입력하세요."
        textField.backgroundColor = UIColor(hex: "#333333")
        textField.layer.cornerRadius = 6
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        
        // 텍스트 스타일링
        textField.textColor = UIColor(hex: "#FFFFFF")
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        
        // 플레이스홀더 스타일링
        textField.attributedPlaceholder = NSAttributedString(
            string: "폴더명을 입력하세요.",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.3),
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )
        
        // 패딩 설정
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightViewMode = .always
        
        return textField
    }()
    
    // 버튼 컨테이너
    private let buttonContainerView: UIView = {
        let view = UIView()
        return view
    }()
    
    // 취소 버튼
    let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("취소", for: .normal)
        button.backgroundColor = UIColor(hex: "#4c4c4c")
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 10
        
        // 버튼 내부 패딩 (상하 10, 좌우 53)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 53, bottom: 10, right: 53)
        
        return button
    }()
    
    // 확인 버튼
    let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("확인", for: .normal)
        button.backgroundColor = UIColor(hex: "#A75825") // 비활성화 색상
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 18, weight: .bold)
        button.layer.cornerRadius = 10
        button.isEnabled = false // 초기에는 비활성화
        
        // 버튼 내부 패딩 (상하 10, 좌우 53)
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 53, bottom: 10, right: 53)
        
        return button
    }()
    
    // MARK: - Properties
    
    var onCancelTapped: (() -> Void)?
    var onConfirmTapped: ((String) -> Void)?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
        setupActions()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup Methods
    
    private func setupUI() {
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        
        addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(folderNameTextField)
        containerView.addSubview(buttonContainerView)
        
        buttonContainerView.addSubview(cancelButton)
        buttonContainerView.addSubview(confirmButton)
    }
    
    private func setupLayout() {
        // 전체 컨테이너 (상하좌우 24px 마진)
        containerView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.leading.trailing.equalToSuperview().inset(24)
        }
        
        // 제목 (상단)
        titleLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().inset(24)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(22) // 18pt 폰트에 적절한 높이
        }
        
        // 텍스트 필드 (제목 아래 32px)
        folderNameTextField.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.height.equalTo(48) // 적절한 텍스트 필드 높이
        }
        
        // 버튼 컨테이너 (텍스트 필드 아래 32px)
        buttonContainerView.snp.makeConstraints { make in
            make.top.equalTo(folderNameTextField.snp.bottom).offset(32)
            make.leading.trailing.equalToSuperview().inset(24)
            make.bottom.equalToSuperview().inset(24)
            make.height.equalTo(50) // 버튼 높이 + 패딩
        }
        
        // 취소 버튼 (왼쪽)
        cancelButton.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.trailing.equalTo(confirmButton.snp.leading).offset(-10) // 버튼 간 10px 간격
        }
        
        // 확인 버튼 (오른쪽)
        confirmButton.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()
            make.width.equalTo(cancelButton.snp.width) // 두 버튼 동일한 너비
        }
    }
    
    private func setupActions() {
        cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmButtonTapped), for: .touchUpInside)
        
        // 텍스트 필드 변경 감지
        folderNameTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        
        // 배경 터치 시 닫기
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(backgroundTapped))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Actions
    
    @objc private func cancelButtonTapped() {
        onCancelTapped?()
    }
    
    @objc private func confirmButtonTapped() {
        guard let folderName = folderNameTextField.text,
              !folderName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // 빈 이름인 경우 에러 처리
            return
        }
        
        onConfirmTapped?(folderName.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    @objc private func textFieldDidChange() {
        updateConfirmButtonState()
    }
    
    @objc private func backgroundTapped(_ gesture: UITapGestureRecognizer) {
        // 컨테이너 뷰 외부를 터치한 경우에만 닫기
        let location = gesture.location(in: self)
        if !containerView.frame.contains(location) {
            onCancelTapped?()
        }
    }
    
    // MARK: - Private Methods
    
    /// 확인 버튼 활성화 상태 업데이트
    /// - 텍스트가 비어있지 않으면 활성화 (#FF7C27)
    /// - 텍스트가 비어있으면 비활성화 (#A75825)
    private func updateConfirmButtonState() {
        let text = folderNameTextField.text ?? ""
        let isEmpty = text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        
        // 버튼 활성화 상태 변경
        confirmButton.isEnabled = !isEmpty
        
        // 색상 애니메이션과 함께 변경
        UIView.animate(withDuration: 0.2) {
            if isEmpty {
                // 비활성화 상태: #A75825
                self.confirmButton.backgroundColor = UIColor(hex: "#A75825")
            } else {
                // 활성화 상태: #FF7C27
                self.confirmButton.backgroundColor = UIColor(hex: "#FF7C27")
            }
        }
    }
    
    // MARK: - Public Methods
    
    /// 모달을 표시하고 텍스트 필드에 포커스
    func show() {
        folderNameTextField.becomeFirstResponder()
    }
    
    /// 모달을 숨기고 텍스트 필드 초기화
    func hide() {
        folderNameTextField.resignFirstResponder()
        folderNameTextField.text = ""
        // 버튼 상태도 초기화
        confirmButton.isEnabled = false
        confirmButton.backgroundColor = UIColor(hex: "#A75825")
    }
}

// MARK: - Modal Presenter Helper
extension CreateFolderModalView {
    
    /// 부모 뷰에 모달을 표시하는 정적 메서드
    /// - Parameters:
    ///   - parentView: 부모 뷰
    ///   - onCancel: 취소 액션
    ///   - onConfirm: 확인 액션 (폴더 이름 전달)
    /// - Returns: 생성된 모달 뷰 인스턴스
    @discardableResult
    static func present(
        in parentView: UIView,
        onCancel: @escaping () -> Void,
        onConfirm: @escaping (String) -> Void
    ) -> CreateFolderModalView {
        
        let modalView = CreateFolderModalView()
        
        modalView.onCancelTapped = {
            modalView.hide()
            modalView.removeFromSuperview()
            onCancel()
        }
        
        modalView.onConfirmTapped = { folderName in
            modalView.hide()
            modalView.removeFromSuperview()
            onConfirm(folderName)
        }
        
        parentView.addSubview(modalView)
        modalView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // 애니메이션과 함께 표시
        modalView.alpha = 0
        UIView.animate(withDuration: 0.3) {
            modalView.alpha = 1
        } completion: { _ in
            modalView.show()
        }
        
        return modalView
    }
}
