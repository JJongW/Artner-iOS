//
//  CameraViewController.swift
//  Artner
//
//  Feature Isolation Refactoring - CameraCoordinating 프로토콜 사용
//

import UIKit
import AVFoundation
import Combine

final class CameraViewController: UIViewController {
    private let cameraView = CameraView()
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    private var cancellables = Set<AnyCancellable>()

    // 카메라 관련 프로퍼티
    private var currentCameraPosition: AVCaptureDevice.Position = .back
    private var hasCheckedPermission = false

    // Coordinator (프로토콜 기반)
    private let coordinator: any CameraCoordinating

    init(coordinator: any CameraCoordinating) {
        self.coordinator = coordinator
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        self.view = cameraView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupActions()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // CameraViewController가 완전히 present된 후 한 번만 권한 체크
        if !hasCheckedPermission {
            hasCheckedPermission = true
            checkCameraPermission()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        // 카메라 세션이 이미 설정되어 있고 실행 중이 아니라면 시작
        if captureSession != nil {
            startCamera()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopCamera()
    }
    
    private func setupActions() {
        // 뒤로가기 버튼 콜백 연결 (CustomNavigationBar 스타일 참고)
        cameraView.onBackButtonTapped = { [weak self] in
            self?.didTapClose()
        }
        
        // 검색창 탭 콜백 연결
        cameraView.onSearchTapped = { [weak self] in
            self?.didTapSearch()
        }
        
        // 촬영 버튼
        cameraView.captureButton.addTarget(self, action: #selector(didTapCapture), for: .touchUpInside)
        
        // 카메라 전환 버튼 (전면/후면)
        cameraView.flipCameraButton.addTarget(self, action: #selector(didTapFlipCamera), for: .touchUpInside)
        
        // 갤러리 버튼
        cameraView.galleryButton.addTarget(self, action: #selector(didTapGallery), for: .touchUpInside)
    }
    
    // MARK: - Camera Permission & Setup
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            // 카메라 설정은 백그라운드 스레드에서 실행
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.setupCamera()
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                if granted {
                    // 카메라 설정은 백그라운드 스레드에서 실행
                    DispatchQueue.global(qos: .userInitiated).async {
                        self?.setupCamera()
                    }
                } else {
                    DispatchQueue.main.async {
                        self?.showPermissionDeniedAlert()
                    }
                }
            }
        case .denied, .restricted:
            showPermissionDeniedAlert()
        @unknown default:
            showPermissionDeniedAlert()
        }
    }
    
    private func showPermissionDeniedAlert() {
        let alert = UIAlertController(
            title: "카메라 접근 권한 필요",
            message: "작품을 촬영하기 위해 카메라 접근 권한이 필요합니다. 설정에서 권한을 허용해주세요.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        alert.addAction(UIAlertAction(title: "취소", style: .cancel) { [weak self] _ in
            self?.dismiss(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func setupCamera() {
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else {
            print("❌ 카메라를 찾을 수 없습니다.")
            return
        }
        
        do {
            let session = AVCaptureSession()
            
            // 세션 구성 시작
            session.beginConfiguration()
            
            // 프리뷰용으로는 .high가 충분하고 더 빠름
            session.sessionPreset = .high
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            if session.canAddInput(input) {
                session.addInput(input)
            }
            
            let output = AVCapturePhotoOutput()
            // 고화질 사진 설정
            output.isHighResolutionCaptureEnabled = true
            
            if session.canAddOutput(output) {
                session.addOutput(output)
            }
            
            // 세션 구성 완료 (한 번에 적용)
            session.commitConfiguration()
            
            self.captureSession = session
            self.photoOutput = output
            
            // previewLayer 설정과 세션 시작을 동시에
            DispatchQueue.main.async { [weak self] in
                self?.setupPreviewLayer()
            }
            
            // 세션 시작 (백그라운드에서 즉시)
            session.startRunning()
            
        } catch {
            print("❌ 카메라 설정 중 오류 발생: \(error)")
        }
    }
    
    private func setupPreviewLayer() {
        guard let captureSession = captureSession else { return }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        
        // 카메라 프리뷰를 cameraView의 previewContainer에 추가
        if let previewLayer = previewLayer {
            previewLayer.frame = cameraView.previewContainer.bounds
            cameraView.previewContainer.layer.insertSublayer(previewLayer, at: 0)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // 프리뷰 레이어 크기를 previewContainer에 맞춤
        previewLayer?.frame = cameraView.previewContainer.bounds
        
        // 스캔 영역 오버레이 업데이트
        cameraView.updateScanOverlay()
    }
    
    private func startCamera() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let captureSession = self?.captureSession,
                  !captureSession.isRunning else { return }
            captureSession.startRunning()
        }
    }
    
    private func stopCamera() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let captureSession = self?.captureSession,
                  captureSession.isRunning else { return }
            captureSession.stopRunning()
        }
    }
    
    // MARK: - Actions
    @objc private func didTapClose() {
        dismiss(animated: true) {
            // 카메라를 닫을 때는 Home으로 돌아가기 (아무것도 하지 않음)
        }
    }
    
    private func didTapSearch() {
        // Coordinator가 dismiss와 화면 전환을 처리
        coordinator.navigateToEntryFromCamera(with: nil)
    }
    
    @objc private func didTapCapture() {
        guard let photoOutput = photoOutput else { return }
        
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc private func didTapFlipCamera() {
        // 전면/후면 카메라 전환
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        
        // 카메라 전환 작업은 백그라운드 스레드에서 실행
        DispatchQueue.global(qos: .userInitiated).async { [weak self] in
            guard let self = self,
                  let captureSession = self.captureSession else { return }
            
            // 세션 구성 시작
            captureSession.beginConfiguration()
            
            // 기존 비디오 입력만 제거 (photoOutput은 유지)
            captureSession.inputs.forEach { input in
                if let videoInput = input as? AVCaptureDeviceInput {
                    captureSession.removeInput(videoInput)
                }
            }
            
            // 새로운 카메라로 설정
            guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: self.currentCameraPosition) else {
                captureSession.commitConfiguration()
                return
            }
            
            do {
                let newInput = try AVCaptureDeviceInput(device: newCamera)
                if captureSession.canAddInput(newInput) {
                    captureSession.addInput(newInput)
                }
            } catch {
                print("❌ 카메라 전환 중 오류: \(error)")
            }
            
            // 세션 구성 완료
            captureSession.commitConfiguration()
        }
    }
    
    @objc private func didTapGallery() {
        // 갤러리 열기
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true)
    }
}

// MARK: - AVCapturePhotoCaptureDelegate
extension CameraViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        if let error = error {
            print("사진 촬영 중 오류 발생: \(error)")
            return
        }
        
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData),
              let jpegData = image.jpegData(compressionQuality: 0.8) else {
            return
        }
        
        // API 호출
        uploadImageToRealtimeDocent(imageData: jpegData)
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage,
           let imageData = selectedImage.jpegData(compressionQuality: 0.8) {
            // picker를 먼저 dismiss하고, 완료 후 API 호출
            picker.dismiss(animated: true) { [weak self] in
                self?.uploadImageToRealtimeDocent(imageData: imageData)
            }
        } else {
            picker.dismiss(animated: true)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - Realtime Docent API
extension CameraViewController {
    
    /// 실시간 도슨트 API 호출 (이미지 업로드)
    /// 카메라 촬영 또는 갤러리에서 이미지 선택 시 호출됨
    /// API 응답이 올 때까지 "도슨트 생성 중" 로딩 토스트를 표시
    private func uploadImageToRealtimeDocent(imageData: Data) {
        // 로딩 토스트 표시 (아이콘 없이 텍스트만)
        DispatchQueue.main.async {
            ToastManager.shared.showLoading("도슨트 생성 중")
        }
        
        // APIService를 통해 API 호출
        APIService.shared.request(
            APITarget.realtimeDocent(inputText: nil, inputImage: imageData)
        ) { [weak self] (result: Result<RealtimeDocentResponseDTO, Error>) in
            // 로딩 토스트 숨김
            DispatchQueue.main.async {
                ToastManager.shared.hideCurrentToast()
            }
            
            switch result {
            case .success(let response):
                // 응답 데이터를 Docent 모델로 변환
                guard let self = self, let baseDocent = self.convertToDocent(from: response) else {
                    self?.showAPIError()
                    return
                }

                // 오디오 상태 Polling 시작
                self.pollAudioStatus(jobId: response.audioJobId, baseDocent: baseDocent)
                
            case .failure(let error):
                print("❌ 실시간 도슨트 API 실패: \(error.localizedDescription)")
                self?.showAPIError()
            }
        }
    }

    /// 오디오 상태를 주기적으로 조회하여 완료 시 Player로 이동
    private func pollAudioStatus(jobId: String, baseDocent: Docent) {
        // 최대 60초, 1.5초 간격으로 조회
        let maxAttempts = 40
        var attempt = 0
        
        func requestStatus() {
            APIService.shared.request(APITarget.audioStatus(jobId: jobId)) { [weak self] (result: Result<AudioStatusDTO, Error>) in
                guard let self = self else { return }
                switch result {
                case .success(let statusDTO):
                    if statusDTO.status == "completed" {
                        // audioUrl이 있으면 사용, 없으면 jobId로 streamAudio 호출
                        if let audioUrlString = statusDTO.audioUrl, let audioUrl = URL(string: audioUrlString) {
                            // audioUrl이 완전한 URL인 경우
                            let docentForPlay = self.buildDocentForPlay(from: baseDocent, status: statusDTO, audioURL: audioUrl)
                            DispatchQueue.main.async {
                                ToastManager.shared.showSuccess("도슨트가 준비되었습니다")
                            }
                            self.coordinator.dismissCameraAndShowPlayer(docent: docentForPlay)
                        } else {
                            // audioUrl이 없거나 job_id만 있는 경우 streamAudio 호출
                            ToastManager.shared.showLoading("오디오 불러오는 중")
                            APIService.shared.streamAudio(jobId: jobId)
                                .receive(on: DispatchQueue.main)
                                .sink(
                                    receiveCompletion: { completion in
                                        ToastManager.shared.hideCurrentToast()
                                        if case .failure = completion {
                                            self.showAPIError()
                                        }
                                    },
                                    receiveValue: { [weak self] fileURL in
                                        guard let self = self else { return }
                                        ToastManager.shared.hideCurrentToast()
                                        let docentForPlay = self.buildDocentForPlay(from: baseDocent, status: statusDTO, audioURL: fileURL)
                                        ToastManager.shared.showSuccess("도슨트가 준비되었습니다")
                                        self.coordinator.dismissCameraAndShowPlayer(docent: docentForPlay)
                                    }
                                )
                                .store(in: &self.cancellables)
                        }
                    } else if statusDTO.status == "failed" {
                        self.showAPIError()
                    } else {
                        attempt += 1
                        if attempt < maxAttempts {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                                requestStatus()
                            }
                        } else {
                            self.showAPIError()
                        }
                    }
                case .failure:
                    attempt += 1
                    if attempt < maxAttempts {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            requestStatus()
                        }
                    } else {
                        self.showAPIError()
                    }
                }
            }
        }
        requestStatus()
    }

    /// AudioStatusDTO의 타임스탬프를 사용하여 Player용 Docent 구성
    private func buildDocentForPlay(from base: Docent, status: AudioStatusDTO, audioURL: URL) -> Docent {
        let duration = status.duration ?? 0
        // timestamp를 문단으로 변환: 각 문장을 하나의 문단으로 매핑
        let paragraphs: [DocentParagraph]
        if let stamps = status.timestamps, !stamps.isEmpty {
            var result: [DocentParagraph] = []
            for (index, stamp) in stamps.enumerated() {
                let startSec = Double(stamp.time) / 1000.0
                let endSec: Double = {
                    if index + 1 < stamps.count { return Double(stamps[index+1].time) / 1000.0 }
                    return duration
                }()
                let script = DocentScript(startTime: startSec, text: stamp.value)
                let paragraph = DocentParagraph(
                    id: "p-\(base.id)-\(index)",
                    startTime: startSec,
                    endTime: max(endSec, startSec + 0.5),
                    sentences: [script]
                )
                result.append(paragraph)
            }
            paragraphs = result
        } else {
            // 타임스탬프가 없는 경우 기존 문단 사용
            paragraphs = base.paragraphs
        }
        
        return Docent(
            id: base.id,
            title: base.title,
            artist: base.artist,
            description: base.description,
            imageURL: base.imageURL,
            audioURL: audioURL,
            audioJobId: base.audioJobId, // audioJobId 유지
            paragraphs: paragraphs
        )
    }
    
    /// RealtimeDocentResponseDTO를 Docent 모델로 변환
    private func convertToDocent(from response: RealtimeDocentResponseDTO) -> Docent? {
        // 텍스트를 문장 단위로 분리 (마침표 기준)
        let sentences = response.text.components(separatedBy: ". ")
            .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
            .map { sentence -> String in
                let trimmed = sentence.trimmingCharacters(in: .whitespacesAndNewlines)
                return trimmed.hasSuffix(".") ? trimmed : trimmed + "."
            }
        
        // DocentScript 배열 생성 (각 문장에 시간 할당)
        let avgTimePerSentence: TimeInterval = 5.0 // 문장당 평균 5초
        var currentTime: TimeInterval = 0.0
        
        let docentScripts = sentences.map { sentence -> DocentScript in
            let script = DocentScript(startTime: currentTime, text: sentence)
            currentTime += avgTimePerSentence
            return script
        }
        
        // DocentParagraph 생성 (전체 텍스트를 하나의 문단으로)
        let paragraph = DocentParagraph(
            id: "p-\(response.audioJobId)",
            startTime: 0.0,
            endTime: currentTime,
            sentences: docentScripts
        )
        
        // Docent 생성
        let docent = Docent(
            id: response.audioJobId.hashValue, // audioJobId를 ID로 변환
            title: response.itemName,
            artist: response.itemType == "artist" ? response.itemName : "알 수 없음",
            description: String(response.text.prefix(200)) + "...", // 앞부분 200자만
            imageURL: "", // 이미지 URL은 아직 제공되지 않음
            audioURL: nil, // 오디오 URL은 나중에 audioJobId로 조회
            audioJobId: response.audioJobId, // audioJobId 저장
            paragraphs: [paragraph]
        )
        
        return docent
    }
    
    /// API 에러 Alert 표시
    private func showAPIError() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self,
                  self.view.window != nil else {
                // view가 window에 없으면 Toast로 표시
                print("⚠️ CameraViewController가 화면에 없음 - Toast로 표시")
                DispatchQueue.main.async {
                    ToastManager.shared.showError("이미지 인식에 실패했습니다")
                }
                return
            }
            
            let alert = UIAlertController(
                title: "이미지 인식 실패",
                message: "작품 정보를 가져오는 데 실패했습니다.\n다시 시도해주세요.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "확인", style: .default))
            self.present(alert, animated: true)
        }
    }
}
