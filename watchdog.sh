#!/bin/bash
# OpenClaw Watchdog - Runs independently, survives agent restarts
# Checks gateway health and iMessage fix progress

LOG_FILE="$HOME/.openclaw/watchdog.log"
STATE_FILE="$HOME/.openclaw/imessage-fix-state.json"
CHECKPOINT_DIR="$HOME/.openclaw/checkpoints"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check if gateway is running
check_gateway() {
  if pgrep -f "openclaw-gateway" > /dev/null; then
    echo "running"
  else
    echo "down"
  fi
}

# Restart gateway
restart_gateway() {
  log "Gateway down! Attempting restart..."
  openclaw gateway start &
  sleep 5
  if [ "$(check_gateway)" = "running" ]; then
    log "Gateway restarted successfully"
    # Notify that we're back
    echo "Gateway was restarted by watchdog at $(date)" >> "$HOME/clawd/RECOVERY_NEEDED.txt"
  else
    log "FAILED to restart gateway!"
  fi
}

# Check iMessage fix progress
check_imessage_progress() {
  if [ -f "$STATE_FILE" ]; then
    local status=$(cat "$STATE_FILE" | grep -o '"status":"[^"]*"' | cut -d'"' -f4)
    local last_test=$(cat "$STATE_FILE" | grep -o '"lastTest":[0-9]*' | cut -d':' -f2)
    local consecutive_passes=$(cat "$STATE_FILE" | grep -o '"consecutivePasses":[0-9]*' | cut -d':' -f2)
    
    if [ -z "$consecutive_passes" ]; then
      consecutive_passes=0
    fi
    
    local now=$(date +%s)
    local elapsed=$((now - last_test))
    
    log "iMessage fix status: $status, passes: $consecutive_passes, last test: ${elapsed}s ago"
    
    # If no progress for 10 minutes, something is wrong
    if [ "$elapsed" -gt 600 ]; then
      log "WARNING: No test results for 10+ minutes!"
      echo "Stalled at $(date) - no updates for ${elapsed}s" >> "$HOME/clawd/RECOVERY_NEEDED.txt"
    fi
    
    # If we've hit 10 passes, we're done
    if [ "$consecutive_passes" -ge 10 ]; then
      log "SUCCESS: iMessage fix complete with $consecutive_passes consecutive passes!"
      # Could send notification here
    fi
  else
    log "No state file found - iMessage fix not started or state lost"
  fi
}

# Main watchdog loop
main() {
  log "Watchdog check starting..."
  
  # Check gateway
  GW_STATUS=$(check_gateway)
  if [ "$GW_STATUS" = "down" ]; then
    restart_gateway
  else
    log "Gateway running OK"
  fi
  
  # Check iMessage progress
  check_imessage_progress
  
  log "Watchdog check complete"
}

# Run
main
