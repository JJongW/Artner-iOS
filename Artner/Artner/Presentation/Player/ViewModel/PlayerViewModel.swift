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

    // 문단 단위 데이터로 변경
    private let paragraphs: [DocentParagraph]
    private var currentHighlightedIndex: Int = -1
    
    // 시뮬레이션을 위한 시간 추적 (실제 오디오가 없을 때 사용)
    private var simulationStartTime: Date?
    private var simulationCurrentTime: TimeInterval = 0.0
    private var isUsingSimulation = false
    
    // 로딩 상태 관리
    private var isLoading = true

    // 외부 콜백들
    var onHighlightIndexChanged: ((Int) -> Void)?
    var onProgressChanged: ((TimeInterval, TimeInterval) -> Void)?
    var onPlayStateChanged: ((Bool) -> Void)?
    var onLoadingStateChanged: ((Bool) -> Void)?

    init(docent: Docent) {
        self.docent = docent
        self.paragraphs = dummyDocentParagraphs
        
        // 데이터 로딩 시뮬레이션
        simulateDataLoading()
        prepareAudio()
    }

    func getDocent() -> PlayerUIModel {
        return PlayerUIModel(
            title: docent.title,
            artist: docent.artist,
            description: docent.description
        )
    }
    
    private func simulateDataLoading() {
        // 실제 서비스에서는 API 호출로 도슨트 데이터를 가져옴
        isLoading = true
        onLoadingStateChanged?(true)
        
        // 2초 후 로딩 완료 시뮬레이션
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            self.isLoading = false
            self.onLoadingStateChanged?(false)
            print("✅ 도슨트 데이터 로딩 완료")
        }
    }

    private func prepareAudio() {
        // 실제 오디오 파일을 찾아보고, 없으면 시뮬레이션 모드로 설정
        guard let url = Bundle.main.url(forResource: "dummy", withExtension: "mp3") else {
            print("⚠️ 오디오 파일을 찾을 수 없어 시뮬레이션 모드로 실행합니다.")
            isUsingSimulation = true
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.prepareToPlay()
            print("✅ 오디오 파일 로딩 성공")
        } catch {
            print("⚠️ 오디오 플레이어 초기화 실패, 시뮬레이션 모드로 전환: \(error.localizedDescription)")
            isUsingSimulation = true
        }
    }

    func togglePlayPause() {
        // 로딩 중에는 재생 불가
        guard !isLoading else {
            print("⚠️ 아직 로딩 중입니다.")
            return
        }
        
        if isPlaying {
            pausePlayback()
        } else {
            startPlayback()
        }
        
        isPlaying.toggle()
        onPlayStateChanged?(isPlaying)
    }
    
    func replay() {
        // 로딩 중에는 리플레이 불가
        guard !isLoading else {
            print("⚠️ 아직 로딩 중입니다.")
            return
        }
        
        print("🔄 리플레이 시작")
        
        // 재생 중이면 먼저 정지
        if isPlaying {
            pausePlayback()
            isPlaying = false
            onPlayStateChanged?(false)
        }
        
        // 재생 위치 초기화
        resetPlaybackPosition()
        
        // 하이라이트 초기화
        currentHighlightedIndex = -1
        
        // 약간의 지연 후 재생 시작
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            self.startPlayback()
            self.isPlaying = true
            self.onPlayStateChanged?(true)
        }
    }
    
    private func resetPlaybackPosition() {
        if isUsingSimulation {
            simulationCurrentTime = 0.0
            simulationStartTime = nil
        } else {
            audioPlayer?.currentTime = 0.0
        }
        
        // 진행률 초기화
        onProgressChanged?(0.0, getTotalTime())
        print("⏪ 재생 위치 초기화")
    }
    
    private func startPlayback() {
        if isUsingSimulation {
            // 시뮬레이션 모드: 현재 시간 기록
            simulationStartTime = Date()
        } else {
            // 실제 오디오 모드
            audioPlayer?.play()
        }
        
        startTimer()
        print("▶️ 재생 시작 (시뮬레이션: \(isUsingSimulation))")
    }
    
    private func pausePlayback() {
        if isUsingSimulation {
            // 시뮬레이션 모드: 현재 진행 시간 저장
            if let startTime = simulationStartTime {
                simulationCurrentTime += Date().timeIntervalSince(startTime)
            }
            simulationStartTime = nil
        } else {
            // 실제 오디오 모드
            audioPlayer?.pause()
        }
        
        timer?.invalidate()
        timer = nil
        print("⏸️ 재생 일시정지")
    }

    func currentPlayButtonTitle() -> String {
        return isPlaying ? "⏸️ 정지" : "▶️ 재생"
    }

    private func startTimer() {
        // 부드러운 업데이트를 위해 0.1초 간격 사용
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.updateHighlightIndex()
            self?.updateProgress()
        }
    }

    private func updateHighlightIndex() {
        let currentTime = getCurrentPlayTime()
        
        // 매번 로그를 출력하면 너무 많으니 0.5초마다만 출력
        if Int(currentTime * 10) % 5 == 0 {
            print("⏱️ 현재 시간: \(String(format: "%.1f", currentTime))초")
        }

        // 현재 시간에 해당하는 문단 인덱스 찾기
        for (index, paragraph) in paragraphs.enumerated().reversed() {
            if currentTime >= paragraph.startTime && currentTime <= paragraph.endTime {
                if currentHighlightedIndex != index {
                    currentHighlightedIndex = index
                    print("👉 문단 하이라이트 변경: [\(index)] \"\(paragraph.id)\"")
                    onHighlightIndexChanged?(index)
                }
                return
            }
        }
        
        // 첫 번째 문단보다 이전 시간이거나 마지막 문단 이후인 경우
        if currentHighlightedIndex != -1 {
            currentHighlightedIndex = -1
            print("👉 문단 하이라이트 해제")
            // 하이라이트 해제는 UI에서 처리하지 않음
        }
    }
    
    private func updateProgress() {
        let currentTime = getCurrentPlayTime()
        let totalTime = getTotalTime()
        
        onProgressChanged?(currentTime, totalTime)
    }
    
    private func getCurrentPlayTime() -> TimeInterval {
        if isUsingSimulation {
            // 시뮬레이션 모드: 시작 시간부터 경과된 시간 계산
            guard let startTime = simulationStartTime else {
                return simulationCurrentTime
            }
            return simulationCurrentTime + Date().timeIntervalSince(startTime)
        } else {
            // 실제 오디오 모드
            return audioPlayer?.currentTime ?? 0.0
        }
    }
    
    private func getTotalTime() -> TimeInterval {
        if isUsingSimulation {
            // 시뮬레이션 모드: 마지막 문단 끝 시간 + 2초
            guard let lastParagraph = paragraphs.last else { return 76.0 }
            return lastParagraph.endTime + 2.0
        } else {
            // 실제 오디오 모드
            return audioPlayer?.duration ?? 76.0
        }
    }

    func getParagraphs() -> [DocentParagraph] {
        return paragraphs
    }
    
    func getIsLoading() -> Bool {
        return isLoading
    }
    
    // MARK: - Deinit
    
    deinit {
        timer?.invalidate()
        audioPlayer?.stop()
        print("🗑️ PlayerViewModel 해제됨")
    }
}

