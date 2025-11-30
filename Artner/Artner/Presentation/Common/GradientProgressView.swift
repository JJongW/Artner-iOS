import UIKit

/// 그라데이션 효과가 있는 커스텀 프로그레스 뷰
class GradientProgressView: UIView {
    
    // MARK: - Properties
    
    /// 진행 상태 (0.0 ~ 1.0)
    var progress: Float = 0.0 {
        didSet {
            updateProgress()
        }
    }
    
    /// 터치 시 진행률 변경 콜백 (0.0 ~ 1.0)
    var onProgressTapped: ((Float) -> Void)?
    
    private let backgroundLayer = CALayer()
    private let progressLayer = CALayer()
    private let gradientLayer = CAGradientLayer()
    
    // MARK: - Colors
    
    internal let layerBackgroundColor = UIColor.white.withAlphaComponent(0.2)
    private let progressStartColor = UIColor(hex: "#C69064") // 좌측 색상
    private let progressEndColor = UIColor(hex: "#FBE4A4")   // 우측 색상
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayers()
        setupGesture()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
        setupGesture()
    }
    
    // MARK: - Setup
    
    private func setupLayers() {
        // 배경 레이어
        backgroundLayer.backgroundColor = layerBackgroundColor.cgColor
        backgroundLayer.cornerRadius = 1 // 2px 높이의 절반
        layer.addSublayer(backgroundLayer)
        
        // 그라데이션 레이어 설정
        gradientLayer.colors = [progressStartColor.cgColor, progressEndColor.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        gradientLayer.cornerRadius = 1
        
        // 프로그레스 레이어 (그라데이션의 마스크 역할)
        progressLayer.backgroundColor = UIColor.white.cgColor
        progressLayer.cornerRadius = 1
        gradientLayer.mask = progressLayer
        
        layer.addSublayer(gradientLayer)
    }
    
    /// 터치 제스처 설정
    private func setupGesture() {
        // 터치 영역을 넓히기 위해 높이를 더 크게 설정 (터치하기 쉽게)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap(_:)))
        addGestureRecognizer(tapGesture)
        
        // 드래그 제스처도 추가 (더 부드러운 조작을 위해)
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        addGestureRecognizer(panGesture)
    }
    
    /// 탭 제스처 처리
    @objc private func handleTap(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: self)
        let progressValue = Float(max(0, min(1, location.x / bounds.width)))
        onProgressTapped?(progressValue)
    }
    
    /// 팬 제스처 처리 (드래그)
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        let location = gesture.location(in: self)
        let progressValue = Float(max(0, min(1, location.x / bounds.width)))
        onProgressTapped?(progressValue)
    }
    
    /// 터치 영역 확장 (터치하기 쉽게 하기 위해)
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        // 프로그레스 바의 높이(4px)보다 넓은 영역(44px)에서 터치 가능하도록 확장
        let expandedBounds = bounds.insetBy(dx: 0, dy: -20)
        return expandedBounds.contains(point)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 배경 레이어 크기 설정
        backgroundLayer.frame = bounds
        
        // 그라데이션 레이어 크기 설정
        gradientLayer.frame = bounds
        
        // 프로그레스 업데이트
        updateProgress()
    }
    
    // MARK: - Progress Update
    
    private func updateProgress() {
        guard bounds.width > 0 else { return }
        
        let progressWidth = bounds.width * CGFloat(progress)
        progressLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: progressWidth,
            height: bounds.height
        )
    }
    
    // MARK: - Animation
    
    func setProgress(_ progress: Float, animated: Bool) {
        if animated {
            CATransaction.begin()
            CATransaction.setAnimationDuration(0.3)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
            
            self.progress = progress
            
            CATransaction.commit()
        } else {
            self.progress = progress
        }
    }
} 
