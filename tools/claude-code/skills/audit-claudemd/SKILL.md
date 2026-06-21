---
name: audit-claudemd
description: Audits a CLAUDE.md file for bloat using claudemd-conventions' rules, and additionally flags content that should be extracted into a new or existing skill instead of living in CLAUDE.md. Use when a CLAUDE.md file has grown long, when you're about to write one and want a gut check, or when asked "is this CLAUDE.md too bloated" / "should any of this be a skill instead."
---

# Audit CLAUDE.md

Reviews a CLAUDE.md file for two different problems: lines that shouldn't exist at all (bloat), and lines that should exist somewhere else (a skill). This is a read-and-report skill: it proposes changes but never edits the target file itself.

This skill builds on `claudemd-conventions` rather than re-deriving bloat rules. If `claudemd-conventions` changes, this skill's bloat pass changes with it automatically, so don't duplicate its test here.

## Step 1: Find the target

If the user named a file, use it. Otherwise look for a `CLAUDE.md` in the current project, and ask if none is found. Read the full file.

## Step 2: Run the bloat pass

Apply `claudemd-conventions`' test line by line: "Would removing this cause Claude to make a mistake on this project specifically?" For each line or block that fails, note why: standard convention, code-derivable, a long explanation that belongs in a doc, something that needs hook-level enforcement instead of advisory text, or frequently-changing info.

## Step 3: Run the extraction pass

For everything that survives Step 2 (specific and non-obvious enough to matter), ask a second question `claudemd-conventions` doesn't ask: is this domain knowledge only needed *sometimes*, or an instruction needed on *every* session?

- Needed every session: correctly placed in CLAUDE.md, leave it.
- Needed only sometimes (a workflow for a specific kind of task, a non-trivial procedure, knowledge only relevant when doing X): it's a skill-extraction candidate.

For each candidate, check `~/.claude/skills/*/SKILL.md` for overlap with an existing skill before proposing a brand new one. If it overlaps, propose folding the content into that skill instead.

## Step 4: Report

For each finding, show the line(s) in question, which pass flagged it, and the proposed fix: delete, move to a doc, move to a hook, fold into skill X, or create new skill Y. Don't edit anything yet.

If the user approves a fix, apply exactly that one. A new skill goes directly under `~/.claude/skills/` unless the project being audited has its own `.claude/skills/` convention and the content is specific to that project.

If you know where the `ai-optimizations` repo (the source of this skill) is checked out and the finding is a genuinely new skill-authoring pattern, append it to that repo's `research/skill-authoring-best-practices.md` log section. Otherwise just note the finding in the report; don't go looking for that repo.
