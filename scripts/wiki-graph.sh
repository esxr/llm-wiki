#!/bin/bash
# wiki-graph.sh — Emit the wiki DAG as JSON for the spider agent.
#
# Walks docs/wiki/**/*.md (excluding schema.md, index.md, log.md), parses YAML
# frontmatter (type + related[]), and emits a JSON array on stdout.

set -uo pipefail

PROJECT_ROOT="${CLAUDE_PROJECT_ROOT:-$(pwd)}"
WIKI_DIR="${PROJECT_ROOT}/docs/wiki"

if [ ! -d "$WIKI_DIR" ]; then
  # No wiki yet — emit empty array and succeed
  echo "[]"
  exit 0
fi

python3 - "$WIKI_DIR" <<'PY'
import json
import os
import re
import sys

wiki_dir = sys.argv[1]
EXCLUDE = {"schema.md", "index.md", "log.md"}

entries = []
errors = []

for root, _dirs, files in os.walk(wiki_dir):
    # Skip hidden dirs like .pending
    _dirs[:] = [d for d in _dirs if not d.startswith(".")]
    for fname in files:
        if not fname.endswith(".md"):
            continue
        if fname in EXCLUDE:
            continue
        abs_path = os.path.join(root, fname)
        rel_path = os.path.relpath(abs_path, wiki_dir)

        try:
            with open(abs_path, "r", encoding="utf-8") as f:
                text = f.read()
        except Exception as e:
            errors.append(f"{rel_path}: read failed: {e}")
            continue

        # Parse YAML frontmatter delimited by --- at top
        m = re.match(r"^---\s*\n(.*?)\n---\s*(?:\n|$)", text, re.DOTALL)
        if not m:
            # No frontmatter — record with nulls
            entries.append({"path": rel_path, "type": None, "related": []})
            continue

        fm = m.group(1)

        # Extract `type:` (scalar)
        t_match = re.search(r"^type\s*:\s*(.+?)\s*$", fm, re.MULTILINE)
        ptype = t_match.group(1).strip().strip("'\"") if t_match else None

        # Extract `related:` — either flow-style [a, b] or block-style list
        related = []
        flow = re.search(r"^related\s*:\s*\[(.*?)\]\s*$", fm, re.MULTILINE | re.DOTALL)
        if flow:
            items = flow.group(1).split(",")
            related = [i.strip().strip("'\"") for i in items if i.strip()]
        else:
            block = re.search(
                r"^related\s*:\s*\n((?:[ \t]*-\s*.+\n?)+)",
                fm,
                re.MULTILINE,
            )
            if block:
                for line in block.group(1).splitlines():
                    item = re.match(r"^[ \t]*-\s*(.+?)\s*$", line)
                    if item:
                        related.append(item.group(1).strip().strip("'\""))

        entries.append({"path": rel_path, "type": ptype, "related": related})

# Sort for stable output
entries.sort(key=lambda e: e["path"])

if errors:
    for err in errors:
        print(f"wiki-graph parse error: {err}", file=sys.stderr)
    # Still emit what we have, but signal non-fatal via exit below
    json.dump(entries, sys.stdout, indent=2)
    sys.stdout.write("\n")
    sys.exit(1)

json.dump(entries, sys.stdout, indent=2)
sys.stdout.write("\n")
PY
