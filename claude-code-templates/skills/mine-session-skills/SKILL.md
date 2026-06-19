---
name: mine-session-skills
description: Reviews the current conversation after a task or long back-and-forth finishes and proposes skills worth creating from what just happened. Manually triggered only, never runs automatically. Use when a task wraps up and something about it felt repeatable, or when explicitly asked to "look for skills from this session" / "did anything just now belong in a skill."
---

# Mine Session for Skills

Looks back over the current conversation (the live context already in this session, not a transcript file) for patterns worth turning into a skill, then proposes them. This never creates anything without confirmation, and it never runs on its own, only when asked.

## Step 1: Scan the conversation for candidates

Look for:
- A multi-step procedure that got executed more than once, or that took several manual tool calls in a row that could collapse into one instruction.
- A correction pointing at a missing *capability* Claude should reliably have next time, not just a one-off preference. One-off preferences belong in memory, not a skill, see "What this isn't" below.
- A piece of domain knowledge (a file format, an API quirk, a deploy step) that took real back-and-forth to establish and would be worth having pre-loaded next time instead of re-discovered.

Ignore anything that only happened because of an unusual one-time circumstance. A skill is for things that will plausibly recur.

## Step 2: Check for overlap before proposing anything new

For each candidate, check `~/.claude/skills/*/SKILL.md` (your installed skills) for something that already covers it. If it overlaps, propose extending that skill (name the section or step that would change) instead of a new one.

## Step 3: Propose, don't create

Present each candidate: what it would do, the trigger phrases that would fire it, where it would live (new skill vs. extending an existing one), and roughly how big the body would need to be. Wait for the user to pick which ones, if any, to build.

## Step 4: Build what's approved

For each approved candidate, write or update the SKILL.md directly under `~/.claude/skills/`. Match the style of whatever skills are already installed there (or, if you know where the `ai-optimizations` repo is checked out, follow its `research/skill-authoring-best-practices.md` and existing skills as the reference: numbered Step sections, name+description-only frontmatter, ends in a Report step, no em dashes).

## Step 5: Report and log

Summarize what was proposed, what got built, and what was skipped. If anything about how to write skills well came up during this process, and you know where the `ai-optimizations` repo is checked out, append it to that repo's `research/skill-authoring-best-practices.md` log section with today's date. Otherwise just mention it in the report.

## What this isn't

This doesn't replace memory. A preference correction with no recurring procedure behind it ("don't summarize at the end of every response") is a feedback memory, not a skill. This only proposes a skill when there's an actual repeatable procedure or piece of domain knowledge involved.
