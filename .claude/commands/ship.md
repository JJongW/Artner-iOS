# Ship — 변경사항 커밋 및 푸시

이 커맨드는 워크플로우가 완료된 후 변경사항을 git에 커밋하고 푸시합니다.

## 실행 전 확인

다음 파일이 존재하는지 확인합니다:
- `AI_REPORT.md` — 없으면 "워크플로우 미완료. /orchestrate를 먼저 실행하세요" 안내

## 실행 순서

### Step 1: 변경 상태 확인
```
git status
git diff --stat
```

### Step 2: 커밋 메시지 생성
`AI_REPORT.md`의 "결론 요약"과 변경 파일 기반으로 커밋 메시지 작성:
```
{type}: {요약}

- {변경 내용 1}
- {변경 내용 2}

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```
type: feat / fix / refactor / chore / docs

### Step 3: 사용자 확인
생성한 커밋 메시지를 보여주고 확인 요청:
> "위 메시지로 커밋하고 push 하시겠습니까?"

### Step 4: 커밋 및 푸시 (확인 후)
```bash
git add -p  # 또는 변경 파일 개별 지정
git commit -m "..."
git push
```

### Step 5: 완료 보고
```
✅ Ship 완료
   브랜치: {현재 브랜치}
   커밋: {커밋 해시}
   변경 파일: N개
```

## 적용할 작업
$ARGUMENTS
