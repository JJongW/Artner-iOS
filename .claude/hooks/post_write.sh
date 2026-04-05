#!/bin/bash
# PostToolUse[Write|Edit] 훅 — 워크플로우 문서 생성/수정 시 다음 단계 피드백
# stdout이 Claude에게 피드백으로 전달되어 다음 단계로 자동 진행을 유도한다

# 실행 위치 기반으로 프로젝트 경로를 동적으로 결정 (하드코딩 방지)
PROJECT="$(cd "$(dirname "$0")/../.." && pwd)"
NOW=$(date +%s)

check_recent() {
  local FILE="$PROJECT/$1"
  local MSG="$2"
  if [ -f "$FILE" ]; then
    MTIME=$(stat -f "%m" "$FILE" 2>/dev/null || echo 0)
    AGE=$((NOW - MTIME))
    if [ "$AGE" -lt 10 ]; then
      echo "$MSG"
      return 0
    fi
  fi
  return 1
}

check_recent "AI_PLAN.md"             "📋 [WORKFLOW] ✅ Step 1 완료: AI_PLAN.md 생성됨 — 즉시 AI_CONTEXT.md 생성으로 진행" && exit 0
check_recent "AI_CONTEXT.md"          "🔍 [WORKFLOW] ✅ Step 2 완료: AI_CONTEXT.md 생성됨 — 즉시 AI_CHECKLIST_WORK.md 생성으로 진행" && exit 0
check_recent "AI_CHECKLIST_WORK.md"   "✅ [WORKFLOW] Step 3 완료: AI_CHECKLIST_WORK.md 생성됨 — 즉시 사전 Self-Check 실행으로 진행" && exit 0
check_recent "AI_QUALITY_REPORT.md"   "🏆 [WORKFLOW] Step 7 완료: 품질 검토 완료 — 즉시 Test 설계(agent.test_design)로 진행" && exit 0
check_recent "AI_TEST_REPORT.md"      "🧪 [WORKFLOW] Step 8 완료: Test 설계 완료 — 즉시 최종 리포트(workflow.report)로 진행" && exit 0
check_recent "AI_REPORT.md"           "📄 [WORKFLOW] ✅ PHASE 5 완료: 모든 문서 생성됨 — PHASE 6 Ship 확인 단계로 진행" && exit 0

exit 0
