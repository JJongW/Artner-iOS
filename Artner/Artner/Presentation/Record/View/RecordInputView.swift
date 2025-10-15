import UIKit
import SnapKit

final class RecordInputView: BaseView {
    let navigationBar = CustomNavigationBar()
    
    // Navigation 바 아래 divider (1px, #FFFFFF 10% opacity)
    let navigationDivider: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.1)
        return view
    }()
    
    // 전시 이름 입력 필드
    let exhibitionNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "전시 이름을 적어주세요."
        textField.font = .systemFont(ofSize: 20, weight: .bold)
        textField.textColor = UIColor.white.withAlphaComponent(0.8)
        textField.attributedPlaceholder = NSAttributedString(
            string: "전시 이름을 적어주세요.",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.3),
                .font: UIFont.systemFont(ofSize: 20, weight: .bold)
            ]
        )
        textField.backgroundColor = .clear
        textField.borderStyle = .none
        textField.returnKeyType = .done
        textField.tintColor = UIColor(hex: "#FF7C27") // 커서 색상 변경
        // 텍스트가 카운터와 겹치지 않도록 우측 마진 설정
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 74, height: 0))
        textField.rightViewMode = .always
        return textField
    }()
    
    let exhibitionNameUnderline: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.8)
        return view
    }()
    
    let exhibitionNameCounter: UILabel = {
        let label = UILabel()
        label.text = "0/50"
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        return label
    }()
    
    // 미술관 이름 입력 필드
    let museumNameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "미술관의 이름을 입력하세요."
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(
            string: "미술관의 이름을 입력하세요.",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.3),
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )
        textField.backgroundColor = UIColor(hex: "#222222")
        textField.layer.cornerRadius = 6
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.returnKeyType = .next
        textField.tintColor = UIColor(hex: "#FF7C27") // 커서 색상 변경
        return textField
    }()
    
    let museumNameCounter: UILabel = {
        let label = UILabel()
        label.text = "0/30"
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        return label
    }()
    
    // 방문 날짜 입력 필드
    let visitDateTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "방문 날짜를 기록하세요."
        textField.font = .systemFont(ofSize: 16, weight: .regular)
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(
            string: "방문 날짜를 기록하세요.",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.3),
                .font: UIFont.systemFont(ofSize: 16, weight: .regular)
            ]
        )
        textField.backgroundColor = UIColor(hex: "#222222")
        textField.layer.cornerRadius = 6
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.rightView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.rightViewMode = .always
        textField.keyboardType = .numbersAndPunctuation
        textField.returnKeyType = .done
        textField.tintColor = UIColor(hex: "#FF7C27") // 커서 색상 변경
        return textField
    }()
    
    // 이미지 추가 섹션
    let imageAddStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 8
        stackView.alignment = .center
        return stackView
    }()
    
    let imageAddIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo.badge.plus")
        imageView.tintColor = .white
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let imageAddLabel: UILabel = {
        let label = UILabel()
        label.text = "이미지 추가하기"
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .white
        return label
    }()
    
    // 선택된 이미지 표시용 ImageView
    let selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = UIColor(hex: "#222222")
        imageView.layer.cornerRadius = 6
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHidden = true
        imageView.isUserInteractionEnabled = false // ImageView 자체는 터치 비활성화
        return imageView
    }()
    
    // 버튼을 위한 컨테이너 뷰 (터치 문제 해결)
    let buttonContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        view.isHidden = true
        return view
    }()
    
    // 이미지 삭제 버튼
    let imageDeleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5) // #000000 50% opacity
        button.layer.cornerRadius = 12
        // 12x12 크기의 X 아이콘 (더 작게)
        let xImage = UIImage(systemName: "xmark")?.withConfiguration(
            UIImage.SymbolConfiguration(pointSize: 12, weight: .medium)
        )
        button.setImage(xImage, for: .normal)
        button.tintColor = UIColor.white.withAlphaComponent(0.8) // #FFFFFF 80% opacity
        button.isHidden = true
        button.isUserInteractionEnabled = true // 터치 활성화
        return button
    }()
    
    // 기록하기 버튼
    let recordButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("기록하기", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.layer.cornerRadius = 12
        button.backgroundColor = UIColor(hex: "#222222")
        button.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .normal)
        button.isEnabled = false
        return button
    }()
    
    override func setupUI() {
        backgroundColor = .black
        
        // 네비게이션 바 설정
        addSubview(navigationBar)
        navigationBar.backgroundColor = .black
        navigationBar.setTitle("전시 기록")
        navigationBar.titleLabel.textColor = .white
        navigationBar.backButton.isHidden = true // 좌측 버튼 숨김
        navigationBar.rightButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        navigationBar.rightButton.tintColor = UIColor.white.withAlphaComponent(0.8)
        
        // Navigation divider 추가
        addSubview(navigationDivider)
        
        // 전시 이름 입력 필드
        addSubview(exhibitionNameTextField)
        addSubview(exhibitionNameUnderline)
        addSubview(exhibitionNameCounter)
        
        // 미술관 이름 입력 필드
        addSubview(museumNameTextField)
        addSubview(museumNameCounter)
        
        // 방문 날짜 입력 필드
        addSubview(visitDateTextField)
        
        // 이미지 추가 섹션
        addSubview(imageAddStackView)
        imageAddStackView.addArrangedSubview(imageAddIcon)
        imageAddStackView.addArrangedSubview(imageAddLabel)
        
        // 선택된 이미지 표시용 ImageView
        addSubview(selectedImageView)
        
        // 버튼 컨테이너 뷰 추가
        addSubview(buttonContainerView)
        buttonContainerView.addSubview(imageDeleteButton)
        
        // 기록하기 버튼
        addSubview(recordButton)
    }
    
    override func setupLayout() {
        // 네비게이션 바
        navigationBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(56)
        }
        
        // Navigation divider
        navigationDivider.snp.makeConstraints {
            $0.top.equalTo(navigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(1)
        }
        
        // 전시 이름 입력 필드 (divider로부터 32px, 좌우 20px 마진)
        exhibitionNameTextField.snp.makeConstraints {
            $0.top.equalTo(navigationDivider.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        exhibitionNameUnderline.snp.makeConstraints {
            $0.top.equalTo(exhibitionNameTextField.snp.bottom).offset(8)
            $0.leading.trailing.equalTo(exhibitionNameTextField)
            $0.height.equalTo(1)
        }
        
        exhibitionNameCounter.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-20)
            $0.centerY.equalTo(exhibitionNameTextField)
        }
        
        // 미술관 이름 입력 필드 (전시 이름으로부터 32px)
        museumNameTextField.snp.makeConstraints {
            $0.top.equalTo(exhibitionNameUnderline.snp.bottom).offset(32)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        museumNameCounter.snp.makeConstraints {
            $0.trailing.equalTo(museumNameTextField).offset(-16)
            $0.centerY.equalTo(museumNameTextField)
        }
        
        // 방문 날짜 입력 필드 (미술관 이름으로부터 27px)
        visitDateTextField.snp.makeConstraints {
            $0.top.equalTo(museumNameTextField.snp.bottom).offset(27)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(44)
        }
        
        // 이미지 추가 섹션 (방문 날짜로부터 26px)
        imageAddStackView.snp.makeConstraints {
            $0.top.equalTo(visitDateTextField.snp.bottom).offset(26)
            $0.leading.equalToSuperview().offset(20)
        }
        
        imageAddIcon.snp.makeConstraints {
            $0.width.height.equalTo(24)
        }
        
        // 선택된 이미지 표시용 ImageView (이미지 추가하기 아래 16px)
        selectedImageView.snp.makeConstraints {
            $0.top.equalTo(imageAddStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(215)
        }
        
        // 버튼 컨테이너 뷰 (이미지와 같은 위치)
        buttonContainerView.snp.makeConstraints {
            $0.top.equalTo(imageAddStackView.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(215)
        }
        
        // 이미지 삭제 버튼 (우측 상단)
        imageDeleteButton.snp.makeConstraints {
            $0.top.trailing.equalToSuperview().inset(4)
            $0.width.height.equalTo(32)
        }
        
        // 기록하기 버튼 (화면 하단으로부터 42px)
        recordButton.snp.makeConstraints {
            $0.bottom.equalTo(safeAreaLayoutGuide).offset(-42)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(50)
        }
    }
    
    // MARK: - Helper Methods
    
    /// 버튼 활성화 상태 업데이트
    func updateRecordButtonState(isEnabled: Bool) {
        recordButton.isEnabled = isEnabled
        if isEnabled {
            recordButton.backgroundColor = UIColor(hex: "#FF7C27")
            recordButton.setTitleColor(UIColor.white, for: .normal)
        } else {
            recordButton.backgroundColor = UIColor(hex: "#222222")
            recordButton.setTitleColor(UIColor.white.withAlphaComponent(0.3), for: .normal)
        }
    }
    
    /// 텍스트 필드 포커스 상태 업데이트
    func updateTextFieldFocus(_ textField: UITextField, isFocused: Bool) {
        if isFocused {
            textField.layer.borderColor = UIColor(hex: "#FF7C27").cgColor
        } else {
            textField.layer.borderColor = UIColor.white.withAlphaComponent(0.1).cgColor
        }
    }
    
    /// 글자 수 카운터 업데이트
    func updateCounter(_ counter: UILabel, current: Int, max: Int) {
        counter.text = "\(current)/\(max)"
    }
    
    /// 선택된 이미지 표시
    func showSelectedImage(_ image: UIImage?) {
        if let image = image {
            selectedImageView.image = image
            selectedImageView.isHidden = false
            buttonContainerView.isHidden = false
            imageDeleteButton.isHidden = false
            
            // 이미지 추가 버튼 비활성화
            setImageAddButtonEnabled(false)
            
            print("📸 [RecordInputView] 이미지 표시됨 - 삭제 버튼 상태: isHidden=\(imageDeleteButton.isHidden), isUserInteractionEnabled=\(imageDeleteButton.isUserInteractionEnabled)")
        } else {
            selectedImageView.image = nil
            selectedImageView.isHidden = true
            buttonContainerView.isHidden = true
            imageDeleteButton.isHidden = true
            
            // 이미지 추가 버튼 활성화
            setImageAddButtonEnabled(true)
            
            print("📸 [RecordInputView] 이미지 숨김 - 삭제 버튼 상태: isHidden=\(imageDeleteButton.isHidden)")
        }
    }
    
    /// 이미지 추가 버튼 활성화/비활성화
    private func setImageAddButtonEnabled(_ isEnabled: Bool) {
        imageAddStackView.isUserInteractionEnabled = isEnabled
        imageAddIcon.alpha = isEnabled ? 1.0 : 0.2
        imageAddLabel.alpha = isEnabled ? 1.0 : 0.2
    }
}
