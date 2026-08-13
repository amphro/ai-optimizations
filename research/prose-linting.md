# Prose Linting Tools

> ***🤖 Claude generated, human reviewed***

## Vale

Vale is a standalone Go binary that applies YAML-defined style rules to prose in Markdown, AsciiDoc, HTML, reStructuredText, and other formats. It is markup-aware: code blocks, inline code, and front matter are excluded from checks by default.

Vale ships with a minimal built-in `Vale` style. All other styles (Google, Microsoft, write-good, proselint) are installable packages fetched via `vale sync`.

### Config (.vale.ini)

```ini
StylesPath = .vale/styles
MinAlertLevel = suggestion

[*.md]
BasedOnStyles = Vale, MyStyle
```

### Custom rule types

| Type | Use case | Key field |
|---|---|---|
| `existence` | Flag forbidden patterns | `tokens` (word list) or `raw` (regex) |
| `substitution` | Enforce preferred terms | `swap: {bad: good}` |
| `occurrence` | Limit pattern frequency | `max: N` |

### What Vale can check (focus areas)

- **Em dashes**: use `raw` with a Unicode escape to avoid embedding the glyph in the rule file.
- **Filler words**: `existence` rule with `tokens` list.
- **Banned vocabulary**: `existence` or `substitution` depending on whether you want a replacement suggested.
- **Transition-word overuse**: `occurrence` rule with `max: 1` or `max: 2` per file.

### Example: filler words + em dash rule

```yaml
extends: existence
message: "Avoid '%s' in prose."
level: warning
ignorecase: true
tokens:
  - just
  - simply
  - essentially
  - basically
  - delve
  - leverage
  - robust
  - seamless
raw:
  - '\x{2014}'
```

### Shell integration

```sh
# Exit 1 on any errors (good for CI)
vale --output=JSON docs/ | jq '.[]'

# Suppress non-zero exit (report only)
vale --no-exit --output=line docs/
```

Exit codes: `0` = clean, `1` = lint errors found, `2` = runtime error.

---

## Alternative tools

| Tool | Language | Markup-aware | Extensible | Notes |
|---|---|---|---|---|
| write-good | Node | No | No | Passive voice, weasel words; also a Vale package |
| textlint | Node | Yes | Plugin-based | Aggregates other linters; slower than Vale |
| proselint | Python | No | No | Opinionated, curated rules; no Markdown support |

Vale is the strongest choice for Markdown CI integration: single binary, no runtime dependencies, structured JSON output, per-file and per-rule suppression, and the fastest benchmark of the group.

---

## Enforcing style on the agent, not just on the repo

Linters check files that already exist. They do nothing about an agent that keeps producing the wrong style in the first place. Those are separate problems and need different layers.

### Why a style skill alone does not hold

Skills are model-invoked. A writing-voice skill fires when the model reads its description and decides the current task is a writing task. That fails exactly when writing is a byproduct rather than the goal:

- Generating end-user content (game text, UI copy) while implementing a feature
- Writing code comments while writing the function
- Touching a Markdown file as a side effect of another change

A CLAUDE.md line that says "follow the writing-voice skill" is a pointer to a rule, not a rule. It needs three things to go right: the model notices the line, decides it applies, and invokes the skill. A one-sentence rule inlined in CLAUDE.md skips all three.

There is also in-context imitation. If the instruction files themselves violate the rule, the model copies what it sees. A skill file that bans em dashes while containing them is worse than no file.

### Layers, weakest to strongest

| Layer | Adherence | Covers | Cost |
|---|---|---|---|
| Skill invocation | Lowest, fires only when classified as a writing task | Voice selection, tone, structure | Free when it fires |
| CLAUDE.md inline rule | ~80%, always in context | All output including chat replies | One line of context budget |
| PreToolUse hook | Deterministic | File writes and commit messages | One retry when it fires |
| Vale in CI | Deterministic | Committed Markdown only | Build step |

Use the strongest layer that covers the surface. Keep the skill for judgment calls (which voice suits this document) and push absolute rules down to the hook.

### Where Vale cannot help

Vale is markup-aware and skips code blocks and inline code by design. That is correct for prose linting and fatal for this use case: it structurally cannot catch a banned character inside a code comment. A PreToolUse hook inspects raw content before the write and does catch those.

The hook has its own blind spot, deliberately. It only inspects Bash commands containing `git commit`, so a heredoc (`cat > file <<'EOF'`) writes whatever it likes. Scanning every Bash command produces false positives on greps and cleanup scripts, which is a worse trade. `protect-secrets.sh` does tokenize whole commands, because a leaked secret is worth the noise and a stray dash is not. Know which tradeoff you picked.

### PreToolUse beats PostToolUse here

PreToolUse blocks the bad write instead of correcting it afterward. It also sees the content before it lands, which is what makes "only block newly introduced violations" possible.

The payloads are not symmetric, and this matters:

| Tool | Payload | Implication |
|---|---|---|
| `Edit` | `new_string` only | Legacy content is invisible, nothing to filter |
| `MultiEdit` | `edits[].new_string` | Same |
| `Write` | the **entire file body** | A full-file rewrite of a legacy file carries every pre-existing violation |

Get this wrong and rewriting any legacy file becomes impossible. The fix is to diff against what is already on disk: for `Write` on an existing file, drop every offending line that already exists verbatim in the file, and block only on what is genuinely new. Do that filtering in a single `awk` pass. A `grep` per offending line costs seconds on a large file, which is unacceptable for a hook that runs on every write (measured: 4.8s versus 0.04s on a 2000-line case).

### Treat the detectable violation as a canary

The trap in mechanical enforcement is that it teaches the narrowest possible lesson. Block on a banned character and print "remove the character," and you get back content with that character removed and every other style problem intact. Filler words, AI cliche vocabulary, transition spam, and forced closing summaries all survive, because nothing asked about them.

One character is a poor goal but an excellent signal. If a banned character appears, the style rules were almost certainly not applied at all. So the block message should ask for a full revision of the passage, not a character swap.

What makes this affordable is that the message only renders on failure. Three things belong in it:

1. The specific violation, with line numbers, so the mechanical part is unambiguous.
2. A regex scan for the rest of the detectable rules, reported but never used as a trigger. Word choice is the only part a regex can see. Blocking on filler words directly would fire constantly on legitimate code and technical prose, so report and let the model judge.
3. The full rule list, printed verbatim.

Read that rule list out of the skill file at block time (`awk '/^## The base/{f=1;next} /^## /{f=0} f'`) rather than duplicating it in the hook. The skill stays the single source of truth, and editing it changes what the hook teaches. A hook with its own hardcoded copy of the rules drifts from the skill within a few edits, and then the two disagree about the style.

Finish by naming what the scan cannot see (sentence-length variety, fragments, forced summaries, bulleted non-lists) and pointing at the skill for anything long enough to need a voice choice rather than a checklist.

### Do not sanitize upstream of the tripwire

This one is counterintuitive and easy to get backwards. Once a canary is in place, the instinct is to push the same rule out to every component that produces text, including subagents whose output is only ever intermediate. That instinct is wrong, and acting on it quietly disables the canary.

A reviewer subagent that strips dashes from its findings hands the orchestrator text that looks clean. If the orchestrator passes any of it through, the guard never fires, so the full style pass never happens. The dash was the only thing that would have triggered a real revision, and a well-meaning upstream rule removed it.

Leave intermediate producers alone and put the style step where the durable artifact is created. In practice that means the skills that write a file (a research write-up, a decision record, a review) invoke the voice skill before writing, and they treat subagent output as raw input rather than finished prose. It also lands the rule where it can actually be followed: read-only reviewer subagents are usually configured without the Skill tool, so telling them to invoke a skill produces an instruction they cannot execute.

The general form: a tripwire only works if the signal survives the whole path to the thing being guarded. Suppressing the signal early feels like defense in depth and is closer to the opposite.

An env-var override is the standard pattern, but it must be documented accurately. Hooks are spawned from the Claude Code process environment, so `export VAR=1` inside a Bash tool call does **not** reach them. Shell state does not persist between tool calls. Telling the model to "export VAR=1 for the session" produces an instruction it cannot follow, which is worse than having no hatch at all: the model gets blocked, tries the documented fix, fails, and routes around the hook some other way.

The reachable forms are an `env` entry in `settings.json` or a launch-time `VAR=1 claude`. Both require the user, so the block message should say to ask the user rather than implying self-service.

Implementation notes from `tools/claude-code/hooks/writing-voice-guard.sh`:

- macOS ships bash 3.2, which has no `$'\uXXXX'` escape. Build the pattern with `printf '\xe2\x80[\x92-\x95]'` and match under `LC_ALL=C` so the range is byte-wise.
- That single range covers U+2012 figure dash through U+2015 horizontal bar, which includes both en dash and em dash.
- Exit 2 sends stderr back to the model as feedback. Name the exact character and print the offending line numbers so the rewrite lands in one retry instead of a guessing loop.
- Restrict the Bash matcher to commands containing `git commit`. Scanning every command produces false positives on greps and cleanup scripts.
- Measured overhead is roughly 19ms per invocation, including the jq parse.
