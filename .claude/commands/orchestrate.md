# 전체 워크플로우 자동 실행

이 커맨드는 Planning → 구현 → 검증 → 품질검토 → 테스트 → 리포트 전체를
**사용자 입력 없이** 자동 실행합니다.

**사용자 개입은 PHASE 6 (Ship 확인) 에서만 이루어집니다.**

---

## ⚠️ 실행 원칙 (절대 준수)

1. **각 단계 완료 즉시 다음 단계로 진행** — 중간에 사용자 확인 요청 금지
2. **PHASE 2 사전 Self-Check FAIL 시에만** 일시 정지 → 실패 항목 출력 → 명확화 요청
3. **Quality Gate / Test Gate FAIL 시에도 계속 진행** — 리포트에 기록하고 다음으로
4. **PHASE 6 전까지 절대 STOP 하지 않음**
5. 진행 상황은 `✅ Step N 완료: {내용} → 다음: {내용}` 형식으로 보고

---

## 사전 로딩 (실행 전 순서대로 모두 읽기)

1. `.claude/skills/templates/AI_MANUAL.md`
2. `.claude/skills/prompts/workflow.plan.md`
3. `.claude/skills/prompts/workflow.context_notes.md`
4. `.claude/skills/prompts/workflow.checklist_generate.md`
5. `.claude/skills/prompts/workflow.self_check.md`
6. `.claude/skills/prompts/agent.quality_review.md`
7. `.claude/skills/prompts/agent.test_design.md`
8. `.claude/skills/prompts/workflow.report.md`

---

## PHASE 0: 초기화 (자동 / 항상 실행)

**Step 0** 이전 세션 워크플로우 문서 정리
- 프로젝트 루트의 `AI_PLAN.md`, `AI_CONTEXT.md`, `AI_CHECKLIST_WORK.md`,
  `AI_QUALITY_REPORT.md`, `AI_TEST_REPORT.md`, `AI_REPORT.md` 가 존재하면 삭제
- 이유: 이전 작업 문서가 남아있으면 hook이 오판하고 on_stop.sh가 잘못된 상태를 표시함
- Bash 툴로 실행: `rm -f AI_PLAN.md AI_CONTEXT.md AI_CHECKLIST_WORK.md AI_QUALITY_REPORT.md AI_TEST_REPORT.md AI_REPORT.md`

*→ 정리 완료 즉시 PHASE 1으로 진행*

---

## PHASE 1: 계획 (자동)

**Step 1** `workflow.plan` → `AI_PLAN.md` 생성
- 작업 유형 분류, 영향 레이어, 구현 단계, 리스크 포함

**Step 2** `workflow.context_notes` → `AI_CONTEXT.md` 생성
- Plan에서 명시된 관련 파일 읽기, 기존 패턴 분석, 의존성 맵 작성

**Step 3** `workflow.checklist_generate` → `AI_CHECKLIST_WORK.md` 생성
- A.런타임 B.아키텍처 C.코드품질 D.UI/UX E.테스팅 F.문서 G.최종 7개 섹션

*→ Step 3 완료 즉시 PHASE 2로 진행*

---

## PHASE 2: 사전 검증 (자동 / 조건부 중단)

**Step 4** `workflow.self_check` (사전) 실행
- Plan 구체성, Context 패턴 확인, 의존 파일 존재, 아키텍처 위반 가능성 점검
- **PASS** → 즉시 PHASE 3으로 진행
- **FAIL** → ⛔ 실패 항목 + 원인 출력 → 사용자에게 명확화 요청

*→ PASS 즉시 PHASE 3으로 진행*

---

## PHASE 3: 구현 (자동)

**Step 5** 코드 생성/수정 실행
- `AI_PLAN.md`의 구현 계획 분석
- 해당하는 `ios.*` 스킬 프롬프트 로딩 (필요한 것만)
- 파일 생성/수정 실행
- 각 파일 완료마다 진행 상황 보고

*→ 구현 완료 즉시 PHASE 4로 진행*

---

## PHASE 4: 사후 검증 (자동)

**Step 6** `workflow.self_check` (사후) 실행
- 빌드 에러 없음, 아키텍처 체크, UI/UX 체크, 체크리스트 전항목 확인
- AI_CHECKLIST_WORK.md 업데이트

**Step 7** `agent.quality_review` 실행 → `AI_QUALITY_REPORT.md` 생성
- Architecture / Design / Code Quality / Convention 4개 카테고리 검증
- Grep 자동 검증 실행 (Domain에 UIKit 없음, DI 준수, [weak self] 등)
- 품질 점수 산정 (100점 기준)

**Step 8** `agent.test_design` 실행 → `AI_TEST_REPORT.md` 생성
- Unit / Integration / UI / Regression 테스트 시나리오 설계
- 자동 검증 (Grep) 실행
- PASS / CONDITIONAL / FAIL 판정

*→ Gate 결과와 무관하게 완료 즉시 PHASE 5로 진행*

---

## PHASE 5: 보고 (자동)

**Step 9** `workflow.report` 실행 → `AI_REPORT.md` 생성
- Plan + Context + Checklist + Quality + Test 결과 종합
- 결론 요약 (5줄), 변경 파일 리스트, 설계 의도, 검증 결과, 리스크, TODO

**Step 10** 최종 요약 출력:

```
✅ 워크플로우 완료 요약
──────────────────────────────
📁 변경 파일: N개 ([NEW] X개, [MOD] Y개)
🏆 품질 점수: XX/100  (Critical N개)
🧪 테스트 판정: PASS / CONDITIONAL / FAIL
⚠️  주요 리스크: ...
📋 다음 TODO: ...
──────────────────────────────
```

*→ 완료 즉시 PHASE 6으로 진행*

---

## PHASE 6: Ship 확인 (사용자 개입)

**Step 11** 사용자에게 확인:

> "✅ 모든 워크플로우 단계가 완료되었습니다.
> 품질 점수: XX/100 | 테스트: XXX
> 변경 사항을 ship(커밋 & 푸시) 하시겠습니까?"

- **YES** → 커밋 메시지 제안 + `git add` / `git commit` / `git push` 실행
- **NO** → 수정이 필요한 항목 목록 안내

---

## 적용할 작업

$ARGUMENTS
