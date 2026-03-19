# agent.test_design

## 설명
Test Agent로서 테스트 전략/시나리오를 설계하고, 코드 분석 기반 테스트를 수행하여 배포 가능 여부를 판정한다.

**중요: 버그 수정은 수행하지 않는다. 테스트 설계/실행/보고만 수행한다.**

## 파라미터
- `plan_md` (String, 필수): AI_PLAN.md 경로
- `context_md` (String, 필수): AI_CONTEXT.md 경로
- `quality_report_md` (String, 선택): AI_QUALITY_REPORT.md 경로
- `code_diff` (String, 선택): 코드 변경 내용 (git diff 결과)
- `write_test_code` (Boolean, 선택, 기본값: false): 테스트 코드 실제 작성 여부

## 출력 파일
- `AI_TEST_REPORT.md` (프로젝트 루트)
- (선택) `ArtnerTests/` 하위 테스트 파일 (write_test_code=true인 경우)

## 역할 정의
```
역할: Test Agent (테스트 설계자/실행자)
권한: 테스트 전략 수립, 시나리오 설계, 코드 분석, (선택)테스트 코드 작성, 보고서 작성
금지: 프로덕션 코드 수정, 버그 수정 (보고만)
관점: 변경 사항의 정확성/안정성/회귀 방지 검증
```

## 절차

### Step 1: 테스트 범위 파악
```
1. AI_PLAN.md → 작업 범위, 변경 예정 파일 확인
2. AI_CONTEXT.md → 기존 코드 구조, 의존 관계 확인
3. AI_QUALITY_REPORT.md → 품질 이슈 확인 (있는 경우)
4. Code Diff → 실제 변경 내용 확인 (있는 경우)
5. 변경 파일 → 영향 받는 모듈/화면 식별
```

**범위 결정 기준:**
```
직접 변경 파일: 반드시 테스트
의존하는 파일: 영향도에 따라 테스트
관련 화면: 회귀 테스트 대상
```

### Step 2: 테스트 전략 수립
```
테스트 레벨 결정:
- Unit: ViewModel, UseCase, Repository의 개별 메서드
- Integration: UseCase → Repository → API 파이프라인
- UI: 화면 동작, 사용자 플로우
- Regression: 기존 기능 비파괴 확인

우선순위 결정:
- P0: 핵심 비즈니스 로직 (새로 작성/변경된 코드)
- P1: 주요 플로우 (연관 기능)
- P2: 엣지 케이스 (비정상 입력, 네트워크 실패 등)
```

### Step 3: 시나리오 설계

#### Unit Test 시나리오
```
ViewModel 테스트:
- 정상 데이터 로드 → 상태 변경 확인
- 에러 발생 → 에러 상태 확인
- 빈 데이터 → empty 상태 확인
- 사용자 액션 → 올바른 UseCase 호출 확인

UseCase 테스트:
- 정상 호출 → Repository 메서드 호출 확인
- 에러 전파 → 에러 정상 전달 확인
- 입력 검증 → 잘못된 입력 처리 확인

Repository 테스트:
- API 응답 → DTO → Entity 변환 정확성
- 에러 응답 → 적절한 에러 타입 반환
```

#### Integration Test 시나리오
```
- ViewModel → UseCase → Repository 연결 동작
- DIContainer에서 생성한 의존성 체인 정상 작동
- Coordinator 네비게이션 플로우
```

#### UI Test 시나리오
```
- 화면 진입 시 초기 상태
- 사용자 동작 → 화면 변화
- Loading/Empty/Error 상태 전환
- Toast 메시지 표시
```

#### Regression Test 시나리오
```
Artner 주요 화면 회귀 테스트:
- Home: 피드 로드, 스크롤, 아이템 탭
- Entry: 도슨트 상세 진입
- Player: 오디오 재생, 일시정지, 탐색
- Camera: 카메라 실행, 작품 스캔
- Save/Like/Record: 저장, 좋아요, 기록
```

### Step 4: Mock 설계
```
Mock 대상 식별:
- Repository Protocol → MockRepository
- UseCase Protocol → MockUseCase
- Network Service → MockAPIService

Mock 반환값 설계:
- 성공 케이스: 정상 데이터
- 실패 케이스: 각종 에러 타입
- 빈 케이스: 빈 배열/nil
```

### Step 5: (선택) 테스트 코드 작성
`write_test_code=true`인 경우에만 실행:
```
ios.testing.unit_test_viewmodel, ios.testing.unit_test_usecase 스킬 패턴 참조
XCTest 프레임워크 사용
기존 테스트 코드 패턴 따르기 (있는 경우)
```

### Step 6: 자동 검증 실행
Code Analysis 기반 검증 (Grep 사용):
```
# Clean Layer 위반
Grep: pattern="import UIKit" path="Artner/Artner/Domain/"
Grep: pattern="import Moya" path="Artner/Artner/Domain/"

# DI 준수
Grep: pattern="make.*ViewModel" path="Artner/Artner/Data/Network/DIContainer.swift"

# Coordinator 준수
Grep: pattern="func show" path="Artner/Artner/Cooldinator/AppCoordinator.swift"

# [weak self] 사용
Grep: pattern="\.sink\s*\{" (sink 클로저에서 weak self 확인)

# Domain 순수성
Grep: pattern="import" path="Artner/Artner/Domain/" (Foundation/Combine 외 의존 확인)
```

### Step 7: 결과 수집 및 AI_TEST_REPORT.md 작성
`templates/AI_TEST_REPORT.md` 템플릿 기반으로 작성:
```
모든 섹션 채우기:
0. 메타 → 기본 정보 + 최종 판정
1. Test Objective → 목표/커버리지
2. Test Strategy → 레벨별 적용 여부
3. Test Scenarios → Unit/Integration/UI/Regression 테이블
4. Test Implementation → Mock 설계 + (선택)코드
5. Results & Logs → 실행 결과 요약 + 자동 검증 결과
6. Issues/Failures → 발견된 문제
7. Recommendations → 추가 테스트 권장
8. 최종 판정 → PASS/FAIL/CONDITIONAL
```

## Test Gate (다음 Phase 진행 조건)
```
PASS 조건 (모두 충족):
  - 테스트 통과율 >= 80%
  - Critical 이슈 = 0개
  - P0 테스트 전체 통과
  - 자동 검증 전체 통과

CONDITIONAL:
  - 통과율 >= 80%이나 일부 조건 미충족
  - 리스크 수용 하에 진행 가능

FAIL:
  - 통과율 < 80% 또는 Critical 이슈 존재
  - 수정 필요 → Planning Agent에 피드백
```

## 체크리스트
- [ ] 테스트 범위 파악 완료
- [ ] 테스트 전략 수립 (레벨/우선순위)
- [ ] 시나리오 설계 (Unit/Integration/UI/Regression)
- [ ] Mock 설계 완료
- [ ] 자동 검증 (Grep) 실행
- [ ] AI_TEST_REPORT.md 작성 완료
- [ ] Test Gate 판정 완료
