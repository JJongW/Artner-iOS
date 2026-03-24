# Camera — 카메라 스캔

작품 이미지를 카메라로 스캔하여 도슨트를 찾거나 생성하는 화면. fullScreen present로 표시.

## 파일 구조

```
Camera/
├── View/
│   └── CameraView.swift             # 카메라 프리뷰 + 촬영 버튼 레이아웃
└── ViewController/
    └── CameraViewController.swift  # AVCaptureSession 관리, 촬영 결과 처리
```

> ViewModel 없음 — 카메라 로직이 단순하여 VC가 직접 처리

## 데이터 흐름

```
CameraView (촬영 버튼)
  ↓
CameraViewController → capturePhoto()
  ↓
AVCapturePhotoOutput → photoOutput(_:didFinishProcessingPhoto:)
  ↓
CameraViewController → coordinator.dismissCameraAndShowEntry(docent:)
                     or coordinator.dismissCameraAndShowPlayer(docent:)
                     or coordinator.navigateToEntryFromCamera(with:capturedImage)
```

## 주요 동작

- `AVCaptureSession` — 카메라 세션 초기화/시작/정지
- `AVCapturePhotoOutput` — 사진 촬영
- 촬영 후 더미 도슨트 or API 응답으로 Entry/Player 진입

## AI 작업 가이드

### 반드시 지킬 것
- Camera는 `present(fullScreen)` 방식 → 닫을 때 반드시 `dismiss(animated:)` 후 화면 이동
- `coordinator.dismissCameraAndShowEntry(docent:)` — dismiss + Entry 이동
- `coordinator.dismissCameraAndShowPlayer(docent:)` — dismiss + Player 이동
- `viewWillDisappear`에서 `captureSession.stopRunning()` 호출 (배터리 절약)

### 권한 처리
- `AVCaptureDevice.requestAccess(for: .video)` — 카메라 권한 요청
- 권한 거부 시 설정 이동 안내 Alert 표시

### 금지사항
- CameraViewController에서 직접 EntryViewController/PlayerViewController push 금지
- 백그라운드 스레드에서 UI 업데이트 금지 (AVCapture 콜백은 별도 큐)

## 관련 문서
- `../../Cooldinator/CLAUDE.md` — dismissCameraAndShowEntry, dismissCameraAndShowPlayer 라우트
- `../Entry/CLAUDE.md` — Entry 화면
