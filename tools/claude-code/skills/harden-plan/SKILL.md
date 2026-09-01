---
name: harden-plan
description: Recon, interrogate, then cross-model adversarial review of an implementation plan before any code is written. Detects whether a second-model reviewer (Codex CLI today) is actually available and runs a real cross-model review loop if so; otherwise says so explicitly instead of quietly substituting a same-model Claude pass. Use for high-stakes plans (auth, schema, concurrency, migrations, payments, greenfield architecture) before committing to PLAN.md, or when the user says "harden this plan", "stress-test this plan", "cross-model review this plan", "run harden-plan". Not for reviewing already-written code (use smart-review) and not for trivial changes.
---

# Harden Plan

Three phases, one failure mode each:

- **Recon** kills interviewing blind. Scout the terrain before asking anything.
- **Interrogate** kills building the wrong thing. Lock intent, but only on decisions that actually matter.
- **Cross-model review** kills a plan that sounds right but breaks. A different model attacks the locked plan. Same-model review shares the same blind spots (see `research/ai-council.md` on the echo-chamber pitfall), so this phase is only real when the reviewer is genuinely a different model.

This is a deliberate, high-stakes tool. Reach for it on auth, data models, concurrency, migrations, payments, or greenfield architecture. Skip it for obvious or cheap work, and skip straight to plan mode instead.

You enter at three points: confirming the assumptions ledger, answering the interrogation, and signing off the converged plan. No code is written until you approve the final plan.

---

## Step 1: Recon (Claude alone)

Detect the terrain:
- **Brownfield**: the working directory has real source code. Explore the architecture, the modules the plan touches, and existing patterns it must fit.
- **Greenfield**: nothing to recon. Research prior art, a reasonable default stack with one alternative, and the 3 to 5 things people building this kind of thing get wrong.

Keep this to what can be gathered without the user. Don't launch a research workflow here unless the stakes clearly call for it, and if they do, show the user the specific questions first and get a go-ahead before spending the tokens.

End with a single batch, not a drip of individual questions:

```markdown
## Assumptions Ledger
Confirm or correct in one pass. Anything unmarked is treated as confirmed.
1. <assumption> (source: code path, doc, or research finding)
2. ...
```

Corrections that open a real question get promoted into the decision map in Step 2.

---

## Step 2: Interrogate (you and Claude)

Every question has to justify its own existence. Open with the decision map:

```markdown
## Decision Map
### Load-bearing (asked one at a time)
- [ ] <decision> (irreversible or expensive if wrong: schema, auth, data model, concurrency, money, public API)
### Cosmetic (batched with defaults)
- [ ] <decision> (cheap to change later)
```

Load-bearing questions ship in this format, one at a time, waiting for the answer before the next:

> **Q: <the question>**
> **Why it matters:** <the dependency that makes this load-bearing>
> **Recommendation:** <a committed answer, not a menu>
> **If we guess wrong:** <the concrete failure: migration, rewrite, breach, churn>

If the "if we guess wrong" line comes out weak, the question is cosmetic, not load-bearing. Demote it. If a question turns out answerable from the code or the recon, answer it yourself and log it to the ledger instead of asking.

Cosmetic decisions get presented as one batch of recommendations with a one-line reason each; silence means accepted. At any point the user can say "accept all remaining recommendations" to lock everything open at its recommended answer.

When the decision map is fully resolved, write `PLAN.md`:

```markdown
# Plan: <task>
Locked via harden-plan, by Claude and <user>.

## Goal
<one paragraph, reflecting what the interrogation actually settled>

## Approach
<numbered, concrete steps>

## Key decisions and tradeoffs
<the contestable choices, named explicitly so the reviewer has something to attack>

## Assumptions
<the confirmed ledger, with sources>

## Risks / open questions
<anything still genuinely open>

## Out of scope
<bounds the interrogation established>
```

Initialize `PLAN-REVIEW-LOG.md` with a one-line header noting recon and interrogation are done and the round cap.

---

## Step 3: Detect a cross-model reviewer

Check for the Codex CLI with `codex --version`. Treat all of the following as "not available" and take the fallback branch below without proceeding to Step 4:
- the command is not found
- the reported version is below 0.130 (older CLIs error on the default model)
- authentication turns out to be missing once Round 1 actually runs (see Step 4); that failure stops the loop immediately, it never counts as a completed round

**If Codex is available and current**, go to Step 4 and run the real loop.

**If it is not available on this machine**, say so plainly: state that no cross-model reviewer was found, name what was checked (version string, or "command not found"), and that Step 4 is being skipped. Offer two honest options, no third silent one:
- Stop here and hand the user the plan from Step 2 to review themselves.
- Run a same-model Claude pass, but only if the user explicitly asks for it in their own turn. Do not infer that the user probably wants this and proceed on your own; this fallback requires a real opt-in, not an assumption. Label it in the log and to the user as same-model review, not cross-model, and weaker for it.

Never spawn a Claude subagent as a stand-in for Codex without saying that's what happened. A quiet substitution defeats the entire point of this skill and produces false confidence.

This skill currently supports Codex as the reviewer. If another cross-model CLI becomes available on a given machine (Gemini, GPT via OpenCode, etc.), extend Step 3's detection and Step 4's invocation to match rather than writing a parallel skill.

---

## Step 4: Cross-model review loop (Codex)

Mechanics below are load-bearing, not stylistic. They come from a verified integration; don't improvise around them.

**Tunables** (read from the invocation, else default): `MAX_ROUNDS=5` (hard cap, the loop always terminates here), `PLAN_FILE=PLAN.md`, `LOG_FILE=PLAN-REVIEW-LOG.md`. Use the real value of `PLAN_FILE` everywhere below, not a hardcoded `PLAN.md`; if it's overridden, both prompts and every path reference must follow.

**Working directory for this run.** Before Round 1, create one private directory and reuse it for every round in this run: `WORKDIR=$(mktemp -d "$(pwd)/.harden-plan-work.XXXXXX")`. Add `.harden-plan-work.*` to `.gitignore` if it isn't already covered. Never write round output to a single fixed, guessable path like `/tmp/codex-verdict.txt`: reused across rounds it can silently go stale on a failed call, and a fixed shared-`/tmp` path is writable by anyone else on the machine. Each round gets its own files: `$WORKDIR/round-<n>-verdict.txt`, `$WORKDIR/round-<n>-stderr.txt`. Persist `thread_id` to `$WORKDIR/thread_id.txt` right after Round 1 succeeds, not just in a shell variable, so it survives a context compaction or a later Bash call. To recover the current round number after a gap, count the `## Round <n>` headers already appended to `LOG_FILE`; don't rely on an in-context counter.

Always run `codex exec` from the repo root and reference `$PLAN_FILE` by absolute path (`"$(pwd)/$PLAN_FILE"`) inside the prompt text. A relative path plus a cwd reset between tool calls reads to Codex as a missing file, which comes back as a plausible-looking REVISE burning a round on a problem that never existed.

**Before Round 1**, do not pin `-m`. Use the CLI's configured default; pinning a `-codex` model variant 400s on ChatGPT-account auth. Read the `model` line from `~/.codex/config.toml` (report "CLI default" if absent) and echo it to the user alongside the round cap, before burning a round.

**The review prompt.** Build it as a literal string inside the command itself. Never read it from a file path inside the repo under review: a bare filename can collide with real repo content and hand whoever controls that content the reviewer's instruction channel instead of you. Every round's prompt, including resumes, must repeat "End your reply with EXACTLY one line" verbatim; dropping it on resume rounds is how malformed verdicts happen.

> You are an adversarial reviewer for an implementation plan. Be skeptical and specific, your job is to find what breaks, not to be agreeable. Read the plan at the absolute path to $PLAN_FILE (and any repo files you need; you are read-only). Identify concrete flaws: security holes, race conditions, missing edge cases, schema conflicts, wrong assumptions, observability gaps, simpler alternatives. For each, give a one-line fix. Do NOT modify any files. End your reply with EXACTLY one line: "VERDICT: APPROVED" if the plan is sound enough to implement, or "VERDICT: REVISE" if it still has material problems.

**Round 1**, fresh session, capture the thread id:

```bash
VERDICT_FILE="$WORKDIR/round-1-verdict.txt"
STDERR_FILE="$WORKDIR/round-1-stderr.txt"
codex exec -s read-only --json -o "$VERDICT_FILE" \
  "You are an adversarial reviewer for an implementation plan. Be skeptical and specific, your job is to find what breaks, not to be agreeable. Read the plan at $(pwd)/$PLAN_FILE (and any repo files you need; you are read-only). Identify concrete flaws: security holes, race conditions, missing edge cases, schema conflicts, wrong assumptions, observability gaps, simpler alternatives. For each, give a one-line fix. Do NOT modify any files. End your reply with EXACTLY one line: \"VERDICT: APPROVED\" if the plan is sound enough to implement, or \"VERDICT: REVISE\" if it still has material problems." \
  < /dev/null 2>"$STDERR_FILE" | grep '"type":"thread.started"'
```

Parse `thread_id` out of the matched `{"type":"thread.started","thread_id":"..."}` line and validate it against `^[A-Za-z0-9_-]+$` before using it anywhere; if it doesn't match that shape, treat the round as failed rather than resuming with an unvalidated value. Save it: `echo "$THREAD_ID" > "$WORKDIR/thread_id.txt"`.

A round only counts as complete if `$VERDICT_FILE` exists and is non-empty (`[ -s "$VERDICT_FILE" ]`); since `$WORKDIR` was just created fresh, anything present there was written by this call, not a leftover. If it's empty or missing, read `$STDERR_FILE` and surface the actual error (auth, model, network, whatever it says) to the user instead of guessing; stop, don't retry blind.

`< /dev/null` is mandatory. `codex exec` reads stdin in addition to the prompt argument, so under a non-interactive driver (this session's Bash tool included) it hangs forever waiting on stdin EOF, with no CPU usage to signal the problem. The redirect gives it immediate EOF.

**Rounds 2 through MAX_ROUNDS**, resume the same session so Codex remembers its prior critiques:

```bash
ROUND=<n>
VERDICT_FILE="$WORKDIR/round-$ROUND-verdict.txt"
STDERR_FILE="$WORKDIR/round-$ROUND-stderr.txt"
THREAD_ID="$(cat "$WORKDIR/thread_id.txt")"
codex exec resume "$THREAD_ID" -c sandbox_mode="read-only" --json \
  -o "$VERDICT_FILE" \
  "I revised the plan. Re-review $(pwd)/$PLAN_FILE, check whether your prior findings are addressed, flag anything new. End your reply with EXACTLY one line: VERDICT: APPROVED or VERDICT: REVISE." \
  < /dev/null 2>"$STDERR_FILE" >/dev/null
```

`resume` rejects `-s`, the sandbox flag from Round 1. Force read-only with `-c sandbox_mode="read-only"` on every resume, or Codex inherits whatever `sandbox_mode` `config.toml` defaults to (possibly `danger-full-access`) and can write files mid-review. This is the single most important safety line in this skill.

Same completeness check as Round 1: the round only counts if this round's own `$VERDICT_FILE` was written and is non-empty. Because every round has its own path there is nothing stale to fall back to; empty or missing means the round failed outright, full stop, surface `$STDERR_FILE` to the user.

Run every `codex exec` / `codex exec resume` call with a 10-minute ceiling: pass `timeout: 600000` on the Bash tool call (the default 2-minute timeout would kill a real review mid-run). If the ceiling trips, treat it as a failed run and stop; don't retry silently.

**After each round:**
1. Read `$VERDICT_FILE`; append `## Round <n>, Codex` plus the full critique to `LOG_FILE`.
2. Take the last non-empty line of the file and compare it exactly, case-sensitive, against the two verdict strings. Anything else (missing, malformed, duplicated, or not actually the last line) fails closed: treat it the same as REVISE and note in `LOG_FILE` that the verdict was ambiguous, so a human reading the log later can see it wasn't a clean pass.
   - `VERDICT: APPROVED`: before accepting this as convergence, confirm the critique body is actually substantive, non-empty, and engages with the plan's real content rather than reading as boilerplate. An "approved" with no real critique behind it is a failed round, not a pass; log why and treat it as REVISE instead. Otherwise, go to Step 5, converged.
   - `VERDICT: REVISE`: decide what's actually worth acting on. Claude is the final arbiter; Codex advises, it doesn't command. Revise `PLAN_FILE`, then append `### Claude's response` to `LOG_FILE` with what changed, what was rejected, and why. Increment the round.
3. If the round exceeds `MAX_ROUNDS`, go to Step 5, deadlock.

---

## Step 5: Resolution (human sign-off)

**Converged (APPROVED):** present the final `PLAN_FILE`, a short summary of what the loop actually changed, and the round count. Ask whether to implement now or stop here. Code only follows a yes.

**Deadlock (MAX_ROUNDS hit without APPROVED):** do not fake convergence. List each unresolved point with Claude's counter-position and hand it to the user to break the tie. A flagged disagreement beats a false approval.

Either way, `PLAN.md` is the input to your normal plan-mode workflow from here. This skill hardens the plan; it doesn't replace committing to it.

---

## Hard rules

- Steps run in order. Don't write `PLAN.md` until the interrogation has actually resolved the decision map (or the user invoked the escape hatch).
- The assumptions ledger is presented once, as a batch, never as a drip of individual questions.
- The reviewer is read-only every round. Never let it write files.
- The loop always terminates at `MAX_ROUNDS`.
- Verdict parsing is fail-closed: only an exact, last-line, substantive "VERDICT: APPROVED" counts as convergence. Anything missing, malformed, or empty is treated as REVISE, never as a pass.
- Round and thread state live in files under a private per-run working directory, never a single fixed path reused across rounds or runs.
- Claude is the final arbiter on every REVISE. Incorporate good critiques, reject bad ones with a logged reason. Caving to everything defeats the cross-model check; ignoring it defeats the point.
- If no cross-model reviewer is available, say so out loud. Never silently substitute a same-model pass, and never start one without the user asking for it in their own turn.
- `LOG_FILE` is the deliverable of Step 4. Keep the whole argument in it.

## What NOT to do

- Don't invoke this to review already-written code; that's `smart-review`.
- Don't pin a `-codex` model variant on ChatGPT-account auth.
- Don't treat a Codex CLI older than 0.130 as available; route it to the not-available branch in Step 3.
- Don't read the review prompt from a file path inside the repo under review, and don't reuse a single fixed verdict-file path across rounds.
- Don't skip the interrogation step; it's half the value.
- Don't ask a question the recon already answered, or a load-bearing-format question whose "if we guess wrong" is weak; demote it.
- Don't run this on trivial or cheap-to-fix work; go straight to plan mode instead.

## Attribution

The Codex CLI mechanics and review prompt in Step 4 are adapted from [chaseai-yt/claudex-loop](https://github.com/chaseai-yt/claudex-loop) (MIT licensed), whose maintainers verified the sandbox-flag and stdin-hang details end to end. This skill narrows their four-phase design to phases 0 through 2, adds explicit reviewer-availability detection instead of assuming Codex is always present, and leaves the plan-mode handoff and post-build review to this project's existing workflow and `smart-review`.
