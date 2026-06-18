# ai-optimizations

A personal toolkit for getting more out of Claude Code: researched settings, reusable agents and skills, and a few meta-skills that keep the whole thing from going stale.

## Why this exists

Figuring out the best way to configure Claude Code (which model alias to use, how to structure CLAUDE.md, which subagents are worth having around) takes real research, and that research has a shelf life. Models change, Claude Code ships new features, and what was the right call a few months ago might not be anymore.

This repo is where that research lives, plus the config it produced, so none of it has to be re-derived from scratch every time. If you're setting up Claude Code for the first time, or just want a sane, opinionated starting point, clone this and go from there.

## What's in here

- **`research/`** Notes on the current AI model landscape, multi-agent orchestration patterns, prompting and context engineering best practices, and Claude Code setup specifics. Each file is dated. Treat it as a snapshot, not gospel, since this stuff moves fast.
- **`claude-code-templates/`** The actual starting point: a `settings.json`, a `CLAUDE.md`, a handful of reviewer subagents (staff engineer, security, product, design, a Cloudflare specialist, a generic domain expert), and two skills (`smart-review` for multi-perspective review, `claudemd-conventions` for keeping CLAUDE.md files lean). These are generic on purpose, nothing in here is specific to any one project or person.
- **`.claude/skills/`** Three skills for maintaining this repo itself (see below).

## The three maintenance skills

These run inside this repo, not as part of your global Claude Code setup.

**`update-research`** Re-checks the research against current sources and updates whatever's drifted. Run this every so often, the snapshots in `research/` go stale.

**`update-templates`** Reads the research and brings `claude-code-templates/` in line with it. Run this after `update-research` finds something worth acting on, or any time you've learned something new worth baking into the starting point.

**`deploy-config`** Copies everything in `claude-code-templates/` out to your real `~/.claude/` directory. This is the one that actually changes your global setup, so it's careful: anything missing gets created, anything identical gets skipped, and anything that already exists and is different gets flagged for you to decide on instead of silently overwritten. Safe to run more than once.

## Getting started

1. Clone the repo and open it in Claude Code.
2. Look through `claude-code-templates/` and decide what you actually want. Cut what doesn't fit your workflow.
3. Ask Claude to run the `deploy-config` skill (or just say "run deploy-config"), or copy the files by hand if you'd rather not run anything automated.
4. Later, when you want to check whether anything's changed, ask Claude to run `update-research` and then `update-templates`.

## A note on the research

Everything in `research/` reflects a point in time (check the "Last updated" line at the top of each file). AI moves fast enough that specific model names, prices, and feature names will drift. Treat the patterns and reasoning as the durable part, and verify specific facts against official docs before relying on them.
