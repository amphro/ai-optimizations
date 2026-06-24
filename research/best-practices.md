# AI Best Practices & Prompting (June 2026)

> ***🤖 Claude generated, human reviewed***

**Last updated:** 2026-06-18  
**Primary source:** Anthropic engineering blog, Claude platform docs  
**Reliability:** High — directly from Anthropic

---

## Context Engineering (the evolution beyond prompt engineering)

Anthropic's framing: **Context engineering** is the progression from prompt engineering. It's not just about writing better prompts — it's about curating the optimal set of tokens (what information goes in) for each inference call.

**Key insight:** LLMs have an "attention budget." Every token depletes it. More tokens ≠ better — it causes **context rot** (accuracy degrades as context grows). The goal is the **smallest set of high-signal tokens** that produce the desired behavior.

### System Prompt Best Practices
- Use simple, direct language at the **right altitude** — not too prescriptive (brittle if-else), not too vague (undefined behavior)
- Organize into distinct sections: `<background_information>`, `<instructions>`, `## Tool guidance`, `## Output description`
- Use XML tags or Markdown headers to delineate sections
- Include **diverse, canonical examples** (few-shot) rather than exhaustive edge cases — examples are "pictures worth a thousand words"
- Start minimal, then add only based on observed failure modes
- Test minimal prompt with best available model first

### Tool Design Best Practices
- Tools should be self-contained, robust to error, extremely clear in purpose
- **Minimal overlap** in tool functionality — if a human can't pick the right tool, the model can't either
- Input parameters: descriptive, unambiguous
- Tool results should be token-efficient
- Avoid bloated tool sets — prune aggressively

---

## Memory Strategies for Long-Running Agents

Three main approaches, use them together:

### 1. Compaction (Context Summarization)
When context nears the limit, summarize and reinitialize a new window with the summary.
- Claude Code does this automatically — preserves architectural decisions, bugs, implementation details; discards redundant tool outputs
- Keep the last 5 most recently accessed files alongside the summary
- Tune compaction prompts for your domain: **maximize recall first, then improve precision**
- Easiest starting point: **clear tool call results from deep history** — you don't need raw outputs from 50 turns ago

### 2. Structured Note-Taking (Agentic Memory)
Agent regularly writes notes to a persistent file (e.g., `NOTES.md`, `TODO.md`), reads them at the start of each session.
- Anthropic ships a **memory tool (public beta)** on the Claude Platform — file-based, exportable, editable via API or Console
- Works across context resets — agent reads its own notes to resume
- Demonstrated dramatically in Claude plays Pokémon: tracks objectives across thousands of game steps

### 3. Sub-agent Architectures
Specialized agents handle focused tasks with clean context windows, return condensed summaries (1,000-2,000 tokens) to lead.
- Lead agent holds high-level plan, subagents do deep work
- Each subagent explores fully then compresses results
- See orchestration-patterns.md for when this is worth the cost

---

## Just-In-Time Context (Agentic Search)

Rather than loading all data upfront, agents maintain **lightweight identifiers** (file paths, URLs, queries) and retrieve data at runtime when needed.

- Claude Code uses this: glob/grep to find files just-in-time instead of loading the whole codebase
- Metadata of references provides implicit signal (folder structure, naming conventions, timestamps)
- Trade-off: slower than pre-computed retrieval, but avoids stale indexing and context bloat
- **Hybrid approach:** Pre-load known-critical data (e.g., CLAUDE.md), explore the rest just-in-time

---

## Prompting Techniques (2026 Applicability)

These still work and Anthropic continues to recommend them:

| Technique | Notes |
|---|---|
| **Few-shot examples** | Still strong — use diverse canonical examples, not exhaustive edge cases |
| **XML tags** | Useful for structuring sections in system prompts |
| **Chain-of-thought / extended thinking** | Ask Claude to reason step by step; for Claude, `thinking` mode activates extended reasoning |
| **Role assignment** | Give Claude a specific persona/role for specialized tasks |
| **Positive + negative examples** | Show what you want AND what you don't want |
| **Specify output format explicitly** | JSON schema, markdown structure, word limits |
| **Ask for verification** | "After completing, double-check X" — models follow explicit verification instructions |

**Note:** Exact formatting of prompts matters less in 2026 than it did in 2024 — models are more capable at parsing intent.

---

## Claude-Specific Tips

### Extended Thinking
- Enable with `thinking` parameter in the API
- Best for: math, complex reasoning, hard coding problems
- Costs more but significantly improves accuracy on hard tasks
- In the Advisor Strategy, evaluations showed **thinking off** for the executor (Sonnet) + Opus advisor outperformed Sonnet with thinking on in some benchmarks — cheaper and better

### Prompt Caching
- Cache expensive system prompts and large documents — up to 90% cost reduction
- Cache is maintained for 5 minutes (refreshed on use), with extended cache available
- Use for: large system prompts, reference documents, few-shot examples

### Model Selection Heuristic (Claude)
- **Quick question / chat / classification:** Haiku 4.5
- **General work / writing / coding:** Sonnet 4.6 (default)
- **Hard problems / architecture / needs maximum accuracy:** Opus 4.8
- **Unclear?** Sonnet + Advisor tool (Opus), `max_uses=3`

---

## Cross-Model Best Practices

These apply regardless of provider:

1. **Treat context as finite and expensive** — prune aggressively
2. **Benchmark your specific task** — benchmark results don't always generalize to your use case
3. **Iterative refinement** — start minimal, add based on failure modes
4. **Explicit verification steps** — don't assume the model will self-check; ask it to
5. **Separate concerns** — different agents for different reasoning modes (exploration vs. synthesis vs. review)
6. **Token volume ≈ quality** — "token usage explains 80% of performance variance" (Anthropic research)

---

## What's Changed in 2026

- **Context engineering > prompt engineering** — managing what's in context matters more than wording
- **Advisor pattern** — the new default for accuracy + cost, replacing both pure orchestrator and pure reviewer patterns
- **Managed agents** — Anthropic and others offer managed infrastructure so you don't have to handle context limits, memory, and agent loops yourself
- **Open models competitive** — Llama 4, DeepSeek, Mistral handle most tasks competently; frontier models matter mainly for hardest tasks

---

## Sources
- [Effective Context Engineering for AI Agents — Anthropic](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- [Context Windows — Claude API Docs](https://docs.anthropic.com/en/docs/build-with-claude/context-windows)
- [Long Context Prompting Tips — Claude Docs](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/long-context-tips)
- [Prompting Best Practices — Claude 4 — Anthropic](https://console.anthropic.com/docs/en/build-with-claude/prompt-engineering/claude-4-best-practices)
- [Context Engineering from Claude — Bojie Li](https://01.me/en/2025/12/context-engineering-from-claude/)
