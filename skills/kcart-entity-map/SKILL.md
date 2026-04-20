---
name: kcart-entity-map
description: Canonical enumeration of KCart Prisma models, API routes, components, user stories, and EIS docs. Use before creating any docs/wiki/ page to verify the source object exists. Triggers on "kcart entities", "which prisma models", "list endpoints", "wiki bootstrap", "does <Entity> exist", "enumerate domain", "kcart-wiki plugin".
---

# KCart Entity Map

Authoritative enumeration of KCart domain objects. **Never invent entities.** If a model, endpoint, component, story, or EIS is not listed in one of the authoritative sources below, it does not exist yet — do not create a wiki page for it.

## Authoritative Sources (in precedence order)

1. **`src/prisma/schema.prisma`** — ground truth for entity names and fields. (Note: the schema lives under `src/prisma/`, not a top-level `prisma/` directory.)
2. **`src/app/api/**/route.ts`** — ground truth for HTTP endpoints.
3. **`src/components/`** — ground truth for UI components.
4. **`docs/reference/stories/INDEX.md`** — ground truth for user stories.
5. **`docs/eis/EIS-*.md`** — ground truth for EIS (Event / Integration Spec) documents.

## How to Enumerate

### Entities (Prisma models)
```
Grep pattern: "^model\s+(\w+)\s*\{"  in file src/prisma/schema.prisma
Glob:         src/prisma/schema.prisma
```

### Endpoints
```
Glob: src/app/api/**/route.ts
```
Each file's path (minus `src/app/api/` prefix and `/route.ts` suffix) is the endpoint path. Methods (`GET`, `POST`, `PATCH`, `DELETE`) are exported as named functions inside each `route.ts`.

### Components
```
Glob: src/components/**/*.tsx
```

### User stories
```
Read: docs/reference/stories/INDEX.md
Glob: docs/reference/stories/US-*.md
```

### EIS documents
```
Glob: docs/eis/EIS-*.md
```

## Wiki Page Mapping Rule

| Source object         | Wiki page path                                        |
|-----------------------|-------------------------------------------------------|
| Prisma model `Foo`    | `docs/wiki/entities/Foo.md`                           |
| Endpoint `GET /x/y`   | `docs/wiki/endpoints/get-x-y.md` (lowercase, `/` -> `-`) |
| Story `US-123`        | `docs/wiki/stories/US-123.md`                         |
| EIS `EIS-045`         | `docs/wiki/eis/EIS-045.md`                            |

One page per source object. No speculative pages.

## Currency Rule

`src/prisma/schema.prisma` is the single source of truth for entity names and field shapes. When a wiki page references a field, **quote the schema** (include the field name, type, and any `@default` / `@db` decorators). Re-read the schema at the start of every wiki update — do not rely on memory.

## Never Hallucinate

If an agent considers writing a wiki page for an entity/endpoint/story/EIS that does not appear in the authoritative sources above, it must **stop** and either (a) find the source file, or (b) decline to create the page. Speculative wiki pages corrupt the map.
