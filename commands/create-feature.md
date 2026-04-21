---
description: Create a new EIS from a natural-language description, verified against the codebase
argument-hint: "<description of the feature to spec>"
allowed-tools: Agent, Read, Glob
---

# Add EIS to Wiki

Create a codebase-grounded Executable Implementation Spec from a natural-language description. Runs overlap detection and feasibility analysis before writing.

## Input
- `$1`: Quoted natural-language description of the feature to spec (e.g., `"real-time inventory tracking with low-stock alerts"`)

## Process

1. Parse the quoted description from `$1`. If empty or missing, ask the user to provide a feature description.
2. Report to user: "Analyzing feasibility and checking for overlaps..."
3. Read `docs/eis/` to confirm the directory exists. If not, create it.
4. Spawn an `eis-author` agent in foreground with task:
   ```
   nl_description: <the parsed description>
   ```
5. Wait for the agent to complete.
6. Present results to the user:
   - **EIS path**: the file created at `docs/eis/EIS-<###>-<slug>.md`
   - **Wiki page**: the companion page at `docs/wiki/eis/EIS-<###>.md`
   - **Feasibility summary**: entities (existing vs new), endpoints (existing vs new), components (existing vs new)
   - **Overlap warnings**: if the agent aborted due to overlap, relay the conflicting EIS and suggested action
   - **Complexity**: the S/M/L rating with rationale
