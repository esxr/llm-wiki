---
description: "Learn about any KCart feature by spidering the wiki DAG — usage: /wiki-learn <feature-name> [--depth N]"
argument-hint: <feature-name> [--depth N]
allowed-tools: Agent, Read, Glob, Grep, Bash
---

# Wiki Learn

Learn about any KCart feature, entity, or concept by resolving it to a wiki page and spidering the DAG outward from that page.

## Input

- `$1`: Feature name (e.g., `checkout`, `orders`, `stripe`, `cart`)
- `--depth N`: Optional BFS depth limit (default 2)

## Process

### 1. Parse Arguments

Extract `<feature-name>` from `$1`. Extract `--depth N` if present; default to 2 if absent.

### 2. Resolve Feature Name to Wiki Page

Try these strategies in order, stopping at the first match:

**a) Exact match:** Check if `docs/wiki/features/<feature-name>.md` exists.

**b) Fuzzy match via index:** Grep for `<feature-name>` (case-insensitive) in `docs/wiki/index.md`. If one or more lines match, pick the best match — prefer exact title matches over substring matches. Extract the wiki-relative path from the matching line.

**c) Broad filename search:** Search across all `docs/wiki/**/*.md` filenames for `<feature-name>`. If found, use that path.

**d) Frontmatter search:** Grep across all `docs/wiki/**/*.md` file contents for `<feature-name>` in the YAML frontmatter or H1 heading. Pick the best match.

**e) No match:** If none of the above yields a result, report to the user:

> No wiki page found for '<feature-name>'. Run `/kcart-wiki:wiki-bootstrap` or `/kcart-wiki:wiki-reconcile` first.

Stop here — do not spider.

### 3. Spawn Wiki Spider

Spawn the `wiki-spider` agent with:
- `entry_page`: the resolved wiki-relative path (e.g. `features/checkout.md`)
- `depth`: the parsed depth value

Wait for the agent to complete and collect its brief output.

### 4. Present Results

Display the structured brief returned by `wiki-spider` to the user. Format it cleanly with markdown headings and bullet points.

If the brief contains an **Open Questions / Conflicts** section, highlight it prominently so the user notices stale or conflicting wiki state.
