---
type: smart-review
date: 2026-07-21T10:07-07:00
task: Research on Claude Code agent teams + adding an orchestrator-by-default rule to global CLAUDE.md
models:
  - agent: staff-engineer
    model: sonnet
  - agent: product-reviewer
    model: sonnet
  - agent: domain-expert
    model: sonnet
agent_count: 3
cost_usd: null
---

# Smart review: agent teams research and orchestrator-default rule

Reviewed: `research/agent-teams.md` (new), the 2026-07-21 update section in `research/orchestration-patterns.md`, and the two new Workflow-defaults lines in `tools/claude-code/user-CLAUDE.md`.

## Critical issues

- **Model-inheritance claim was wrong (domain-expert).** The doc said teammates do not inherit the lead's model and pointed only to a `/config` setting. The local changelog (v2.1.72) shows a fix making team agents inherit the leader's model, and `CLAUDE_CODE_SUBAGENT_MODEL` is a real override lever. The official docs and the changelog conflict on the out-of-box default. Fixed by describing the levers (`/config` default, env var, spawn prompt, or follow-the-lead) without asserting a wrong default. Verified separately that the practical point holds: you can pin teammates to a cheap tier.

## Agreement across reviewers

- **The conditional recommendation is sound and matches the research** (staff-engineer and product-reviewer both). "Orchestrator by default" should be conditional, not blanket. No contradiction between the research verdict and the CLAUDE.md rule content.
- **The evidence is honestly caveated** (product-reviewer and domain-expert). Cost multipliers stay flagged as self-reported estimates, and the Reddit gap is stated plainly. Keep that confidence level.

## Findings applied

1. **Headline primed the wrong posture (staff-engineer, major).** The rule opened with "Default to orchestrating," the exact framing the research argues against. Reworded to lead with the condition and the context-isolation reason.
2. **No verification step before building on delegated output (staff-engineer, major).** Added "spot-check what a subagent reports before building on it" to the rule.
3. **What is already configured vs what is new was never reconciled (product-reviewer, major).** Added a section to `agent-teams.md`: `advisorModel` already makes the advisor pattern live, `opusplan` already splits Opus planning from Sonnet execution, and the only new habit is delegating exploration to cheap subagents.
4. **"How is it different from how I use subagents" was answered abstractly (product-reviewer, major).** Added a direct comparison to the existing `council` skill (parallel agents, no peer messaging) and the fixed-role reviewer subagents.
5. **Model-tier framing mislabeled the savings (staff-engineer, minor).** Reframed so context isolation is the main win and the cheaper model is a bonus, in both the rule and the doc.
6. **Placement decision was asserted, not argued (product-reviewer, minor).** Added one line making the case for global CLAUDE.md over a skill.
7. **Version framing (domain-expert, major).** Noted teams launched at v2.1.32 and that v2.1.178 was a breaking redesign, with a caveat that older blog posts may show the old setup flow.
8. **`teammateMode` values (domain-expert, minor).** Listed all four: auto, tmux, iterm2, in-process.
9. **Stale metadata date (staff-engineer, minor).** Bumped `orchestration-patterns.md` last-updated to 2026-07-21.
10. **Mechanism gap (product-reviewer, minor).** The rule now says to pass a cheaper model on the spawn, matching how `council` pins `model: sonnet`.

## Verification done

- Spot-checked GitHub issues #23415 and #58762 by fetching them. Both resolve and match the described mailbox-delivery bugs, so the sentiment agent's issue citations are real, not fabricated (a risk the domain-expert flagged given the doc is Claude-generated).

## What looks good

- The research answers all four teams sub-questions (what it is, enable-in-settings, do people like it, how it differs).
- The two-line CLAUDE.md footprint passes the "would removing this cause a mistake" test and stays well under the 50-line cap.
- `agent-teams.md` correctly keeps itself out of the CLAUDE.md rule; teams are situational, not a standing default.
