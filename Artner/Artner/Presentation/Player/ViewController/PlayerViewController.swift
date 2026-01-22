//
//  PlayerViewController.swift
//  Artner
//
//  Created by 신종원 on 4/5/25.
//  Feature Isolation Refactoring - PlayerCoordinating 프로토콜 사용
//

import UIKit
import AVFoundation
import Combine

final class PlayerViewController: BaseViewController<PlayerViewModel, any PlayerCoordinating> {
    private var coordinatorCancellables = Set<AnyCancellable>()

    private let playerView = PlayerView()
    private var isSavedCurrent: Bool = false

    override func loadView() {
        self.view = playerView
    }

    override func setupUI() {
        super.setupUI()
        configureAudioSession()
        setupViewModelBinding()
        setupPlayerData()
    }
    
    private func dismissPlayer() {
        navigationController?.popViewController(animated: true)
    }

    override func setupBinding() {
        super.setupBinding()
        print("🔧 PlayerViewController setupBinding 시작")
        bindData()
        bindAction()
        print("🔧 PlayerViewController setupBinding 완료")
    }

    private func bindData() {
        print("📊 PlayerViewController bindData 시작")
        
        // 하이라이트 인덱스 변경 감지 (문단 단위)
        viewModel.onHighlightIndexChanged = { [weak self] index in
            DispatchQueue.main.async {
                self?.playerView.highlightParagraph(at: index)
            }
        }
        
        // 진행률 업데이트 감지
        viewModel.onProgressChanged = { [weak self] currentTime, totalTime in
            DispatchQueue.main.async {
                self?.playerView.updateProgress(currentTime, totalTime: totalTime)
            }
        }
        
        // 재생 상태 변경 감지
        viewModel.onPlayStateChanged = { [weak self] isPlaying in
            DispatchQueue.main.async {
                self?.playerView.updatePlayState(isPlaying)
            }
        }
        
        print("📊 PlayerViewController bindData 완료")
    }

    private func bindAction() {
        print("🎯 PlayerViewController bindAction 시작")
        
        // 플레이어 컨트롤 액션들
        setupPlayerControlActions()
        
        // 프로그레스 바 터치 이벤트 바인딩
        playerView.onProgressTapped = { [weak self] progress in
            print("⏩ [PlayerViewController] 프로그레스 바 터치: \(progress)")
            self?.viewModel.seek(to: progress)
        }
        
        print("🎯 PlayerViewController bindAction 완료")
    }
    
    private func setupPlayerControlActions() {
        print("🎮 PlayerViewController setupPlayerControlActions 시작")
        
        // 플레이어 컨트롤 액션들을 PlayerView를 통해 설정
        playerView.setupPlayerControlsActions(
            onSave: { [weak self] in
                print("💾 저장 액션 콜백 실행됨")
                self?.handleSaveAction()
            },
            onPlay: { [weak self] in
                print("▶️ 플레이 액션 콜백 실행됨")
                self?.handlePlayAction()
            },
            onPause: { [weak self] in
                print("⏸️ 정지 액션 콜백 실행됨")
                self?.handlePauseAction()
            },
            onReplay: { [weak self] in
                print("🔄 리플레이 액션 콜백 실행됨")
                self?.handleReplayAction()
            }
        )
        
        print("🎮 PlayerViewController setupPlayerControlActions 완료")
    }

    // MARK: - Audio Session
    private func configureAudioSession() {
        do {
            let session = AVAudioSession.sharedInstance()
            // playback 카테고리로 설정하여 무음 모드에서도 소리가 나도록 함
            // mixWithOthers 옵션 제거 - 다른 앱 오디오를 중단하고 이 앱 오디오만 재생
            try session.setCategory(.playback, mode: .default, options: [])
            try session.setActive(true, options: [.notifyOthersOnDeactivation])
            print("✅ AVAudioSession 설정 완료 - Category: playback")
        } catch {
            print("⚠️ AVAudioSession 설정 실패: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Action Handlers
    
    private func handleSaveAction() {
        print("💾 저장 버튼 클릭")
        // 이미 저장된 상태면 저장 취소로 동작
        if isSavedCurrent {
            let docentData = viewModel.getRawDocent()

            // 캐시된 folderId가 있으면 바로 저장 해제
            if let folderId = getSavedFolderIdCached(title: docentData.title, artist: docentData.artist) {
                unbookmarkDocent(docentData: docentData, folderId: folderId)
            } else {
                // folderId가 없으면 폴더 목록에서 검색 후 해제
                findAndUnbookmarkDocent(docentData: docentData)
            }
            return
        }
        // 1) 폴더 목록 가져오기 (Coordinator를 통해)
        var cancellable: AnyCancellable?
        cancellable = coordinator.getFolders()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion { ToastManager.shared.showError("폴더 목록을 불러오지 못했어요") }
                    // 메모리 정리
                    cancellable = nil
                },
                receiveValue: { [weak self] folders in
                    guard let self = self else { return }
                    // 2) 폴더 선택 모달 표시
                    let modal = SelectFolderModalView(folders: folders)
                    modal.onCancelTapped = { modal.removeFromSuperview() }
                    modal.onConfirmTapped = { [weak self] folder in
                        modal.removeFromSuperview()
                        self?.bookmarkDocent(to: folder)
                    }
                    self.view.addSubview(modal)
                    modal.snp.makeConstraints { $0.edges.equalToSuperview() }
                }
            )
    }
    
    private func handlePlayAction() {
        print("▶️ 플레이 버튼 클릭")
        viewModel.togglePlayPause()
    }
    
    private func handlePauseAction() {
        print("⏸️ 정지 버튼 클릭")
        viewModel.togglePlayPause()
    }
    
    private func handleReplayAction() {
        print("🔄 리플레이 버튼 클릭")
        viewModel.replay()
    }
    
    // MARK: - Helper Methods

    /// 선택된 폴더로 도슨트를 북마크 저장
    private func bookmarkDocent(to folder: Folder) {
        // 로딩 토스트
        ToastManager.shared.showLoading("저장 중")
        
        // request body 구성
        let docentInfo = viewModel.getDocent()
        let scriptText: String = viewModel.getParagraphs().map { $0.sentences.map { $0.text }.joined(separator: " ") }.joined(separator: " ")
        let payload = BookmarkDocentRequestDTO(
            folderId: folder.id,
            itemType: "artist", // 요구 사양대로 고정
            name: docentInfo.title,
            lifePeriod: "",
            artistName: docentInfo.artist,
            script: scriptText,
            notes: "",
            thumbnail: "" // 추후 실제 썸네일 URL 연결 가능
        )
        
        APIService.shared.request(APITarget.bookmarkDocent(payload: payload)) { (result: Result<BookmarkResponseDTO, Error>) in
            // 로딩 토스트 닫기
            ToastManager.shared.hideCurrentToast()
            switch result {
            case .success:
                // 저장 버튼 색 변경 및 캐시 반영
                self.playerView.setSaved(true)
                self.setDocentSavedCached(title: docentInfo.title, artist: docentInfo.artist, saved: true)
                self.setSavedFolderIdCached(title: docentInfo.title, artist: docentInfo.artist, folderId: folder.id)
                self.isSavedCurrent = true
                
                // 저장 완료 토스트 표시 (보기 버튼 포함)
                ToastManager.shared.showSaved("도슨트가 저장되었습니다") { [weak self] in
                    // "보기" 버튼 클릭 시 Save 화면으로 이동
                    print("💾 [Toast] 저장된 도슨트 보기 버튼 클릭됨")
                    self?.coordinator.showSave(folderId: folder.id)
                }
            case .failure:
                ToastManager.shared.showError("저장에 실패했습니다")
            }
        }
    }

    /// 도슨트 저장 해제 (folderId 있음)
    private func unbookmarkDocent(docentData: Docent, folderId: Int) {
        ToastManager.shared.showLoading("저장 해제 중")

        let itemType = (docentData.artist.isEmpty ? "artwork" : "artist")
        let name = docentData.artist.isEmpty ? docentData.title : docentData.artist
        let payload = BookmarkDocentRequestDTO(
            folderId: folderId,
            itemType: itemType,
            name: name,
            lifePeriod: "",
            artistName: docentData.artist,
            script: "",
            notes: "",
            thumbnail: ""
        )

        APIService.shared.request(APITarget.bookmarkDocent(payload: payload)) { [weak self] (result: Result<BookmarkResponseDTO, Error>) in
            guard let self = self else { return }
            ToastManager.shared.hideCurrentToast()

            switch result {
            case .success:
                self.setDocentSavedCached(title: docentData.title, artist: docentData.artist, saved: false)
                self.setSavedFolderIdCached(title: docentData.title, artist: docentData.artist, folderId: nil)
                self.isSavedCurrent = false
                DispatchQueue.main.async {
                    self.playerView.setSaved(false)
                    ToastManager.shared.showDelete("저장이 해제되었습니다")
                }
            case .failure:
                DispatchQueue.main.async {
                    ToastManager.shared.showError("저장 해제에 실패했습니다")
                }
            }
        }
    }

    /// folderId가 없을 때 폴더를 검색하여 저장 해제
    private func findAndUnbookmarkDocent(docentData: Docent) {
        ToastManager.shared.showLoading("폴더 검색 중")

        var cancellable: AnyCancellable?
        cancellable = coordinator.getFolders()
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { completion in
                    if case .failure = completion {
                        ToastManager.shared.hideCurrentToast()
                        ToastManager.shared.showError("폴더 목록을 불러오지 못했어요")
                    }
                    cancellable = nil
                },
                receiveValue: { [weak self] folders in
                    guard let self = self else { return }
                    self.searchDocentInFolders(folders: folders, docentData: docentData, index: 0)
                }
            )
    }

    /// 폴더 목록에서 도슨트가 저장된 폴더를 검색
    private func searchDocentInFolders(folders: [Folder], docentData: Docent, index: Int) {
        guard index < folders.count else {
            // 모든 폴더를 검색했지만 찾지 못함
            ToastManager.shared.hideCurrentToast()
            ToastManager.shared.showError("저장된 폴더를 찾을 수 없어요")
            // 상태 초기화 (서버와 동기화 안 됨 가능성)
            self.isSavedCurrent = false
            self.playerView.setSaved(false)
            return
        }

        let folder = folders[index]

        // 폴더 상세 조회
        APIService.shared.request(APITarget.getFolderDetail(id: folder.id)) { [weak self] (result: Result<FolderDetailDTO, Error>) in
            guard let self = self else { return }

            switch result {
            case .success(let detail):
                // 폴더 내 도슨트 검색 (이름 또는 작가명으로 매칭)
                let found = detail.items.contains { item in
                    item.name == docentData.title ||
                    item.artistName == docentData.artist ||
                    (item.name == docentData.artist && !docentData.artist.isEmpty)
                }

                if found {
                    // 찾음! folderId 캐시하고 저장 해제
                    self.setSavedFolderIdCached(title: docentData.title, artist: docentData.artist, folderId: folder.id)
                    self.unbookmarkDocent(docentData: docentData, folderId: folder.id)
                } else {
                    // 다음 폴더 검색
                    self.searchDocentInFolders(folders: folders, docentData: docentData, index: index + 1)
                }

            case .failure:
                // 이 폴더 조회 실패, 다음으로 진행
                self.searchDocentInFolders(folders: folders, docentData: docentData, index: index + 1)
            }
        }
    }

    private func setupViewModelBinding() {
        // 로딩 상태 변경 감지
        viewModel.onLoadingStateChanged = { [weak self] isLoading in
            DispatchQueue.main.async {
                if isLoading {
                    return
                }
                let paragraphs = self?.viewModel.getParagraphs() ?? []
                print("✅ 로딩 완료 - paragraphs: \(paragraphs.count)")
                self?.playerView.setParagraphs(paragraphs)
                self?.playerView.showContentState()
            }
        }

        // 기존 하이라이트 관련 바인딩 설정
        viewModel.onHighlightSaved = { [weak self] highlight in
            // 저장 후 전체 하이라이트를 다시 적용
            let all = self?.viewModel.getAllHighlights() ?? [:]
            DispatchQueue.main.async {
                self?.playerView.updateHighlights(all)
            }
        }
        
        viewModel.onHighlightsLoaded = { [weak self] highlights in
            DispatchQueue.main.async {
                self?.playerView.updateHighlights(highlights)
            }
        }

        // Underline 화면으로 이동 콜백 연결
        viewModel.onShowUnderline = { [weak self] in
            self?.coordinator.showUnderlineFromPlayer()
        }

        playerView.onHighlightCreated = { [weak self] highlight in
            self?.viewModel.saveHighlight(highlight)
        }
        
        playerView.onHighlightDeleted = { [weak self] highlight in
            self?.viewModel.deleteHighlight(highlight)
        }
        
        // ViewModel에서 하이라이트를 가져오는 콜백 설정
        playerView.onGetHighlightsForParagraph = { [weak self] paragraphId in
            return self?.viewModel.getHighlights(for: paragraphId) ?? []
        }
        
        print("🔗 [Controller] 하이라이트 바인딩 설정 완료")
        
        // 상단 뒤로가기 버튼 액션 연결
        playerView.onBackButtonTapped = { [weak self] in
            self?.dismissPlayer()
        }
    }
    
    private func setupPlayerData() {
        // PlayerView에 기본 데이터 설정 (문단은 로딩 완료 시 주입)
        let docentData = viewModel.getDocent()
        // ArtnerPrimaryBar에 타이틀/아티스트 설정
        playerView.artnerPrimaryBar.setTitle(docentData.title, subtitle: docentData.artist)
        // 저장 상태 초기 반영 (캐시 기반)
        let saved = isDocentSavedCached(title: docentData.title, artist: docentData.artist)
        isSavedCurrent = saved
        playerView.setSaved(saved)
        // 서버 기준 저장 상태 확인 (우선 캐시 표시 후 동기화)
        let itemType = (docentData.artist.isEmpty ? "artwork" : "artist")
        let name = docentData.artist.isEmpty ? docentData.title : docentData.artist
        APIService.shared.request(APITarget.docentStatus(itemType: itemType, name: name)) { (result: Result<DocentStatusResponseDTO, Error>) in
            switch result {
            case .success(let res):
                DispatchQueue.main.async {
                    self.isSavedCurrent = res.saved
                    self.playerView.setSaved(res.saved)
                    self.setDocentSavedCached(title: docentData.title, artist: docentData.artist, saved: res.saved)
                }
            case .failure:
                break
            }
        }
    }

    // MARK: - Saved State Cache
    private func savedCacheKey(title: String, artist: String) -> String {
        return "SavedDocent_\(title)_\(artist)"
    }
    private func isDocentSavedCached(title: String, artist: String) -> Bool {
        let key = savedCacheKey(title: title, artist: artist)
        return UserDefaults.standard.bool(forKey: key)
    }
    private func setDocentSavedCached(title: String, artist: String, saved: Bool) {
        let key = savedCacheKey(title: title, artist: artist)
        UserDefaults.standard.set(saved, forKey: key)
    }
    private func savedFolderIdKey(title: String, artist: String) -> String {
        return "SavedDocentFolder_\(title)_\(artist)"
    }
    private func getSavedFolderIdCached(title: String, artist: String) -> Int? {
        let key = savedFolderIdKey(title: title, artist: artist)
        let value = UserDefaults.standard.object(forKey: key)
        return value as? Int
    }
    private func setSavedFolderIdCached(title: String, artist: String, folderId: Int?) {
        let key = savedFolderIdKey(title: title, artist: artist)
        if let id = folderId {
            UserDefaults.standard.set(id, forKey: key)
        } else {
            UserDefaults.standard.removeObject(forKey: key)
        }
    }
}
// MARK: - UIGestureRecognizerDelegate
// UIGestureRecognizerDelegate 제거 (스와이프 뒤로가기 폐지)
