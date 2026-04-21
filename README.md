# llm-wiki

A Claude Code plugin that builds persistent, compounding knowledge bases inside Obsidian using the Karpathy LLM Wiki pattern. Ingest sources, query synthesized knowledge, lint for gaps — all from your Claude Code session. It maintains `docs/wiki/` as a self-healing DAG of LLM-authored pages, automatically kept in sync as your codebase evolves.

---

## How it works

Every time Claude edits a source file, a `PostToolUse` hook logs the change. When enough changes accumulate, a background agent reconciles them into structured wiki pages — without interrupting your flow.

```
File edit → changes.jsonl → wiki-maintainer agent → wiki DAG → bidirectional cross-links
```

The wiki is a **directed acyclic graph**: each page tracks its raw source files in frontmatter, and all cross-references are bidirectional. Pages are typed: `entity`, `feature`, `endpoint`, `story`, `eis`. The graph can be linted, spidered, and reconciled on demand.

---

## Commands

| Command | Description |
|---------|-------------|
| `/init` | One-time population of `docs/wiki/` from Prisma models, API routes, user stories, and EIS documents. Runs phases in parallel and cross-links all results. |
| `/sync` | Manually drain `.pending/changes.jsonl` into wiki pages. Useful after a large refactor. |
| `/audit` | Health-check the wiki DAG — finds orphans, broken links, stale pages, contradictions, and asymmetric cross-references. |
| `/explore-feature <feature>` | Spider the wiki DAG from any entry point up to a configurable BFS depth. Returns a structured brief of everything the wiki knows about that topic. |
| `/create-feature <description>` | Author a new Executable Implementation Spec from a natural-language description, with overlap detection and feasibility analysis. |

---

## Wiki structure

```
docs/wiki/
├── index.md              # auto-rebuilt master index
├── log.md                # append-only drain history
├── schema.md             # wiki contract (frontmatter spec, link rules)
├── .pending/
│   └── changes.jsonl     # hook-written pending queue
├── entities/             # one page per Prisma model
├── features/             # synthesized feature areas
├── endpoints/            # one page per API route
├── stories/              # user story summaries
└── eis/                  # executable implementation specs
```

---

## Architecture

**Agents**
- `wiki-maintainer` — drains the pending queue into wiki page updates
- `wiki-linter` — health-checks the entire wiki DAG
- `wiki-spider` — BFS traversal from an entry point page
- `eis-author` — authors Executable Implementation Specs with codebase grounding

**Hooks (PostToolUse)**
- `log-change.sh` — appends one JSONL entry per qualifying file change to `.pending/changes.jsonl`
- `threshold-check.sh` — counts the queue and auto-spawns the maintainer when the threshold is crossed
- `wiki-graph.sh` — utility for graph queries

**Skills**
- `doc-guide` — schema contract reference (frontmatter rules, link rules, contradiction protocol)
- `spec-guide` — conventions for authoring EIS documents
- `product-map` — canonical source locations for entity enumeration (Prisma models, API routes, stories, EIS docs)

---

## Zero-friction sync

Whenever Claude edits a file in `src/`, `docs/`, or `prisma/`, `log-change.sh` appends a timestamped entry to the pending queue. When the queue crosses the threshold (default: 10 changes), `wiki-maintainer` drains it automatically.

The drain is **idempotent** — safe to run at any queue depth. It reads raw sources, reconciles changes into existing wiki pages, handles contradictions by flagging them (not silently overwriting), and truncates the queue only after full success.

---

## Install

Add the `product-wiki` marketplace and install the plugin in three commands:

```
/plugin marketplace add esxr/product-wiki
/plugin install product-wiki@pranav.com.au
/reload-plugins
```

---

## Getting started

```bash
# After installing, bootstrap from your existing codebase:
/init

# Hooks maintain the wiki automatically from here.
# Run /audit any time to health-check the graph.
```

---

## Inspiration

llm-wiki is an extension of **Andrej Karpathy's** original idea for using language models to maintain living documentation alongside code. The core insight — that LLMs should be first-class authors of a project's knowledge graph, not just consumers of it — comes directly from his work.

Original idea: https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f

---

## License

MIT
