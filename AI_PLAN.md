# Plan Document — 사이드바 스켈레톤 UX 개선

## 1. 작업 개요
- 작업명: 사이드바 스켈레톤 애니메이션 및 열림 UX 개선
- 작성일: 2026-03-28
- 작업자: AI (Claude)

## 2. 목표
- 이 작업을 통해 해결할 문제:
  1. 스켈레톤 컴포넌트 영역 겹침 (aiSettingsSkeletonViews 제약조건 없음, statSkeletonViews 오프셋 불일치)
  2. 스켈레톤 shimmer 애니메이션 없음 (단순 배경색 박스)
  3. 로딩 완료 전환이 갑작스러움 (isHidden 토글)
  4. 사이드바 슬라이드인 전 내용이 잘못된 레이아웃으로 미리 노출
  5. settings.local.json hook 경로 오류 (/Users/sinjong-won → /Users/sjw)
- 성공 기준:
  - 스켈레톤 뷰들이 실제 컨텐츠 위치와 정확히 일치
  - shimmer 애니메이션이 부드럽게 반복
  - 로딩 완료 시 alpha 기반 fade-in 전환
  - 사이드바 슬라이드인이 완료된 후 컨텐츠가 자연스럽게 표시

## 3. 범위 (Scope)
### 포함
- `Artner/Artner/Presentation/Save/Sidebar/View/SidebarView.swift` — 스켈레톤 레이아웃 및 애니메이션 개선
- `Artner/Artner/Presentation/Save/Sidebar/View/SideMenuContainerView.swift` — 사이드바 열림 UX 개선
- `.claude/settings.local.json` — hook 경로 수정

### 제외
- SidebarViewModel, SidebarViewController 로직 변경 없음
- 실제 데이터 로딩 플로우 변경 없음
- 다른 화면 영향 없음

## 4. 요구사항
- 기능 요구: shimmer 애니메이션, 겹침 제거, 부드러운 전환
- 제약 조건: Clean Architecture 준수, 기존 바인딩 인터페이스 유지
- 우선순위: P0 (UX 버그 수준)

## 5. 의존 관계
- 연관 파일:
  - `Artner/Artner/Presentation/Save/Sidebar/View/SidebarView.swift`
  - `Artner/Artner/Presentation/Save/Sidebar/View/SideMenuContainerView.swift`
  - `.claude/settings.local.json`
- 연관 스킬: 없음 (UI 수정만)

## 6. 구현 계획

### Step 1: settings.local.json hook 경로 수정
- `/Users/sinjong-won/` → `/Users/sjw/` 경로 교정

### Step 2: SidebarView.swift — 스켈레톤 구조 개선

#### 2-1. 기존 개별 스켈레톤 뷰를 overlay 방식으로 교체
- `statSkeletonViews [4개]` → `statSkeletonOverlay: UIView` (statContainerView 전체 덮는 단일 overlay)
- `aiSettingsSkeletonViews [3개]` → `aiSettingsSkeletonOverlay: UIView` (aiSettingsStack 영역 덮는 overlay)
- 각 overlay 내에 shimmer CAGradientLayer 애니메이션 추가

#### 2-2. shimmer 애니메이션 추가
- CAGradientLayer 기반 shimmer (SkeletonView.swift의 패턴 참조)
- 좌 → 우 방향 반복 애니메이션

#### 2-3. updateLoadingState 개선
- isHidden 토글 → alpha 기반 fade (0.3s)
- 스켈레톤 사라질 때 alpha 0 → 컨텐츠 alpha 0→1

### Step 3: SideMenuContainerView.swift — 열림 UX 개선
- present() 시 menuView.alpha = 0으로 시작
- 슬라이드인 시작 시 동시에 alpha 0 → 1 fade-in

## 7. 리스크/대책
- 리스크 1: overlay 방식 전환 시 SidebarViewController의 statStackView 바인딩과 충돌 가능
  → 대책: statStackView.alpha 0/1 사용 (isHidden 사용 금지)
- 리스크 2: CALayer 애니메이션이 layoutSubviews에서 업데이트 필요
  → 대책: layoutSubviews override에서 shimmer frame 업데이트

## 8. 다음 단계
1. Step 1: settings.local.json 수정
2. Step 2: SidebarView.swift 수정
3. Step 3: SideMenuContainerView.swift 수정
