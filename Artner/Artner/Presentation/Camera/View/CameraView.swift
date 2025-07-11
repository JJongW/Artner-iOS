import UIKit
import SnapKit

final class CameraView: UIView {
    
    // MARK: - UI Components
    
    // 상단 컨트롤 바
    private let topControlBar: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // 하단 컨트롤 바
    private let bottomControlBar: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    // 카메라 프리뷰 컨테이너
    let previewContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        view.clipsToBounds = true
        return view
    }()
    
    // 상단 컨트롤 버튼들
    let closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        return button
    }()
    
    // 하단 컨트롤 버튼들
    let captureButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 35 // 70x70 크기의 반지름
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.8).cgColor
        button.clipsToBounds = true
        return button
    }()
    
    let flipCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        return button
    }()
    
    let galleryButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "photo.on.rectangle"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        button.layer.cornerRadius = 25
        button.clipsToBounds = true
        return button
    }()
    
    // 검색 텍스트 필드
    private let searchTextField: UITextField = {
        let textField = UITextField()
        textField.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        textField.textColor = .white
        textField.attributedPlaceholder = NSAttributedString(
            string: "작품 또는 작가를 입력하세요.",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.white.withAlphaComponent(0.7)]
        )
        textField.layer.cornerRadius = 20
        textField.clipsToBounds = true
        
        // 텍스트 필드 왼쪽 패딩 추가
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        
        // 검색 아이콘 추가
        let searchIcon = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        searchIcon.tintColor = UIColor.white.withAlphaComponent(0.7)
        searchIcon.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: textField.frame.height))
        rightPaddingView.addSubview(searchIcon)
        searchIcon.center = CGPoint(x: 20, y: rightPaddingView.frame.height / 2)
        textField.rightView = rightPaddingView
        textField.rightViewMode = .always
        
        return textField
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = .black
        
        addSubview(previewContainer)
        addSubview(topControlBar)
        addSubview(bottomControlBar)
        
        // 상단 컨트롤에 버튼 추가
        topControlBar.addSubview(closeButton)
        topControlBar.addSubview(searchTextField)
        
        // 하단 컨트롤에 버튼 추가
        bottomControlBar.addSubview(captureButton)
        bottomControlBar.addSubview(flipCameraButton)
        bottomControlBar.addSubview(galleryButton)
    }
    
    private func setupLayout() {
        // 상단 컨트롤 바
        topControlBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(120)
        }
        
        // 하단 컨트롤 바
        bottomControlBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(160)
        }
        
        // 카메라 프리뷰 컨테이너 (상단과 하단 바 사이 전체 영역)
        previewContainer.snp.makeConstraints {
            $0.top.equalTo(topControlBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomControlBar.snp.top)
        }
        
        // 상단 컨트롤 버튼들
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(40)
        }
        
        searchTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.bottom.equalToSuperview().offset(-20)
            $0.height.equalTo(40)
        }
        
        // 하단 컨트롤 버튼들
        captureButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview()
            $0.size.equalTo(70)
        }
        
        flipCameraButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-30)
            $0.centerY.equalTo(captureButton)
            $0.size.equalTo(50)
        }
        
        galleryButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(30)
            $0.centerY.equalTo(captureButton)
            $0.size.equalTo(50)
        }
    }
}

// MARK: - Public Methods
extension CameraView {
    func updateSearchText(_ text: String) {
        searchTextField.text = text
    }
    
    func getSearchText() -> String {
        return searchTextField.text ?? ""
    }
} 