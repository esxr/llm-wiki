---
description: Health-check the wiki DAG — finds orphans, broken links, stale pages, contradictions, and missing entities
argument-hint: (no arguments)
allowed-tools: Agent, Bash, Read
---

# Wiki Lint

Run the wiki-linter agent to health-check the entire wiki DAG.

## Process

1. Report: "Running wiki health checks..."
2. Spawn the `wiki-linter` agent in background.
3. When the agent completes, present the full lint report to the user.
4. If the total issue count is greater than 0:
   - For **stale pages**: suggest running `/sync` to drain pending changes and refresh reconciliation dates.
   - For **contradictions**: advise manual review — agents do not auto-resolve conflicts per schema section 6.
   - For **orphans, broken links, asymmetric links, missing pages, or index inconsistencies**: offer to run the linter in fix mode if the user wants automated remediation.
5. If no issues found, report "Wiki is clean — no issues detected."
