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
    
    // 뒤로가기 버튼 (CustomNavigationBar 스타일 참고)
    let closeButton: UIButton = {
        let button = UIButton()
        button.layer.opacity = 0.8
        button.setImage(UIImage(named: "ic_left_arrow"), for: .normal) // 기존 아이콘 사용
        button.tintColor = .white
        button.backgroundColor = .clear
        return button
    }()
    
    // 뒤로가기 콜백 (CustomNavigationBar 스타일 참고)
    var onBackButtonTapped: (() -> Void)?
    
    // 상단 안내 텍스트
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "작품 전체가 카메라에 잘히게 촬영해주세요."
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        label.textAlignment = .center
        return label
    }()
    
    // 촬영 버튼
    let captureButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.layer.cornerRadius = 35 // 70x70 크기의 반지름
        button.layer.borderWidth = 4
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.clipsToBounds = true
        return button
    }()
    
    // 갤러리 버튼
    let galleryButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "photo.on.rectangle.angled"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        return button
    }()
    
    // 카메라 전환 버튼 (우측에 위치할 예정)
    let flipCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "camera.rotate"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        return button
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
        
        // 상단 컨트롤에 요소들 추가
        topControlBar.addSubview(closeButton)
        topControlBar.addSubview(instructionLabel)
        
        // 하단 컨트롤에 버튼들 추가
        bottomControlBar.addSubview(captureButton)
        bottomControlBar.addSubview(galleryButton)
        bottomControlBar.addSubview(flipCameraButton)
        
        // 뒤로가기 버튼 액션 추가 (CustomNavigationBar 스타일 참고)
        closeButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
    }
    
    private func setupLayout() {
        // 상단 컨트롤 바 (네비게이션 바 영역)
        topControlBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(44) // CustomNavigationBar와 동일한 높이
        }
        
        // 하단 컨트롤 바
        bottomControlBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(140)
        }
        
        // 카메라 프리뷰 컨테이너 (상단 바 다음부터 하단 바 전까지)
        previewContainer.snp.makeConstraints {
            $0.top.equalTo(topControlBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomControlBar.snp.top)
        }
        
        // 상단 컨트롤 요소들 (CustomNavigationBar 스타일 참고)
        closeButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(20)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(24) // 아이콘 크기
        }
        
        // 안내 텍스트를 카메라 프리뷰 상단에 배치 (55px 높이 영역)
        instructionLabel.snp.makeConstraints {
            $0.top.equalTo(previewContainer.snp.top).offset(20)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(55) // 요청한 55px 높이
        }
        
        // 하단 컨트롤 버튼들
        captureButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.top.equalToSuperview().offset(30)
            $0.size.equalTo(70)
        }
        
        galleryButton.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(40)
            $0.centerY.equalTo(captureButton)
            $0.size.equalTo(44)
        }
        
        flipCameraButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-40)
            $0.centerY.equalTo(captureButton)
            $0.size.equalTo(44)
        }
    }
    
    // MARK: - Actions (CustomNavigationBar 스타일 참고)
    @objc private func didTapBack() {
        onBackButtonTapped?()
    }
}

// MARK: - Public Methods
extension CameraView {
    func updateInstructionText(_ text: String) {
        instructionLabel.text = text
    }
} 
