---
name: council
description: Run the AI Council on an idea, decision, or plan. Five adversarial personas evaluate in parallel, then a Chairman synthesizes to one concrete verdict. Use for high-stakes decisions, strategy, or pressure-testing ideas — not for code review (use smart-review for that).
---

# AI Council

When invoked, follow this exact process.

## Step 1: Extract the question

The user may say "council this", "run the council on X", "pressure-test this", "war room this", or just describe a topic. Extract the core question or decision to evaluate.

If no clear question exists, ask: "What decision or idea should the council evaluate?"

## Step 2: Scan for context

If the question references project work, read relevant files (CLAUDE.md, memory files, relevant code or docs) before spawning advisors. Personas with domain context give specific answers; without it they give generic ones.

## Step 3: Choose the model

Default every spawned agent (all five advisors and the Chairman) to `sonnet` by passing `model: sonnet` on the Agent call. Sonnet is the floor: capable enough for almost every decision, at a fraction of Opus cost. Only deviate when the decision itself clearly warrants it:

| Decision complexity | Model | When |
|---|---|---|
| Normal (default) | `sonnet` | Most decisions, plans, and ideas |
| High-stakes / complex | `opus` | Irreversible or costly-to-reverse calls, deep strategy, heavy ambiguity, anything expensive to get wrong |

(No haiku tier here: if a decision is worth convening the council, it is past haiku territory.)

Pick one model for the whole run unless the Chairman synthesis is clearly harder than the advisor passes (then keep advisors on sonnet and raise only the Chairman). State which model you chose and why in one line before spawning.

## Step 4: Spawn the five advisors in parallel

Use the Agent tool to spawn all five simultaneously, each with the model from Step 3. Each advisor runs in isolated context — no persona sees another's answer before responding. This isolation is intentional: it prevents anchoring and herding.

Brief each agent with:
- The question
- Their persona mandate (exact text below)
- A hard output cap: 3-5 sentences maximum
- This rule: "Do not soften your view to seem agreeable. Do not offer balanced perspectives. Optimize for your mandate only."

### Persona mandates

**Contrarian** — "Your only job is to find where this breaks. List every reason this decision fails. Do not offer solutions — only failures. Identify at minimum 3 failure modes."

**First Principles Thinker** — "Question whether we are solving the right problem. Strip every assumption. Rebuild from zero. What is the actual underlying problem, and is this the right solution to it?"

**Expansionist** — "Find the hidden upside. What asymmetric outcome is possible if this succeeds beyond expectations? What are we underestimating? What adjacent opportunities does this open up?"

**Outsider** — "You have no domain expertise. Ask the naive questions insiders stopped asking. What is obviously strange about this that an expert would rationalize away? What does everyone assume that might be wrong?"

**Executor** — "Convert everything to action. Ignore strategy. What happens Monday morning? Give week-one tasks only — specific, concrete, completable."

## Step 5: Chairman synthesis

After all five advisors report, spawn the Chairman as a **separate Agent call with fresh context** (same model choice from Step 3). The Chairman receives all five advisor responses labeled by persona name, plus this mandate:

"You are the Chairman. Five advisors have given their analysis. Your job is to synthesize — not average, not diplomacize.

Deliver exactly four things:
1. **The Decision** — one concrete position on what to do (or not do). No 'it depends.' No 'consider both options.' Make a call.
2. **The Biggest Risk** — the single thing most likely to cause failure across all advisor input.
3. **The First Step** — what happens this week. One specific action, not a direction.
4. **Where Advisors Disagreed** — note any genuine split and which position had stronger reasoning. If a lone dissent had a strong point, say so.

'It depends' is a failure. Diplomatic non-answers are a failure. A position with a clear rationale, even if wrong, is better than a hedge."

## Step 6: Present results

Format the output as:

---
### Council Report: [one-line summary of the question]

**Contrarian:** [response]

**First Principles:** [response]

**Expansionist:** [response]

**Outsider:** [response]

**Executor:** [response]

---
### Chairman's Verdict

**Decision:** [one concrete position]
**Biggest Risk:** [one risk]
**First Step:** [this week's specific action]
**Where We Disagreed:** [genuine splits, with reasoning]

---

## Step 7: Store the decision

Save the run so cost and quality can be analysed over time. Resolve where to write it, in this order:

1. If the project's CLAUDE.md (or AGENTS.md) names a place for decisions, use that.
2. Else if a conventional decisions folder already exists — `decisions/` or `docs/decisions/` (ADR-style) — write there.
3. Else ask the user where to store it: a checked-in folder (offer to create `decisions/`) or gitignored `.claude-logs/council/`. If you cannot ask, default to `.claude-logs/council/`.

Name the file `YYYY-MM-DD-HHMM-<slug>.md` (`<slug>` is a short kebab-case tag from the question) and use this shape:

```markdown
---
type: council
date: 2026-07-07T14:32-04:00   # actual local timestamp
task: <one-line question the council evaluated>
models:                         # the model each spawned agent actually ran on
  - agent: contrarian
    model: sonnet
  - agent: first-principles
    model: sonnet
  - agent: expansionist
    model: sonnet
  - agent: outsider
    model: sonnet
  - agent: executor
    model: sonnet
  - agent: chairman
    model: sonnet
agent_count: 6
cost_usd: null   # not knowable at runtime; fill later from `ccusage` or the API console, keyed by the date above
---

<the full Council Report and Chairman's Verdict from Step 6>
```

Do not invent a token or dollar figure. A spawned agent cannot read its own usage, so `cost_usd` stays `null` and real cost is reconciled later from `ccusage`/the console using the timestamp.

## Notes

- **Reserve for complex decisions.** The council is overkill for factual lookups, simple tasks, or anything with an obvious answer.
- **The council doesn't decide — you do.** Treat this as structured input to your judgment, not an oracle.
- **Cost:** 6 subagent spawns (5 advisors + 1 chairman), on sonnet by default (see Step 3). Still a meaningful token cost. Worth it for high-stakes choices; not for casual questions. Every run is logged (see Step 7) for later cost/quality analysis.
- **For code, docs, or implementation review**, use `smart-review` instead — it selects the right domain experts for technical work. Council is for ideas, strategy, and decisions.
- **Inspired by** Andrej Karpathy's `llm-council` project and community research. See `research/ai-council.md` for full background.
