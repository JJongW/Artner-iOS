# Launch — 카카오 로그인 화면

앱 최초 진입 or 로그아웃 시 표시. 카카오 로그인 처리 후 Home으로 이동.

## 파일 구조

```
Launch/
├── View/
│   ├── LaunchView.swift             # 로그인 버튼 + 배경 레이아웃
│   └── GradientBackgroundView.swift # 그라디언트 배경 뷰
├── ViewController/
│   └── LaunchViewController.swift  # 카카오 로그인 트리거, 결과 처리
└── ViewModel/
    └── LaunchViewModel.swift        # 카카오 로그인 UseCase 호출 + 상태 관리
```

## 데이터 흐름

```
LaunchView (로그인 버튼 탭)
  ↓
LaunchViewController → viewModel.login()
  ↓
LaunchViewModel → KakaoLoginUseCase.execute()
  ↓
KakaoLoginUseCaseImpl → AuthRepository.kakaoLogin()
  ↓
AuthRepositoryImpl → APIService → POST /auth/kakao
  ↓ 성공
LaunchViewModel → loginSuccess (Publisher)
  ↓
LaunchViewController → coordinator.showMainScreen()
```

## UseCase / Repository / API 맵

| 항목 | 값 |
|------|----|
| UseCase | `KakaoLoginUseCase` |
| Repository | `AuthRepository` |
| API | POST `/auth/kakao` (KakaoLoginDTO) |
| DIContainer | `makeLaunchViewModel()` |

## 주요 컴포넌트

- `LaunchViewModel.login()` — 카카오 SDK 토큰 획득 → 서버 인증 → Token 저장
- `KeychainTokenManager` — accessToken/refreshToken Keychain 저장
- `LaunchCoordinating.showMainScreen()` — 로그인 성공 후 Home 이동

## AI 작업 가이드

### 반드시 지킬 것
- 로그인 성공 후 화면 이동은 반드시 `coordinator.showMainScreen()` 호출
- Token 저장은 `KeychainTokenManager` 사용 (UserDefaults 금지)
- 로그인 중 로딩 표시: `ToastManager.shared.showLoading("로그인 중")`
- 실패 시: `ToastManager.shared.showError("로그인 실패")`

### 금지사항
- LaunchViewController에서 직접 HomeViewController 생성 금지
- 카카오 SDK를 ViewController에서 직접 호출 금지 (ViewModel 경유)

## 관련 문서
- `../Common/CLAUDE.md` — Toast 사용
- `../../Cooldinator/CLAUDE.md` — showMainScreen 라우트
- `../../Data/Storage/` — KeychainTokenManager
