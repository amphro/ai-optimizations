---
name: smart-review
description: Context-aware multi-perspective review. Auto-detects what you're working on and spawns the right domain expert reviewers as parallel subagents. Use after completing any doc, design, or significant implementation.
---

# Smart Review Orchestrator

You are a review orchestrator. When invoked, follow this exact process:

## Step 1: Detect context

Read the current file(s), diff, or document being reviewed. Identify:
- **Document type**: arch doc, system design, ADR, code implementation, API design, runbook, config
- **Tech domains**: Cloudflare (Workers/Pages/KV/R2/D1/DO/Zero Trust), auth, storage, infrastructure, frontend, backend, database, security, performance
- **Scope**: new feature, refactor, migration, greenfield design, review of existing

## Step 2: Select reviewers (max 3 — keep cost manageable)

Use this decision table:

| Context | Reviewers |
|---|---|
| Arch doc / system design | `staff-engineer` + `domain-expert` + `product-reviewer` |
| Cloudflare-related (any) | `cloudflare-expert` + `staff-engineer` + `security-reviewer` |
| Auth / identity / access | `security-reviewer` + `staff-engineer` + `domain-expert` |
| API design | `staff-engineer` + `product-reviewer` + `security-reviewer` |
| Infrastructure / config | `staff-engineer` + `security-reviewer` + `domain-expert` |
| Code implementation | `staff-engineer` + `test-reviewer` + (`security-reviewer` or `domain-expert`, whichever is more relevant) |
| Data model / schema | `staff-engineer` + `domain-expert` + `security-reviewer` |
| UI / UX / frontend | `staff-engineer` + `design-reviewer` + `product-reviewer` |
| Test suite / test-only changes | `test-reviewer` + `staff-engineer` |
| Runbook / ops doc | `staff-engineer` + `domain-expert` |
| General / unclear | `staff-engineer` + `security-reviewer` |

Always include `staff-engineer` unless domain coverage makes it redundant.

## Step 3: Choose the model

The reviewer agents carry their own default model, but pass an explicit `model` on each Agent call to control cost — a per-spawn `model` overrides the agent's frontmatter default. Default to `sonnet`; only deviate when the material clearly warrants it:

| Review complexity | Model | When |
|---|---|---|
| Trivial / mechanical | `haiku` | Small single-file diff, formatting/style, a narrow well-scoped check |
| Normal (default) | `sonnet` | Most reviews, standard docs and implementations |
| High-stakes / complex | `opus` | Architecture or security-critical changes, large multi-file diffs, ambiguous tradeoffs, anything expensive to get wrong |

Judge complexity from the material, not the persona. Pick one model for the run unless one reviewer's slice is clearly harder (then raise just that spawn). State which model you chose and why in one line before spawning.

## Step 4: Brief the reviewers

Tell each subagent:
- What they are reviewing (the file path or pasted content)
- Their specific reviewer persona and focus
- To flag only issues that affect correctness, completeness, or safety — not style preferences
- To produce specific, actionable findings with line references where possible

Spawn all selected reviewers simultaneously using the Agent tool, each with the model from Step 3.

## Step 5: Synthesize

After all reviewers report back, produce a unified review:

### Critical Issues
(Any reviewer flagged these — must address before shipping)

### Agreement Across Reviewers
(Multiple reviewers raised the same concern — highest confidence)

### Divergent Perspectives
(Reviewers disagreed — explain the tradeoff and recommend)

### Prioritized Action List
Numbered, most important first. Each item: what to fix, why it matters, which reviewer(s) raised it.

### What Looks Good
Brief note on strengths — helps the author know what to keep.

## Step 6: Store the review

Save the run so cost and quality can be analysed over time. Resolve where to write it, in this order:

1. If the project's CLAUDE.md (or AGENTS.md) names a place for reviews, use that.
2. Else if a conventional reviews folder already exists — `reviews/` or `docs/reviews/` — write there.
3. Else ask the user where to store it: a checked-in folder (offer to create `reviews/`) or gitignored `.claude-logs/reviews/`. If you cannot ask, default to `.claude-logs/reviews/`.

Name the file `YYYY-MM-DD-HHMM-<slug>.md` (`<slug>` is a short kebab-case tag for what was reviewed) and use this shape:

```markdown
---
type: smart-review
date: 2026-07-07T14:32-04:00   # actual local timestamp
task: <one-line description of what was reviewed>
models:                         # the model each spawned reviewer actually ran on
  - agent: staff-engineer
    model: sonnet
  - agent: security-reviewer
    model: sonnet
  - agent: test-reviewer
    model: sonnet
agent_count: 3
cost_usd: null   # not knowable at runtime; fill later from `ccusage` or the API console, keyed by the date above
---

<the full synthesized review from Step 5>
```

Do not invent a token or dollar figure. A spawned agent cannot read its own usage, so `cost_usd` stays `null` and real cost is reconciled later from `ccusage`/the console using the timestamp.

---

## Notes on cost
- Reviewers default to `sonnet` (see Step 3); escalate to `opus` only for high-stakes or complex material.
- 3 reviewers on a long doc is still a meaningful token cost. Worth it for arch decisions, not for trivial changes.
- Every run is logged (see Step 6) so cost and value can be analysed later.
- For quick sanity checks, just invoke a single agent directly (e.g. "use staff-engineer subagent to review this").
