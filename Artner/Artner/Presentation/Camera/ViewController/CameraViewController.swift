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
    
    // Coordinator 주입
    private let coordinator: AppCoordinator
    
    init(coordinator: AppCoordinator) {
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
        checkCameraPermission()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        startCamera()
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
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCamera()
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in
                DispatchQueue.main.async {
                    if granted {
                        self?.setupCamera()
                    } else {
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
            print("카메라를 찾을 수 없습니다.")
            return
        }
        
        do {
            captureSession = AVCaptureSession()
            captureSession?.sessionPreset = .photo
            
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            if captureSession?.canAddInput(input) == true {
                captureSession?.addInput(input)
            }
            
            photoOutput = AVCapturePhotoOutput()
            if captureSession?.canAddOutput(photoOutput!) == true {
                captureSession?.addOutput(photoOutput!)
            }
            
            setupPreviewLayer()
            
        } catch {
            print("카메라 설정 중 오류 발생: \(error)")
        }
    }
    
    private func setupPreviewLayer() {
        guard let captureSession = captureSession else { return }
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer?.videoGravity = .resizeAspectFill
        
        // 카메라 프리뷰를 cameraView의 previewContainer에 추가
        // ㄱ자 테두리가 가려지지 않도록 맨 아래 레이어(index 0)에 추가
        if let previewLayer = previewLayer {
            cameraView.previewContainer.layer.insertSublayer(previewLayer, at: 0)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 프리뷰 레이어 크기를 previewContainer에 맞춤
        previewLayer?.frame = cameraView.previewContainer.bounds
        
        // 스캔 영역 오버레이 업데이트
        cameraView.updateScanOverlay()
        
        // 디버깅: previewContainer와 previewLayer 크기 확인
        print("📐 [CameraVC] previewContainer.bounds: \(cameraView.previewContainer.bounds)")
        print("📐 [CameraVC] previewLayer.frame: \(previewLayer?.frame ?? .zero)")
        print("📐 [CameraVC] captureSession.isRunning: \(captureSession?.isRunning ?? false)")
    }
    
    private func startCamera() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.startRunning()
        }
    }
    
    private func stopCamera() {
        DispatchQueue.global(qos: .background).async { [weak self] in
            self?.captureSession?.stopRunning()
        }
    }
    
    // MARK: - Actions
    @objc private func didTapClose() {
        dismiss(animated: true) {
            // 카메라를 닫을 때는 Home으로 돌아가기 (아무것도 하지 않음)
        }
    }
    
    private func didTapSearch() {
        print("🔍 검색창 탭 - Entry 화면으로 이동")
        // 카메라를 닫고 Entry로 이동 (이미지 없이)
        dismiss(animated: true) { [weak self] in
            self?.coordinator.navigateToEntryFromCamera(with: nil)
        }
    }
    
    @objc private func didTapCapture() {
        guard let photoOutput = photoOutput else { return }
        
        let photoSettings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: photoSettings, delegate: self)
    }
    
    @objc private func didTapFlipCamera() {
        // 전면/후면 카메라 전환
        currentCameraPosition = (currentCameraPosition == .back) ? .front : .back
        
        // 기존 입력 제거
        captureSession?.inputs.forEach { input in
            captureSession?.removeInput(input)
        }
        
        // 새로운 카메라로 설정
        guard let newCamera = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: currentCameraPosition) else { return }
        
        do {
            let newInput = try AVCaptureDeviceInput(device: newCamera)
            if captureSession?.canAddInput(newInput) == true {
                captureSession?.addInput(newInput)
            }
        } catch {
            print("카메라 전환 중 오류 발생: \(error)")
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
              let image = UIImage(data: imageData) else {
            print("이미지 데이터를 변환할 수 없습니다.")
            return
        }
        
        // 촬영된 이미지 처리 - Entry로 이동
        print("사진이 촬영되었습니다.")
        
        // 카메라를 닫고 Entry로 이동
        dismiss(animated: true) { [weak self] in
            self?.coordinator.navigateToEntryFromCamera(with: image)
        }
    }
}

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension CameraViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
        
        if let selectedImage = info[.originalImage] as? UIImage {
            // 선택된 이미지 처리 - Entry로 이동
            print("갤러리에서 이미지를 선택했습니다.")
            
            // 카메라를 닫고 Entry로 이동
            dismiss(animated: true) { [weak self] in
                self?.coordinator.navigateToEntryFromCamera(with: selectedImage)
            }
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true)
    }
}

// MARK: - UITextFieldDelegate
// 검색창은 탭하면 검색 화면으로 이동하므로 UITextFieldDelegate는 필요 없음 
