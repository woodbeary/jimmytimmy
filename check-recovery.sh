#!/bin/bash
# Auto-recovery script - source this in your shell profile or run manually after restart

echo "🔍 Checking for recovery needs..."

# Check if gateway died
if ! pgrep -f "openclaw-gateway" > /dev/null; then
  echo "⚠️  Gateway is down!"
  echo "Run: openclaw gateway start"
fi

# Check for recovery notes
if [ -f "$HOME/clawd/RECOVERY_NEEDED.txt" ]; then
  echo ""
  echo "🚨 RECOVERY NOTES FOUND:"
  cat "$HOME/clawd/RECOVERY_NEEDED.txt"
  echo ""
fi

# Check iMessage fix status
if [ -f "$HOME/.openclaw/imessage-fix-state.json" ]; then
  echo "📊 iMessage Fix Status:"
  cat "$HOME/.openclaw/imessage-fix-state.json" | grep -E '"status"|"consecutivePasses"|"lastTest"'
  echo ""
fi

# List latest checkpoint
echo "💾 Latest Checkpoint:"
ls -la ~/.openclaw/checkpoints/ | tail -3

