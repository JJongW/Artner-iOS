# Skill Mapping Examples

사용자 지시 → 스킬 매핑 예시 29개 (ios.* 19개 + workflow 7개 + agent 3개).

## 예시 목록

### 1. 화면 생성
**지시**: "새로운 Search 화면 만들어줘 (검색바 + 테이블뷰)"
**스킬**: `ios.uikit.create_screen`
**파라미터**:
```json
{
  "featureName": "Search",
  "components": ["UISearchBar", "UITableView"],
  "hasViewModel": true
}
```
**생성 파일**: `SearchViewController.swift`, `SearchView.swift`, `SearchViewModel.swift`

---

### 2. 셀 생성
**지시**: "DocentTableViewCell 새로 만들어줘"
**스킬**: `ios.uikit.create_cell`
**파라미터**:
```json
{
  "cellName": "Docent",
  "cellType": "UITableViewCell",
  "components": ["UIImageView", "UILabel"]
}
```

---

### 3. 네비게이션 추가
**지시**: "AppCoordinator에서 Home→Search 네비게이션 추가"
**스킬**: `ios.navigation.add_route`
**파라미터**:
```json
{
  "fromFeature": "Home",
  "toFeature": "Search",
  "navigationType": "push"
}
```
**수정 파일**: `AppCoordinator.swift` - `showSearch()` 메서드 추가

---

### 4. Coordinating 프로토콜
**지시**: "SearchCoordinating 프로토콜 생성해줘"
**스킬**: `ios.navigation.create_protocol`
**파라미터**:
```json
{
  "featureName": "Search",
  "methods": ["showSearchDetail", "dismissSearch"]
}
```

---

### 5. API 엔드포인트
**지시**: "도슨트 검색 API 엔드포인트 추가해줘"
**스킬**: `ios.networking.add_endpoint`
**파라미터**:
```json
{
  "endpoint": "/docents/search",
  "method": "GET",
  "parameters": {"query": "String"}
}
```
**수정 파일**: `APITarget.swift` - `case searchDocents(query: String)` 추가

---

### 6. DTO 생성
**지시**: "SearchResultDTO 만들어줘. id, title, thumbnail 필드로"
**스킬**: `ios.networking.create_dto`
**파라미터**:
```json
{
  "dtoName": "SearchResult",
  "fields": [
    {"name": "id", "type": "Int"},
    {"name": "title", "type": "String"},
    {"name": "thumbnail", "type": "String?", "serverKey": "thumbnail_url"}
  ],
  "entityName": "SearchResult"
}
```

---

### 7. 전체 파이프라인
**지시**: "검색 기능 전체 파이프라인 구축 (API부터 ViewModel까지)"
**스킬**: `ios.networking.add_full_pipeline`
**파라미터**:
```json
{
  "featureName": "Search",
  "endpoint": "/docents/search",
  "responseType": "SearchResultDTO"
}
```
**생성/수정 파일**: APITarget, DTO, Repository(Protocol+Impl), UseCase(Protocol+Impl), DIContainer

---

### 8. Feature 스캐폴딩
**지시**: "Setting Feature 전체 스캐폴딩 생성"
**스킬**: `ios.architecture.create_feature`
**파라미터**:
```json
{
  "featureName": "Setting",
  "hasApi": true,
  "components": ["UITableView"]
}
```

---

### 9. UseCase 생성
**지시**: "GetSearchResultsUseCase 만들어줘"
**스킬**: `ios.architecture.create_usecase`
**파라미터**:
```json
{
  "action": "GetSearchResults",
  "entityName": "SearchResult",
  "repositoryName": "SearchRepository"
}
```

---

### 10. Repository 생성
**지시**: "SearchRepository 만들어줘"
**스킬**: `ios.architecture.create_repository`
**파라미터**:
```json
{
  "entityName": "Search",
  "methods": ["search", "getRecentSearches"]
}
```

---

### 11. 저장소 추가
**지시**: "최근 검색어 UserDefaults 저장 기능 추가"
**스킬**: `ios.persistence.add_storage`
**파라미터**:
```json
{
  "storageType": "UserDefaults",
  "dataKey": "recentSearches",
  "valueType": "[String]"
}
```

---

### 12. Combine 바인딩
**지시**: "SearchViewModel에 Combine 바인딩 세팅해줘"
**스킬**: `ios.combine.create_binding`
**파라미터**:
```json
{
  "publishedProperties": ["searchResults", "isLoading"],
  "actions": ["search", "clearResults"]
}
```

---

### 13. 테스트 인프라
**지시**: "테스트 인프라 구축해줘 (Mock + XCTest)"
**스킬**: `ios.testing.setup_infrastructure`
**파라미터**:
```json
{
  "testTarget": "ArtnerTests",
  "mockingStrategy": "protocol_mock"
}
```

---

### 14. ViewModel 유닛 테스트
**지시**: "HomeViewModel 유닛 테스트 작성"
**스킬**: `ios.testing.unit_test_viewmodel`
**파라미터**:
```json
{
  "targetClass": "HomeViewModel",
  "testCases": ["loadFeed_success", "loadFeed_failure"]
}
```

---

### 15. 버그 진단
**지시**: "피드 로딩 중 앱이 크래시돼, Combine 디코딩 에러 같아"
**스킬**: `ios.bugfix.diagnose_fix`
**파라미터**:
```json
{
  "symptom": "crash_on_feed_load",
  "affectedArea": "Combine+Decoding"
}
```

---

### 16. 리팩토링
**지시**: "PlayerViewController 리팩토링 - 콜백을 Combine으로 변경"
**스킬**: `ios.refactor.extract_pattern`
**파라미터**:
```json
{
  "targetFiles": ["PlayerViewController.swift", "PlayerViewModel.swift"],
  "refactorType": "callback_to_combine"
}
```

---

### 17. 렌더링 최적화
**지시**: "HomeView 스크롤 할 때 프레임 드롭이 심해"
**스킬**: `ios.performance.optimize_rendering`
**파라미터**:
```json
{
  "targetView": "HomeView",
  "issue": "scroll_frame_drop"
}
```

---

### 18. 메모리 진단
**지시**: "PlayerViewModel에서 메모리 누수가 의심돼"
**스킬**: `ios.performance.diagnose_memory`
**파라미터**:
```json
{
  "targetArea": "PlayerViewModel",
  "symptom": "suspected_retain_cycle"
}
```

---

### 19. CI/CD 설정
**지시**: "GitHub Actions iOS 빌드 + 테스트 워크플로우 세팅"
**스킬**: `ci_cd.setup_github_actions`
**파라미터**:
```json
{
  "triggers": ["push", "pull_request"],
  "includeTests": true
}
```

---

## Workflow 스킬 예시

### 20. 전체 워크플로우 오케스트레이션
**지시**: "검색 기능 작업 처음부터 끝까지 진행해줘"
**스킬**: `workflow.orchestrate`
**파라미터**:
```json
{
  "task_description": "검색 기능 작업 처음부터 끝까지 진행해줘"
}
```
**실행 체인**: plan → context_notes → checklist_generate → self_check(사전) → execute_task → self_check(사후) → report

---

### 21. 작업 계획 수립
**지시**: "도슨트 즐겨찾기 기능 플랜 짜줘"
**스킬**: `workflow.plan`
**파라미터**:
```json
{
  "task_description": "도슨트 즐겨찾기 기능 추가"
}
```
**출력**: `AI_PLAN.md`

---

### 22. 컨텍스트 노트 생성
**지시**: "현재 Plan 기반으로 컨텍스트 분석해줘"
**스킬**: `workflow.context_notes`
**파라미터**:
```json
{
  "input_source": "AI_PLAN.md"
}
```
**출력**: `AI_CONTEXT.md`

---

### 23. 체크리스트 생성
**지시**: "이번 작업 체크리스트 만들어줘"
**스킬**: `workflow.checklist_generate`
**파라미터**:
```json
{
  "task_plan_md": "AI_PLAN.md",
  "context_md": "AI_CONTEXT.md"
}
```
**출력**: `AI_CHECKLIST_WORK.md`

---

### 24. Self-Check 실행
**지시**: "코드 변경사항 셀프체크 돌려줘"
**스킬**: `workflow.self_check`
**파라미터**:
```json
{
  "checklist_md": "AI_CHECKLIST_WORK.md",
  "code_diff": "git diff 결과"
}
```
**반환**: `true` (전체 통과) 또는 `false` (실패 항목 존재)

---

### 25. 코드 실행
**지시**: "Plan대로 코딩 시작해줘"
**스킬**: `workflow.execute_task`
**파라미터**:
```json
{
  "task_plan_md": "AI_PLAN.md",
  "context_md": "AI_CONTEXT.md"
}
```
**내부 체이닝**: Plan 분석 → dispatcher로 ios.* 스킬 매핑 → 코드 생성

---

### 26. 최종 리포트
**지시**: "작업 결과 리포트 작성해줘"
**스킬**: `workflow.report`
**파라미터**:
```json
{
  "task_plan_md": "AI_PLAN.md",
  "context_md": "AI_CONTEXT.md",
  "checklist_md": "AI_CHECKLIST_WORK.md",
  "code_diff": "변경 내용"
}
```
**출력**: `AI_REPORT.md`

---

## Agent 스킬 예시

### 27. Quality Review (품질 리뷰)
**지시**: "이번 변경사항 품질 리뷰 해줘"
**스킬**: `agent.quality_review`
**파라미터**:
```json
{
  "plan_md": "AI_PLAN.md",
  "context_md": "AI_CONTEXT.md",
  "code_diff": "git diff 결과"
}
```
**출력**: `AI_QUALITY_REPORT.md` (품질 점수, 발견 사항, 수정 제안)

---

### 28. Test Design (테스트 설계)
**지시**: "검색 기능 테스트 전략 설계해줘"
**스킬**: `agent.test_design`
**파라미터**:
```json
{
  "plan_md": "AI_PLAN.md",
  "context_md": "AI_CONTEXT.md",
  "quality_report_md": "AI_QUALITY_REPORT.md",
  "write_test_code": false
}
```
**출력**: `AI_TEST_REPORT.md` (테스트 시나리오, 통과율, 배포 판정)

---

### 29. Full Agent Team (에이전트 팀 전체 플로우)
**지시**: "검색 기능 에이전트 팀으로 만들어줘"
**스킬**: `agent.team_orchestrate`
**파라미터**:
```json
{
  "task_description": "검색 기능 에이전트 팀으로 만들어줘"
}
```
**실행 체인**:
```
Phase 1: Planning Agent
  └── plan → context → checklist → self_check → execute → self_check
Phase 2: Quality Agent
  └── agent.quality_review → AI_QUALITY_REPORT.md
Phase 3: Test Agent
  └── agent.test_design → AI_TEST_REPORT.md
Phase 4: Integration
  └── AI_REPORT_INTEGRATED.md (최종 배포 판정: GO/NO-GO/CONDITIONAL)
```
