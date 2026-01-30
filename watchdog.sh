#!/bin/bash
# OpenClaw Watchdog - Safe gateway health monitoring
# Only restarts if gateway is actually down, never kills it

LOG_FILE="$HOME/.openclaw/watchdog.log"

log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if gateway is running (safe check, no side effects)
is_gateway_running() {
  pgrep -f "openclaw" > /dev/null 2>&1
}

# Main
if is_gateway_running; then
  # All good, silent unless verbose
  exit 0
else
  log "Gateway appears DOWN - attempting restart"
  nohup openclaw gateway start > /dev/null 2>&1 &
  sleep 5
  
  if is_gateway_running; then
    log "Gateway restarted successfully"
  else
    log "FAILED to restart gateway"
  fi
fi
