# Skill Authoring Best Practices

**Last updated:** 2026-06-19
**Source:** Anthropic's official `skill-creator` plugin and `plugin-dev`'s `skill-development` skill (both bundled with Claude Code), cross-checked against this repo's own existing skills
**Reliability:** High for official mechanics (read directly from the bundled plugin source). The house-style section below is this repo's own convention, not an external standard.

---

## TL;DR

For SKILL.md mechanics (frontmatter, progressive disclosure, description-triggering, when to add `scripts/`/`references/`/`assets/`, the eval/iterate loop), read the official guidance directly rather than duplicating it here. It's bundled with Claude Code and won't drift out of sync the way a copy would. This file exists for what the official docs don't cover: the conventions this repo's own skills have settled into, plus a running log of new practices as they're discovered.

## Where the mechanics live

- `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/skill-creator/skills/skill-creator/SKILL.md`: full create/test/eval/iterate workflow, progressive disclosure, the `scripts/`/`references/`/`assets/` anatomy.
- `~/.claude/plugins/marketplaces/claude-plugins-official/plugins/plugin-dev/skills/skill-development/SKILL.md`: stricter conventions (third-person trigger phrases in the description, imperative body, word budgets, a validation checklist, common mistakes to avoid).

Read both before writing or reviewing a SKILL.md. If a path above goes stale after a plugin update, search `~/.claude/plugins/marketplaces/` for `skill-creator` / `skill-development` rather than guessing at a new path.

## This repo's house style (not in the official docs)

The skills in `.claude/skills/` and `claude-code-templates/skills/` have converged on a lighter style than the official plugin-dev template. New skills in this repo should match it for consistency:

- Frontmatter has only `name` and `description`, no `version` field.
- Description is a natural sentence, not a rigid third-person template: state what the skill does, then "Use when..." / "Apply when..." with concrete trigger phrases.
- Two body shapes, pick based on what the skill does. **Workflow skills** (`update-research`, `update-templates`, `deploy-config`, `audit-claudemd`, `mine-session-skills`) run a procedure and end in a `## Step N: Report` section. **Reference/behavioral skills** (`claudemd-conventions`, `writing-voice`) don't execute steps, they're rules Claude applies while doing something else, so they use plain topic sections (`## The base`, `## The voices`) and have no Report step.
- Each skill states what it does NOT touch and names the sibling skill responsible for that instead (see `update-research`, `update-templates`, `deploy-config`).
- One file per skill, unless a skill's reference content is large enough that loading it every time would be wasteful. Then split it into a `references/` file loaded only when needed (the official progressive-disclosure pattern), and say so explicitly rather than letting the split go unexplained.
- No em dashes. Casual, direct tone, consistent with the README.

## Worth restating from the official docs

A couple of things easy to under-weight:

- Descriptions should be a little pushy about *when* to trigger. The failure mode is under-triggering, not over-triggering. Name concrete situations, not just topics.
- All "when to use this" information belongs in the description. The body is instructions for what to do once triggered, not more triggering criteria.
- Keep the body lean. If a section would only be needed sometimes, that's a reason to cut it or move it out, not a reason to make the skill heavier.

## Log of practices learned from real sessions

Newest first. `mine-session-skills` appends here when a session surfaces something genuinely new about skill authoring, not every session adds a line.

**2026-06-19:** Not every skill is a workflow. `writing-voice` and `claudemd-conventions` are rules Claude applies while doing something else, not a procedure Claude runs, so they use topic sections instead of numbered Steps and have no Report step. Forcing a Report step onto a reference skill produces a section nobody reads. See the house-style note above for the two-shape split.

## Sources

- Anthropic `skill-creator` plugin (bundled with Claude Code)
- Anthropic `plugin-dev` `skill-development` skill (bundled with Claude Code)
- This repo's own `.claude/skills/*` and `claude-code-templates/skills/*`
