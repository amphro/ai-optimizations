---
name: update-research
description: Refreshes research/*.md with current AI model info, pricing, and Claude Code features via web search. Use when the research feels stale or you want to check what's changed since the last snapshot.
---

# Update Research

The files in `research/` are point-in-time snapshots, each with a `Last updated` date near the top. This skill brings them current.

## Step 1: Check what's there

Read every file in `research/` and note its `Last updated` date and the specific claims it makes (model names, prices, feature names, benchmark numbers, API/header versions). These are the things most likely to drift.

## Step 2: Search for what changed

For each file, search the web for updates on its topic:
- `research/ai-model-landscape.md` — current models and pricing across major providers
- `research/orchestration-patterns.md` — new multi-agent or orchestration guidance from Anthropic
- `research/best-practices.md` — updated prompting/context engineering guidance, new Claude-specific tips
- `research/claude-code-setup.md` — current Claude Code model aliases, effort levels, settings.json options

Prefer official docs and primary sources over blog posts or aggregators.

## Step 3: Diff against the file

For each fact you checked, decide: still accurate, changed, or no longer mentioned anywhere (deprecated). Don't rewrite things that haven't changed.

## Step 4: Update

- Edit only what's actually changed.
- Bump the `Last updated` date on any file you touched.
- Keep the existing tone and format (TL;DR sections, tables, sources list) rather than restructuring.
- Add new sources to the `Sources` list if you used new ones.

## Step 5: Report

Summarize what changed per file, in one or two lines each: what was outdated, what it's now. If nothing changed in a file, say so rather than padding the diff.

If something you found would change a recommendation in `claude-code-templates/` (a setting, an agent, a skill), mention it explicitly so the user knows to run the `update-templates` skill next. Don't touch `claude-code-templates/` yourself from this skill.
