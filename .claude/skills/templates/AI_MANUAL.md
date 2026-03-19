# AI Manual — Artner-iOS (개발 컨텍스트/규칙/패턴)

이 문서는 Artner-iOS에서 AI가 개발 작업을 수행할 때 반드시 따라야 하는 "프로젝트 컨텍스트 + 표준 작업 방식"을 정의한다.
목표는 **일관된 아키텍처**, **깨지는 변경 최소화**, **재현 가능한 구현/검증**이다.

---

## 0. 프로젝트 한 줄 요약
Artner-iOS는 **도슨트(art docent) 경험**을 제공하는 iOS 앱으로, 작품에 대한 **AI 기반 오디오 가이드**를 제공한다.

---

## 1. 아키텍처 원칙 (절대 규칙)
### 1.1 레이어 분리 (Clean Architecture)
- Domain: 순수 비즈니스 규칙 (Entity, Repository Protocol, UseCase Protocol)
- Data: 네트워크/스토리지/Repository 구현체/UseCase 구현체
- Presentation: UI(VC/View), ViewModel(MVVM), 공통 컴포넌트

**금지**
- Presentation → Data 구현체 직접 참조 금지 (Protocol을 통해서만)
- Domain에서 UIKit/Network/Storage 의존 금지
- Coordinator 없이 화면 전환 로직을 VC 내부에서 처리하는 것 지양

### 1.2 Navigation은 Coordinator가 책임
- 모든 화면 전환은 `Cooldinator/AppCoordinator.swift`에서 수행
- ViewController는 "이벤트를 발생"시키고, Coordinator가 "이동"을 처리

### 1.3 DI는 DIContainer에서만 생성
- 의존성 생성은 `Data/Network/DIContainer.swift` 팩토리 메서드로만
- ViewModel/UseCase/Repository/Service를 화면에서 직접 new 하지 않는다.

---

## 2. 디렉토리 구조 (표준)
Artner/Artner/
├── Cooldinator/          # navigation
├── Domain/
│   ├── Entity/
│   ├── Repository/       # protocols
│   └── UseCase/          # protocols
├── Data/
│   ├── Network/          # API service, DTOs, DIContainer
│   ├── RepositoryImpl/
│   ├── UseCaseImpl/
│   └── Storage/
└── Presentation/
├── Base/
├── Common/
└── {Feature}/
├── ViewController/
├── ViewModel/
└── View/ (필요 시)

---

## 3. 코딩 컨벤션 (필수)
### 3.1 언어/네이밍
- 변수/함수/타입명: English
- 주석/문서/설명: 한국어
- 파일명: PascalCase (예: `HomeViewModel.swift`)

### 3.2 접근제어/의존성
- 가능한 `final` 사용
- 외부로 노출할 필요 없으면 `private`/`fileprivate` 우선
- Domain 프로토콜은 **작게**, UseCase는 **의도가 드러나게**

### 3.3 Combine 사용 규칙 (권장)
- ViewModel은 Publisher/Subject로 상태/이벤트 노출
- VC는 bind만 담당(상태 해석 최소화)
- 메모리 누수 방지: `AnyCancellable` 관리 철저

---

## 4. 개발 작업의 표준 흐름 (AI가 반드시 따를 것)
작업 유형에 따라 아래 중 하나를 선택해도, 기본 흐름은 동일하다.

### 4.1 "새 화면" 추가 플로우
1) Presentation/{Feature}/ViewModel 생성  
2) Presentation/{Feature}/ViewController 생성  
3) (필요 시) View 생성  
4) DIContainer에 `make{Feature}ViewModel()` 추가  
5) AppCoordinator에 `show{Feature}()` 추가  
6) 기존 화면에서 Coordinator 호출 트리거 연결  
7) Toast/Loading/Empty/Error UI 정책 준수 (아래 6절)

### 4.2 "API 연동" 추가/변경 플로우
1) `Data/Network/APITarget.swift`에 endpoint 정의  
2) `Data/Network/DTOs/`에 Request/Response DTO 추가  
3) Domain `Repository protocol` 정의/수정 (메서드 시그니처는 도메인 중심)  
4) Data `RepositoryImpl` 구현  
5) Domain `UseCase protocol` 정의/수정  
6) Data `UseCaseImpl` 구현  
7) DIContainer 연결  
8) Presentation ViewModel에서 UseCase 호출 + 상태/에러 처리

### 4.3 "스토리지" 추가/변경 플로우
- Keychain/Token 등은 `Data/Storage/`로
- Domain이 스토리지 구체 타입을 모르게 설계 (Protocol 필요 시 Domain에)

---

## 5. 환경변수/실행 (개발 필수 조건)
Xcode → Product → Scheme → Edit Scheme → Run → Environment Variables:
- `DEV_ACCESS_TOKEN`
- `DEV_REFRESH_TOKEN`

**AI가 변경/추가 작업 시**
- 환경변수 요구사항이 바뀌면, 반드시 문서에 반영하고 체크리스트에도 추가한다.

---

## 6. UI/UX 정책 (공통)
### 6.1 Toast 사용 규칙 (필수)
- 성공: `ToastManager.shared.showSuccess("...")`
- 실패: `ToastManager.shared.showError("...")`
- 로딩: `ToastManager.shared.showLoading("...")` (필요 시)

**원칙**
- 네트워크 요청 시작/종료 시 사용자 피드백이 있어야 함
- 치명적 실패는 화면 내 상태(Empty/Error View) + Toast를 함께 고려

### 6.2 상태 처리 기준 (권장)
- Loading: 스켈레톤/로딩 표시(프로젝트 방식에 맞춤)
- Empty: "데이터 없음"을 명확히 표현
- Error: 재시도/뒤로가기/문의 등의 다음 행동 제공
- Success: 정상 UI 렌더

---

## 7. 변경 단위(Commit) 기준 (AI 출력 규칙)
AI는 작업 결과를 낼 때 다음을 반드시 포함한다.
- 변경 파일 리스트
- 각 파일의 변경 요약
- 설계 의도(왜 이렇게 했는지) 3~6줄
- 검증 방법(어떤 화면/플로우를 어떻게 확인했는지)
- 리스크/후속 TODO

---

## 8. “피처별 세부 문서” 확장 규칙
전체 공통 문서(AI_MANUAL.md) 이후, 필요하면 아래처럼 추가한다.
- `docs/feature-home.md`
- `docs/feature-player.md`
- `docs/feature-camera.md`
- `docs/networking.md` (API, DTO, 에러 모델, retry, logging 등)

피처 문서에는 반드시 포함:
- 사용자 플로우
- 화면 구성 요소
- 상태(loading/empty/error) 처리 방식
- 이벤트/로그 포인트(있다면)
- API/UseCase/Repository 맵

---