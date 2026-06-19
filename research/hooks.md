# Claude Code Hooks

**Last updated:** 2026-06-19
**Source:** Official Claude Code docs (hooks reference, hooks guide), verified GitHub repos (existence and stars/activity checked via `gh api`), awesome-claude-code's curated Hooks category
**Reliability:** High for mechanics and official use cases (verified directly against docs). Mixed for community patterns and third-party repos, code snippets below were pulled verbatim from real repos, but quality and maintenance varies repo to repo (noted inline).

---

## TL;DR

Hooks are shell commands (or HTTP calls, MCP tool calls, single-turn LLM checks, or subagents) that Claude Code runs automatically at specific points in its lifecycle: before/after a tool call, at session start/end, when a prompt is submitted, when Claude stops, and about 20 other events. They get JSON on stdin describing what's happening and can respond with an exit code or JSON to allow, block, modify, or inject context. Official docs recommend them for auto-formatting, notifications, blocking edits to sensitive files, re-injecting context after compaction, audit logging, and environment reloading. The community has pushed well past that into TDD enforcement, permission-fatigue reduction, dependency security gates, and even hooking `ExitPlanMode` to drive a custom UI. Biggest catch: hooks run with your full shell permissions and can be bypassed (Claude can usually find another tool path around a blocked one), so they're a guardrail layer, not a sandbox.

## 1. Mechanics

### Handler types

| Type | What it does |
|---|---|
| `command` | Shell script gets JSON on stdin. Default and most common. |
| `http` | POST to a URL, JSON body in, same JSON-response format out. Good for centralized audit services. |
| `mcp_tool` | Calls a tool on a connected MCP server. |
| `prompt` | Sends the hook input plus a prompt you write to a model (e.g. Haiku) for a yes/no judgment call. Returns `{"ok": true/false, "reason": "..."}`. |
| `agent` | Spawns a subagent with tool access (Read, Grep, Bash, etc.) to verify something more complex. Same `{"ok": ..., "reason": ...}` response. Experimental. |

### Event categories (full list, grouped)

- **Session:** `SessionStart`, `SessionEnd`, `Setup` (fires on `--init-only`/`--init`/`--maintenance`)
- **Turn:** `UserPromptSubmit`, `UserPromptExpansion`, `Stop`, `StopFailure`
- **Tool call:** `PreToolUse`, `PostToolUse`, `PostToolUseFailure`, `PostToolBatch`, `PermissionRequest`, `PermissionDenied`
- **Notification/display:** `Notification`, `MessageDisplay`
- **Agents/tasks:** `SubagentStart`, `SubagentStop`, `TaskCreated`, `TaskCompleted`, `TeammateIdle`
- **Config/files:** `ConfigChange`, `CwdChanged`, `FileChanged`, `InstructionsLoaded`
- **Compaction/worktree:** `PreCompact`, `PostCompact`, `WorktreeCreate`, `WorktreeRemove`
- **MCP elicitation:** `Elicitation`, `ElicitationResult`

`PreToolUse` is the only one that can truly stop something before it happens. `PostToolUse` and friends fire after the fact, they're for audit/cleanup/redaction, not prevention.

### Input/output

Every hook gets common fields (`session_id`, `cwd`, `hook_event_name`, `timestamp`) plus event-specific ones, e.g. `PreToolUse` adds `tool_name`/`tool_input`/`tool_use_id`.

Exit codes: `0` = no objection (stdout becomes injected context for some events). `2` = block; stderr becomes feedback to Claude (tool events) or the user (non-blockable events). Anything else = proceeds, logged as a hook error.

JSON output gives finer control, the key fields:

```json
{
  "continue": true,
  "systemMessage": "Warning injected to Claude",
  "hookSpecificOutput": {
    "hookEventName": "PreToolUse",
    "permissionDecision": "deny",
    "permissionDecisionReason": "why",
    "additionalContext": "text injected into Claude's context"
  }
}
```

Decision field location varies by event, this trips people up:

| Event | Field |
|---|---|
| `PreToolUse` | `hookSpecificOutput.permissionDecision`: `allow`/`deny`/`ask`/`defer` |
| `PostToolUse`, `Stop`, `UserPromptSubmit` | top-level `decision: "block"` |
| `PermissionRequest` | `hookSpecificOutput.decision.behavior`: `allow`/`deny` |

A `PreToolUse` hook returning `deny` blocks the call even under `--dangerously-skip-permissions`, policy hooks can override user bypass modes. Conversely an `allow` from a hook never overrides an explicit `deny` in settings permissions, deny always wins.

### Matchers and the `if` field

Plain alphanumeric strings match exactly (`Bash` matches only the Bash tool); anything with regex syntax is evaluated as regex (`mcp__.*`). `Edit|Write` is literal pipe-alternation, not a regex metachar trap.

Since v2.1.85, a per-hook `if` field filters on tool name *and arguments* using permission-rule syntax, e.g. `"if": "Bash(git *)"` to only fire on git subcommands rather than all Bash calls. Fails open (runs anyway) if it can't parse the command.

## 2. Official use cases (documented, low-risk to copy)

- **Desktop notifications** (`Notification` event) when Claude needs input or finishes. `osascript`/`notify-send`/PowerShell depending on OS.
- **Auto-formatting after edits** (`PostToolUse`, matcher `Edit|Write`): run Prettier/Black/Ruff on the edited file path from `tool_input.file_path`.
- **Blocking edits to protected files** (`PreToolUse`): exit 2 to stop edits to `.env`, `package-lock.json`, `.git/`. Docs note: a `deny` permission rule is more secure than a hook for this since it makes the file invisible to Claude entirely; use hooks for conditional/contextual blocking rules instead.
- **Re-injecting context after compaction** (`SessionStart`, matcher `compact`): restore dynamic state (branch, recent issues) that static CLAUDE.md can't capture.
- **Audit logging of config changes** (`ConfigChange`): log or block changes to settings/skills files.
- **Environment reloading** (`SessionStart` + `CwdChanged`, paired with direnv-style tools): write to `$CLAUDE_ENV_FILE`, which the Bash tool sources before each command. This is the documented way to persist env vars, not relying on shell session state.
- **Auto-approving specific low-risk prompts** (`PermissionRequest`): keep the matcher narrow, a broad one auto-approves destructive stuff too.

## 3. Community patterns (not officially documented, but widely used)

- Dependency security gates: block `npm install`/`pip install` of new packages without review (`PreToolUse` + Bash matcher).
- Type-check on every edit: `tsc --noEmit` after writes, catches "compiles but wrong" bugs faster than lint-on-commit.
- LLM-judged security review (`prompt` hook type): offload context-dependent calls ("does this touch auth/payments?") that regex can't express.
- Cross-file consistency checks via subagent (`agent` hook type): verify a new endpoint matches existing auth patterns.
- Auto-commit on task completion (`Stop` hook), once tests pass.
- TTS/sound alerts on `Notification`, ambient awareness without staring at the terminal.
- Slack/Discord/webhook posts on `PostToolUse`/`Stop` for async monitoring of long sessions.
- TDD enforcement: block edits that violate test-first discipline (see TDD Guard below).
- Permission-fatigue reduction: AST-based auto-approval of bash commands judged safe (see Dippy below).
- Hooking UI-adjacent events: `Plannotator` intercepts `ExitPlanMode` to drive an interactive plan-review UI, a hook used for UX, not just guardrails.

## 4. Security, performance, and pitfalls

**Security (the important one):** hooks run with your full shell permissions. A cloned repo's `.claude/settings.json` can ship hooks that exfiltrate credentials or sabotage a build, treat it with the same suspicion as an unfamiliar `package.json`/postinstall script before trusting a repo's hooks. Don't log raw tool input verbatim (it can contain secrets typed into Bash commands). Never build shell commands from hook input via string interpolation, parse with `jq` and use exec-form commands to avoid shell injection. And remember hooks aren't a sandbox: blocking `Edit` on a file doesn't stop Claude from achieving the same write via `Bash` unless you also block that path or use real filesystem permissions.

**Performance:** hooks run synchronously and block the agent loop by default, a slow hook adds that latency to every matching tool call. Keep them fast, or mark slow ones `"async": true`. Multiple hooks matching the same event run in parallel, if two `PreToolUse` hooks both try to modify `tool_input`, the result is non-deterministic, don't design hooks that depend on order.

**Idempotency:** hooks can fire more than once per logical event (retries, resumed sessions), design them to be safe to re-run (append-only logging, not "increment a counter"). `Stop` hooks specifically cap at 8 consecutive blocks (`CLAUDE_CODE_STOP_HOOK_BLOCK_CAP`) to prevent infinite loops, check the `stop_hook_active` field if you need to detect this in your own script.

**Debugging:** `claude --debug-file /tmp/claude.log` captures full hook execution. Test scripts manually by piping sample JSON (`echo '{"tool_name":"Bash",...}' | ./hook.sh; echo $?`). Run `/hooks` inside a session to see every registered hook by event. A common false alarm: a hook's "JSON validation failed" error is often your `.bashrc`/`.zshrc` printing stuff to stdout before your hook's actual JSON, in non-interactive shells.

## 5. Limitations

- No access to rate limits, token budget, or model state, hooks can't make "we're low on quota" decisions (see [[usage-limit-visibility]], same underlying gap).
- Don't fire in every execution path: gaps exist in pipe mode (`-p`), some VS Code flows, and subagent isolation.
- Hooks can't trigger slash commands or call tools directly, only block/allow/inject text. If you need a security scan, the scan has to run inside the hook script itself.
- `PreToolUse` can't rewrite output after the fact (use `PostToolUse`), and `PostToolUse` can't undo an action that already happened, there's no built-in rollback, only git as your manual undo.
- Context injected via `SessionStart` counts against the context window, keep it concise, use CLAUDE.md for big static docs.

## 6. Notable repos (verified to exist, stars/activity as of 2026-06-19)

| Repo | Stars | Last push | Notable for |
|---|---|---|---|
| [disler/claude-code-hooks-mastery](https://github.com/disler/claude-code-hooks-mastery) | 3,774 | 2026-03-04 | Most complete single reference, wires 13 lifecycle events in one real settings.json |
| [ChrisWiles/claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase) | 5,965 | 2026-01-06 | Branch-protection + chained PostToolUse hooks (format, install, test, typecheck) |
| [karanb192/claude-code-hooks](https://github.com/karanb192/claude-code-hooks) | 424 | 2026-04-26 | Ready-to-use Node scripts: dangerous-bash blocker, secrets protector, Slack notifier, auto-stage, JSONL audit log |
| [luongnv89/claude-howto](https://github.com/luongnv89/claude-howto) | 37,555 | 2026-06-17 | `06-hooks/` directory, 9 distinct example scripts, well-commented |
| [tarekziade/claude-tools](https://github.com/tarekziade/claude-tools) | 8 | 2025-12-18 | Small but real: compacts Python tracebacks in prompts/output to save tokens |
| [nizos/tdd-guard](https://github.com/nizos/tdd-guard) | 2,203 | active | Blocks edits that violate TDD discipline |
| [ldayton/Dippy](https://github.com/ldayton/Dippy) | 237 | active | AST-based auto-approval of safe bash commands, reduces permission-prompt fatigue |
| [backnotprop/plannotator](https://github.com/backnotprop/plannotator) | 6,327 | active | Hooks `ExitPlanMode` to drive an interactive plan-review UI, most creative use case found |
| [ctoth/claudio](https://github.com/ctoth/claudio) | 105 | active | OS-native sound effects on hook events |
| [GowayLee/cchooks](https://github.com/GowayLee/cchooks) | 131 | active | Python SDK abstraction over the hook JSON protocol (also on PyPI) |
| [anthropics/claude-code](https://github.com/anthropics/claude-code/tree/main/examples/hooks) | 133,247 | active (official) | Canonical minimal example, cleanest reference for exit-code semantics |

Stale, exist but don't copy as current best practice: `johnlindquist/claude-hooks`, `dazuiba/CCNotify`, `bartolli/claude-code-typescript-hooks` (all flagged `Stale: TRUE` by awesome-claude-code's own curator, 8-10+ months without a push). Also worth knowing: `pascalporedda/awesome-claude-code` is a small, unrelated, 10-months-stale repo that happens to share a name with the much larger `hesreallyhim/awesome-claude-code`, don't confuse the two.

## 7. Concrete examples

**Blocking dangerous bash commands** (`karanb192/claude-code-hooks`, `block-dangerous-commands.js`):
```js
{ level: 'critical', id: 'rm-home', regex: /\brm\s+(-.+\s+)*["']?~\/?["']?(\s|$|[;&|])/, reason: 'rm targeting home directory' },
{ level: 'high', id: 'curl-pipe-sh', regex: /\b(curl|wget)\b.+\|\s*(ba)?sh\b/, reason: 'piping URL to shell (RCE risk)' },
{ level: 'high', id: 'git-reset-hard', regex: /\bgit\s+reset\s+--hard/, reason: 'git reset --hard loses uncommitted work' },
```
Wired as `PreToolUse` + matcher `Bash`, exits 2 on a match, logs to `~/.claude/hooks-logs/YYYY-MM-DD.jsonl`.

**Protecting secrets** (same repo, `protect-secrets.js`): `PreToolUse` + matcher `Read|Edit|Write|Bash`, blocks access to `.env`, `.ssh/id_*`, `.aws/credentials`, `*.pem`, `*.key`.

**Branch protection + auto-format** (`ChrisWiles/claude-code-showcase`):
```json
"PreToolUse": [{ "matcher": "Edit|MultiEdit|Write", "hooks": [{ "type": "command",
  "command": "[ \"$(git branch --show-current)\" != \"main\" ] || { echo '{\"block\": true, \"message\": \"Cannot edit files on main branch.\"}' >&2; exit 2; }" }] }]
```
Note: this repo's `PostToolUse` formatter step reads a `$CLAUDE_TOOL_INPUT_FILE_PATH` env var that isn't part of Claude Code's documented hook interface, the documented way is reading `tool_input.file_path` from stdin JSON via `jq`. If you copy this pattern, use the documented path, not the env var.

**Git context injection at session start** (`disler/claude-code-hooks-mastery`):
```json
"SessionStart": [{ "matcher": "", "hooks": [{ "type": "command", "command": "uv run $CLAUDE_PROJECT_DIR/.claude/hooks/session_start.py" }] }]
```
Companion script runs `git status --porcelain`, loads `CONTEXT.md`/`TODO.md` if present, returns it via `additionalContext`.

**Official minimal reference** (`anthropics/claude-code/examples/hooks/bash_command_validator_example.py`):
```python
_VALIDATION_RULES = [
    (r"^grep\b(?!.*\|)", "Use 'rg' (ripgrep) instead of 'grep'"),
    (r"^find\s+\S+\s+-name\b", "Use 'rg --files -g pattern' instead of 'find -name'"),
]
```
Cleanest example of exit-code semantics straight from Anthropic: 0 allow, 1 user-only stderr, 2 block-and-explain-to-Claude.

**A real documented gotcha** (`luongnv89/claude-howto`, `notify-team.sh`'s own comment): there's no native "after git push" event, so people fake it by string-matching `git push` inside a `PostToolUse` Bash-matcher hook.

## 8. Patterns across repos

- Bash-based hooks converge on `jq` for parsing stdin JSON; `$CLAUDE_PROJECT_DIR` is the one reliably-documented path variable everyone actually uses correctly.
- Append-only JSONL logging under `~/.claude/hooks-logs/` or a project `logs/` dir is an emergent convention (seen independently in two unrelated repos), not anything Anthropic specifies.
- GitHub stars don't track recency, several well-starred hook repos are stale by 8+ months. Check `pushed_at`, not just star count, before treating a repo as current best practice.

## Sources

- [Claude Code hooks reference](https://code.claude.com/docs/en/hooks.md)
- [Claude Code hooks guide](https://code.claude.com/docs/en/hooks-guide.md)
- [disler/claude-code-hooks-mastery](https://github.com/disler/claude-code-hooks-mastery)
- [ChrisWiles/claude-code-showcase](https://github.com/ChrisWiles/claude-code-showcase)
- [karanb192/claude-code-hooks](https://github.com/karanb192/claude-code-hooks)
- [luongnv89/claude-howto](https://github.com/luongnv89/claude-howto)
- [hesreallyhim/awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) (Hooks category, `THE_RESOURCES_TABLE.csv`)
- [anthropics/claude-code/examples/hooks](https://github.com/anthropics/claude-code/tree/main/examples/hooks)
