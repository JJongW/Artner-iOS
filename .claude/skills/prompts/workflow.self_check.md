# workflow.self_check

## 설명
AI_CHECKLIST_WORK.md의 각 항목을 코드/컨텍스트와 대조하여 Self-Check를 수행한다.
코딩 전(사전)과 코딩 후(사후) 두 시점에 실행.

## 파라미터
- `checklist_md` (String, 필수): AI_CHECKLIST_WORK.md 경로
- `code_diff` (String, 선택): 코드 변경 내용 (사후 검증 시)

## 반환
- `boolean`: 모든 항목 통과 시 true, 하나라도 실패 시 false
- AI_CHECKLIST_WORK.md 업데이트 (체크 결과 마킹)

## 실행 시점

### 사전 Self-Check (코딩 전)
Plan + Context가 충분한지 검증:
```
체크 항목:
- [ ] Plan의 구현 단계가 구체적인가?
- [ ] Context에 기존 코드 패턴이 확인되었는가?
- [ ] 의존 파일이 모두 존재하는가?
- [ ] 아키텍처 위반 가능성이 식별되었는가?
- [ ] 불확실한 요구사항이 있는가? → 있으면 false → 사용자 확인 요청
```

### 사후 Self-Check (코딩 후)
실제 코드 변경이 체크리스트를 만족하는지 검증:
```
체크 항목:
- [ ] 빌드 에러 없음 (코드 문법 확인)
- [ ] 아키텍처 체크 전체 통과
- [ ] UI/UX 체크 전체 통과
- [ ] 체크리스트의 모든 항목 확인 완료
```

## 절차

### Step 1: 체크리스트 읽기
```
AI_CHECKLIST_WORK.md에서 모든 `- [ ]` 항목 추출
```

### Step 2: 항목별 검증

#### 자동 검증 가능 항목
```
- DI 준수: DIContainer에 factory 메서드 존재 확인 (Grep)
- Coordinator 준수: AppCoordinator에 show 메서드 존재 확인 (Grep)
- Clean Layer: Domain 파일에 UIKit/Moya import 없음 확인 (Grep)
- BaseViewController 상속: VC 파일에서 패턴 확인 (Grep)
- [weak self]: Combine sink 클로저에서 확인 (Grep)
- CodingKeys: DTO에서 snake_case 매핑 확인 (Read)
```

#### 수동 확인 필요 항목
```
- 빌드 성공: Xcode 빌드 필요 (안내만 제공)
- UI 동작: 시뮬레이터 확인 필요 (안내만 제공)
- 크래시: 런타임 확인 필요 (안내만 제공)
```

### Step 3: 결과 마킹
```markdown
# 통과 항목
- [x] DI 준수 ✅

# 실패 항목
- [ ] Coordinator 준수 ❌ — show{Feature}() 메서드 누락

# 수동 확인 필요
- [ ] 빌드 성공 ⚠️ — Xcode 빌드 필요
```

### Step 4: 판정
```
전체 통과 (자동 검증 항목 기준):
  → true 반환, 다음 단계 진행

하나 이상 실패:
  → false 반환
  → 실패 항목 + 원인 + 수정 방안 출력
  → 사전: 사용자에게 명확화 요청
  → 사후: 수정 후 재검증 또는 리포트에 기록
```

## 체크리스트
- [ ] 모든 체크 항목이 검증됨 (자동 또는 수동 표시)
- [ ] 실패 항목에 구체적 사유 기재
- [ ] AI_CHECKLIST_WORK.md에 결과 반영
- [ ] false 시 명확한 다음 액션 제시
