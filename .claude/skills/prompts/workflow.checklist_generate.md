# workflow.checklist_generate

## 설명
AI_PLAN.md + AI_CONTEXT.md를 기반으로 작업별 맞춤 체크리스트 (AI_CHECKLIST_WORK.md)를 생성한다.

## 파라미터
- `task_plan_md` (String, 필수): AI_PLAN.md 경로
- `context_md` (String, 필수): AI_CONTEXT.md 경로

## 출력 파일
- `AI_CHECKLIST_WORK.md` (프로젝트 루트)

## 절차

### Step 1: Plan + Context 읽기
두 문서에서 추출:
- 작업 유형 → 적용할 체크 항목 결정
- 변경 파일 목록 → 파일별 체크 항목
- 아키텍처 규칙 → 준수 확인 항목

### Step 2: 체크리스트 생성
`templates/AI_CHECKLIST_WORK.md` 기반으로 작업에 맞게 확장:

```markdown
# Work Checklist — {작업명}

## A. 런타임/기능
- [ ] Xcode 빌드 성공 (에러/워닝 0)
- [ ] 크래시 없음 (해당 화면 진입/이탈 반복)
- [ ] 핵심 기능 동작 확인: {구체적 기능 목록}
- [ ] 엣지 케이스: {빈 데이터, 네트워크 오류, 토큰 만료 등}

## B. 아키텍처
- [ ] DI 준수: DIContainer.make{Feature}ViewModel() factory 사용
- [ ] Coordinator 준수: AppCoordinator.show{Feature}() 사용
- [ ] Clean Layer 준수: Domain → Data 역방향 의존 없음
- [ ] {작업별 추가 아키텍처 항목}

## C. 코드 품질
- [ ] BaseViewController 상속 패턴 준수
- [ ] BaseView 상속 + SnapKit 레이아웃
- [ ] @Published + Combine 바인딩 패턴
- [ ] [weak self] 메모리 관리
- [ ] 주석 한국어 / 변수명 영어

## D. UI/UX
- [ ] Loading 상태 처리
- [ ] Empty 상태 처리
- [ ] Error 상태 처리 + Toast
- [ ] {작업별 UI 체크 항목}

## E. 테스트
- [ ] 유닛 테스트 (해당 시)
- [ ] 수동 테스트 시나리오: {구체적 플로우}

## F. 문서
- [ ] 변경 파일 목록 기록
- [ ] 설계 의도 기록

## G. 최종 Self-Check
- [ ] 전체 Plan 달성 확인
- [ ] AI_MANUAL.md 규칙 위반 없음
- [ ] 회귀 영향 확인
```

### Step 3: 작업 유형별 커스터마이즈

| 작업 유형 | 추가 체크 항목 |
|---|---|
| 신규 화면 | VC+View+VM 세트, Coordinator 메서드, DIContainer factory |
| API 연동 | APITarget case, DTO CodingKeys, Repository+UseCase 쌍 |
| 버그 수정 | 재현 확인, 근본 원인 식별, 유사 패턴 검색 |
| 리팩토링 | 외부 인터페이스 불변, 기능 보존 |
| UI 개선 | 다양한 디바이스 크기, 다크모드, 접근성 |

## 체크리스트
- [ ] Plan의 모든 요구사항이 체크 항목으로 변환됨
- [ ] 아키텍처 체크가 AI_MANUAL.md 규칙과 일치
- [ ] 체크 항목이 검증 가능 (모호하지 않음)
- [ ] 작업 유형에 맞는 추가 항목 포함
