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

    // Implement updatePlayerState method
    func updatePlayerState(_ isPlaying: Bool) {
        // 플레이어 상태 업데이트 로직
        // 예시: self.isPlaying = isPlaying
    }

    // Implement saveHighlight method
    func saveHighlight(_ highlight: TextHighlight) {
        // 문단별 배열 초기화
        if savedHighlights[highlight.paragraphId] == nil {
            savedHighlights[highlight.paragraphId] = []
        }
        
        // 간단한 중복 방지: 동일 범위/텍스트가 이미 있으면 무시
        let isDuplicate = savedHighlights[highlight.paragraphId]!.contains {
            $0.startIndex == highlight.startIndex &&
            $0.endIndex == highlight.endIndex &&
            $0.highlightedText == highlight.highlightedText
        }
        if !isDuplicate {
            savedHighlights[highlight.paragraphId]?.append(highlight)
            saveHighlightsToStorage()
        }
        
        // UI에 알림
        onHighlightSaved?(highlight)
    }
    
    // 하이라이트 삭제
    func deleteHighlight(_ highlight: TextHighlight) {
        // 해당 문단의 하이라이트 목록에서 제거
        if var paragraphHighlights = savedHighlights[highlight.paragraphId] {
            paragraphHighlights.removeAll { $0.id == highlight.id }
            savedHighlights[highlight.paragraphId] = paragraphHighlights
            
            // 스토리지에 저장
            saveHighlightsToStorage()
            
            // UI에 알림
            onHighlightSaved?(highlight) // 같은 콜백 사용 (UI 업데이트 트리거)
            
            print("🗑️ [ViewModel] 하이라이트 삭제: \(highlight.id)")
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
            guard let lastParagraph = paragraphs.last else { return 60.0 }
            return lastParagraph.endTime + 2.0
        } else {
            // 실제 오디오 모드
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
        print("🗑️ PlayerViewModel 해제됨")
    }
}

