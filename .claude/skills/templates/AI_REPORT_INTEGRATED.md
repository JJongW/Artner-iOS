# AI Integrated Report — {작업명}

> 작성 목적: Planning Agent, Quality Agent, Test Agent 3개 에이전트의 결과를 종합하여 최종 배포 판정과 작업 요약을 제공하기 위함.

---

## 0. 메타
- 작업명:
- 작업 유형: (신규 화면 / API 연동 / 버그 수정 / 리팩토링 / UX 개선 / 기타)
- 작업 날짜:
- Agent Team: Planning Agent + Quality Agent + Test Agent
- 최종 배포 판정: **GO / NO-GO / CONDITIONAL**

---

## 1. Executive Summary

### 한줄 요약
>

### 핵심 지표
| 지표 | 값 |
|------|-----|
| 변경 파일 수 | 0개 |
| 품질 점수 (Quality Agent) | __/100 |
| 테스트 통과율 (Test Agent) | __% |
| Critical 이슈 수 | 0개 |
| 배포 차단 항목 | 0개 |

### 3줄 결론
1.
2.
3.

---

## 2. Planning Summary (Phase 1)

### 2.1 작업 계획 요약
- 작업 범위:
- 주요 변경점:
- 사용된 스킬:

### 2.2 구현 결과
| 계획 항목 | 완료 여부 | 비고 |
|-----------|-----------|------|
| | O/X/부분 | |

### 2.3 변경 파일 리스트
- (예) `Presentation/Home/ViewModel/HomeViewModel.swift`
- (예) `Data/Network/APITarget.swift`

---

## 3. Quality Insights (Phase 2)

### 3.1 품질 점수
- **점수: __/100 (등급: A/B/C/D)**
- 산정 근거: Critical ×0, High ×0, Medium ×0, Low ×0

### 3.2 주요 발견 사항
| # | 심각도 | 카테고리 | 요약 | 조치 상태 |
|---|--------|----------|------|-----------|
| 1 | | 아키텍처/설계/코드품질/컨벤션 | | 수정완료/미수정/수용 |

### 3.3 AI_MANUAL 준수율
| 규칙 | 준수 | 비고 |
|------|------|------|
| 1.1 레이어 분리 (Clean Architecture) | O/X | |
| 1.2 Navigation은 Coordinator가 책임 | O/X | |
| 1.3 DI는 DIContainer에서만 생성 | O/X | |
| 3.1 네이밍 컨벤션 | O/X | |
| 3.3 Combine 사용 규칙 | O/X | |

---

## 4. Test Results (Phase 3)

### 4.1 테스트 실행 요약
| 레벨 | 전체 | 통과 | 실패 | 통과율 |
|------|------|------|------|--------|
| Unit | 0 | 0 | 0 | 0% |
| Integration | 0 | 0 | 0 | 0% |
| UI | 0 | 0 | 0 | 0% |
| Regression | 0 | 0 | 0 | 0% |
| **합계** | **0** | **0** | **0** | **0%** |

### 4.2 주요 이슈
| # | 심각도 | 테스트 ID | 요약 | 조치 상태 |
|---|--------|-----------|------|-----------|
| 1 | | | | 수정완료/미수정 |

### 4.3 자동 검증 결과
| 항목 | 결과 |
|------|------|
| Clean Layer 위반 | PASS/FAIL |
| DI 준수 | PASS/FAIL |
| Coordinator 준수 | PASS/FAIL |
| [weak self] 사용 | PASS/FAIL |
| Domain 순수성 | PASS/FAIL |

---

## 5. Overall Conclusion

### 5.1 배포 판정 로직
```
최종 판정 = Quality Gate AND Test Gate

Quality Gate:
  - 품질 점수 >= 70 → PASS
  - Critical 이슈 = 0 → PASS
  - 둘 다 충족 → Quality PASS

Test Gate:
  - 테스트 통과율 >= 80% → PASS
  - P0 테스트 100% 통과 → PASS
  - 둘 다 충족 → Test PASS

최종:
  - Quality PASS + Test PASS → GO
  - 하나만 PASS → CONDITIONAL (리스크 수용 필요)
  - 둘 다 FAIL → NO-GO
```

### 5.2 판정 결과
| Gate | 기준 | 현재 | 결과 |
|------|------|------|------|
| Quality Gate | 점수 >= 70, Critical = 0 | 점수: __, Critical: __ | PASS/FAIL |
| Test Gate | 통과율 >= 80%, P0 100% | 통과율: __%, P0: __% | PASS/FAIL |
| **최종 판정** | | | **GO / NO-GO / CONDITIONAL** |

### 5.3 리스크 요약
| 리스크 | 영향 | 발생 확률 | 완화책 |
|--------|------|-----------|--------|
| | 높음/중간/낮음 | 높음/중간/낮음 | |

---

## 6. Lessons Learned
- 이번 작업에서 배운 점:
- 개선할 프로세스:
- 재사용 가능한 패턴:

---

## 7. Appendix

### 개별 보고서 링크
| Agent | 보고서 | 경로 |
|-------|--------|------|
| Planning Agent | AI_PLAN.md | 프로젝트 루트 |
| Planning Agent | AI_CONTEXT.md | 프로젝트 루트 |
| Planning Agent | AI_CHECKLIST_WORK.md | 프로젝트 루트 |
| Quality Agent | AI_QUALITY_REPORT.md | 프로젝트 루트 |
| Test Agent | AI_TEST_REPORT.md | 프로젝트 루트 |

### Phase 진행 로그
| Phase | 시작 | 완료 | 소요 | 결과 |
|-------|------|------|------|------|
| Phase 1: Planning | | | | 완료/실패 |
| Phase 2: Quality | | | | PASS/FAIL |
| Phase 3: Test | | | | PASS/FAIL |
| Phase 4: Integration | | | | GO/NO-GO/CONDITIONAL |

---
