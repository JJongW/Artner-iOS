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
    
    // 검색창 탭 콜백
    var onSearchTapped: (() -> Void)?
    
    // 상단 안내 텍스트
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.text = "작품 전체가 카메라에 잡히게 촬영해주세요"
        label.textColor = UIColor.white.withAlphaComponent(0.6) // #FFFFFF 60% opacity
        label.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        label.textAlignment = .center
        return label
    }()
    
    // ㄱ자 테두리 뷰들 (4개 모서리)
    private let topLeftCorner: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let topRightCorner: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let bottomLeftCorner: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    private let bottomRightCorner: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    }()
    
    // 스캔 영역 오버레이 (중앙은 투명, 외부는 어둡게)
    private let scanOverlayLayer = CAShapeLayer()
    
    // 검색창 컨테이너
    private let searchContainer: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: "#FFFFFF").withAlphaComponent(0.15)
        view.layer.cornerRadius = 24
        view.layer.masksToBounds = true
        return view
    }()
    
    // 검색 텍스트 필드
    let searchTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "작품 또는 작가를 입력하세요."
        textField.textColor = .white
        textField.font = UIFont.systemFont(ofSize: 15, weight: .regular)
        textField.tintColor = .white
        textField.isUserInteractionEnabled = false // 직접 입력 비활성화
        
        // Placeholder 색상 설정
        textField.attributedPlaceholder = NSAttributedString(
            string: "작품 또는 작가를 입력하세요.",
            attributes: [
                .foregroundColor: UIColor.white.withAlphaComponent(0.5),
                .font: UIFont.systemFont(ofSize: 15, weight: .regular)
            ]
        )
        
        return textField
    }()
    
    // 검색 아이콘
    private let searchIconView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "ic_search")?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.white.withAlphaComponent(0.5) // #FFFFFF 50%
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    // 촬영 버튼 (원형)
    let captureButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor(hex: "#232323")
        button.layer.borderWidth = 5
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.cornerRadius = 35 
        return button
    }()
    
    // 갤러리 버튼 (원형)
    let galleryButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_gallary_open"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1) // #FFFFFF 10% opacity
        button.layer.cornerRadius = 30 
        return button
    }()
    
    // 카메라 전환 버튼 (원형)
    let flipCameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "ic_recycle"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.white.withAlphaComponent(0.1) // #FFFFFF 10% opacity
        button.layer.cornerRadius = 30 
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
        
        // 하단 컨트롤에 요소들 추가
        bottomControlBar.addSubview(searchContainer)
        searchContainer.addSubview(searchTextField)
        searchContainer.addSubview(searchIconView)
        
        bottomControlBar.addSubview(captureButton)
        bottomControlBar.addSubview(galleryButton)
        bottomControlBar.addSubview(flipCameraButton)
        
        // ㄱ자 테두리들을 프리뷰 컨테이너에 직접 추가
        previewContainer.addSubview(topLeftCorner)
        previewContainer.addSubview(topRightCorner)
        previewContainer.addSubview(bottomLeftCorner)
        previewContainer.addSubview(bottomRightCorner)
        
        // 스캔 영역 오버레이 추가 (previewLayer 위, 테두리 아래)
        previewContainer.layer.addSublayer(scanOverlayLayer)
        
        // 뒤로가기 버튼 액션 추가
        closeButton.addTarget(self, action: #selector(didTapBack), for: .touchUpInside)
        
        // 검색창 탭 제스처 추가
        let searchTapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapSearch))
        searchContainer.addGestureRecognizer(searchTapGesture)
        searchContainer.isUserInteractionEnabled = true
        
        // ㄱ자 테두리 그리기
        setupCornerFrames()
    }
    
    private func setupLayout() {
        // 상단 컨트롤 바 (네비게이션 바 영역 + 안내 텍스트 공간)
        topControlBar.snp.makeConstraints {
            $0.top.leading.trailing.equalTo(safeAreaLayoutGuide)
            $0.height.equalTo(80) 
        }
        
        // 하단 컨트롤 바 (검색창 + 버튼들 포함)
        bottomControlBar.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(safeAreaLayoutGuide)
            // 높이는 내부 컨텐츠에 따라 자동 결정
        }
        
        // 카메라 프리뷰 컨테이너 (bottomControlBar와 연결)
        previewContainer.snp.makeConstraints {
            $0.top.equalTo(topControlBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(bottomControlBar.snp.top)
        }
        
        // 상단 컨트롤 요소들
        closeButton.snp.makeConstraints {
            $0.top.equalToSuperview().offset(11)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(24)
        }
        
        // 안내 텍스트를 상단 컨트롤 바에 배치
        instructionLabel.snp.makeConstraints {
            $0.top.equalTo(closeButton.snp.bottom).offset(16)
            $0.centerX.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(20)
        }
        
        // ㄱ자 테두리들을 중앙에 배치
        setupCornerConstraints()
        
        // 촬영 버튼
        captureButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-42)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(70) 
        }
        
        // 갤러리 버튼 (촬영 버튼과 같은 top, 좌측)
        galleryButton.snp.makeConstraints {
            $0.top.equalTo(captureButton.snp.top) // top을 동일하게
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(60) // 60pt diameter
        }
        
        // 카메라 전환 버튼 (촬영 버튼과 같은 top, 우측)
        flipCameraButton.snp.makeConstraints {
            $0.top.equalTo(captureButton.snp.top) // top을 동일하게
            $0.trailing.equalToSuperview().offset(-20)
            $0.size.equalTo(60) // 60pt diameter
        }
        
        // 검색창 (카메라 화면과 20pt 간격, 촬영 버튼과 21pt 간격)
        searchContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20) 
            $0.centerX.equalToSuperview()
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
            $0.height.equalTo(48)
            $0.bottom.equalTo(captureButton.snp.top).offset(-21) // 버튼과 21pt 간격
        }
        
        // 검색 텍스트 필드
        searchTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(13)
            $0.bottom.equalToSuperview().offset(-13)
        }
        
        // 검색 아이콘 (우측 16pt, 세로 중앙)
        searchIconView.snp.makeConstraints {
            $0.trailing.equalToSuperview().offset(-16)
            $0.centerY.equalToSuperview()
            $0.size.equalTo(20)
        }
    }
    
    // MARK: - ㄱ자 테두리 위치 설정
    private func setupCornerConstraints() {
        let cornerLength: CGFloat = 20
        let horizontalMargin: CGFloat = 32
        let verticalMargin: CGFloat = 46  
        
        // 상단 좌측 ㄱ자
        topLeftCorner.snp.makeConstraints {
            $0.top.equalTo(topControlBar.snp.bottom).offset(verticalMargin)
            $0.leading.equalToSuperview().offset(horizontalMargin)
            $0.size.equalTo(cornerLength)
        }
        
        // 상단 우측 ㄱ자
        topRightCorner.snp.makeConstraints {
            $0.top.equalTo(topControlBar.snp.bottom).offset(verticalMargin)
            $0.trailing.equalToSuperview().offset(-horizontalMargin)
            $0.size.equalTo(cornerLength)
        }
        
        // 하단 좌측 ㄱ자
        bottomLeftCorner.snp.makeConstraints {
            $0.bottom.equalTo(bottomControlBar.snp.top).offset(-verticalMargin)
            $0.leading.equalToSuperview().offset(horizontalMargin)
            $0.size.equalTo(cornerLength)
        }
        
        // 하단 우측 ㄱ자
        bottomRightCorner.snp.makeConstraints {
            $0.bottom.equalTo(bottomControlBar.snp.top).offset(-verticalMargin)
            $0.trailing.equalToSuperview().offset(-horizontalMargin)
            $0.size.equalTo(cornerLength)
        }
    }
    
    // MARK: - ㄱ자 테두리 설정
    private func setupCornerFrames() {
        // 레이아웃이 완료된 후 ㄱ자 테두리 그리기
        DispatchQueue.main.async { [weak self] in
            self?.drawCornerFrames()
        }
    }
    
    private func drawCornerFrames() {
        let cornerLength: CGFloat = 20
        let lineWidth: CGFloat = 5
        
        // 상단 좌측 ㄱ자
        drawCornerFrame(
            in: topLeftCorner,
            cornerLength: cornerLength,
            lineWidth: lineWidth,
            position: .topLeft
        )
        
        // 상단 우측 ㄱ자
        drawCornerFrame(
            in: topRightCorner,
            cornerLength: cornerLength,
            lineWidth: lineWidth,
            position: .topRight
        )
        
        // 하단 좌측 ㄱ자
        drawCornerFrame(
            in: bottomLeftCorner,
            cornerLength: cornerLength,
            lineWidth: lineWidth,
            position: .bottomLeft
        )
        
        // 하단 우측 ㄱ자
        drawCornerFrame(
            in: bottomRightCorner,
            cornerLength: cornerLength,
            lineWidth: lineWidth,
            position: .bottomRight
        )
    }
    
    private enum CornerPosition {
        case topLeft, topRight, bottomLeft, bottomRight
    }
    
    private func drawCornerFrame(
        in view: UIView,
        cornerLength: CGFloat,
        lineWidth: CGFloat,
        position: CornerPosition
    ) {
        // 기존 레이어 제거 (중복 방지)
        view.layer.sublayers?.forEach { $0.removeFromSuperlayer() }
        
        // ㄱ자 그리기
        let path = UIBezierPath()
        path.lineWidth = lineWidth
        path.lineCapStyle = .round
        path.lineJoinStyle = .round
        
        switch position {
        case .topLeft:
            // 좌상단 ㄱ자
            path.move(to: CGPoint(x: 0, y: cornerLength))
            path.addLine(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: cornerLength, y: 0))
        case .topRight:
            // 우상단 ㄱ자
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: cornerLength, y: 0))
            path.addLine(to: CGPoint(x: cornerLength, y: cornerLength))
        case .bottomLeft:
            // 좌하단 ㄱ자
            path.move(to: CGPoint(x: 0, y: 0))
            path.addLine(to: CGPoint(x: 0, y: cornerLength))
            path.addLine(to: CGPoint(x: cornerLength, y: cornerLength))
        case .bottomRight:
            // 우하단 ㄱ자
            path.move(to: CGPoint(x: cornerLength, y: 0))
            path.addLine(to: CGPoint(x: cornerLength, y: cornerLength))
            path.addLine(to: CGPoint(x: 0, y: cornerLength))
        }
        
        // 레이어 생성 및 추가
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = path.cgPath
        shapeLayer.strokeColor = UIColor.white.cgColor
        shapeLayer.fillColor = UIColor.clear.cgColor
        shapeLayer.lineWidth = lineWidth
        shapeLayer.lineCap = .round
        shapeLayer.lineJoin = .round
        
        view.layer.addSublayer(shapeLayer)
    }
    
    // MARK: - Actions
    @objc private func didTapBack() {
        onBackButtonTapped?()
    }
    
    @objc private func didTapSearch() {
        onSearchTapped?()
    }
}

// MARK: - Public Methods
extension CameraView {
    func updateInstructionText(_ text: String) {
        instructionLabel.text = text
    }
    
    /// 스캔 영역 오버레이 업데이트 (중앙은 투명, 외부는 어둡게)
    func updateScanOverlay() {
        let bounds = previewContainer.bounds
        guard bounds.width > 0, bounds.height > 0 else { return }
        
        // 스캔 영역 크기 계산 (ㄱ자 테두리가 투명 영역 안에 완전히 들어가도록)
        let horizontalMargin: CGFloat = 32
        let verticalMargin: CGFloat = 46
        let borderLineWidth: CGFloat = 5 // 테두리 선 두께
        
        // 테두리가 완전히 투명 영역 안에 들어가도록 여백을 줄임
        let adjustedHorizontalMargin = horizontalMargin - (borderLineWidth / 2) - 1 // -1은 추가 여유
        let adjustedVerticalMargin = verticalMargin - (borderLineWidth / 2) - 1
        
        let scanWidth = bounds.width - (adjustedHorizontalMargin * 2)
        let scanHeight = bounds.height - (adjustedVerticalMargin * 2)
        let scanX = adjustedHorizontalMargin
        let scanY = adjustedVerticalMargin
        
        let scanRect = CGRect(x: scanX, y: scanY, width: scanWidth, height: scanHeight)
        
        // 전체 영역 path
        let fullPath = UIBezierPath(rect: bounds)
        
        // 중앙 투명 영역 path (반대 방향으로 그림)
        let clearPath = UIBezierPath(rect: scanRect)
        
        // 두 path를 결합 (even-odd fill rule로 중앙을 뚫음)
        fullPath.append(clearPath)
        fullPath.usesEvenOddFillRule = true
        
        // 오버레이 레이어 설정
        scanOverlayLayer.path = fullPath.cgPath
        scanOverlayLayer.fillRule = .evenOdd
        scanOverlayLayer.fillColor = UIColor.black.withAlphaComponent(0.25).cgColor // #000000 25%
        scanOverlayLayer.frame = bounds
    }
} 
