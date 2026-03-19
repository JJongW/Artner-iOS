# workflow.orchestrate

## 설명
전체 워크플로우를 자동으로 오케스트레이션한다.
사용자의 작업 요청 하나로 Plan → Context → Checklist → Self-Check →
Execute → Self-Check → Quality → Test → Report → Ship 전체를 수행.

**사용자 개입은 사전 Self-Check FAIL 시와 최종 Ship 확인 시에만 이루어진다.**

## 파라미터
- `task_description` (String, 필수): 사용자가 요청한 작업 설명

## 출력 파일
- `AI_PLAN.md`, `AI_CONTEXT.md`, `AI_CHECKLIST_WORK.md`
- `AI_QUALITY_REPORT.md`, `AI_TEST_REPORT.md`, `AI_REPORT.md`

## 오케스트레이션 순서 (반드시 준수 / 각 단계 완료 즉시 다음으로)

```
┌──────────────────────────────────────────────────────────────┐
│ PHASE 1: 계획                                                 │
│  Step 1. workflow.plan          → AI_PLAN.md 생성            │
│  Step 2. workflow.context_notes → AI_CONTEXT.md 생성         │
│  Step 3. workflow.checklist_generate → AI_CHECKLIST_WORK.md  │
│                                                               │
│ PHASE 2: 사전 검증                                            │
│  Step 4. workflow.self_check (사전)                           │
│    ├── PASS → 즉시 PHASE 3으로                                │
│    └── FAIL → 실패 항목 출력 → 사용자 명확화 요청 [중단점]   │
│                                                               │
│ PHASE 3: 구현                                                 │
│  Step 5. ios.* 스킬 연계 → 코드 생성/수정                    │
│                                                               │
│ PHASE 4: 사후 검증                                            │
│  Step 6. workflow.self_check (사후)                           │
│  Step 7. agent.quality_review → AI_QUALITY_REPORT.md         │
│  Step 8. agent.test_design    → AI_TEST_REPORT.md            │
│    (Gate FAIL 시에도 계속 진행, 리포트에 기록)                │
│                                                               │
│ PHASE 5: 보고                                                 │
│  Step 9. workflow.report → AI_REPORT.md 생성                 │
│  Step 10. 최종 요약 출력                                      │
│                                                               │
│ PHASE 6: Ship 확인 [유일한 사용자 개입]                       │
│  Step 11. ship 여부 확인 → YES: commit/push / NO: 항목 안내  │
└──────────────────────────────────────────────────────────────┘
```

## 실행 규칙

### 규칙 1: 연속 실행 (핵심)
- 각 단계 완료 즉시 다음 단계로 자동 진행
- PHASE 6 이전에 STOP 금지
- 중간에 사용자 확인 요청 금지 (PHASE 2 FAIL 예외)

### 규칙 2: Self-Check 게이트
- 사전 FAIL → 코딩 시작하지 않음 → 사용자 명확화 요청
- 사후 FAIL → 실패 항목을 리포트에 기록 → 계속 진행

### 규칙 3: Quality / Test Gate
- FAIL/CONDITIONAL → 리포트에 기록 → PHASE 5로 계속 진행
- Ship 확인 시 Gate 결과를 함께 표시

### 규칙 4: ios.* 스킬 연계 (PHASE 3)
```
AI_PLAN.md 분석 → dispatcher.md 매핑 → 스킬 프롬프트 로딩 → 구현
```

### 규칙 5: 진행 상황 보고
```
✅ Step 1 완료: AI_PLAN.md 생성 → 다음: Context 분석
✅ Step 2 완료: AI_CONTEXT.md 생성 → 다음: Checklist 생성
✅ Step 3 완료: AI_CHECKLIST_WORK.md 생성 → 다음: 사전 Self-Check
✅ Step 4 완료: 사전 Self-Check PASS → 다음: 구현
🔨 Step 5 진행 중: 코드 생성/수정...
✅ Step 5 완료: 구현 완료 → 다음: 사후 Self-Check
✅ Step 6 완료: 사후 Self-Check → 다음: Quality Review
✅ Step 7 완료: AI_QUALITY_REPORT.md 생성 → 다음: Test 설계
✅ Step 8 완료: AI_TEST_REPORT.md 생성 → 다음: 최종 리포트
✅ Step 9 완료: AI_REPORT.md 생성 → 다음: Ship 확인
```

## 체크리스트
- [ ] 11단계 전체 순서 준수
- [ ] Self-Check 게이트 작동
- [ ] Quality Review + Test Design 단계 포함
- [ ] 6개 문서 모두 생성/업데이트
- [ ] 사용자 진행 상황 보고
- [ ] ios.* 스킬 정확하게 매핑
- [ ] Ship 확인 후 마무리
