---
description: Manually trigger wiki reconciliation — drains .pending/changes.jsonl into wiki pages
argument-hint: (no arguments)
allowed-tools: Agent, Bash, Read
---

# Wiki Reconcile

Manually trigger the wiki-maintainer agent to drain pending changes into wiki pages.

## Process

1. Read `docs/wiki/.pending/changes.jsonl` and count the number of pending entries.
2. If the file is empty or does not exist, report "No pending changes to reconcile" and stop.
3. Report the count: "Found N pending change(s). Spawning wiki-maintainer..."
4. Spawn the `wiki-maintainer` agent in background, passing it the path `docs/wiki/.pending/changes.jsonl` as context.
5. Return immediately after spawning. The agent will report its own summary when finished.
