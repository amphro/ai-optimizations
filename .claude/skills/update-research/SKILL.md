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
- `research/hooks.md` — new hook event types, changed JSON schemas, new community patterns worth noting
- `research/usage-limit-visibility.md` — any new official way to check usage limits
- `research/writing-voice-personas.md` — new style/persona features from Claude, ChatGPT, or other tools; new community consensus on AI writing tells. **After updating this file, also update `benchmark/writing-style-config.json`** — sync the `ai_cliches` and `filler_words` word lists to match the current research on what AI models actually overuse. The benchmark scorer reads that config directly; no other file needs changing.
- `docs/index.html` — AI/LLM definitions and term definitions (all 6 persona levels)
- `docs/claude-code/index.html` — model version claims, feature names, Claude Code behavior descriptions

Prefer official docs and primary sources over blog posts or aggregators.

`research/skill-authoring-best-practices.md` is the exception: its authoritative source is the locally bundled `skill-creator` and `plugin-dev` `skill-development` SKILL.md files (under `~/.claude/plugins/marketplaces/`), not the web. Re-read those directly and diff against what this file says, rather than web searching.

## Step 3: Diff against the file

For each fact you checked, decide: still accurate, changed, or no longer mentioned anywhere (deprecated). Don't rewrite things that haven't changed.

## Step 4: Update

- Edit only what's actually changed.
- Bump the `Last updated` date on any file you touched.
- Keep the existing tone and format (TL;DR sections, tables, sources list) rather than restructuring.
- Add new sources to the `Sources` list if you used new ones.

## Step 5: Update docs

Check `docs/index.html` and `docs/claude-code/index.html` for any claims that your research found to be outdated: model version names, feature descriptions, term definitions, benchmark numbers. Update them in place, same as you do for `research/`. Note doc changes alongside research changes in the report.

Don't restructure or rewrite the docs, only update specific facts that have drifted.

## Step 6: Report

Summarize what changed per file (research and docs), in one or two lines each: what was outdated, what it's now. If nothing changed in a file, say so rather than padding the diff.

If something you found would change a recommendation in `tools/claude-code/` (a setting, an agent, a skill), mention it explicitly so the user knows to run the `update-templates` skill next. Don't touch `tools/claude-code/` yourself from this skill.
