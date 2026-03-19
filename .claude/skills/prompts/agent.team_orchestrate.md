# agent.team_orchestrate

## 설명
Agent Team 전체 파이프라인을 오케스트레이션한다.
Planning Agent → Quality Agent → Test Agent → Integration 4단계 Phase로 작업을 수행하고,
최종 통합 보고서 (AI_REPORT_INTEGRATED.md)를 생성한다.

## 파라미터
- `task_description` (String, 필수): 사용자가 요청한 작업 설명

## 출력 파일
- Phase 1: `AI_PLAN.md`, `AI_CONTEXT.md`, `AI_CHECKLIST_WORK.md`
- Phase 2: `AI_QUALITY_REPORT.md`
- Phase 3: `AI_TEST_REPORT.md`
- Phase 4: `AI_REPORT_INTEGRATED.md`

## 기존 workflow.orchestrate와의 차이
```
workflow.orchestrate:
  선형 파이프라인 (plan → execute → report)
  Self-Check 검증만

agent.team_orchestrate:
  Phase 기반 다중 에이전트
  Quality Agent 전문 품질 리뷰
  Test Agent 전문 테스트 설계
  에이전트별 보고서 + 통합 보고서
  Phase 간 Gate 검증
```

## 4단계 Phase 파이프라인

```
┌─────────────────────────────────────────────────────────────┐
│ Phase 1: Planning Agent                                      │
│   ├── workflow.plan → AI_PLAN.md                            │
│   ├── workflow.context_notes → AI_CONTEXT.md                │
│   ├── workflow.checklist_generate → AI_CHECKLIST_WORK.md    │
│   ├── workflow.self_check (사전)                             │
│   ├── workflow.execute_task → 코드 생성/수정                 │
│   └── workflow.self_check (사후)                             │
│                                                              │
│   Gate: Self-Check 사후 통과                                 │
├──────────────────────────────────────────────────────────────┤
│ Phase 2: Quality Agent  (Gate: Phase 1 완료)                 │
│   └── agent.quality_review → AI_QUALITY_REPORT.md           │
│                                                              │
│   Gate: 품질점수 >= 70 AND Critical = 0개                    │
├──────────────────────────────────────────────────────────────┤
│ Phase 3: Test Agent  (Gate: Phase 2 통과)                    │
│   └── agent.test_design → AI_TEST_REPORT.md                 │
│                                                              │
│   Gate: 테스트통과율 >= 80%                                   │
├──────────────────────────────────────────────────────────────┤
│ Phase 4: Integration                                         │
│   └── 3개 Agent 결과 통합 → AI_REPORT_INTEGRATED.md         │
│       최종 배포 가능 여부 판정 (GO / NO-GO / CONDITIONAL)     │
└──────────────────────────────────────────────────────────────┘
```

## Phase 상세

### Phase 1: Planning Agent
기존 `workflow.orchestrate`와 동일한 프로세스를 수행한다.

**실행 순서:**
```
1. workflow.plan → AI_PLAN.md 생성
2. workflow.context_notes → AI_CONTEXT.md 생성
3. workflow.checklist_generate → AI_CHECKLIST_WORK.md 생성
4. workflow.self_check (사전)
   ├── true  → Step 5로 진행
   └── false → 사용자에게 명확화 요청 → 재시도
5. workflow.execute_task → 코드 생성/수정
   (dispatcher.md로 적절한 ios.* 스킬 매핑)
6. workflow.self_check (사후)
   ├── true  → Phase 2로 진행
   └── false → 실패 항목 수정 → 재검증 (최대 2회)
```

**Phase 1 완료 보고:**
```
✅ Phase 1 완료: Planning Agent
  - AI_PLAN.md 생성 완료
  - AI_CONTEXT.md 생성 완료
  - AI_CHECKLIST_WORK.md 생성 완료
  - 코드 생성/수정 완료
  - 사후 Self-Check 통과
  → Phase 2 (Quality Agent) 진행
```

### Phase 2: Quality Agent
`agent.quality_review` 프롬프트를 실행한다.

**입력:**
```
- plan_md: AI_PLAN.md
- context_md: AI_CONTEXT.md
- checklist_md: AI_CHECKLIST_WORK.md
- code_diff: Phase 1에서 생성된 코드 변경 내용
```

**Quality Gate 검증:**
```
PASS 조건:
  - 품질 점수 >= 70점
  - Critical 이슈 = 0개

FAIL 처리:
  1. Quality Agent 발견 사항을 Planning Agent에 전달
  2. Planning Agent가 코드 수정
  3. Quality Agent 재리뷰 (최대 1회)
  4. 재리뷰도 FAIL → 사용자 판단 요청
     "품질 점수 {X}점, Critical {N}개. 진행하시겠습니까?"
```

**Phase 2 완료 보고:**
```
✅ Phase 2 완료: Quality Agent
  - 품질 점수: {X}/100 (등급: {A/B/C/D})
  - Critical: {N}개, High: {N}개
  - Quality Gate: PASS/FAIL
  → Phase 3 (Test Agent) 진행 / 수정 필요
```

### Phase 3: Test Agent
`agent.test_design` 프롬프트를 실행한다.

**입력:**
```
- plan_md: AI_PLAN.md
- context_md: AI_CONTEXT.md
- quality_report_md: AI_QUALITY_REPORT.md
- code_diff: Phase 1에서 생성된 코드 변경 내용
- write_test_code: false (기본값, 사용자 요청 시 true)
```

**Test Gate 검증:**
```
PASS 조건:
  - 테스트 통과율 >= 80%
  - P0 테스트 전체 통과
  - Critical 이슈 = 0개

FAIL 처리:
  1. 실패 테스트 목록을 Planning Agent에 전달
  2. Planning Agent가 코드 수정
  3. Test Agent 재검증 (최대 1회)
  4. 재검증도 FAIL → 사용자 판단 요청
     "테스트 통과율 {X}%. 진행하시겠습니까?"
```

**Phase 3 완료 보고:**
```
✅ Phase 3 완료: Test Agent
  - 테스트 통과율: {X}%
  - Critical 이슈: {N}개
  - Test Gate: PASS/FAIL/CONDITIONAL
  → Phase 4 (Integration) 진행 / 수정 필요
```

### Phase 4: Integration
3개 Agent의 결과를 종합하여 통합 보고서를 생성한다.

**입력:**
```
- AI_PLAN.md (Phase 1)
- AI_CONTEXT.md (Phase 1)
- AI_CHECKLIST_WORK.md (Phase 1)
- AI_QUALITY_REPORT.md (Phase 2)
- AI_TEST_REPORT.md (Phase 3)
```

**통합 보고서 작성:**
`templates/AI_REPORT_INTEGRATED.md` 템플릿 기반으로 작성:
```
모든 섹션 채우기:
0. 메타 → 기본 정보 + 최종 배포 판정
1. Executive Summary → 한줄요약, 핵심지표, 3줄결론
2. Planning Summary → Phase 1 결과 요약
3. Quality Insights → Phase 2 결과 요약 (점수, 주요 발견)
4. Test Results → Phase 3 결과 요약 (통과율, 이슈)
5. Overall Conclusion → 배포 판정 로직 적용
6. Lessons Learned → 작업 회고
7. Appendix → 개별 보고서 링크, Phase 로그
```

**최종 배포 판정:**
```
GO:     Quality PASS + Test PASS → 배포 가능
NO-GO:  Quality FAIL + Test FAIL → 배포 불가, 재작업
CONDITIONAL: 하나만 PASS → 조건부 배포 (리스크 수용 필요)
```

**Phase 4 완료 보고:**
```
✅ Phase 4 완료: Integration
  - 최종 배포 판정: GO / NO-GO / CONDITIONAL
  - 품질 점수: {X}/100
  - 테스트 통과율: {X}%
  - AI_REPORT_INTEGRATED.md 생성 완료

📋 생성된 문서:
  1. AI_PLAN.md
  2. AI_CONTEXT.md
  3. AI_CHECKLIST_WORK.md
  4. AI_QUALITY_REPORT.md
  5. AI_TEST_REPORT.md
  6. AI_REPORT_INTEGRATED.md
```

## 실행 규칙

### 규칙 1: Phase 순서 엄수
- Phase 1 → 2 → 3 → 4 순서를 반드시 따른다
- Gate를 통과해야 다음 Phase로 진행
- Phase를 건너뛰지 않는다

### 규칙 2: Gate 실패 처리
```
1차 실패: 자동 수정 → 재검증
2차 실패: 사용자 판단 요청
  → "진행" 선택: 다음 Phase로 (리스크 기록)
  → "중단" 선택: 현재까지 결과 보고서 생성
```

### 규칙 3: 사용자 소통
각 Phase 완료 시 진행 상황 보고:
```
🔨 Phase 1 진행 중: Planning Agent...
✅ Phase 1 완료 → Phase 2 진행
🔍 Phase 2 진행 중: Quality Agent...
✅ Phase 2 완료 (품질: 85/100) → Phase 3 진행
🧪 Phase 3 진행 중: Test Agent...
✅ Phase 3 완료 (통과율: 92%) → Phase 4 진행
📊 Phase 4 진행 중: Integration...
✅ Phase 4 완료 → 최종 판정: GO
```

### 규칙 4: 문서 일관성
- 6개 문서가 서로 참조 가능
- 같은 작업명, 같은 파일 목록, 같은 용어 사용
- 통합 보고서에 개별 보고서 링크 포함

### 규칙 5: 기존 workflow 호환
- Phase 1은 기존 `workflow.orchestrate` 프로세스를 재사용
- 기존 `workflow.*` 스킬은 그대로 유지
- `agent.team_orchestrate`는 `workflow.orchestrate`의 상위 확장

## 스킬 체이닝 예시

### 예시 1: "새 검색 화면 Agent Team으로 만들어줘"
```
Phase 1: Planning Agent
  ├── workflow.plan → Search Feature Plan
  ├── workflow.context_notes → Home 패턴 분석
  ├── workflow.checklist_generate → 신규 화면 체크리스트
  ├── workflow.self_check (사전) → 통과
  ├── workflow.execute_task:
  │   ├── ios.uikit.create_screen(Search)
  │   ├── ios.navigation.add_route(Home→Search)
  │   └── ios.networking.add_full_pipeline(Search)
  └── workflow.self_check (사후) → 통과

Phase 2: Quality Agent
  └── agent.quality_review → 품질 85/100, Critical 0

Phase 3: Test Agent
  └── agent.test_design → 통과율 90%, PASS

Phase 4: Integration
  └── AI_REPORT_INTEGRATED.md → GO
```

### 예시 2: "도슨트 좋아요 버그 수정 (Agent Team)"
```
Phase 1: Planning Agent
  ├── workflow.plan → 버그 분석 + 수정 Plan
  ├── workflow.context_notes → 관련 코드 분석
  ├── workflow.execute_task:
  │   └── ios.bugfix.diagnose_fix → 원인 분석 + 수정
  └── workflow.self_check (사후) → 통과

Phase 2: Quality Agent
  └── agent.quality_review → 품질 92/100, Critical 0

Phase 3: Test Agent
  └── agent.test_design → Regression 테스트 설계, PASS

Phase 4: Integration
  └── AI_REPORT_INTEGRATED.md → GO
```

## 체크리스트
- [ ] 4개 Phase 전체 순서 준수
- [ ] Phase 간 Gate 검증 작동
- [ ] 6개 문서 모두 생성
- [ ] 각 Phase 완료 시 사용자에게 진행 상황 보고
- [ ] Gate 실패 시 적절한 처리 (수정/재검증/사용자 판단)
- [ ] 통합 보고서에 최종 배포 판정 포함
- [ ] 기존 workflow.* 스킬과 호환
