# Session Recovery System

## Quick Use

### Before Restarting Gateway (Auto-saves)
```bash
# This saves checkpoint + recent memory + context
node ~/clawd/save-context.js "About to restart for imessage fix"
```

### If Gateway Crashes / You Lose Context
```bash
# Restarts gateway AND feeds you memory summary
node ~/clawd/recover.sh
```

### Manual Checkpoint
```bash
node ~/clawd/checkpoint.js save "before-imessage-fix"
```

## Files

- `checkpoint.js` - Full checkpoint system with config snapshots
- `save-context.js` - Quick context saver (called automatically before risky ops)
- `recover.sh` - Recovery script that restores + summarizes
- `context-snapshots/` - Auto-saved context before restarts

## How It Works

1. **Before restart:** Context is saved to `~/.openclaw/context-snapshots/`
2. **On crash/recovery:** You can read the snapshot to remember where you were
3. **Checkpoints:** Full gateway state snapshots for major changes

## Integration with OpenClaw

Add to your shell profile for quick access:
```bash
alias ocp='node ~/clawd/checkpoint.js'
alias ocr='bash ~/clawd/recover.sh'
```
