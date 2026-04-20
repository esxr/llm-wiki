---
description: One-time bootstrap — populate docs/wiki/ from existing codebase sources (Prisma models, API routes, stories, EIS)
argument-hint: (no arguments)
allowed-tools: Agent, Bash, Read, Write, Edit, Glob, Grep
---

# Wiki Bootstrap

One-time population of `docs/wiki/` from authoritative codebase sources. You are the orchestrator — delegate heavy lifting to parallel subagents where possible, then cross-link and index the results.

Before starting, read these two files:
- `docs/wiki/schema.md` — the wiki contract (frontmatter spec, link rules, page-creation rules)
- `.claude/plugins/kcart-wiki/skills/kcart-entity-map/SKILL.md` — canonical source locations and enumeration patterns

Obey every convention in those files. Violations corrupt the wiki.

---

## Pre-check

1. Read `docs/wiki/index.md`.
2. If the file contains real entries (more than just category headings or stub text), warn the user:

   > Wiki already has content. Running bootstrap will overwrite stubs but skip pages that already exist. Continue? [y/N]

   Use `AskUserQuestion` and abort if the user declines.
3. If the file is empty, missing, or contains only headings/stubs, proceed without asking.

---

## Phase 1 — Entities (from Prisma)

Read `src/prisma/schema.prisma` (if not found, check `prisma/schema.prisma`).

For each `model` block in the schema, create `docs/wiki/entities/<ModelName>.md` with:

**Frontmatter:**
```yaml
---
type: entity
raw_sources:
  - src/prisma/schema.prisma
related: []
last_reconciled: <today YYYY-MM-DD>
status: current
---
```

**Body:**
```markdown
# <ModelName>

<One-sentence description derived from field names and relations.>

## Fields

| Field | Type | Attributes |
|-------|------|------------|
| id    | String | @id @default(cuid()) |
| ...   | ...  | ... |

## Relations

- [RelatedModel](RelatedModel.md) — <nature of relation>
```

Leave the `related:` frontmatter array empty for now — Phase 6 fills it.

**Skip rule:** If `docs/wiki/entities/<ModelName>.md` already exists, do not overwrite it.

---

## Phase 2 — Endpoints (from API routes)

Glob `src/app/api/**/route.ts`.

For each route file, create **one** wiki page at `docs/wiki/endpoints/<path-slug>.md` where `<path-slug>` is the route path with slashes replaced by dashes, lowercased (e.g. `src/app/api/orders/[id]/route.ts` becomes `orders-[id].md`).

Read each `route.ts` to determine which HTTP methods are exported (`GET`, `POST`, `PUT`, `DELETE`, `PATCH`).

**Frontmatter:**
```yaml
---
type: endpoint
raw_sources:
  - <path to the route.ts file>
related: []
last_reconciled: <today YYYY-MM-DD>
status: current
---
```

**Body:**
```markdown
# <METHOD(s)> /api/<path>

<Brief description of what each handler does, derived from reading the file.>

## Methods

### GET
<What it returns, if exported.>

### POST
<What it creates/does, if exported.>

<...repeat for each exported method.>
```

**Skip rule:** If the endpoint page already exists, do not overwrite it.

---

## Phase 3 — User Stories

Read `docs/reference/stories/INDEX.md`.

For each story entry (identified by `US-###`), create `docs/wiki/stories/US-###.md`.

Locate and read the story's source file — check `docs/reference/stories/US-###/story.md` and also `docs/reference/stories/US-###_*/story.md` (some directories include a title suffix).

**Frontmatter:**
```yaml
---
type: story
raw_sources:
  - <path to story.md>
related: []
last_reconciled: <today YYYY-MM-DD>
status: current
---
```

**Body:**
```markdown
# US-### — <Story Title>

<One-paragraph summary of the story.>

## References

- [Full Story](<relative path to story.md from repo root>)
- [Flow](<path to flow.md if it exists>) — omit if not found
- [Sequence](<path to sequence.md if it exists>) — omit if not found
```

**Skip rule:** If `docs/wiki/stories/US-###.md` already exists, do not overwrite it.

---

## Phase 4 — EIS (External Integration Specs)

Glob `docs/eis/EIS-*.md`.

For each file, create `docs/wiki/eis/EIS-###.md` (match the number from the filename).

Read each EIS source file to extract the title, summary, and scope.

**Frontmatter:**
```yaml
---
type: eis
raw_sources:
  - <path to the EIS file>
related: []
last_reconciled: <today YYYY-MM-DD>
status: current
---
```

**Body:**
```markdown
# EIS-### — <Title>

<2-3 line summary of the integration.>

## Scope

<Scope section content, summarized.>
```

**Skip rule:** If `docs/wiki/eis/EIS-###.md` already exists, do not overwrite it.

---

## Phase 5 — Features (synthesized)

**This phase depends on Phases 1-4 completing first.**

Review all pages created in Phases 1-4. Identify major feature areas by grouping related entities, endpoints, stories, and EIS documents. Typical feature areas include (but are not limited to):

- **Auth** — login, registration, password reset, tenant membership
- **Products** — product catalog, variants, categories, manufacturers
- **Orders** — order lifecycle, invoices, packing, returns
- **Cart** — cart management, cart items
- **Checkout** — cart-to-order conversion, payment
- **Customers** — customer management, addresses, ledgers
- **Discounts** — discount rules and application
- **Shipping** — shipping packages, wallets, settings
- **Storefront** — public-facing store pages, page builder
- **Dashboard** — admin UI, reports, settings
- **Marketing** — SEO labels, market i18n

Only create a feature page if it groups at least two wiki pages from earlier phases. Do not create speculative features with no backing pages.

For each feature, create `docs/wiki/features/<Feature>.md` (PascalCase or kebab-case matching the feature name).

**Frontmatter:**
```yaml
---
type: feature
raw_sources: []
related: []
last_reconciled: <today YYYY-MM-DD>
status: current
---
```

**Body:**
```markdown
# <Feature Name>

<What this feature does, 2-3 sentences.>

## Involves

### Entities
- [EntityName](../entities/EntityName.md)

### Endpoints
- [METHOD /api/path](../endpoints/path-slug.md)

### Stories
- [US-### — Title](../stories/US-###.md)

### EIS
- [EIS-### — Title](../eis/EIS-###.md)
```

Only include subsections that have entries. Omit empty subsections.

---

## Phase 6 — Cross-link and Index

**This phase depends on all previous phases completing.**

### 6a. Cross-link `related` arrays

Walk every wiki page created during this bootstrap. For each page:

1. Determine which other wiki pages it should relate to — based on entity relations (Prisma foreign keys), endpoint-to-entity usage, story-to-entity/endpoint references, EIS-to-feature connections, and feature groupings.
2. Add those paths to the page's `related:` frontmatter array using wiki-relative paths (e.g. `../features/checkout.md`, `Order.md` for same-directory).
3. Ensure bidirectionality: if page A lists page B in `related`, page B must also list page A.

### 6b. Rebuild `index.md`

Regenerate `docs/wiki/index.md` from scratch. Group pages by type in this order: Entities, Features, Stories, EIS, Flows, Components, Endpoints, Queries. Use this format for each entry:

```markdown
- [Title](relative/path.md) — one-line summary
```

Omit category sections that have no pages. The title must match the page's H1.

### 6c. Append to `log.md`

Append exactly one entry to `docs/wiki/log.md`:

```markdown
## [YYYY-MM-DD HH:MM] bootstrap | Created N pages across K categories

- entities/Foo.md
- entities/Bar.md
- endpoints/orders.md
- stories/US-001.md
- ...

Initial wiki bootstrap from codebase sources.
```

List every page created (wiki-relative paths). Include the total count in the header.

---

## Parallelism

Phases 1, 2, 3, and 4 are **independent** — run them as parallel subagents or parallel tool calls. Do not wait for one to finish before starting another.

Phase 5 depends on Phases 1-4 completing. Phase 6 depends on Phase 5 completing.

---

## Final Report

After all phases complete, report to the user:

```
Wiki bootstrap complete.
  Entities:  X pages
  Endpoints: X pages
  Stories:   X pages
  EIS:       X pages
  Features:  X pages
  Total:     X pages across Y categories
  Cross-links applied. Index rebuilt. Log updated.
```
