# Claude Code Setup for Complex Arch Docs & Implementation

**Last updated:** 2026-06-18  
**Source:** [Claude Code model config docs](https://code.claude.com/docs/en/model-config), [Best practices](https://code.claude.com/docs/en/best-practices)  
**Reliability:** High — official docs

---

## TL;DR: The Best Default Config for Complex Arch Work

```json
// ~/.claude/settings.json
{
  "model": "opusplan"
}
```

That's it. `opusplan` is a built-in Claude Code alias that:
- Uses **Opus** automatically during plan mode (complex reasoning, architecture decisions)
- Switches to **Sonnet** automatically for execution (code generation, implementation)

This is the native Claude Code equivalent of the Advisor Strategy — no extra configuration needed.

---

## Model Aliases Available in Claude Code

Set via `/model`, `--model`, or `"model"` in settings.json:

| Alias | What it does |
|---|---|
| `opusplan` | **Best for arch work** — Opus in plan mode, Sonnet in execution |
| `opus` | Full Opus everywhere (most capable, highest cost) |
| `sonnet` | Full Sonnet everywhere (best default for everyday coding) |
| `opus[1m]` | Opus with 1M context window (Max/Team/Enterprise: included; Pro: costs extra) |
| `sonnet[1m]` | Sonnet with 1M context (costs usage credits on all sub tiers) |
| `best` | Fable 5 if you have access, otherwise latest Opus |
| `fable` | Fable 5 — longest autonomous sessions, most capable, highest cost |

**Recommendation:** Start with `opusplan`. Switch to `opus[1m]` when dealing with very large codebases. Use `fable` if you're on Max/Enterprise and doing multi-hour autonomous sessions.

---

## Effort Levels (Set in settings.json)

```json
{
  "model": "opusplan",
  "effortLevel": "high"
}
```

| Level | When to use |
|---|---|
| `high` | **Default** — balances token usage and intelligence. Good for most arch work |
| `xhigh` | Deeper reasoning, higher cost. Good for the hardest architecture decisions |
| `max` | Session-only. Deepest reasoning, no token ceiling. Use sparingly |

Add `ultrathink` anywhere in your prompt for one-off deep reasoning on a single turn without changing the session effort.

**`ultracode`** (session-only, set via `/effort`): Plans a dynamic workflow for each substantive task with xhigh reasoning. Worth trying for complex implementation sessions.

---

## CLAUDE.md: What to Put In It

The ~150-200 instruction budget is shared with Claude Code's system prompt (~50 instructions). **Keep it short.** Every unnecessary line pushes out a useful one.

**Rule of thumb:** If Claude already does it correctly without the instruction, don't include it.

### What to include

```markdown
# Architecture conventions
- [Your specific patterns, e.g. "ADRs live in docs/decisions/"]  
- [Non-obvious decisions Claude can't infer from code]

# Workflow
- Always enter plan mode before touching multiple files
- After making changes, run [your verification command]
- For arch docs: create a plan first, get explicit approval before writing

# Doc standards  
- [Your specific format requirements for arch docs]
- [Where docs should live, naming conventions]

# Common gotchas
- [Things Claude gets wrong repeatedly in YOUR codebase]
```

### What NOT to include
- Standard conventions Claude already knows
- Things derivable from reading your code
- Long explanations or tutorials (use Skills instead)
- File-by-file descriptions of the codebase

**Important:** CLAUDE.md is advisory (~80% adherence). For things that MUST happen (linting, security checks), use hooks instead — they're deterministic.

---

## Subagent Reviewer Pattern (Adversarial Review)

For arch docs where accuracy matters, this is the best built-in review mechanism:

Create `.claude/agents/arch-reviewer.md`:

```markdown
---
name: arch-reviewer
description: Reviews architecture docs and implementation plans for gaps, edge cases, and errors
tools: Read, Grep, Glob
model: opus
---
You are a senior architect doing adversarial review. Your job is to find problems, not confirm everything is fine.

Review the provided document or diff for:
- Logical gaps or missing considerations
- Unstated assumptions that could fail
- Edge cases not covered
- Inconsistencies with existing architecture
- Missing error handling or failure modes

Report specific findings with line references. Flag only issues that affect correctness or completeness — not style preferences.
```

Invoke it: *"Use the arch-reviewer subagent to review this doc before we finalize it"*

The reviewer runs in a **fresh context** with no memory of what generated the doc — so it evaluates the result on its own terms, not the reasoning that produced it. This is the closest approximation to the Advisor Strategy's accuracy gains within Claude Code.

---

## Workflow for Complex Arch Docs

Anthropic's recommended pattern for large tasks:

1. **Plan mode first** (Ctrl+Shift+P or `/plan`): Claude explores, reads files, asks questions — no edits
2. **Get a written plan**: Ask Claude to write it to `PLAN.md` so you can review/edit it before execution
3. **Execute against the plan**: Switch out of plan mode, Claude implements against the written plan
4. **Adversarial review**: Invoke the arch-reviewer subagent against the output

For very large arch tasks: break into phases, each phase gets its own plan → execute → review cycle. Large tasks exceed a single context window.

---

## Context Management Tips for Long Sessions

- **`/clear` between unrelated tasks** — long sessions with irrelevant context degrade quality
- **`/compact`** — summarize conversation history when approaching limits; customize with `/compact Focus on the arch decisions`
- **Add to CLAUDE.md:** `"When compacting, always preserve the full list of modified files, architecture decisions made, and open questions"` — so critical context survives compaction
- **Use subagents for exploration** — "Use a subagent to investigate how auth works" — subagent reads all the files, reports back a summary, without filling YOUR main context
- **`/btw`** — ask side questions without adding them to context history

---

## Quick Reference: settings.json for Arch Work

```json
{
  "model": "opusplan",
  "effortLevel": "high"
}
```

That's the recommended starting point. Adjust from there based on your plan:

- On Max/Team/Enterprise doing large autonomous runs → `"model": "fable"`
- Very large codebase → `"model": "opus[1m]"` or `"opusplan[1m]"`
- Cost-sensitive, routine tasks → `"model": "sonnet"`

---

## Sources
- [Claude Code Model Config](https://code.claude.com/docs/en/model-config)
- [Claude Code Best Practices](https://code.claude.com/docs/en/best-practices)
- [Claude Code Settings Reference](https://gist.github.com/mculp/c082bd1e5a439410158974de90c89db7)
