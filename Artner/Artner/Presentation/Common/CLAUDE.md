# Presentation/Common — 공통 UI 컴포넌트

모든 피처에서 재사용하는 UI 컴포넌트 모음. 새 컴포넌트 추가 전 여기서 기존 것 확인 필수.

> Toast 상세 사용법: `README_Toast.md`

## 파일 구조

```
Common/
├── ToastManager.swift           # 전역 Toast 싱글톤 (showSuccess/showError/showLoading/showSaved)
├── ToastView.swift              # Toast UI 컴포넌트 (아이콘 + 텍스트 + 버튼)
├── CustomNavigationBar.swift    # 뒤로가기 버튼 포함 네비게이션 바
├── CustomNavigationHomeBar.swift # 홈용 네비게이션 바 (카메라/사이드바 버튼)
├── ArtnerPrimaryBar.swift       # 하단 탭 바 스타일 프라이머리 바
├── GradientProgressView.swift   # 그라디언트 프로그레스 바 (Player 재생 진행도)
├── SkeletonView.swift           # 스켈레톤 로딩 UI
└── VideoPlayerView.swift        # AI 비디오 플레이어 (런치 화면용)
```

## ToastManager API

```swift
// 성공 (체크마크 아이콘)
ToastManager.shared.showSuccess("저장되었습니다")

// 에러 (경고 아이콘)
ToastManager.shared.showError("네트워크 오류가 발생했습니다")

// 로딩 (스피너)
ToastManager.shared.showLoading("불러오는 중")
ToastManager.shared.hideCurrentToast()  // 로딩 종료 시

// 저장 완료 (저장 아이콘 + "보기" 버튼)
ToastManager.shared.showSaved("하이라이트가 저장되었습니다") {
    // "보기" 버튼 클릭 액션
}

// 텍스트만
ToastManager.shared.showSimple("재생됩니다")
```

## 디자인 토큰 (AppColor 참조)

| 항목 | 값 |
|------|----|
| Toast 배경 | `#222222` |
| Toast 텍스트 | `#FFFFFF` |
| 성공/저장 아이콘 | `#FF7C27` |
| 에러 아이콘 | `#FC5959` |
| 강조 색상 | `#FF7C27` |
| 폰트 Bold | `AppFont` 참조 |

## NavigationBar 사용 패턴

```swift
// 뒤로가기 포함 일반 화면
let navBar = CustomNavigationBar()
navBar.title = "화면 제목"
navBar.onBackTapped = { [weak self] in
    self?.coordinator?.popViewController(animated: true)
}

// 홈 화면 (카메라 + 사이드바)
let homeBar = CustomNavigationHomeBar()
homeBar.onCameraTapped = { [weak self] in self?.onCameraTapped?() }
homeBar.onSidebarTapped = { [weak self] in self?.onShowSidebar?() }
```

## AI 작업 가이드

### Toast 필수 사용 규칙
- 네트워크 요청 시작: `showLoading(...)` → 완료 시 `hideCurrentToast()` 후 결과 Toast
- 성공: `showSuccess(...)` 또는 `showSaved(...)`
- 실패: `showError(...)`
- Toast는 메인 스레드 자동 처리 — 별도 DispatchQueue.main 불필요

### 새 컴포넌트 추가 기준
- 2개 이상의 피처에서 재사용 → Common에 추가
- 단일 피처 전용 → 해당 피처의 `View/` 폴더에 추가

### 금지사항
- 특정 피처 로직(UseCase 호출, API 호출)을 Common 컴포넌트 내부에 넣지 않음
- ToastManager 외에 별도 alert/toast 방식 구현 금지

## 관련 문서
- `README_Toast.md` — Toast 전체 스펙 + 커스텀 Configuration 상세
