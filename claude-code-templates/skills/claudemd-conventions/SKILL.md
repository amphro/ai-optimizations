---
name: claudemd-conventions
description: Apply when creating or updating any CLAUDE.md file. Rules for keeping CLAUDE.md files tight, effective, and under the instruction budget.
---

# CLAUDE.md Quality Rules

## The core principle
CLAUDE.md is advisory and burns instruction budget on EVERY session. The total budget is ~150-200 instructions. Claude Code's own system prompt uses ~50. You have roughly 100-150 lines left for everything across all loaded CLAUDE.md files combined.

Every line you add pushes another line out of memory. Write accordingly.

## What to include
Only include things Claude cannot correctly infer from reading the code:
- Non-obvious conventions specific to THIS project (e.g. "ADRs go in docs/decisions/")
- The commands to run for build/test/lint if non-standard
- Known gotchas or non-obvious behaviors that have caused mistakes before
- Architectural decisions that affect how new code should be written
- Specific workflow steps required for this project

## What NOT to include
- Standard language conventions Claude already knows
- Anything derivable by reading the code or project structure
- Long explanations, tutorials, or rationale (write a doc instead)
- File-by-file descriptions of the codebase
- Things that must always happen — use hooks instead (hooks are deterministic, CLAUDE.md is ~80% adherence)
- Information that changes frequently

## Format
- Use brief Markdown headers and short bullets
- No nested bullets more than one level deep
- No long paragraphs
- Each rule should be one line if possible

## The test
Before adding any line, ask: "Would removing this cause Claude to make a mistake on this project specifically?" If no — cut it. If the answer is "maybe" — it's probably already a standard convention. Cut it.

## After writing
Count the lines. If over 40 lines for a project CLAUDE.md, review every line with the test above and prune.
