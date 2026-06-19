# Skill Authoring Best Practices

**Last updated:** 2026-06-19
**Source:** Anthropic's official `skill-creator` plugin and `plugin-dev`'s `skill-development` skill (both bundled with Claude Code), cross-checked against this repo's own existing skills
**Reliability:** High for official mechanics (read directly from the bundled plugin source). The house-style section below is this repo's own convention, not an external standard.

---

## TL;DR

For SKILL.md mechanics (frontmatter, progressive disclosure, description-triggering, when to add `scripts/`/`references/`/`assets/`, the eval/iterate loop), read the official guidance directly rather than duplicating it here — it's bundled with Claude Code and won't drift out of sync the way a copy would. This file exists for what the official docs don't cover: the conventions this repo's own skills have settled into, plus a running log of new practices as they're discovered.

## Where the mechanics live

- `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator/SKILL.md` — full create/test/eval/iterate workflow, progressive disclosure, the `scripts/`/`references/`/`assets/` anatomy.
- `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/plugin-dev/skills/skill-development/SKILL.md` — stricter conventions (third-person trigger phrases in the description, imperative body, word budgets, a validation checklist, common mistakes to avoid).

Read both before writing or reviewing a SKILL.md. If a path above goes stale after a plugin update, search `~/.claude/plugins/marketplaces/` for `skill-creator` / `skill-development` rather than guessing at a new path.

## This repo's house style (not in the official docs)

The skills in `.claude/skills/` and `claude-code-templates/skills/` have converged on a lighter style than the official plugin-dev template. New skills in this repo should match it for consistency:

- Frontmatter has only `name` and `description` — no `version` field.
- Description is a natural sentence, not a rigid third-person template: state what the skill does, then "Use when..." / "Apply when..." with concrete trigger phrases.
- Body is structured as numbered `## Step N: ...` sections, ending in a `## Step N: Report` section that says exactly what to summarize back to the user.
- Each skill states what it does NOT touch and names the sibling skill responsible for that instead (see `update-research`, `update-templates`, `deploy-config`).
- One file per skill. No `scripts/`, `references/`, or `assets/` subdirectories unless something concrete actually needs them — none of this repo's skills have needed them yet.
- No em dashes. Casual, direct tone, consistent with the README.

## Worth restating from the official docs

A couple of things easy to under-weight:

- Descriptions should be a little pushy about *when* to trigger — the failure mode is under-triggering, not over-triggering. Name concrete situations, not just topics.
- All "when to use this" information belongs in the description. The body is instructions for what to do once triggered, not more triggering criteria.
- Keep the body lean. If a section would only be needed sometimes, that's a reason to cut it or move it out, not a reason to make the skill heavier.

## Log of practices learned from real sessions

Newest first. `mine-session-skills` appends here when a session surfaces something genuinely new about skill authoring — not every session adds a line.

(none yet)

## Sources

- Anthropic `skill-creator` plugin (bundled with Claude Code)
- Anthropic `plugin-dev` `skill-development` skill (bundled with Claude Code)
- This repo's own `.claude/skills/*` and `claude-code-templates/skills/*`
