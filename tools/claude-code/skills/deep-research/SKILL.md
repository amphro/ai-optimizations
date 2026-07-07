---
name: deep-research
description: Run deep multi-angle research on a question by spawning parallel agents, each investigating one sub-question, then synthesizing a single grounded answer with sources. Use for open-ended research, technology or vendor comparisons, landscape scans, feasibility questions, or anything that needs several independent lines of investigation. Not for reviewing code or docs (use smart-review) or pressure-testing a decision (use council).
---

# Deep Research

When invoked, follow this process.

## Step 1: Frame the question

Extract the core research question. If it is vague ("look into X"), sharpen it into a specific question that has a knowable answer. If you cannot, ask the user what decision the research is meant to inform, then frame around that.

## Step 2: Decompose into sub-questions

Break the question into 3 to 5 independent sub-questions that can be researched in parallel without depending on each other's answers. Good decompositions cover distinct angles (e.g. capability, cost, maturity, alternatives, risks) rather than slicing one angle thinner. Fewer, sharper sub-questions beat many overlapping ones.

## Step 3: Choose the model

Default every spawned agent to `sonnet` by passing `model: sonnet` on the Agent call. Sonnet is the floor: capable enough for almost all research, at a fraction of Opus cost. Only deviate when the material warrants it:

| Research complexity | Model | When |
|---|---|---|
| Shallow / factual | `haiku` | A lookup or a narrow, well-bounded fact-find |
| Normal (default) | `sonnet` | Most research and comparisons |
| Deep / high-stakes | `opus` | Heavy synthesis across conflicting sources, subtle technical judgment, a decision that is expensive to get wrong |

Pick one model for the whole run unless the final synthesis is clearly harder than the per-sub-question passes (then keep the researchers on sonnet and raise only the synthesis pass). State which model you chose and why in one line before spawning.

## Step 4: Spawn parallel research agents

Use the Agent tool to spawn one `general-purpose` agent per sub-question, all simultaneously, each with the model from Step 3. Brief each agent with:
- The one sub-question it owns and the overall question for context
- To use web search and fetch for current information, and to prefer primary or authoritative sources
- To return a short findings summary with the specific sources (URLs) it relied on, and to flag where sources disagree or evidence is thin
- A hard output cap so it returns conclusions, not raw dumps

## Step 5: Synthesize

After all researchers report, produce one grounded answer:

### Answer
The direct answer to the framed question, up front.

### What the evidence shows
The key findings, organized by theme rather than by which agent found them. Note confidence and where sources conflict.

### Open questions / weak spots
What the research could not settle, and what would resolve it.

### Sources
The sources that actually carried weight, grouped by sub-question.

## Step 6: Store the research

Save the run so cost and quality can be analysed over time. Resolve where to write it, in this order:

1. If the project's CLAUDE.md (or AGENTS.md) names a place for research, use that.
2. Else if a conventional research folder already exists — `research/` or `docs/research/` — write there. These are usually checked in, which is the point: research is worth keeping.
3. Else ask the user where to store it: a checked-in folder (offer to create `research/`) or gitignored `.claude-logs/research/`. If you cannot ask, default to `.claude-logs/research/`.

Name the file `YYYY-MM-DD-HHMM-<slug>.md` (`<slug>` is a short kebab-case tag from the question) and use this shape:

```markdown
---
type: deep-research
date: 2026-07-07T14:32-04:00   # actual local timestamp
task: <one-line research question>
models:                         # the model each spawned agent actually ran on
  - agent: research-capability
    model: sonnet
  - agent: research-cost
    model: sonnet
  - agent: research-alternatives
    model: sonnet
agent_count: 3
cost_usd: null   # not knowable at runtime; fill later from `ccusage` or the API console, keyed by the date above
---

<the full synthesized answer from Step 5>
```

Do not invent a token or dollar figure. A spawned agent cannot read its own usage, so `cost_usd` stays `null` and real cost is reconciled later from `ccusage`/the console using the timestamp.

## Step 7: Report

Present the synthesized answer from Step 5 and note where the run was stored.

## Notes

- **Parallel and independent.** Sub-questions must not depend on each other, or the parallel spawn wastes work. If one truly depends on another's answer, do that one first, then fan out the rest.
- **Cost:** one spawn per sub-question plus the synthesis you run yourself, on sonnet by default (see Step 3). Every run is logged (see Step 6) for later cost/quality analysis.
- **Not a reviewer or a decider.** For reviewing code or docs use `smart-review`; for pressure-testing a decision use `council`. Deep research gathers and synthesizes evidence, it does not make the call for you.
