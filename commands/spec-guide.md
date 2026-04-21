---
description: "Display the EIS (Executable Implementation Spec) writing guide — template, naming, sections, grounding rules"
allowed-tools: Read, Glob
---

# EIS Writing Guide

Display the EIS authoring conventions so you can review the template or prepare to write a new spec.

1. Read and display the EIS writing skill at `${CLAUDE_PLUGIN_ROOT}/skills/eis-writing/SKILL.md`.
2. List existing EIS files by running: `Glob docs/eis/EIS-*.md` — show the list so the user knows the current highest number and can see what's covered.
3. Summarize the key rules:
   - **Naming**: `EIS-###-<kebab-slug>.md` in `docs/eis/`, next sequential number
   - **8 required sections**: Problem, Scope, Solution Design, Files to Create, Files to Modify, Dependencies, Complexity, (plus title)
   - **Grounding rule**: every EIS must reference specific files/functions from an actual `src/` scan
   - **Overlap check**: never duplicate an existing EIS — extend or abort
   - **Wiki companion**: every new EIS gets a summary page at `docs/wiki/eis/`
4. If the user wants to actually create an EIS, direct them to `/wiki-add-eis "<description>"` instead.
