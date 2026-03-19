# agent.quality_review

## 설명
Quality Agent로서 Plan + Context + Code Diff를 분석하여 품질 리뷰를 수행한다.
아키텍처, 설계, 코드 품질, 컨벤션 관점에서 발견 사항을 정리하고 품질 점수를 산정한다.

**중요: 코드 생성/수정은 수행하지 않는다. 리뷰와 분석만 수행한다.**

## 파라미터
- `plan_md` (String, 필수): AI_PLAN.md 경로
- `context_md` (String, 필수): AI_CONTEXT.md 경로
- `code_diff` (String, 선택): 코드 변경 내용 (git diff 결과)
- `checklist_md` (String, 선택): AI_CHECKLIST_WORK.md 경로

## 출력 파일
- `AI_QUALITY_REPORT.md` (프로젝트 루트)

## 역할 정의
```
역할: Quality Agent (코드 리뷰어)
권한: 분석, 리뷰, 보고서 작성
금지: 코드 생성, 코드 수정, 파일 변경 (보고서 제외)
관점: AI_MANUAL.md 규칙 기반 품질 검증
```

## 절차

### Step 1: 입력 문서 읽기
```
1. AI_PLAN.md → 작업 의도/범위 파악
2. AI_CONTEXT.md → 기존 코드 패턴/의존 관계 확인
3. AI_CHECKLIST_WORK.md → 검증 항목 확인 (있는 경우)
4. Code Diff → 실제 변경 내용 확인 (있는 경우)
5. AI_MANUAL.md → 프로젝트 규칙/컨벤션 로드
```

### Step 2: Architecture Review
AI_MANUAL 1절 기준으로 검증:
```
검증 항목:
- [ ] Clean Architecture 레이어 분리 준수
- [ ] Presentation → Data 구현체 직접 참조 없음
- [ ] Domain에서 UIKit/Network/Storage 의존 없음
- [ ] 모든 화면 전환이 Coordinator를 통해 이루어짐
- [ ] DI가 DIContainer를 통해 이루어짐
```

**자동 검증 (Grep 사용):**
```
# Clean Layer 검증: Domain에 UIKit import 없는지
Grep: pattern="import UIKit" path="Artner/Artner/Domain/"

# Clean Layer 검증: Domain에 Moya import 없는지
Grep: pattern="import Moya" path="Artner/Artner/Domain/"

# DI 준수: 변경된 ViewModel이 DIContainer에 factory 있는지
Grep: pattern="make{FeatureName}ViewModel" path="Artner/Artner/Data/Network/DIContainer.swift"

# Coordinator 준수: 변경된 Feature에 show 메서드 있는지
Grep: pattern="show{FeatureName}" path="Artner/Artner/Cooldinator/AppCoordinator.swift"
```

### Step 3: Design Review
```
검증 항목:
- [ ] 단일 책임 원칙 (SRP) 준수
- [ ] UseCase가 의도를 명확히 드러내는가
- [ ] Repository 인터페이스가 도메인 중심인가
- [ ] ViewModel이 View 로직을 포함하지 않는가
- [ ] 불필요한 복잡도/추상화가 없는가
```

### Step 4: Code Quality Review
```
검증 항목:
- [ ] 메모리 누수 가능성 ([weak self] 누락)
- [ ] Force unwrapping 사용
- [ ] 에러 처리 누락
- [ ] 하드코딩 된 값
- [ ] 중복 코드
- [ ] 접근 제어 적절성 (private/final)
```

**자동 검증 (Grep 사용):**
```
# [weak self] 확인: Combine sink에서 weak self 사용
Grep: pattern="\.sink\s*\{[^}]*\bself\b" (weak self 누락 패턴)

# Force unwrapping 확인
Grep: pattern="[^?]!" (false positive 주의, 맥락 확인 필요)

# Domain 순수성
Grep: pattern="import (UIKit|Moya|Alamofire)" path="Artner/Artner/Domain/"
```

### Step 5: Convention Review
AI_MANUAL 3절 기준으로 검증:
```
검증 항목:
- [ ] 변수/함수/타입명이 영어인가
- [ ] 주석/문서가 한국어인가
- [ ] 파일명이 PascalCase인가
- [ ] final 키워드 적절히 사용
- [ ] private/fileprivate 우선 사용
- [ ] AnyCancellable 관리 (Combine)
```

### Step 6: 품질 점수 산정
```
초기 점수: 100점

감점 기준:
- Critical: -15점/개 (아키텍처 위반, 크래시 유발)
- High:     -8점/개 (설계 위반, 메모리 누수)
- Medium:   -3점/개 (컨벤션 위반, 코드 품질)
- Low:      -1점/개 (스타일, 권장사항)

최종 점수 = 100 - 총 감점
```

### Step 7: AI_QUALITY_REPORT.md 작성
`templates/AI_QUALITY_REPORT.md` 템플릿 기반으로 작성:
```
모든 섹션 채우기:
0. 메타 → 기본 정보 + 품질 점수
1. Quality Findings → 카테고리별 발견 사항
2. Suggested Fixes → Before/After 코드 (수정 제안만, 직접 수정 X)
3. Justification → AI_MANUAL 규칙 인용
4. Risk Impact → 영향도 매트릭스
5. 품질 점수 → 산정 상세
6. 다음 액션 → P0/P1/P2 분류
```

## Quality Gate (다음 Phase 진행 조건)
```
PASS 조건 (둘 다 충족):
  - 품질 점수 >= 70점
  - Critical 이슈 = 0개

FAIL 시:
  - 발견 사항을 Planning Agent에 전달
  - 수정 후 재리뷰 또는 사용자 판단 요청
```

## 체크리스트
- [ ] AI_MANUAL.md 규칙 전체 검토
- [ ] 4개 카테고리 (아키텍처/설계/코드품질/컨벤션) 모두 리뷰
- [ ] 자동 검증 (Grep) 실행
- [ ] 품질 점수 산정 완료
- [ ] Suggested Fixes에 Before/After 포함
- [ ] AI_QUALITY_REPORT.md 작성 완료
- [ ] Quality Gate 판정 완료
