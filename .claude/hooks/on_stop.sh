#!/bin/bash
# Stop 훅 — Claude가 종료할 때 워크플로우 미완료 상태를 사용자에게 알림
# 이 출력은 터미널에 표시된다 (사용자 대상)

PROJECT="/Users/sinjong-won/ted.urssu/Artner-iOS"

exists() { [ -f "$PROJECT/$1" ] && echo "✅" || echo "⏳"; }

HAS_PLAN=$([ -f "$PROJECT/AI_PLAN.md" ] && echo "1" || echo "0")
HAS_REPORT=$([ -f "$PROJECT/AI_REPORT.md" ] && echo "1" || echo "0")

# Plan은 있는데 Report가 없으면 워크플로우 미완료
if [ "$HAS_PLAN" = "1" ] && [ "$HAS_REPORT" = "0" ]; then
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⚠️  [WORKFLOW] 파이프라인이 완료되지 않았습니다"
  echo ""
  echo "  $(exists AI_PLAN.md)            AI_PLAN.md"
  echo "  $(exists AI_CONTEXT.md)         AI_CONTEXT.md"
  echo "  $(exists AI_CHECKLIST_WORK.md)  AI_CHECKLIST_WORK.md"
  echo "  $(exists AI_QUALITY_REPORT.md)  AI_QUALITY_REPORT.md"
  echo "  $(exists AI_TEST_REPORT.md)     AI_TEST_REPORT.md"
  echo "  $(exists AI_REPORT.md)          AI_REPORT.md"
  echo ""
  echo "  👉 계속하려면: /orchestrate 재실행"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
fi

exit 0
