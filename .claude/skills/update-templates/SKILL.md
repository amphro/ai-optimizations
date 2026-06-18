---
name: update-templates
description: Aligns claude-code-templates/ (settings, CLAUDE.md, agents, skills) with the current research/ findings. Use after update-research, or whenever you've learned something new worth baking into the starting templates.
---

# Update Templates

`claude-code-templates/` is the local, generic starting point that the `deploy-config` skill pushes to `~/.claude/`. This skill keeps it aligned with what's in `research/` so the starting point stays good advice, not stale advice.

This skill only touches files under `claude-code-templates/`. It never reads or writes anything under `~/.claude/` — that's `deploy-config`'s job, and keeping them separate means you can update the templates without touching your live setup until you're ready.

## Step 1: Read both sides

Read all of `research/*.md` and all of `claude-code-templates/` (`user-settings.json`, `user-CLAUDE.md`, `skills/*/SKILL.md`, `agents/*.md`).

## Step 2: Find the gaps

Look for places where research recommends something the templates don't reflect:
- A model alias, effort level, or settings.json key the research now recommends that's missing or outdated in `user-settings.json`
- A workflow rule in the research that should be a line in `user-CLAUDE.md`
- A reviewer persona or domain that's missing from `agents/`, or guidance in an existing agent that's now outdated
- A pattern from `orchestration-patterns.md` or `best-practices.md` that should change how `smart-review` or `claudemd-conventions` works

Also check for drift the other direction: something in the templates that the research no longer supports (a deprecated alias, an outdated number).

## Step 3: Update

Make the changes directly in `claude-code-templates/`. Keep these generic and instance-agnostic. No absolute paths, no specifics from any one person's setup. Keep `user-CLAUDE.md` under 50 lines, same discipline as the `claudemd-conventions` skill describes.

## Step 4: Report

List what changed, file by file, and which research finding justified each change. If you considered a change and decided against it, say why (e.g. "research mentions X but it's too narrow/personal to bake into a generic template").

Remind the user that the live `~/.claude/` config won't reflect these changes until they run `deploy-config`.
