# Multi-Agent Orchestration Patterns (June 2026)

> ***🤖 Claude generated, human reviewed***

**Last updated:** 2026-07-21  
**Key question:** Opus orchestrator + Sonnet workers vs. all-Sonnet + Opus review at end?  
**Answer:** Neither — use the Advisor Strategy (Sonnet runs everything, Opus on-demand)

---

## The Advisor Strategy (Anthropic's Recommended Pattern)

**Published:** April 9, 2026 by Anthropic  
**Source:** https://claude.com/blog/the-advisor-strategy

### How It Works

Instead of Opus orchestrating or reviewing at the end, Anthropic's pattern is:

1. **Sonnet (or Haiku) runs everything end-to-end** — calls tools, reads results, iterates
2. **When Sonnet hits a decision it can't resolve**, it invokes Opus as an advisor via tool call
3. **Opus reads the shared context**, returns a plan or correction
4. **Sonnet resumes** — Opus never produces user-facing output or calls tools itself

This is fundamentally different from both patterns you asked about:
- NOT "Opus orchestrates, Sonnet works" — Sonnet drives the whole thing
- NOT "Sonnet works, Opus reviews at end" — Opus is called mid-task on hard decisions only

### Benchmark Results

| Setup | SWE-bench Multilingual | BrowseComp | Cost vs Opus-only |
|---|---|---|---|
| Sonnet alone | baseline | 19.7% (Haiku) | ~60% less |
| Sonnet + Opus advisor | +2.7 pp | — | ~12% less than Sonnet alone |
| Haiku + Opus advisor | — | 41.2% (2x solo) | 85% less than Sonnet |
| Opus alone | — | — | full cost |

**Key stats:**
- Sonnet + Opus advisor: **+2.7% accuracy, -11.9% cost** vs Sonnet alone
- Haiku + Opus advisor: **doubled BrowseComp score** (19.7% → 41.2%), still 85% cheaper than Sonnet
- Opus token output is short (400-700 tokens for a plan) — billed at Opus rates but barely adds to cost

### API Implementation

```python
response = client.messages.create(
    model="claude-sonnet-4-6",  # executor
    tools=[
        {
            "type": "advisor_20260301",
            "name": "advisor",
            "model": "claude-opus-4-6",  # advisor
            "max_uses": 3,  # cost control lever
        },
        # ... your other tools
    ],
    messages=[...]
)
```

Add header: `anthropic-beta: advisor-tool-2026-03-01`

**max_uses guidance:**
- `1` — lightweight sanity check
- `3` — typical complex tasks
- `5` — multi-step workflows with lots of branching decisions

Advisor tokens are billed separately in the usage block so you can track spend per tier.

---

## Pattern Comparison: Your Original Question

### Option A: Opus orchestrates, spawns Sonnet workers
**Verdict: Not recommended**
- Expensive — Opus runs for the full duration of orchestration
- Multi-agent architectures add latency and complexity
- Research shows 90.2% improvement over single-agent Opus in research tasks, but at **~15x token cost**
- Better for: truly parallel, independent research tasks where the question is large and the answer is worth many tokens

### Option B: All Sonnet, then Opus reviews at end
**Verdict: Decent but suboptimal**
- Errors caught late = wasted work on the wrong path
- Opus reviewing a completed doc is less impactful than Opus correcting a wrong decision mid-task
- No ability for Opus to redirect mid-course

### Option C: Advisor Strategy (Anthropic's recommendation)
**Verdict: Best default for accuracy + cost**
- Sonnet catches its own easy decisions without burning Opus tokens
- Opus intervenes only at hard decision points — highest leverage
- +2.7% accuracy AND -12% cost vs Sonnet alone
- Single API request — no orchestration logic needed
- Works best for: structured writing, code generation, multi-step analysis, complex docs

---

## When Multi-Agent IS Worth It

Sub-agent architectures (where a lead agent spawns subagents) are best when:
- The task is truly parallelizable and independent across subtasks
- Each subtask needs deep exploration (tens of thousands of tokens)
- Subagents return condensed summaries (1,000-2,000 tokens) to the lead
- Example: comprehensive research where 10 directions are explored simultaneously

Anthropic's own research system (Opus lead + Sonnet subagents) outperformed single-agent Opus by 90.2% on research evals — but costs ~15x tokens. Only worth it if the question is big enough.

---

## Practical Recommendations for This Project

For generating accurate docs and catching errors:
1. **Default:** Use Sonnet 4.6 with the Advisor tool (Opus 4.6), `max_uses=3`
2. **For research tasks:** Consider Sonnet subagents that explore independently, then a final Sonnet/Opus synthesis pass
3. **For verification/review:** Explicit review steps in your prompt are more reliable than relying on a separate model pass at the end
4. **Token efficiency:** 80% of performance variance is explained by token usage — more tokens = better output, but use them on signal not noise

---

## Update: How people orchestrate subagents in practice (2026-07-21)

Field research on how power users run an orchestrator plus subagents, and what it means for defaulting every session to that posture.

**Keep the orchestrator in coordination mode.** The main session should plan, delegate, and synthesize, not implement. When the orchestrator writes code itself, its context fills with debugging noise and the original plan decays. One writeup calls this the orchestrator's dilemma: architectural intent and implementation detail compete for the same attention ([responseawareness.substack.com](https://responseawareness.substack.com/p/claude-code-subagents-the-orchestrators)).

**Split work by context ownership, not by type.** Anthropic's guidance is that dividing "one agent writes code, one writes tests" creates a telephone-game handoff. The agent that builds a feature already holds the context to test it, so let it do both ([claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them)).

**Cheap-model delegation is the real cost win.** Strong model plans and reviews, cheap model executes. Reports cite 5x to 10x token cost reduction with little quality loss on straightforward code generation, search, and repetitive edits. Quality drops on architectural judgment and ambiguity, so a review step stays mandatory. A common tiering: strong model orchestrates, Haiku explores, Sonnet implements against a clear spec ([mindstudio.ai](https://www.mindstudio.ai/blog/smart-orchestrator-cheaper-sub-agent-models-claude-code)).

**Multi-agent is expensive in raw terms.** Anthropic's own numbers: agentic chat uses about 4x the tokens of plain chat, full multi-agent systems about 15x. The spend buys real performance (token usage alone explains about 80 percent of variance in research task success), but only if the task value justifies it.

**Anthropic's guidance is explicitly anti-default.** Start with a single agent. Go multi-agent only for three reasons: context protection (isolate noisy context), parallelization (for thoroughness, not speed), or specialization (when one agent would need 15 to 20 plus tools or conflicting prompts). They name coding as a weaker fit than research, because most coding subtasks are tightly coupled ([anthropic.com/engineering/multi-agent-research-system](https://www.anthropic.com/engineering/multi-agent-research-system)).

**Opus over-spawns.** Documented tendency for Opus to delegate even when a direct pass would be faster and cheaper. A simple task that burns 50K tokens is often an unnecessary delegation.

**Verdict on "orchestrator by default" as a standing instruction:** conditional, not blanket. A rule to always spawn subagents would trigger the exact failure Anthropic warns about, delegating trivial and sequential work at extra cost and latency. What holds up is narrower: default to delegating exploration, search, and parallelizable research to cheap subagents to keep the main context lean, keep planning and synthesis in the main session, and use the advisor for hard mid-task decisions. Do not delegate trivial or tightly coupled work. This matches both the cost data and Anthropic's own warnings.

### Sources (2026-07-21 update)
- [How we built our multi-agent research system - Anthropic](https://www.anthropic.com/engineering/multi-agent-research-system)
- [When to use multi-agent systems (and when not to) - Anthropic](https://claude.com/blog/building-multi-agent-systems-when-and-how-to-use-them)
- [Effective context engineering for AI agents - Anthropic](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Building a C compiler with parallel Claudes - Anthropic](https://www.anthropic.com/engineering/building-c-compiler)
- [Smart orchestrator, cheaper sub-agent models - MindStudio](https://www.mindstudio.ai/blog/smart-orchestrator-cheaper-sub-agent-models-claude-code)
- [The Orchestrator's Dilemma - Response Awareness](https://responseawareness.substack.com/p/claude-code-subagents-the-orchestrators)

---

## Sources
- [The Advisor Strategy — Anthropic Blog](https://claude.com/blog/the-advisor-strategy)
- [Advisor Tool Docs — Claude Platform](https://platform.claude.com/docs/en/agents-and-tools/tool-use/advisor-tool)
- [Anthropic Multi-Agent Research Architecture](https://theaiengineer.substack.com/p/how-anthropic-built-multi-agent-deep)
- [AdaptOrch: Task-Adaptive Multi-Agent Orchestration](https://arxiv.org/pdf/2602.16873)
- [Claude Advisor Strategy: +2.7% Accuracy, -12% Cost](https://pasqualepillitteri.it/en/news/831/claude-advisor-strategy-opus-sonnet-contesto-condiviso)
