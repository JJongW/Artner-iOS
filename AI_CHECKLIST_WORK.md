# Work Checklist — 사이드바 스켈레톤 UX 개선

## A. 런타임/기능
- [ ] Xcode 빌드 성공 (에러/워닝 없음)
- [ ] 사이드바 열릴 때 스켈레톤이 올바른 위치에 표시됨
- [ ] 스켈레톤 컴포넌트들이 서로 겹치지 않음
- [ ] shimmer 애니메이션이 매끄럽게 반복됨
- [ ] 데이터 로드 완료 시 스켈레톤→컨텐츠 전환이 부드러움 (alpha fade)
- [ ] 사이드바 슬라이드인 애니메이션이 매끄러움 (내용 미리 노출 없음)
- [ ] 사이드바 닫기(슬라이드아웃) 정상 동작

## B. 아키텍처
- [ ] View 파일만 수정 — ViewModel/UseCase 변경 없음
- [ ] SidebarViewController.updateLoadingState(isLoading:isAISettingsLoading:) 시그니처 유지
- [ ] AppCoordinator.showSidebar() 변경 없음

## C. 코드 품질
- [ ] CAGradientLayer shimmer 패턴이 SkeletonView.swift 패턴과 일관성 있음
- [ ] layoutSubviews에서 shimmerLayer.frame 업데이트 구현
- [ ] alpha 기반 전환 (isHidden 최소화)
- [ ] [weak self] 메모리 관리

## D. UI/UX
- [ ] 스켈레톤 위치가 실제 컨텐츠 위치와 정확히 일치
- [ ] 로딩 중 shimmer가 부드럽게 반복
- [ ] 로딩 완료 후 alpha 0.3s fade-in
- [ ] 사이드바 슬라이드인 완료 후 컨텐츠 자연스럽게 등장

## E. 환경 설정
- [ ] settings.local.json hook 경로 수정 (/Users/sinjong-won → /Users/sjw)

## F. 문서
- [ ] AI_PLAN.md 작성 완료
- [ ] AI_CONTEXT.md 작성 완료

## G. 최종 Self-Check
- [ ] 기존 바인딩 인터페이스 유지
- [ ] 회귀 없음 (사이드바 닫기, 데이터 표시 등)
- [ ] AI_MANUAL.md 규칙 위반 없음
