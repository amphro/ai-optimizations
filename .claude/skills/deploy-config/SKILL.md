---
name: deploy-config
description: Deploys tools/claude-code/ (settings, CLAUDE.md, skills, agents) to your global ~/.claude/ directory. Asks before overwriting anything that already exists and differs. Use to set up a new machine or pick up template changes.
---

# Deploy Config

Pushes the generic templates in `tools/claude-code/` out to your real global Claude Code config at `~/.claude/`. This only ever deploys the templates folder — never the maintenance skills in this repo's own `.claude/skills/` (including this one).

The one rule that matters more than any other: **never silently overwrite a file that already exists and differs from the template.** If it's new, create it. If it's identical, skip it. If it's different, ask.

## What deploys where

| Source | Target | Merge strategy |
|---|---|---|
| `tools/claude-code/user-settings.json` | `~/.claude/settings.json` | Key-by-key merge |
| `tools/claude-code/user-CLAUDE.md` | `~/.claude/CLAUDE.md` | Section-by-section merge |
| `tools/claude-code/skills/*/SKILL.md` | `~/.claude/skills/*/SKILL.md` | Whole-file, ask on conflict |
| `tools/claude-code/agents/*.md` | `~/.claude/agents/*.md` | Whole-file, ask on conflict |
| `tools/claude-code/statusline.sh` | `~/.claude/statusline.sh` | Whole-file, ask on conflict; `chmod +x` after writing |
| `tools/claude-code/hooks/*.sh` | `~/.claude/hooks/*.sh` | Whole-file, ask on conflict; `chmod +x` after writing |

## Step 1: Read before writing anything

Read every source file in `tools/claude-code/`, then read every corresponding target under `~/.claude/` that exists. Build a picture of the full diff before touching anything.

## Step 2: Classify each target

For each file:
- **Missing** — target doesn't exist yet. Create it. No need to ask.
- **Identical** — target exists and matches what you'd write. Skip it.
- **Conflicting** — target exists and differs. Do not write it yet — queue it for step 3.

For `settings.json`, do this at the key level rather than the whole file: a key present in the template but absent locally is "missing" (add it), a key present in both with the same value is "identical" (skip it), a key present in both with different values is "conflicting" (queue it).

For `CLAUDE.md`, do this at the section level: a template section whose heading doesn't exist locally is "missing" (append it), a section that exists locally with the same content is "identical," a section that exists locally with different content is "conflicting."

## Step 3: Ask about conflicts, once, with all the detail

If there are zero conflicts, skip this step. Otherwise, show the user every conflicting file/key/section with a short diff (old vs new) and ask how to resolve each one: keep the existing local version, take the template version, or skip it for now. Don't guess and don't overwrite first and mention it after.

## Step 4: Write

Apply missing additions, the merges from step 2, and whatever the user decided in step 3. Create `~/.claude/skills/`, `~/.claude/agents/`, and `~/.claude/hooks/` directories if they don't exist yet.

## Step 5: Report

Show a summary table: created / merged / skipped (identical) / skipped (user chose to keep local) per file. Then show the final contents of `~/.claude/settings.json` and `~/.claude/CLAUDE.md` so the user can verify at a glance.

## Idempotency

Running this skill twice in a row with no template changes in between should report everything as "identical, skipped" the second time and write nothing. If it doesn't, something in the merge logic is wrong.
