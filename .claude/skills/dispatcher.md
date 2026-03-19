# Intent-to-Skill Dispatcher

사용자 지시를 분석하여 적절한 스킬을 선택하는 분류 로직.

## 분류 파이프라인

```
1. 키워드 매칭 (한국어/영어 동의어 맵)
2. 의미 분류 (동사 기반: 생성/추가/수정/삭제/진단/최적화)
3. 복합 의도 → multi-skill chaining
4. 폴백 → 일반 어시스트 (스킬 미적용)
```

## 키워드 → 스킬 매핑

| 키워드 (한국어) | 키워드 (영어) | 스킬 |
|---|---|---|
| 화면, 스크린, 뷰컨, 새 VC | screen, ViewController, new VC | `ios.uikit.create_screen` |
| 셀, 테이블뷰셀, 컬렉션뷰셀 | Cell, TableViewCell, CollectionViewCell | `ios.uikit.create_cell` |
| 네비게이션, 이동, 라우팅, 푸시, 프레젠트 | navigation, route, push, present, coordinator | `ios.navigation.add_route` |
| 코디네이팅 프로토콜, Coordinating | Coordinating protocol, coordinator protocol | `ios.navigation.create_protocol` |
| API, 엔드포인트, 요청 추가 | endpoint, API endpoint, add request | `ios.networking.add_endpoint` |
| DTO, 모델, 응답 모델, Codable | DTO, response model, Codable struct | `ios.networking.create_dto` |
| 전체 연동, 파이프라인, API부터 전부 | full pipeline, end-to-end API, API to ViewModel | `ios.networking.add_full_pipeline` |
| 새 기능, 피처, 신규 화면 전체, 스캐폴딩 | new feature, feature scaffolding, create feature | `ios.architecture.create_feature` |
| 유즈케이스, UseCase | UseCase, use case, business logic | `ios.architecture.create_usecase` |
| 레포지토리, Repository | Repository, data access | `ios.architecture.create_repository` |
| 저장, 키체인, UserDefaults, 캐시 | storage, Keychain, UserDefaults, cache, persist | `ios.persistence.add_storage` |
| 바인딩, 구독, Combine 연결 | binding, subscribe, Combine, reactive | `ios.combine.create_binding` |
| 테스트 인프라, Mock 세팅, XCTest | test infrastructure, Mock setup, XCTest setup | `ios.testing.setup_infrastructure` |
| ViewModel 테스트, 유닛 테스트 | ViewModel test, unit test ViewModel | `ios.testing.unit_test_viewmodel` |
| UseCase 테스트 | UseCase test, unit test UseCase | `ios.testing.unit_test_usecase` |
| 버그, 에러, 크래시, 수정, fix | bug, error, crash, fix, debug | `ios.bugfix.diagnose_fix` |
| 리팩토링, 개선, 정리, 구조 변경 | refactor, improve, clean up, restructure | `ios.refactor.extract_pattern` |
| 메모리 누수, 릭, retain cycle, Instruments | memory leak, retain cycle, Instruments | `ios.performance.diagnose_memory` |
| 렌더링, 스크롤, 프레임 드롭, 성능, 최적화 | rendering, scroll, frame drop, performance, optimize | `ios.performance.optimize_rendering` |
| 문서, 문서화, README, API 문서 | docs, document, README, API docs | `docs.generate_api_docs` |
| CI/CD, 워크플로우, 빌드 자동화, Actions | CI/CD, workflow, build automation, GitHub Actions | `ci_cd.setup_github_actions` |

### Workflow 스킬

| 키워드 (한국어) | 키워드 (영어) | 스킬 |
|---|---|---|
| 작업 시작, 전체 플로우, 처음부터 끝까지 | full workflow, orchestrate, start task | `workflow.orchestrate` |
| 계획, 플랜, 작업 계획 | plan, planning, task plan | `workflow.plan` |
| PDF 내보내기, PDF 출력, 변환 | export PDF, convert to PDF | `workflow.export_pdf` |
| 컨텍스트, 맥락 분석, 컨텍스트 노트 | context notes, context analysis | `workflow.context_notes` |
| 체크리스트, 검증 목록, 확인 항목 | checklist, verification list | `workflow.checklist_generate` |
| 셀프체크, 자가검증, 검수, 점검 | self-check, validate, verify code | `workflow.self_check` |
| 코드 실행, 구현, 코딩 시작 | execute task, implement, code it | `workflow.execute_task` |
| 리포트, 보고서, 결과 보고, 요약 | report, summary, final report | `workflow.report` |

### Agent 스킬

| 키워드 (한국어) | 키워드 (영어) | 스킬 |
|---|---|---|
| 품질 리뷰, 코드 리뷰, 품질 검증, 아키텍처 리뷰 | quality review, code review, quality check, architecture review | `agent.quality_review` |
| 테스트 설계, 테스트 전략, 테스트 시나리오, 테스트 플랜 | test design, test strategy, test scenario, test plan | `agent.test_design` |
| 에이전트 팀, Agent Team, 전체 에이전트, 팀 워크플로우 | agent team, full agent, team workflow, agent orchestrate | `agent.team_orchestrate` |

## 동사 기반 의미 분류

| 동사 패턴 | 의도 | 대표 스킬 카테고리 |
|---|---|---|
| 만들어, 생성, create, add, new | 생성 | ios.uikit, ios.architecture |
| 추가해, 넣어, append, insert | 추가 | ios.networking, ios.navigation |
| 수정해, 고쳐, fix, patch, update | 수정 | ios.bugfix |
| 리팩토링, 개선, refactor, improve | 개선 | ios.refactor |
| 진단, 분석, diagnose, analyze, profile | 진단 | ios.performance, ios.bugfix |
| 최적화, optimize, improve performance | 최적화 | ios.performance |
| 테스트, test, verify | 테스트 | ios.testing |
| 문서화, document | 문서 | docs |
| 세팅, setup, configure | 설정 | ci_cd, ios.testing |
| 작업, 기능, 플로우 | task, feature, workflow | workflow |

## 복합 의도 처리

여러 스킬이 필요한 경우, 의존 순서대로 체이닝:

### 패턴 1: 새 Feature 전체
```
"새 검색 기능 전체 만들어줘"
→ ios.architecture.create_feature (내부에서 자동 체이닝)
  ├── ios.uikit.create_screen
  ├── ios.navigation.add_route
  ├── ios.navigation.create_protocol
  ├── ios.networking.add_full_pipeline
  └── ios.combine.create_binding
```

### 패턴 2: API 연동 + 바인딩
```
"API 추가하고 ViewModel 바인딩까지"
→ ios.networking.add_full_pipeline
→ ios.combine.create_binding
```

### 패턴 3: 테스트 작성
```
"HomeViewModel 테스트 전체"
→ ios.testing.setup_infrastructure (인프라 미존재 시)
→ ios.testing.unit_test_viewmodel
```

### 패턴 4: 화면 + 네비게이션
```
"새 설정 화면 만들고 사이드바에서 이동 가능하게"
→ ios.uikit.create_screen
→ ios.navigation.create_protocol
→ ios.navigation.add_route
```

### 패턴 5: 전체 워크플로우 (Orchestration)
```
"검색 기능 작업 시작해줘" 또는 "Search feature 처음부터 끝까지"
→ workflow.orchestrate
  ├── workflow.plan → AI_PLAN.md
  ├── workflow.context_notes → AI_CONTEXT.md
  ├── workflow.checklist_generate → AI_CHECKLIST_WORK.md
  ├── workflow.self_check (사전)
  ├── workflow.execute_task (ios.* 스킬 체이닝)
  ├── workflow.self_check (사후)
  └── workflow.report → AI_REPORT.md
```

### 패턴 6: Agent Team 전체 플로우
```
"검색 기능 Agent Team으로 만들어줘" 또는 "에이전트 팀 전체 돌려줘"
→ agent.team_orchestrate
  Phase 1: Planning Agent
    ├── workflow.plan → AI_PLAN.md
    ├── workflow.context_notes → AI_CONTEXT.md
    ├── workflow.checklist_generate → AI_CHECKLIST_WORK.md
    ├── workflow.self_check (사전/사후)
    └── workflow.execute_task (ios.* 스킬 체이닝)
  Phase 2: Quality Agent
    └── agent.quality_review → AI_QUALITY_REPORT.md
  Phase 3: Test Agent
    └── agent.test_design → AI_TEST_REPORT.md
  Phase 4: Integration
    └── AI_REPORT_INTEGRATED.md (최종 배포 판정)
```

## Agent Team vs Workflow 판별

| 사용자 표현 | 판별 | 선택 스킬 |
|---|---|---|
| "검색 기능 작업 시작해줘" | 단순 파이프라인 | `workflow.orchestrate` |
| "검색 기능 에이전트 팀으로" | 다중 에이전트 | `agent.team_orchestrate` |
| "품질 리뷰만 해줘" | 품질 리뷰 단독 | `agent.quality_review` |
| "테스트 설계만 해줘" | 테스트 단독 | `agent.test_design` |
| "전체 에이전트 돌려줘" | 다중 에이전트 | `agent.team_orchestrate` |

**핵심 판별 규칙:**
- "에이전트", "Agent Team", "팀", "품질 리뷰", "테스트 설계" → `agent.*` 스킬
- "작업 시작", "플로우", "처음부터" (에이전트 언급 없음) → `workflow.orchestrate`
- 명시적으로 "품질"만 요청 → `agent.quality_review` 단독
- 명시적으로 "테스트"만 요청 (설계/전략) → `agent.test_design` 단독

---

## Workflow vs ios.* 스킬 판별

| 사용자 표현 | 판별 | 선택 스킬 |
|---|---|---|
| "검색 화면 만들어줘" | 단일 코드 작업 | `ios.uikit.create_screen` |
| "검색 기능 작업 시작" | 전체 플로우 | `workflow.orchestrate` |
| "플랜 먼저 짜줘" | 계획만 | `workflow.plan` |
| "코드 검증해줘" | 검증만 | `workflow.self_check` |
| "결과 리포트 써줘" | 리포트만 | `workflow.report` |

**핵심 판별 규칙:**
- "작업", "플로우", "처음부터", "전체 과정" → `workflow.orchestrate`
- 구체적 코드 작업 → `ios.*` 스킬 직접 실행

## 우선순위 규칙

1. **workflow 키워드 최우선**: "작업 시작" → `workflow.orchestrate` (ios.* 스킬 직접 호출 아님)
2. **구체적 키워드 우선**: "UseCase 테스트" → `ios.testing.unit_test_usecase` (not `ios.architecture.create_usecase`)
3. **범위가 넓은 것 우선**: "전체 만들어줘" → `ios.architecture.create_feature` (개별 스킬 대신 통합)
4. **수정 > 생성**: "ViewModel 바인딩 수정" → 기존 파일 수정 (새 파일 생성 아님)
5. **한국어/영어 동등 취급**: "새 화면" = "new screen"
