//
//  VideoLoopPlayerView.swift
//  Artner
//
//  AVQueuePlayer + AVPlayerLooper를 사용한 무한 루프 비디오 뷰
//  AI 도슨트 선택 모달 등에서 MP4 아이콘을 재생할 때 사용

import AVFoundation
import UIKit

final class VideoLoopPlayerView: UIView {

    // MARK: - Properties
    private var player: AVQueuePlayer?
    private var playerLooper: AVPlayerLooper?

    // MARK: - Layer
    override class var layerClass: AnyClass { AVPlayerLayer.self }

    private var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }

    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        playerLayer.videoGravity = .resizeAspectFill
        backgroundColor = .clear
    }

    required init?(coder: NSCoder) { fatalError() }

    // MARK: - Public API

    /// 리소스 이름과 확장자로 무한 루프 재생 설정
    func configure(resourceName: String, fileExtension: String = "mp4") {
        // 기존 플레이어 정리
        stopAndCleanup()

        guard let url = Bundle.main.url(forResource: resourceName, withExtension: fileExtension) else {
            print("⚠️ VideoLoopPlayerView: 파일 없음 — \(resourceName).\(fileExtension)")
            return
        }

        let templateItem = AVPlayerItem(url: url)
        let queuePlayer = AVQueuePlayer()
        playerLooper = AVPlayerLooper(player: queuePlayer, templateItem: templateItem)
        player = queuePlayer
        playerLayer.player = queuePlayer
        queuePlayer.play()
    }

    func pause() { player?.pause() }
    func play()  { player?.play()  }

    // MARK: - Lifecycle

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window == nil {
            // 뷰가 윈도우에서 제거될 때 재생 중지
            pause()
        } else {
            play()
        }
    }

    // MARK: - Helpers

    private func stopAndCleanup() {
        player?.pause()
        playerLooper?.disableLooping()
        playerLooper = nil
        player = nil
        playerLayer.player = nil
    }
}
