//
//  UIImageView+Extension.swift
//  Artner
//
//  Created by AI Assistant on Date.
//

import UIKit

// MARK: - UIImageView URL Image Loading Extension
extension UIImageView {
    
    /// URL로부터 이미지를 비동기적으로 로드합니다.
    /// - Parameter url: 이미지 URL (nil일 경우 플레이스홀더 이미지 표시)
    func loadImage(from url: URL?) {
        // 기존 이미지 초기화 및 로딩 상태 설정
        self.image = nil
        
        // URL이 nil인 경우 플레이스홀더 처리
        guard let url = url else {
            setPlaceholderImage()
            return
        }
        
        // 캐시에서 이미지 확인
        if let cachedImage = ImageCache.shared.image(for: url) {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
        
        setLoadingState()
        
        // 비동기 이미지 다운로드
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                // 에러 처리
                if let error = error {
                    print("🚨 이미지 로드 실패: \(error.localizedDescription)")
                    self.setPlaceholderImage()
                    return
                }
                
                // 데이터 유효성 검증
                guard let data = data,
                      let image = UIImage(data: data) else {
                    print("🚨 이미지 데이터 변환 실패: \(url)")
                    self.setPlaceholderImage()
                    return
                }
                
                // 캐시에 저장
                ImageCache.shared.setImage(image, for: url)
                
                // 이미지 설정 with 애니메이션
                UIView.transition(with: self, duration: 0.3, options: .transitionCrossDissolve) {
                    self.image = image
                }
            }
        }.resume()
    }
    
    /// 플레이스홀더 이미지 설정
    private func setPlaceholderImage() {
        self.image = nil
    }
    
    private func setLoadingState() {
        self.image = nil
    }
}

// MARK: - Simple Image Cache
final class ImageCache {
    static let shared = ImageCache()
    
    private let cache = NSCache<NSURL, UIImage>()
    
    private init() {
        cache.countLimit = 100  // 최대 100개 이미지 캐시
        cache.totalCostLimit = 50 * 1024 * 1024  // 50MB 제한
    }
    
    func image(for url: URL) -> UIImage? {
        return cache.object(forKey: url as NSURL)
    }
    
    func setImage(_ image: UIImage, for url: URL) {
        cache.setObject(image, forKey: url as NSURL)
    }
    
    func clearCache() {
        cache.removeAllObjects()
    }
}