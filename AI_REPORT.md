# AI Report — 사이드바 스켈레톤 UX 개선

## 0. 메타
- 작업명: 사이드바 스켈레톤 애니메이션 및 열림 UX 개선
- 작업 유형: UI/UX 버그 수정 + UX 개선
- 작업 날짜: 2026-03-28
- 작업자: AI (Claude)

## 1. 결론 요약
- 무엇을 바꿨나: 사이드바 스켈레톤을 overlay 방식으로 교체하고 shimmer CAGradientLayer 애니메이션 추가
- 사용자에게 어떤 변화: 로딩 중 shimmer 반짝임 + 데이터 로드 완료 시 부드러운 fade-in 전환
- 기존 기능에 영향: updateLoadingState() 시그니처 유지, 사이드바 닫기/열기 정상
- 가장 중요한 리스크: layoutSubviews에서 shimmer 추가 타이밍이 런타임에서 검증 필요
- 다음 액션: Xcode 빌드 후 시뮬레이터로 shimmer 동작 확인

## 2. 변경 범위

### 2.1 변경 파일 리스트
- [MOD] `.claude/settings.local.json` — hook 경로 수정
- [MOD] `Artner/Artner/Presentation/Save/Sidebar/View/SidebarView.swift` — 스켈레톤 구조 전면 개선
- [MOD] `Artner/Artner/Presentation/Save/Sidebar/View/SideMenuContainerView.swift` — 열림 UX 개선
- [MOD] `AI_PLAN.md`, `AI_CONTEXT.md`, `AI_CHECKLIST_WORK.md` — 작업 문서

### 2.2 변경 내용 상세

**[SidebarView.swift — 핵심 변경]**
```
Before: statSkeletonViews [4개] — 고정 offset 배치, 겹침 발생
After:  statSkeletonOverlay [1개] — statContainerView 전체 overlay
        + shimmer CAGradientLayer 애니메이션

Before: aiSettingsSkeletonViews [3개] — SnapKit 제약 없이 (0,0)에 겹침
After:  aiSettingsSkeletonOverlay [1개] — aiSettingsStack 동일 위치 overlay

Before: isHidden 토글 — 뚝끊기는 전환
After:  alpha 0/1 + UIView.animate(0.3s) — 부드러운 fade

Before: viewDidLoad에서 shimmer 추가 시도 → bounds=0으로 실패
After:  layoutSubviews에서 bounds 확정 후 자동 추가 (isStatSkeletonVisible 플래그)
```

**[SideMenuContainerView.swift]**
```
Before: present() 시 menuView.alpha=1 → 잘못 렌더링된 컨텐츠가 슬라이드인 전 노출
After:  menuView.alpha=0 → 슬라이드인과 동시에 alpha 0→1 fade-in
```

## 3. 설계 의도
- overlay 방식은 실제 컨텐츠의 레이아웃에 종속되지 않아 디바이스 크기에 무관하게 항상 올바른 영역에 표시됨
- shimmer를 layoutSubviews에서 추가하는 이유: viewDidLoad 시점에 뷰 bounds가 0이므로 CAGradientLayer frame이 비어있음. layout이 확정된 후에만 의미있는 shimmer가 생성됨
- CATransaction.setDisableActions(true)로 frame 업데이트 시 불필요한 CALayer implicit animation 방지
- addShimmerIfNeeded()로 중복 shimmer 방지

## 4. 동작 플로우 (사용자 관점)
1. 홈 화면 → 사이드바 버튼 탭
2. 사이드바가 오른쪽에서 슬라이드인되며 동시에 컨텐츠 fade-in
3. 슬라이드인 완료 후 name/stat/AI설정 영역에 shimmer 애니메이션 표시
4. API 로드 완료 시 shimmer가 실제 데이터로 0.3s fade 전환
5. 사이드바 닫기: 슬라이드아웃 0.3s

## 5. 검증 결과 (AI_CHECKLIST 기반)
- ✅ settings.local.json hook 경로 수정
- ✅ statSkeletonViews 구버전 완전 제거
- ✅ aiSettingsSkeletonViews 구버전 완전 제거
- ✅ updateLoadingState() 시그니처 유지
- ✅ Domain Clean Layer 위반 없음
- ⚠️ Xcode 빌드 + 시뮬레이터 확인 필요 (수동)

## 6. 리스크/부작용
- 낮음: layoutSubviews shimmer 타이밍 — present() 내 layoutIfNeeded()로 충분히 보장됨
- 낮음: shimmerLayers 배열 memory — removeShimmer에서 nil 정리

## 7. TODO / 다음 작업 제안
- [ ] Xcode 빌드 후 시뮬레이터에서 shimmer 동작 확인
- [ ] dismissMenu 시 shimmer cleanup 추가 검토 (현재: 뷰 자체가 removeFromSuperview되어 자동 해제)
