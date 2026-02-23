# Commit Message Convention (Conventional Commits)

형식:
(<scope?>): 

<body?>

<footer?>

예시:
feat(player): add background audio resume

fix(ui): prevent button overlap on small screens

docs(readme): update setup instructions

타입:
- `feat`: 새로운 기능 추가
- `fix`: 버그 수정
- `docs`: 문서 수정/추가
- `refactor`: 구조 개선 (동작 변경 X)
- `perf`: 성능 개선
- `test`: 테스트 추가/수정
- `build`: 빌드 관련 변경
- `ci`: CI/CD 관련 변경
- `chore`: 기타 잡일

속성:
- `scope`: 영향을 받는 모듈/컴포넌트 (선택)
- `subject`: 핵심 한 줄 설명