# docs.generate_api_docs

## 설명
프로젝트의 API 엔드포인트, 아키텍처, 또는 특정 Feature에 대한 문서를 생성한다.

## 파라미터
- `scope` (String, 필수): 문서 범위 (api | architecture | feature | full)
- `format` (String, 선택, 기본: markdown): 출력 형식

## 생성 파일
- 프로젝트 루트 또는 지정 위치에 .md 파일

## 문서 유형별 템플릿

### API 문서 (scope: api)
```markdown
# Artner API Reference

## Base URL
`https://artner.shop/api`

## 인증
- Bearer Token (`Authorization: Bearer {access_token}`)
- TokenManager.shared에서 자동 관리

## Endpoints

### Feed API
| Method | Path | Description | Parameters |
|--------|------|-------------|------------|
| GET | /feeds | 피드 목록 조회 | - |
| GET | /feeds/{id} | 피드 상세 조회 | id: String |

### Folder API
| Method | Path | Description | Parameters |
|--------|------|-------------|------------|
| GET | /folders | 폴더 목록 조회 | - |
| POST | /folders | 폴더 생성 | name, description |
```

### 아키텍처 문서 (scope: architecture)
```markdown
# Artner Architecture

## 레이어 구조
- **Presentation**: MVVM + Combine (BaseViewController, BaseView)
- **Domain**: Entity, Repository Protocol, UseCase Protocol
- **Data**: RepositoryImpl, UseCaseImpl, APITarget (Moya), DTOs, Storage

## 의존성 방향
Presentation → Domain ← Data

## 네비게이션
Coordinator Pattern (AppCoordinator + Feature Coordinating Protocols)

## DI
DIContainer Singleton (lazy var + factory method)
```

### Feature 문서 (scope: feature)
```markdown
# {Feature} Feature

## 파일 구조
- ViewController: `Presentation/{Feature}/ViewController/`
- View: `Presentation/{Feature}/View/`
- ViewModel: `Presentation/{Feature}/ViewModel/`

## 데이터 흐름
APITarget → DTO → Repository → UseCase → ViewModel → ViewController

## API Endpoints
- `GET /endpoint` - 설명

## 주요 동작
1. 화면 진입 시 `viewModel.loadData()` 호출
2. Combine 바인딩으로 UI 자동 업데이트
```

## 문서 생성 절차
1. APITarget.swift에서 모든 enum case 추출
2. DTOs 폴더에서 모든 DTO 구조체 추출
3. Repository, UseCase 프로토콜에서 메서드 추출
4. Presentation 구조에서 화면 목록 추출
5. 템플릿에 맞게 문서 구성

## 체크리스트
- [ ] 모든 API 엔드포인트 포함
- [ ] 요청/응답 파라미터 명시
- [ ] 아키텍처 다이어그램 (텍스트 기반)
- [ ] 한국어 설명 + 영어 코드명 혼용
