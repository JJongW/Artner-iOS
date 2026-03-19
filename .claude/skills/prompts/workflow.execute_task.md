# workflow.execute_task

## 설명
AI_PLAN.md + AI_CONTEXT.md를 기반으로 실제 코드 생성/수정을 실행한다.
적절한 ios.* 스킬을 참조하여 프로젝트 패턴에 맞는 코드를 생성.

## 파라미터
- `task_plan_md` (String, 필수): AI_PLAN.md 경로
- `context_md` (String, 필수): AI_CONTEXT.md 경로

## 반환
- 코드 변경 내용 (code_diff)

## 절차

### Step 1: 실행 계획 로드
```
1. AI_PLAN.md의 "구현 계획" 섹션 읽기
2. AI_CONTEXT.md의 "기존 코드 패턴" + "의존성 맵" 읽기
3. 실행 순서 결정
```

### Step 2: 스킬 매핑
Plan의 각 단계를 적절한 ios.* 스킬에 매핑:

| Plan 단계 | 매핑 스킬 |
|---|---|
| VC + View + VM 생성 | `ios.uikit.create_screen` |
| Cell 생성 | `ios.uikit.create_cell` |
| API 엔드포인트 추가 | `ios.networking.add_endpoint` |
| DTO 생성 | `ios.networking.create_dto` |
| Repository 생성 | `ios.architecture.create_repository` |
| UseCase 생성 | `ios.architecture.create_usecase` |
| DIContainer 등록 | 직접 수정 |
| Coordinator 메서드 추가 | `ios.navigation.add_route` |
| Combine 바인딩 | `ios.combine.create_binding` |

### Step 3: 코드 생성 실행
각 스킬의 프롬프트에 정의된 패턴을 따라 코드 생성:

```
실행 원칙:
1. 한 번에 하나의 파일씩 (순서대로)
2. 새 파일 생성 전 기존 파일 수정 먼저
3. 각 파일 작성 후 AI_CONTEXT의 패턴과 대조
4. 기존 코드와의 일관성 우선
```

### Step 4: 변경 추적
모든 변경 사항을 기록:
```
변경 파일:
1. [NEW] Presentation/{Feature}/ViewController/{Feature}ViewController.swift
2. [NEW] Presentation/{Feature}/View/{Feature}View.swift
3. [MOD] Data/Network/DIContainer.swift — make{Feature}ViewModel() 추가
4. [MOD] Cooldinator/AppCoordinator.swift — show{Feature}() 추가
```

## 코드 품질 규칙
- AI_MANUAL.md 4절 "개발 작업의 표준 흐름" 준수
- 변수명: English / 주석: 한국어
- `final` + `private` 접근제어 기본
- Domain에서 UIKit/Network 의존 금지
- Combine 사용 시 반드시 `[weak self]` + `cancellables`

## 체크리스트
- [ ] Plan의 모든 구현 단계 실행 완료
- [ ] 각 파일이 Context의 기존 패턴과 일치
- [ ] 변경 파일 목록 기록 완료
- [ ] AI_MANUAL.md 규칙 위반 없음
