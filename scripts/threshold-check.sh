#!/bin/bash
# threshold-check.sh — PostToolUse hook: trigger wiki-maintainer when pending log ≥ 15.
#
# Counts lines in docs/wiki/.pending/changes.jsonl. If threshold reached, prints a
# prompt-injection message on stdout so the main conversation spawns wiki-maintainer.
# Exits 0 always — never blocks tool execution.

set -u

PROJECT_ROOT="${CLAUDE_PROJECT_ROOT:-$(pwd)}"
PENDING_LOG="${PROJECT_ROOT}/docs/wiki/.pending/changes.jsonl"
THRESHOLD=15

# Count pending entries (0 if file missing)
if [ -f "$PENDING_LOG" ]; then
  COUNT=$(wc -l < "$PENDING_LOG" 2>/dev/null | tr -d ' ' || echo 0)
else
  COUNT=0
fi

# Normalize to integer
case "$COUNT" in
  ''|*[!0-9]*) COUNT=0 ;;
esac

if [ "$COUNT" -lt "$THRESHOLD" ]; then
  exit 0
fi

# Emit prompt-hook trigger message on stdout
cat <<EOF
The wiki change log has reached the reconciliation threshold ($COUNT entries pending in docs/wiki/.pending/changes.jsonl). Please spawn the \`wiki-maintainer\` subagent to drain the pending log into docs/wiki/ pages, updating index.md and appending a log.md entry. Do this in the background so the user's current task isn't interrupted.
EOF

exit 0
