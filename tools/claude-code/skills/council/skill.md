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

## Step 3: Spawn the five advisors in parallel

Use the Agent tool to spawn all five simultaneously. Each advisor runs in isolated context — no persona sees another's answer before responding. This isolation is intentional: it prevents anchoring and herding.

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

## Step 4: Chairman synthesis

After all five advisors report, spawn the Chairman as a **separate Agent call with fresh context**. The Chairman receives all five advisor responses labeled by persona name, plus this mandate:

"You are the Chairman. Five advisors have given their analysis. Your job is to synthesize — not average, not diplomacize.

Deliver exactly four things:
1. **The Decision** — one concrete position on what to do (or not do). No 'it depends.' No 'consider both options.' Make a call.
2. **The Biggest Risk** — the single thing most likely to cause failure across all advisor input.
3. **The First Step** — what happens this week. One specific action, not a direction.
4. **Where Advisors Disagreed** — note any genuine split and which position had stronger reasoning. If a lone dissent had a strong point, say so.

'It depends' is a failure. Diplomatic non-answers are a failure. A position with a clear rationale, even if wrong, is better than a hedge."

## Step 5: Present results

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

## Notes

- **Reserve for complex decisions.** The council is overkill for factual lookups, simple tasks, or anything with an obvious answer.
- **The council doesn't decide — you do.** Treat this as structured input to your judgment, not an oracle.
- **Cost:** 6 subagent spawns (5 advisors + 1 chairman). Meaningful token cost. Worth it for high-stakes choices; not for casual questions.
- **For code, docs, or implementation review**, use `smart-review` instead — it selects the right domain experts for technical work. Council is for ideas, strategy, and decisions.
- **Inspired by** Andrej Karpathy's `llm-council` project and community research. See `research/ai-council.md` for full background.
