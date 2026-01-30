#!/usr/bin/env node
/**
 * Quick context saver - run before risky operations
 * Saves: recent conversation, current state, notes
 */

import { writeFileSync, mkdirSync, existsSync, readFileSync } from 'fs';
import { join } from 'path';
import { homedir } from 'os';

const CONTEXT_DIR = join(homedir(), '.openclaw/context-snapshots');

function ensureDir(dir) {
  if (!existsSync(dir)) mkdirSync(dir, { recursive: true });
}

const note = process.argv[2] || 'Manual context save';
const timestamp = new Date().toISOString();

const snapshot = {
  timestamp,
  note,
  whereWeAre: {
    problem: 'iMessage plugin sending duplicate messages (3x)',
    rootCause: 'Multiple poll loop instances running - startAccount called multiple times without cleanup',
    attempts: [
      'Added mutex (didnt work)',
      'Saved state before async dispatch (didnt work)', 
      'GROUP BY in SQL (didnt work)',
      'Full stop/start (still duplicating)'
    ],
    nextSteps: [
      'Check if register() is being called multiple times',
      'Check if OpenClaw core is calling startAccount multiple times',
      'Add instance logging to find actual source of duplicates',
      'Consider: global singleton pattern in plugin'
    ]
  },
  recentConfig: {
    channels: { 'imessage-legacy': { enabled: true, pollIntervalMs: 2000 } },
    plugins: { 'imessage-bridge': { enabled: true } }
  },
  filesTouched: [
    '~/clawd/imessage-bridge/index.js (multiple edits)',
    '~/.openclaw/openclaw.json (config patches)'
  ],
  time: '2:48 AM - debugging for hours'
};

ensureDir(CONTEXT_DIR);
const filename = `snapshot-${timestamp.replace(/[:.]/g, '-')}.json`;
const filepath = join(CONTEXT_DIR, filename);

writeFileSync(filepath, JSON.stringify(snapshot, null, 2));
writeFileSync(join(CONTEXT_DIR, 'LATEST'), filepath);

console.log('💾 Context saved:', filepath);
console.log('📝 Note:', note);
console.log('\nIf gateway crashes, run: node ~/clawd/checkpoint.js restore');
