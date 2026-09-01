---
type: smart-review
date: 2026-08-31T13:24-0700
task: New harden-plan skill (tools/claude-code/skills/harden-plan/SKILL.md)
models:
  - agent: staff-engineer
    model: sonnet
  - agent: security-reviewer
    model: sonnet
  - agent: domain-expert
    model: sonnet
agent_count: 3
cost_usd: null
---

## Critical Issues

All three reviewers independently found the same root problem in Step 4 (the Codex review loop), the one part of the skill explicitly marked "load-bearing, not stylistic":

1. **The Round 1 command referenced a file, `REVIEW_PROMPT`, that nothing in the skill ever created.** Followed literally, `cat REVIEW_PROMPT` would fail, the substitution would silently resolve to an empty string, and Codex would run a review round against an empty prompt. The security reviewer flagged the sharper version of this: a bare relative filename read out of the repo under review is a real prompt-injection path. A repo file that happened to be named `REVIEW_PROMPT` would silently become the entire instruction set sent to the reviewer, replacing the read-only and no-file-modification constraints.
2. **The verdict file (`/tmp/codex-verdict.txt`) was a single fixed path, reused unchanged across all 5 rounds, with stdout and stderr both discarded to `/dev/null`.** If any resume call failed silently (auth expiry, network blip, thread expiry), the loop would read the previous round's leftover file and log it as the current round's result. That could rediscover a stale APPROVED and declare false convergence on a review that never ran.
3. **stderr was unconditionally discarded on every invocation.** This directly undercut the skill's own stated principle, "stop and tell the user rather than retrying blind," since there was no diagnostic text left to tell the user anything.

## Agreement Across Reviewers

- The `< /dev/null` redirect and its rationale (avoiding a stdin-read hang under a non-interactive driver) is correct and standard practice. No reviewer found fault with it.
- The `-s read-only` / `-c sandbox_mode="read-only"` split between the fresh call and the resume call is real. `resume` genuinely rejects `-s`, so the resume-specific override is necessary, not decorative.
- The `PLAN_FILE` tunable was declared but never actually threaded into the two review prompts, which hardcoded the literal string `PLAN.md`. An override would silently break the review.
- The verdict-line check had no fail-closed behavior. A missing, malformed, or non-exact verdict line had no defined handling, and an APPROVED was accepted with no check that Codex had produced a substantive critique at all.
- Round number and thread ID were tracked only as implicit in-context state, with no durable location, making them fragile across a context compaction mid-loop.

## Divergent Perspectives

None substantive. The three reviews converged on the same failure modes from different angles (process correctness, security, CLI-integration plausibility) rather than disagreeing on severity or fix direction.

## Prioritized Action List

All items below were fixed directly in `tools/claude-code/skills/harden-plan/SKILL.md` rather than left as findings, since they sit in the one section the skill itself calls load-bearing.

1. **Removed the undefined `REVIEW_PROMPT` file reference.** The prompt is now built as a literal string inline in the `codex exec` command itself, for both Round 1 and resume rounds. This also closes the prompt-injection path the security reviewer flagged. (staff-engineer, security-reviewer, domain-expert)
2. **Replaced the single fixed `/tmp/codex-verdict.txt` with a private per-run working directory** (`mktemp -d` under the repo root) holding per-round verdict and stderr files (`round-<n>-verdict.txt`, `round-<n>-stderr.txt`) plus a persisted `thread_id.txt`. A round now only counts as complete if its own file was freshly written and non-empty. There is no stale file left to fall back to. (staff-engineer, security-reviewer)
3. **Stopped discarding stderr.** Each round's stderr is captured to its own file and surfaced to the user on failure instead of being thrown away. (staff-engineer, security-reviewer, domain-expert)
4. **Threaded `$PLAN_FILE` through both prompts as an absolute path**, and added an explicit instruction to run `codex exec` from the repo root. This closes the relative-path/cwd-reset failure mode the staff-engineer raised. (staff-engineer, security-reviewer)
5. **Made verdict parsing fail-closed.** Only an exact, last-non-empty-line, case-sensitive "VERDICT: APPROVED" with a substantive (non-boilerplate) critique body counts as convergence. Everything else, including a well-formed but hollow APPROVED, is treated as REVISE. Added the "exactly one line" instruction to the resume prompt, which had dropped it. (all three reviewers, especially the security reviewer's point that an uncritically trusted APPROVED was the actual highest-risk branch, not REVISE)
6. **Wired the Codex-version gate into the Step 3 availability check** so a CLI older than 0.130 routes to the same not-available branch as a missing binary, instead of proceeding into Step 4 and hitting an undocumented model-default error. (security-reviewer)
7. **Made the same-model fallback require an explicit user opt-in in their own turn**, rather than an inferred "the user probably wants this," since this skill runs under an auto-mode bias toward not stopping to ask. (security-reviewer)
8. **Added `thread_id` format validation** (`^[A-Za-z0-9_-]+$`) before reuse in the resume command, as defense in depth against consuming an unexpected value out of the JSON stream. (security-reviewer)

## What Looks Good

- The three-phase structure (recon, interrogate, cross-model review) and the reasoning for each phase's existence is clear and was not challenged by any reviewer.
- The load-bearing-vs-cosmetic question framing in Step 2, including the "if we guess wrong" test for demoting a question, was called out as sound by the staff-engineer.
- The core safety property, that Codex is read-only every round including on resume, was verified as correctly reasoned, not just asserted, by the security reviewer.
- The explicit refusal to silently substitute a same-model Claude review for a genuine cross-model one is enforced consistently through the skill. That refusal was the entire point of building this rather than adopting the source project wholesale.

## Sources

- [chaseai-yt/claudex-loop](https://github.com/chaseai-yt/claudex-loop) (MIT licensed), origin of the Codex CLI mechanics and review prompt this skill adapts.
- `research/ai-council.md`, echo-chamber pitfall motivating the cross-model design.
