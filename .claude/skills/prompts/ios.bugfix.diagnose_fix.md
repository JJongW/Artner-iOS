# ios.bugfix.diagnose_fix

## 설명
버그를 체계적으로 진단하고 수정한다. 증상 분석 → 원인 추적 → 수정 → 검증 순서.

## 파라미터
- `symptom` (String, 필수): 버그 증상 설명
- `affectedArea` (String, 선택): 영향 받는 영역 (예: Combine+Decoding, Navigation, Memory)

## 수정 대상 파일
- 상황 의존적 (진단 결과에 따라 결정)

## 진단 절차

### Step 1: 증상 분류
| 증상 | 우선 확인 영역 |
|---|---|
| 크래시 (EXC_BAD_ACCESS) | Optional 강제 언래핑, 해제된 객체 접근 |
| 크래시 (디코딩 에러) | DTO CodingKeys, 서버 응답 구조 불일치 |
| UI 미반영 | Combine 바인딩, main thread, `@Published` |
| 메모리 증가 | retain cycle, Combine 구독 미해제 |
| 네비게이션 오류 | Coordinator 메서드, VC 생성 순서 |
| 네트워크 실패 | APITarget path/method, 인증 토큰 |

### Step 2: 프로젝트별 흔한 원인
```
1. Combine 디코딩: CodingKeys의 snake_case 매핑 누락
2. UI 미반영: receive(on: DispatchQueue.main) 누락
3. 메모리 누수: sink 클로저에서 [weak self] 누락
4. 네비게이션: Coordinating 프로토콜 미채택
5. 네트워크: APITarget.task에서 인코딩 방식 오류
   - GET: URLEncoding.queryString
   - POST: JSONEncoding.default
6. 토큰: TokenManager.shared.accessToken nil 체크
```

### Step 3: 진단 도구
```
1. 관련 파일 읽기 (Grep/Read로 에러 영역 탐색)
2. 데이터 흐름 추적: APITarget → DTO → Repository → UseCase → ViewModel → VC
3. Combine 체인 검증: sink의 receiveCompletion에서 에러 출력 확인
4. 타입 불일치 확인: DTO 필드 타입 vs 서버 응답 타입
```

### Step 4: 수정 패턴
```swift
// 디코딩 에러 수정
enum CodingKeys: String, CodingKey {
    case startDate = "start_date"  // 누락된 매핑 추가
}

// UI 미반영 수정
viewModel.$items
    .receive(on: DispatchQueue.main)  // 추가
    .sink { ... }

// 메모리 누수 수정
.sink { [weak self] value in  // weak self 추가
    self?.updateUI(value)
}

// 네트워크 수정
case .searchDocents(let query):
    return .requestParameters(
        parameters: ["query": query],
        encoding: URLEncoding.queryString  // JSON → URL 수정
    )
```

## 체크리스트
- [ ] 증상 재현 경로 확인
- [ ] 데이터 흐름 전체 추적 (API → UI)
- [ ] 수정 후 사이드 이펙트 확인
- [ ] 유사 패턴이 다른 곳에도 있는지 검색
- [ ] 수정 내용이 기존 아키텍처 패턴과 일관적인지 확인
