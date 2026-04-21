---
description: "Enumerate project domain entities, endpoints, stories, and EIS from authoritative sources — never hallucinate"
allowed-tools: Read, Glob, Grep
---

# Entity Map

Enumerate the canonical domain objects from their authoritative sources.

**Before probing any paths:** check whether `.claude/plugins/product-wiki/entity-map.json` exists. If it does, read it for path overrides; otherwise use the probe-order defaults below.

1. **Prisma models**: Locate the schema file — try `src/prisma/schema.prisma` first, then `prisma/schema.prisma`. Grep for `^model\s+(\w+)` — list all model names grouped by domain (Auth, Products, Orders, Cart, Shipping, Settings, etc.).
2. **API endpoints**: Glob `src/app/api/**/route.ts` (fall back to `app/api/**/route.ts` if the `src/` variant yields nothing) — list each route path and its HTTP methods.
3. **User stories**: Read `docs/reference/stories/INDEX.md` — list all US-### entries.
4. **EIS documents**: Glob `docs/eis/EIS-*.md` — list all specs.
5. **Components** (if asked): Glob `src/components/**/*.tsx` (fall back to `components/**/*.tsx`) — list component files.

Present as a structured table per category. Include counts.

If the user asks about a specific entity, grep for it across the authoritative sources and the wiki (`docs/wiki/`) to show where it appears.

**Rule**: if something doesn't appear in an authoritative source, it does not exist — say so explicitly rather than guessing.
