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

    init(docent: Docent) {
        self.docent = docent
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
        } else {
            player.play()
        }

        isPlaying.toggle()
    }

    func currentPlayButtonTitle() -> String {
        return isPlaying ? "⏸️ 정지" : "▶️ 재생"
    }
}
