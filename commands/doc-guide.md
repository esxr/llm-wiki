---
description: "Display wiki conventions and editing rules — the contract every wiki edit must satisfy"
allowed-tools: Read
---

# Wiki Conventions

Display the wiki editing contract so you can review or reference it.

1. Read and display `docs/wiki/schema.md` in full — this is the authoritative conventions document.
2. Summarize the 5 key rules at the top:
   - **Frontmatter**: every page needs `type`, `raw_sources`, `related`, `last_reconciled`, `status`
   - **Links**: relative markdown only, bidirectional (`related:` on both ends)
   - **Page creation**: only when ≥2 raw sources reference a concept or lint flagged it missing
   - **Contradictions**: never silently overwrite — open a `## ⚠ Conflict` section
   - **Exclusion**: wiki edits never trigger the change-logging hook (docs/wiki/ is excluded)
3. If the user asks a follow-up question about conventions, answer from schema.md content.
