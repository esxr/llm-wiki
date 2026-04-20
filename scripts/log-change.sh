#!/bin/bash
# log-change.sh — PostToolUse hook: append one JSONL entry per qualifying file change.
#
# Reads hook JSON from stdin, filters to src/, docs/, prisma/ (excluding docs/wiki/
# and .claude/), and appends {ts,tool,path,ref} to docs/wiki/.pending/changes.jsonl.
#
# Never blocks the tool — exits 0 on every path, silently `|| true`s anything risky.

set -u

PROJECT_ROOT="/Users/pranav/Desktop/kcart"
PENDING_DIR="${PROJECT_ROOT}/docs/wiki/.pending"
PENDING_LOG="${PENDING_DIR}/changes.jsonl"

# Read all of stdin into a variable (empty-safe)
INPUT="$(cat || true)"
[ -z "$INPUT" ] && exit 0

# Extract tool_name and file_path
TOOL_NAME=$(printf '%s' "$INPUT" | jq -r '.tool_name // empty' 2>/dev/null || true)
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // empty' 2>/dev/null || true)

# Gate on tool type
case "$TOOL_NAME" in
  Edit|Write|MultiEdit) ;;
  *) exit 0 ;;
esac

[ -z "$FILE_PATH" ] && exit 0

# Resolve to path relative to project root
case "$FILE_PATH" in
  "${PROJECT_ROOT}/"*)
    REL_PATH="${FILE_PATH#${PROJECT_ROOT}/}"
    ;;
  /*)
    # Absolute path outside project — ignore
    exit 0
    ;;
  *)
    REL_PATH="$FILE_PATH"
    ;;
esac

# Filter: accept only src/, docs/, prisma/; reject docs/wiki/ and .claude/
case "$REL_PATH" in
  docs/wiki/*) exit 0 ;;
  .claude/*) exit 0 ;;
  src/*|docs/*|prisma/*) ;;
  *) exit 0 ;;
esac

# Compute short git ref — fast path via git log, fallback to "(new)"
REF=$(cd "$PROJECT_ROOT" 2>/dev/null && git log -n1 --format=%h -- "$REL_PATH" 2>/dev/null || true)
[ -z "$REF" ] && REF="(new)"

# Timestamp (UTC, ISO 8601)
TS=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || true)

# Ensure pending dir exists
mkdir -p "$PENDING_DIR" 2>/dev/null || true

# Emit JSONL line — use jq for proper escaping
LINE=$(jq -nc \
  --arg ts "$TS" \
  --arg tool "$TOOL_NAME" \
  --arg path "$REL_PATH" \
  --arg ref "$REF" \
  '{ts:$ts, tool:$tool, path:$path, ref:$ref}' 2>/dev/null || true)

[ -z "$LINE" ] && exit 0

printf '%s\n' "$LINE" >> "$PENDING_LOG" 2>/dev/null || true

exit 0
