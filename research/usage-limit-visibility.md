# Checking Claude Code's Usage Limits Programmatically

> ***🤖 Claude generated, human reviewed***

**Last updated:** 2026-06-19
**Source:** Official Claude Code docs (statusline, hooks), anthropics/claude-code GitHub issues, community tooling (ccusage and others)
**Reliability:** Mixed — the statusline field is official and verified directly against the docs; hook/CLI/API access beyond that is either unofficial or doesn't exist yet

---

## TL;DR

Claude Code can show a human-visible usage percentage in the terminal status line against the account's rolling 5-hour and weekly limits (official, shipped in v2.1.80). It cannot feed that data into its own context to self-pace, into hooks, or into headless/scripted runs (`-p`, `--output-format json`). The biggest open community feature request for true scriptable access ([anthropics/claude-code#13585](https://github.com/anthropics/claude-code/issues/13585)) has 92 reactions and is still open.

This is about the **subscription plan quota** (Pro/Max 5-hour and 7-day windows, shown on claude.ai/settings/usage), not the separate, already-documented API-tier rate limit headers (`x-ratelimit-*`) for pay-as-you-go API keys.

## What's officially available

The statusline JSON input includes a `rate_limits` field, present for Claude.ai subscribers (Pro/Max) after the first API response in a session:

```json
"rate_limits": {
  "five_hour": { "used_percentage": 23.5, "resets_at": 1738425600 },
  "seven_day": { "used_percentage": 41.2, "resets_at": 1738857600 }
}
```

This is account-wide, server-sourced data, not a local estimate — it reflects the same numbers shown on the claude.ai usage settings page. A statusline script can read `rate_limits.five_hour.used_percentage` and `rate_limits.seven_day.used_percentage` directly. Either window can be independently absent, so scripts need a fallback (`jq -r '.rate_limits.five_hour.used_percentage // empty'`).

`/usage` (interactive slash command) also shows plan usage bars, but its per-skill/subagent attribution breakdown is explicitly local-only — the docs note usage from other devices or claude.ai isn't included in that breakdown. There's no `--json` flag on it.

## What's not available

- No CLI command with machine-readable output for quota (e.g. `claude quota --json`)
- No environment variable Claude Code sets with remaining quota
- No documented public API endpoint a script can call directly for this
- **Hooks do not receive `rate_limits`** — confirmed directly against the hook input JSON schema. Only the statusline script gets it.
- Headless mode (`-p`, `--output-format json`) doesn't expose it either, per the open feature-request thread.

Net effect: the agent itself (me, running inside Claude Code) cannot natively check "how close are we to the limit" mid-task. The data exists and is visible to the human via the status bar, but doesn't reach my own context by default.

## The technical path that exists, and its real cost

Hooks support `hookSpecificOutput.additionalContext` (on SessionStart, PreToolUse, PostToolUse, Stop, SubagentStart/Stop, and others) — this injects text directly into the model's context as a system reminder. In principle, a hook could fetch quota data and hand it to the model this way.

The catch: since hooks don't get `rate_limits` on their own, the hook would have to call whatever backend powers the statusline field — and that's not a documented public API. The community has reverse-engineered an undocumented endpoint (`GET https://api.anthropic.com/api/oauth/usage`, bearer auth pulled from the local OAuth credential store) that returns the same `five_hour` / `seven_day` data plus a few extra fields. It's unofficial: the schema has drifted before, and multiple users report aggressive 429s when polling it.

So this is buildable, but it means a script that reads local credentials and calls an undisclosed endpoint Anthropic could change or rate-limit without notice. That's a real tradeoff, not a free win.

## Community tooling

- **ccusage** (npm) — parses Claude Code's local JSONL session logs and estimates usage against publicly known plan limits. Purely local: can't see usage from other devices or sessions, and isn't querying the real account quota at all, it's an estimate.
- Various statusline plugins (ccstatusline, claude-pace, claude-rate-monitor, and others) — pre-v2.1.80 versions scraped the undocumented endpoint directly; several have since switched to reading the official `rate_limits` statusline field instead.
- A separate macOS menu-bar app polls yet another undocumented endpoint (`/api/organizations/{org_id}/usage`) via a session cookie, a second, independent unofficial path. There's no single stable community standard here.

## Feature requests worth knowing about

- **[anthropics/claude-code#13585](https://github.com/anthropics/claude-code/issues/13585)** ("Add Quota Information Access to Claude Code CLI") — open, 92 reactions, 17 comments, filed 2025-12-10. Asks for a real `claude quota` / `claude quota --json` command. The thread documents the whole history here (endpoint reverse-engineering, the eventual statusline fix) and explicitly flags that headless/scripted mode still lacks access even after that fix shipped.
- Roughly a dozen related issues (including #27915 and #18121) were closed as resolved once the statusline field shipped in v2.1.80, but that only solved the human-visible case, not the scriptable one #13585 is actually asking for.
- Newer open issues (#59709, #60674, #63659) suggest the underlying demand, and some reliability complaints, persist even after the statusline fix.

## Bottom line

- For a human-visible warning in the terminal: trivial, fully supported, no real risk. Add `rate_limits.five_hour.used_percentage` / `rate_limits.seven_day.used_percentage` to a statusline script.
- For the agent itself to see and act on this mid-task: not natively supported. Possible via a hook calling an undocumented endpoint, but that means depending on something Anthropic could change or throttle at any time.
- The right feature request already exists and is well-supported. A comment describing the hooks-specific gap is more useful than filing a near-duplicate new issue.

---

## Sources
- [Claude Code statusline docs](https://code.claude.com/docs/en/statusline.md)
- [Claude Code hooks docs](https://code.claude.com/docs/en/hooks.md)
- [anthropics/claude-code#13585](https://github.com/anthropics/claude-code/issues/13585)
- ccusage README (github.com/ryoppippi/ccusage)
