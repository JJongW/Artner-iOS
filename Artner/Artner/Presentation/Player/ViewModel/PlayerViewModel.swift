//
//  PlayerViewModel.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//
import AVFoundation

final class PlayerViewModel: NSObject {

    private let docent: Docent
    private var audioPlayer: AVAudioPlayer?
    private var avPlayer: AVPlayer?
    private var timeObserver: Any?
    private var isPlaying = false
    private var timer: Timer?

    // 문단 단위 데이터로 변경
    private var paragraphs: [DocentParagraph] = []
    private var currentHighlightedIndex: Int = -1
    
    // 하이라이트 관리 - ViewModel로 이동
    private var savedHighlights: [String: [TextHighlight]] = [:]  // paragraphId: [highlights]
    
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
    
    // 하이라이트 관련 콜백 추가
    var onHighlightSaved: ((TextHighlight) -> Void)?
    var onHighlightsLoaded: (([String: [TextHighlight]]) -> Void)?

    init(docent: Docent) {
        self.docent = docent
        super.init()
        // 데이터 로딩 시뮬레이션
        simulateDataLoading()
        prepareAudio()
        
        // 저장된 하이라이트 로드
        loadSavedHighlights()
    }

    func getDocent() -> PlayerUIModel {
        return PlayerUIModel(
            title: docent.title,
            artist: docent.artist,
            description: docent.description
        )
    }
    
    // MARK: - Public Interface
    
    func getParagraphs() -> [DocentParagraph] {
        return paragraphs
    }
    
    func getIsPlaying() -> Bool {
        return isPlaying
    }
    
    func getHighlights(for paragraphId: String) -> [TextHighlight] {
        return savedHighlights[paragraphId] ?? []
    }
    
    // MARK: - Highlight Management
    
    // Implement setParagraphs method
    func setParagraphs(_ paragraphs: [DocentParagraph]) {
        self.paragraphs = paragraphs
        // 로딩 상태 업데이트
        isLoading = false
        onLoadingStateChanged?(false)
    }

    // Implement saveHighlight method
    func saveHighlight(_ highlight: TextHighlight) {
        // 문단별 배열 초기화
        if savedHighlights[highlight.paragraphId] == nil {
            savedHighlights[highlight.paragraphId] = []
        }
        
        // 강화된 중복 방지: 동일 범위가 이미 있으면 무시
        // 조건을 완화하여 범위가 겹치는 경우도 체크
        let isDuplicate = savedHighlights[highlight.paragraphId]!.contains { existing in
            // 정확히 동일한 범위
            if existing.startIndex == highlight.startIndex && existing.endIndex == highlight.endIndex {
                return true
            }
            // 범위가 겹치는 경우 (더 엄격한 체크)
            if existing.startIndex <= highlight.endIndex && existing.endIndex >= highlight.startIndex {
                print("⚠️ [ViewModel] 하이라이트 범위가 기존 하이라이트와 겹칩니다")
                return true
            }
            return false
        }
        
        if isDuplicate {
            print("⚠️ [ViewModel] 중복 하이라이트 - 저장 무시")
            ToastManager.shared.showSimple("이미 하이라이트된 영역입니다")
            return
        }
        
        savedHighlights[highlight.paragraphId]?.append(highlight)
        saveHighlightsToStorage()
        
        // Toast 표시 - 하이라이트 저장 완료 알림
        showHighlightSavedToast(highlight: highlight)
        
        // UI에 즉시 알림 (UI 업데이트 강제)
        onHighlightSaved?(highlight)
    }
    
    /// 하이라이트 저장 완료 Toast 표시
    private func showHighlightSavedToast(highlight: TextHighlight) {
        let message = "하이라이트가 저장되었습니다"
        
        // 저장된 하이라이트 목록으로 이동하는 액션
        let viewAction = { [weak self] in
            // 실제 프로젝트에서는 저장된 하이라이트 화면으로 이동하는 로직 구현
            print("💡 [Toast] 저장된 하이라이트 보기 버튼 클릭됨")
            // 예: Coordinator를 통해 Save 화면으로 이동
            // self?.coordinator?.showSavedHighlights()
        }
        
        ToastManager.shared.showSaved(message, viewAction: viewAction)
    }
    
    // 하이라이트 삭제
    func deleteHighlight(_ highlight: TextHighlight) {
        print("🗑️ [ViewModel] 하이라이트 삭제 요청: ID=\(highlight.id), 문단=\(highlight.paragraphId)")
        
        // 해당 문단의 하이라이트 목록에서 제거
        if var paragraphHighlights = savedHighlights[highlight.paragraphId] {
            let beforeCount = paragraphHighlights.count
            paragraphHighlights.removeAll { $0.id == highlight.id }
            savedHighlights[highlight.paragraphId] = paragraphHighlights
            let afterCount = paragraphHighlights.count
            
            print("🗑️ [ViewModel] 삭제 전: \(beforeCount)개, 삭제 후: \(afterCount)개")
            
            // 스토리지에 저장
            saveHighlightsToStorage()
            
            // UI에 즉시 알림 (UI 업데이트 트리거)
            onHighlightSaved?(highlight) // 같은 콜백 사용 (UI 업데이트 트리거)
            
            print("🗑️ [ViewModel] 하이라이트 삭제 완료 및 UI 업데이트 트리거")
        } else {
            print("❌ [ViewModel] 해당 문단의 하이라이트를 찾을 수 없음")
        }
    }
    
    // 모든 하이라이트 반환 (UI 업데이트 용)
    func getAllHighlights() -> [String: [TextHighlight]] {
        return savedHighlights
    }
    
    /// 저장된 하이라이트 로드
    private func loadSavedHighlights() {
        loadHighlightsFromStorage()
        
        // UI에 로드된 하이라이트 전달
        onHighlightsLoaded?(savedHighlights)
    }
    
    /// 텍스트 선택 가능 여부 (재생 중이 아닐 때만 가능)
    func isTextSelectionEnabled() -> Bool {
        return !isPlaying
    }
    
    /// 저장소에 하이라이트 저장 (UserDefaults 사용)
    private func saveHighlightsToStorage() {
        let encoder = JSONEncoder()
        var allHighlights: [TextHighlight] = []
        
        for highlights in savedHighlights.values {
            allHighlights.append(contentsOf: highlights)
        }
        
        if let data = try? encoder.encode(allHighlights) {
            UserDefaults.standard.set(data, forKey: "SavedTextHighlights")
            print("💾 [Storage] 하이라이트 저장 완료: \(allHighlights.count)개")
        }
    }
    
    /// 저장소에서 하이라이트 로드
    private func loadHighlightsFromStorage() {
        guard let data = UserDefaults.standard.data(forKey: "SavedTextHighlights"),
              let highlights = try? JSONDecoder().decode([TextHighlight].self, from: data) else {
            print("📂 [Storage] 저장된 하이라이트가 없습니다")
            return
        }
        
        // paragraphId별로 그룹화
        savedHighlights.removeAll()
        for highlight in highlights {
            if savedHighlights[highlight.paragraphId] == nil {
                savedHighlights[highlight.paragraphId] = []
            }
            savedHighlights[highlight.paragraphId]?.append(highlight)
        }
        
        print("📂 [Storage] 하이라이트 로드 완료: \(highlights.count)개")
    }
    
    private func simulateDataLoading() {
        // 로딩 시작 알림
        isLoading = true
        onLoadingStateChanged?(true)
        print("⏳ 로딩 시작 - Docent ID: \(docent.id), paragraphs in source: \(docent.paragraphs.count)")

        // 데이터 로딩 시뮬레이션 (가시적인 로딩 시간을 보장)
        let sourceParagraphs = docent.paragraphs
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) { [weak self] in
            guard let self = self else { return }
            self.paragraphs = sourceParagraphs
            self.isLoading = false
            self.onLoadingStateChanged?(false)
            print("✅ 도슨트 데이터 로딩 완료: \(self.paragraphs.count)개 문단")
        }
    }

    private func prepareAudio() {
        // 우선 Docent의 오디오 URL이 있으면 그걸 사용
        if let audioURL = docent.audioURL {
            // URL이 원격 URL(HTTP/HTTPS)인지 확인
            let isRemoteURL = audioURL.scheme == "http" || audioURL.scheme == "https"
            
            if isRemoteURL {
                // 원격 URL인 경우 AVPlayer 사용
                let playerItem = AVPlayerItem(url: audioURL)
                avPlayer = AVPlayer(playerItem: playerItem)
                
                // 볼륨 확인 및 설정 (0이면 소리가 안 남)
                avPlayer?.volume = 1.0
                
                isUsingSimulation = false
                print("✅ 원격 오디오 URL 로딩 성공 (AVPlayer): \(audioURL.absoluteString)")
                
                // 재생 상태 관찰
                setupAVPlayerObservers(playerItem: playerItem)
                return
            } else {
                // 로컬 파일 URL인 경우 AVAudioPlayer 사용
                do {
                    audioPlayer = try AVAudioPlayer(contentsOf: audioURL)
                    audioPlayer?.prepareToPlay()
                    isUsingSimulation = false
                    print("✅ 로컬 오디오 파일 로딩 성공 (AVAudioPlayer): \(audioURL.path)")
                    return
                } catch {
                    print("⚠️ 로컬 오디오 초기화 실패: \(error.localizedDescription) -> 애니메이션 시뮬레이션으로 전환")
                    audioPlayer = nil
                    isUsingSimulation = true
                    return
                }
            }
        }
        // 없으면 더미로 시뮬레이션
        if let url = Bundle.main.url(forResource: "dummy", withExtension: "mp3") {
            do {
                audioPlayer = try AVAudioPlayer(contentsOf: url)
                audioPlayer?.prepareToPlay()
                isUsingSimulation = false
                print("✅ 더미 오디오 로딩 성공")
                return
            } catch { }
        }
        print("⚠️ 오디오 파일을 찾을 수 없어 시뮬레이션 모드로 실행합니다.")
        isUsingSimulation = true
    }
    
    private func setupAVPlayerObservers(playerItem: AVPlayerItem) {
        guard let player = avPlayer else { return }
        
        // AVPlayerItem 상태 관찰 (준비 완료 확인)
        playerItem.addObserver(self, forKeyPath: "status", options: [.new], context: nil)
        
        // 재생 시간 관찰 (0.1초 간격)
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] _ in
            self?.updateHighlightIndex()
            self?.updateProgress()
        }
        
        // 재생 완료 알림
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(playerDidFinishPlaying),
            name: .AVPlayerItemDidPlayToEndTime,
            object: playerItem
        )
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let playerItem = object as? AVPlayerItem {
                switch playerItem.status {
                case .readyToPlay:
                    print("✅ AVPlayerItem 준비 완료 - 재생 가능")
                case .failed:
                    print("❌ AVPlayerItem 로딩 실패: \(playerItem.error?.localizedDescription ?? "알 수 없는 오류")")
                    isUsingSimulation = true
                case .unknown:
                    print("⚠️ AVPlayerItem 상태 알 수 없음")
                @unknown default:
                    break
                }
            }
        }
    }
    
    @objc private func playerDidFinishPlaying() {
        isPlaying = false
        onPlayStateChanged?(false)
        timer?.invalidate()
        timer = nil
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
            // 오디오 로딩이 안된 경우 재시도
            if audioPlayer == nil && !isUsingSimulation {
                prepareAudio()
            }
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
        } else if let avPlayer = avPlayer {
            avPlayer.seek(to: .zero)
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
            startTimer()
        } else if let avPlayer = avPlayer {
            // AVPlayer 사용 (원격 URL)
            // AVPlayerItem이 준비되었는지 확인
            if let playerItem = avPlayer.currentItem, playerItem.status == .readyToPlay {
                avPlayer.play()
                print("▶️ AVPlayer 재생 시작")
            } else {
                print("⚠️ AVPlayerItem이 아직 준비되지 않음. 상태: \(avPlayer.currentItem?.status.rawValue ?? -1)")
                // 준비되지 않았어도 재생 시도 (비동기 로딩 중일 수 있음)
                avPlayer.play()
            }
            // AVPlayer는 timeObserver로 시간 업데이트하므로 별도 타이머 불필요
        } else {
            // AVAudioPlayer 사용 (로컬 파일)
            audioPlayer?.play()
            startTimer()
        }
        
        print("▶️ 재생 시작 (시뮬레이션: \(isUsingSimulation), AVPlayer: \(avPlayer != nil))")
    }
    
    private func pausePlayback() {
        if isUsingSimulation {
            // 시뮬레이션 모드: 현재 진행 시간 저장
            if let startTime = simulationStartTime {
                simulationCurrentTime += Date().timeIntervalSince(startTime)
            }
            simulationStartTime = nil
            timer?.invalidate()
            timer = nil
        } else if let avPlayer = avPlayer {
            // AVPlayer 사용 (원격 URL)
            avPlayer.pause()
        } else {
            // AVAudioPlayer 사용 (로컬 파일)
            audioPlayer?.pause()
            timer?.invalidate()
            timer = nil
        }
        
        print("⏸️ 재생 일시정지")
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
        } else if let avPlayer = avPlayer {
            // AVPlayer 사용 (원격 URL)
            return CMTimeGetSeconds(avPlayer.currentTime())
        } else {
            // AVAudioPlayer 사용 (로컬 파일)
            return audioPlayer?.currentTime ?? 0.0
        }
    }
    
    private func getTotalTime() -> TimeInterval {
        if isUsingSimulation {
            // 시뮬레이션 모드: 마지막 문단 끝 시간 + 2초
            guard let lastParagraph = paragraphs.last else { return 60.0 }
            return lastParagraph.endTime + 2.0
        } else if let avPlayer = avPlayer, let duration = avPlayer.currentItem?.duration {
            // AVPlayer 사용 (원격 URL)
            let seconds = CMTimeGetSeconds(duration)
            return seconds.isFinite ? seconds : 60.0
        } else {
            // AVAudioPlayer 사용 (로컬 파일)
            return audioPlayer?.duration ?? 60.0
        }
    }

    func getIsLoading() -> Bool {
        return isLoading
    }
    
    // MARK: - Deinit
    
    deinit {
        timer?.invalidate()
        audioPlayer?.stop()
        
        // AVPlayer 정리
        if let timeObserver = timeObserver {
            avPlayer?.removeTimeObserver(timeObserver)
        }
        // AVPlayerItem observer 제거
        avPlayer?.currentItem?.removeObserver(self, forKeyPath: "status")
        NotificationCenter.default.removeObserver(self)
        avPlayer?.pause()
        avPlayer = nil
        
        print("🗑️ PlayerViewModel 해제됨")
    }
}

