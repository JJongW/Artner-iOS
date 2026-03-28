#!/bin/bash
# =============================================================
# Claude Code 알림 훅 설치 스크립트
# 작업 완료 / 허락 대기 시 macOS 알림을 표시합니다.
#
# 사용법: bash setup-claude-notifications.sh
# =============================================================

set -e

CLAUDE_DIR="$HOME/.claude"
HOOKS_DIR="$CLAUDE_DIR/hooks"
SETTINGS_FILE="$CLAUDE_DIR/settings.json"

echo "🔧 Claude Code 알림 훅 설치 시작..."

# 1. terminal-notifier 설치 확인
if ! command -v terminal-notifier &>/dev/null; then
  echo "📦 terminal-notifier 설치 중..."
  brew install terminal-notifier
else
  echo "✅ terminal-notifier 이미 설치됨: $(which terminal-notifier)"
fi

NOTIFIER=$(which terminal-notifier)

# 2. 훅 디렉토리 생성
mkdir -p "$HOOKS_DIR"

# 3. notify_stop.sh 생성 (Claude 응답 완료 알림)
cat > "$HOOKS_DIR/notify_stop.sh" <<EOF
#!/bin/bash
$NOTIFIER \\
  -title "Claude Code ✅" \\
  -message "응답이 완료되었습니다." \\
  -sound "Glass"
EOF
chmod +x "$HOOKS_DIR/notify_stop.sh"
echo "✅ notify_stop.sh 생성 완료"

# 4. notify_permission.sh 생성 (허락 대기 알림)
cat > "$HOOKS_DIR/notify_permission.sh" <<'EOF'
#!/bin/bash
INPUT=$(cat)
MSG=$(echo "$INPUT" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message','확인이 필요합니다.'))" 2>/dev/null || echo "확인이 필요합니다.")
NOTIFIER=$(which terminal-notifier)
$NOTIFIER \
  -title "Claude Code 🔔" \
  -message "$MSG" \
  -sound "Ping"
EOF
chmod +x "$HOOKS_DIR/notify_permission.sh"
echo "✅ notify_permission.sh 생성 완료"

# 5. ~/.claude/settings.json 업데이트
# 기존 파일이 있으면 hooks 섹션만 병합, 없으면 새로 생성
if [ -f "$SETTINGS_FILE" ]; then
  # hooks 섹션 추가 (python3로 JSON 병합)
  python3 - "$SETTINGS_FILE" "$HOOKS_DIR" <<'PYEOF'
import sys, json

settings_path = sys.argv[1]
hooks_dir = sys.argv[2]

with open(settings_path, 'r') as f:
    settings = json.load(f)

settings.setdefault('hooks', {})
settings['hooks']['Stop'] = [{"hooks": [{"type": "command", "command": f"bash {hooks_dir}/notify_stop.sh"}]}]
settings['hooks']['Notification'] = [{"hooks": [{"type": "command", "command": f"bash {hooks_dir}/notify_permission.sh"}]}]

with open(settings_path, 'w') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write('\n')

print("✅ settings.json 업데이트 완료")
PYEOF
else
  # 새로 생성
  cat > "$SETTINGS_FILE" <<EOF
{
  "hooks": {
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash $HOOKS_DIR/notify_stop.sh"
          }
        ]
      }
    ],
    "Notification": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "bash $HOOKS_DIR/notify_permission.sh"
          }
        ]
      }
    ]
  }
}
EOF
  echo "✅ settings.json 생성 완료"
fi

# 6. 알림 테스트
echo ""
echo "🔔 알림 테스트 중..."
bash "$HOOKS_DIR/notify_stop.sh"

echo ""
echo "🎉 설치 완료!"
echo "   - 응답 완료 시: Glass 소리 + '응답이 완료되었습니다.' 알림"
echo "   - 허락 대기 시: Ping 소리 + 해당 메시지 알림"
echo ""
echo "⚠️  알림이 안 뜨면: 시스템 설정 → 알림 → terminal-notifier 허용"
