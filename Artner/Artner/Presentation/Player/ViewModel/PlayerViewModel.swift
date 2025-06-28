//
//  PlayerViewModel.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//
import AVFoundation

final class PlayerViewModel {

    private let docent: Docent
    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false
    private var timer: Timer?

    private let scripts: [DocentScript]
    private var currentHighlightedIndex: Int = -1

    // 외부에 현재 index 전달용
    var onHighlightIndexChanged: ((Int) -> Void)?

    init(docent: Docent) {
        self.docent = docent
        self.scripts = dummyDocentScripts // ✅ 실제 서비스에서는 API로 받아야 함
        prepareAudio()
    }

    func getDocent() -> PlayerUIModel {
        return PlayerUIModel(
            title: docent.title,
            artist: docent.artist,
            description: docent.description
        )
    }

    private func prepareAudio() {
        guard let url = Bundle.main.url(forResource: "dummy", withExtension: "mp3") else {
            print("오디오 파일을 찾을 수 없습니다.")
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
        } catch {
            print("오디오 플레이어 초기화 실패: \(error.localizedDescription)")
        }
    }

    func togglePlayPause() {
        guard let player = audioPlayer else { return }

        if isPlaying {
            player.pause()
            timer?.invalidate()
        } else {
            player.play()
            startTimer()
        }

        isPlaying.toggle()
    }

    func currentPlayButtonTitle() -> String {
        return isPlaying ? "⏸️ 정지" : "▶️ 재생"
    }

    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { [weak self] _ in
            self?.updateHighlightIndex()
        }
    }

    private func updateHighlightIndex() {
        guard let currentTime = audioPlayer?.currentTime else { return }
        print("⏱️ 현재 시간: \(currentTime)초") // ✅ 디버깅용 로그

        for (index, script) in scripts.enumerated().reversed() {
            if currentTime >= script.startTime {
                if currentHighlightedIndex != index {
                    currentHighlightedIndex = index
                    print("👉 강조 인덱스 변경: \(index)") // ✅ 디버깅용 로그
                    onHighlightIndexChanged?(index)
                }
                return
            }
        }
    }

    func getScripts() -> [DocentScript] {
        return scripts
    }
}
