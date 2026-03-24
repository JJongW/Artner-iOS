# AI_PLAN.md — 피처별 CLAUDE.md 분산 배치

## 작업 유형
- 문서 생성 (Documentation)
- 아키텍처 정보 분산 (Architecture Knowledge Distribution)

## 목표
루트 `CLAUDE.md`에 집중된 프로젝트 컨텍스트를 각 모듈/피처 단위로 분산하여,
AI가 특정 피처 작업 시 해당 디렉토리의 CLAUDE.md만으로 충분한 컨텍스트를 얻을 수 있도록 한다.

## 기존 README 현황
- `Data/Network/README_Network.md` — Moya 기반 네트워크 시스템
- `Presentation/Common/README_Toast.md` — Toast 컴포넌트 가이드
- `Presentation/Record/README_RecordInput.md` — 전시기록 입력 화면 상세

→ 이 README 파일들의 내용을 CLAUDE.md에 통합/참조하고, AI 작업 가이드를 추가한다.

## 생성할 CLAUDE.md 목록 (14개)

### 큰 단위 레이어
1. `Artner/Artner/Domain/CLAUDE.md` — 도메인 레이어 전체
2. `Artner/Artner/Data/CLAUDE.md` — 데이터 레이어 전체
3. `Artner/Artner/Cooldinator/CLAUDE.md` — 네비게이션 Coordinator

### Data 서브레이어
4. `Artner/Artner/Data/Network/CLAUDE.md` — 네트워크 + DTOs + DIContainer

### Presentation 피처
5. `Artner/Artner/Presentation/Common/CLAUDE.md` — 공통 UI 컴포넌트
6. `Artner/Artner/Presentation/Launch/CLAUDE.md` — 카카오 로그인 화면
7. `Artner/Artner/Presentation/Home/CLAUDE.md` — 홈 피드 화면
8. `Artner/Artner/Presentation/Entry/CLAUDE.md` — 도슨트 입장점 + 채팅
9. `Artner/Artner/Presentation/Player/CLAUDE.md` — 오디오 플레이어 + 하이라이트
10. `Artner/Artner/Presentation/Camera/CLAUDE.md` — 카메라 스캔
11. `Artner/Artner/Presentation/Save/CLAUDE.md` — 저장 폴더 + Sidebar + AIDocentSettings
12. `Artner/Artner/Presentation/Like/CLAUDE.md` — 좋아요 목록
13. `Artner/Artner/Presentation/Record/CLAUDE.md` — 전시 기록 (입력+목록)
14. `Artner/Artner/Presentation/Underline/CLAUDE.md` — 하이라이트 목록

## CLAUDE.md 표준 섹션 구성

각 파일은 아래 섹션을 포함한다:
1. **한 줄 요약** — 이 모듈이 하는 일
2. **파일 구조** — 디렉토리/파일 목록 + 역할
3. **데이터 흐름** — View → VC → VM → UseCase → Repository 체인
4. **UseCase / Repository / API 맵** — 어떤 UseCase/endpoint를 쓰는지
5. **주요 컴포넌트** — 핵심 클래스/구조체의 역할
6. **AI 작업 가이드** — 이 모듈 작업 시 주의사항, 패턴, 금지사항
7. **관련 문서** — 다른 CLAUDE.md 또는 README 링크

## 구현 단계
1. Domain/CLAUDE.md 생성
2. Data/CLAUDE.md 생성
3. Data/Network/CLAUDE.md 생성
4. Cooldinator/CLAUDE.md 생성
5. Presentation/Common/CLAUDE.md 생성
6. 각 피처(Launch/Home/Entry/Player/Camera/Save/Like/Record/Underline) CLAUDE.md 생성

## 리스크
- 기존 README 파일과 내용 중복 가능성 → CLAUDE.md는 README를 "참조"로 링크, AI 작업 가이드에 집중
- 정보 노후화 → CLAUDE.md는 구조/패턴 중심으로 작성, 세부 스펙은 README에 위임

## 영향 레이어
- 코드 변경 없음 (문서만 추가)
- 빌드 영향 없음
