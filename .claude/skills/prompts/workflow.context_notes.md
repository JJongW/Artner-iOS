# workflow.context_notes

## 설명
Plan 문서와 프로젝트 코드를 분석하여 Context Notes (AI_CONTEXT.md)를 생성한다.
작업 실행에 필요한 모든 컨텍스트를 하나의 문서에 집약.

## 파라미터
- `input_source` (String, 필수): 입력 소스 (AI_PLAN.md 또는 PDF 경로)

## 출력 파일
- `AI_CONTEXT.md` (프로젝트 루트)

## 절차

### Step 1: Plan 읽기
- `AI_PLAN.md` 또는 입력 PDF에서 작업 범위, 요구사항, 의존 파일 추출

### Step 2: 코드 컨텍스트 수집
Plan에서 명시된 관련 파일들을 읽고 핵심 정보 추출:
```
1. 관련 파일 구조 파악 (Glob)
2. 기존 코드 패턴 분석 (Read)
3. 의존성 체인 확인 (Grep)
4. AI_MANUAL.md 규칙 참조
```

### Step 3: AI_CONTEXT.md 작성

```markdown
# Context Notes — {작업명}

## 1. 아키텍처 컨텍스트
### 적용 규칙 (AI_MANUAL.md 기반)
- {이 작업에 해당하는 아키텍처 규칙}
- {DI 규칙}
- {Coordinator 규칙}

### 레이어 의존 방향
- 이 작업이 건드리는 레이어: {Presentation/Domain/Data}
- 의존 방향 확인: {위반 가능성 체크}

## 2. 기존 코드 분석
### 관련 파일 요약
| 파일 | 역할 | 핵심 패턴 |
|------|------|----------|
| {파일경로} | {역할} | {시그니처/패턴} |

### 기존 패턴 (반드시 따를 것)
- ViewController: `BaseViewController<VM, any {Feature}Coordinating>` 상속
- View: `BaseView` 상속, SnapKit
- ViewModel: `@Published` + `Set<AnyCancellable>`
- DIContainer: `lazy var` + `make{Feature}ViewModel()` factory
- DTO: `Codable` + `CodingKeys` + `toDomainEntity()`

## 3. 의존성 맵
### 이 작업에서 수정/생성할 파일
- {파일 1}: {수정 내용}
- {파일 2}: {수정 내용}

### 영향 받는 기존 파일
- {기존 파일}: {영향 범위}

## 4. API/데이터 컨텍스트 (해당 시)
- 엔드포인트: {API 경로}
- 요청/응답 형식: {파라미터/DTO}
- 인증: Bearer Token (TokenManager.shared)

## 5. UI 컨텍스트 (해당 시)
- 상태 처리: Loading/Empty/Error/Success
- Toast 사용: ToastManager.shared
- 네비게이션: Coordinator 패턴

## 6. 주의사항
- {이 작업에서 특별히 주의할 점}
```

## 품질 기준
- 이 문서만 읽으면 코드 실행 없이도 전체 작업 맥락을 이해 가능
- 기존 코드 패턴이 정확하게 기록됨
- AI_MANUAL.md 규칙 중 이 작업에 해당하는 항목만 추출

## 체크리스트
- [ ] Plan의 모든 관련 파일이 분석됨
- [ ] 기존 코드 패턴이 정확
- [ ] AI_MANUAL.md 규칙 반영
- [ ] 의존성 맵 완전
- [ ] 주의사항 1개 이상
