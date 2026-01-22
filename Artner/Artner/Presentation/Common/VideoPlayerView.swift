//
//  VideoPlayerView.swift
//  Artner
//
//  Created by AI Assistant on 2025-01-27.
//

import UIKit
import AVFoundation

/// MP4 비디오를 재생하는 커스텀 뷰
/// - AVPlayer와 AVPlayerLayer를 사용하여 비디오 재생
/// - 자동 반복 재생 지원
final class VideoPlayerView: UIView {
    
    // MARK: - Properties
    
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var playerItem: AVPlayerItem?
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    // MARK: - Setup
    
    private func setup() {
        backgroundColor = .clear
        clipsToBounds = true
    }
    
    // MARK: - Public Methods
    
    /// Bundle에서 비디오 파일을 로드하여 재생
    /// - Parameter fileName: 비디오 파일명 (확장자 제외, 예: "ai_video")
    func loadVideo(fileName: String) {
        // 확장자 제거
        let nameWithoutExtension = fileName.replacingOccurrences(of: ".mp4", with: "")
        
        // 1. 먼저 일반 Bundle 경로에서 찾기
        if let videoURL = Bundle.main.url(forResource: nameWithoutExtension, withExtension: "mp4") {
            loadVideo(url: videoURL)
            return
        }
        
        // 2. Assets.xcassets의 dataset에서 찾기 (NSDataAsset 사용)
        if let dataAsset = NSDataAsset(name: nameWithoutExtension, bundle: Bundle.main) {
            let data = dataAsset.data
            // 임시 파일로 저장하여 재생
            let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(nameWithoutExtension).mp4")
            
            do {
                try data.write(to: tempURL)
                loadVideo(url: tempURL)
                print("✅ [VideoPlayerView] Assets에서 비디오 로드 성공: \(nameWithoutExtension)")
            } catch {
                print("❌ [VideoPlayerView] 임시 파일 저장 실패: \(error.localizedDescription)")
            }
            return
        }
        
        print("❌ [VideoPlayerView] 비디오 파일을 찾을 수 없습니다: \(nameWithoutExtension).mp4")
    }
    
    /// URL에서 비디오를 로드하여 재생
    /// - Parameter url: 비디오 파일 URL
    func loadVideo(url: URL) {
        // 기존 플레이어 정리
        cleanup()
        
        // AVPlayerItem 생성
        let newPlayerItem = AVPlayerItem(url: url)
        self.playerItem = newPlayerItem
        
        // AVPlayer 생성
        let newPlayer = AVPlayer(playerItem: newPlayerItem)
        self.player = newPlayer
        
        // AVPlayerLayer 생성 및 추가
        let newPlayerLayer = AVPlayerLayer(player: newPlayer)
        newPlayerLayer.videoGravity = .resizeAspectFill
        newPlayerLayer.frame = bounds
        layer.addSublayer(newPlayerLayer)
        self.playerLayer = newPlayerLayer
        
        // 무한 반복 재생을 위한 NotificationCenter observer 등록
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: newPlayerItem
        )
        
        // 재생 시작
        newPlayer.play()
        
        print("✅ [VideoPlayerView] 비디오 재생 시작: \(url.lastPathComponent)")
    }
    
    /// 재생 시작
    func play() {
        player?.play()
    }
    
    /// 재생 일시정지
    func pause() {
        player?.pause()
    }
    
    /// 재생 중인지 확인
    var isPlaying: Bool {
        return player?.rate != 0 && player?.error == nil
    }
    
    // MARK: - Private Methods
    
    /// 재생 완료 시 호출 (반복 재생을 위해)
    @objc private func playerDidFinishPlaying() {
        player?.seek(to: .zero)
        player?.play()
    }
    
    /// 리소스 정리
    private func cleanup() {
        // NotificationCenter observer 제거
        NotificationCenter.default.removeObserver(self)
        
        // 기존 playerLayer 제거
        playerLayer?.removeFromSuperlayer()
        playerLayer = nil
        
        // 기존 player 정리
        player?.pause()
        player = nil
        
        // playerItem 정리
        playerItem = nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // playerLayer의 frame을 뷰의 bounds에 맞춤
        playerLayer?.frame = bounds
    }
    
    // MARK: - Deinit
    
    deinit {
        cleanup()
        print("🗑️ VideoPlayerView deinit - 리소스 정리 완료")
    }
}

