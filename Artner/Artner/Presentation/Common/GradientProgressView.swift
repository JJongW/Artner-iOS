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
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLayers()
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
        
        print("🎨 GradientProgressView 초기화 완료")
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
        
        print("📊 Progress 업데이트: \(progress) (width: \(progressWidth))")
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
