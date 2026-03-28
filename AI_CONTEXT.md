# Context Notes — 사이드바 스켈레톤 UX 개선

## 1. 아키텍처 컨텍스트

### 적용 규칙 (AI_MANUAL.md 기반)
- Presentation 레이어 내부 수정 — Clean Architecture 위반 없음
- View 파일만 수정 (SidebarView, SideMenuContainerView)
- ViewModel/UseCase 변경 없음

### 레이어 의존 방향
- 이 작업이 건드리는 레이어: Presentation (View)
- 의존 방향 위반 없음

## 2. 기존 코드 분석

### 관련 파일 요약
| 파일 | 역할 | 핵심 패턴 |
|------|------|----------|
| SidebarView.swift | 사이드바 전체 UI | UIScrollView + contentView + SnapKit 레이아웃 |
| SideMenuContainerView.swift | 슬라이드 컨테이너 | trailing constraint 기반 슬라이드인/아웃 |
| SkeletonView.swift | 공통 스켈레톤 | CAGradientLayer shimmer 패턴 |
| SidebarViewController.swift | 바인딩 담당 | $isLoading, $isAISettingsLoading 구독 |

### 발견된 버그들
1. **aiSettingsSkeletonViews 겹침**: `aiSettingsStack.addSubview(skeletonView)` 로 추가 후 SnapKit 제약조건 없음 → 모두 (0,0) 좌표에 겹쳐서 표시
2. **statSkeletonViews 불일치**: 고정 offset (14 + index*80)이 실제 fillEqually 분배와 미묘하게 다름
3. **shimmer 없음**: 단순 backgroundColor만 있고 CAGradientLayer 애니메이션 없음
4. **isHidden 토글**: 뚝끊기는 전환 — alpha 기반으로 개선 필요
5. **사이드바 조기 노출**: present() 시 menuView가 alpha=1인 채로 렌더링된 후 슬라이드인

### 기존 shimmer 패턴 (SkeletonView.swift에서 참조)
```swift
let shimmerLayer = CAGradientLayer()
shimmerLayer.colors = [UIColor.clear.cgColor, AppColor.textPoint.withAlphaComponent(0.3).cgColor, UIColor.clear.cgColor]
shimmerLayer.locations = [0.0, 0.5, 1.0]
shimmerLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
shimmerLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
let shimmerAnimation = CABasicAnimation(keyPath: "transform.translation.x")
shimmerAnimation.fromValue = -bar.frame.width
shimmerAnimation.toValue = bar.frame.width
shimmerAnimation.duration = 1.5
shimmerAnimation.repeatCount = .infinity
```

### updateLoadingState 현재 인터페이스 (SidebarViewController에서 호출)
```swift
// SidebarViewController.bindLoadingStates()에서:
self?.sidebarView.updateLoadingState(isLoading: isLoading, isAISettingsLoading: ...)
```
→ 이 인터페이스는 변경 금지

## 3. 의존성 맵

### 수정할 파일
- `SidebarView.swift`: 스켈레톤 구조 개선 (overlay 방식), shimmer 추가, alpha 전환
- `SideMenuContainerView.swift`: present()에서 menuView.alpha 조정
- `.claude/settings.local.json`: hook 경로 수정

### 영향 받는 기존 파일
- `SidebarViewController.swift`: `updateLoadingState(isLoading:isAISettingsLoading:)` 호출 — 시그니처 유지 필수
- `AppCoordinator.swift`: `showSidebar(from:)` — 변경 없음

## 4. UI 컨텍스트

### 스켈레톤 개선 방향
- `nameSkeletonView` (이름): 현재 위치 맞음, shimmer만 추가
- `statContainerView` 영역: overlay UIView 1개로 단순화 + shimmer
- `aiDocentContainer` 내 설정값 영역: overlay UIView 1개로 단순화 + shimmer

### 색상 팔레트
- 스켈레톤 배경: `UIColor.white.withAlphaComponent(0.1)` (기존)
- shimmer highlight: `UIColor.white.withAlphaComponent(0.25)`

### 전환 타이밍
- 슬라이드인 duration: 0.3s (SideMenuContainerView 기존 값)
- 로딩 완료 fade: 0.3s
- menuView alpha fade: 슬라이드인과 동시에 (0.3s)

## 5. 주의사항
- SidebarViewController.bindViewModel()에서 `statStackView.arrangedSubviews[i]`를 isHidden으로 접근하므로, overlay 방식으로 바꿀 때 isHidden 제거하고 alpha 사용해야 함
- layoutSubviews에서 shimmerLayer.frame 업데이트 필수 (CALayer는 auto layout 추적 안 함)
- CAAnimation은 앱이 백그라운드 갔다 돌아올 때 멈출 수 있으므로 UIApplication.willEnterForeground에서 재시작 고려 (단, 이번 작업 범위 밖)
