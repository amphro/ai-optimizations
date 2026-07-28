# Claude Code Agent Teams (July 2026)

> ***🤖 Claude generated, human reviewed***

**Last updated:** 2026-07-21
**Key question:** What is agent teams, do people like it, and is it different from how I use subagents?
**Short answer:** Yes it is a different tool, still experimental, useful for a narrow set of tasks, and not a replacement for how you already orchestrate subagents.

---

## What agent teams is

One Claude Code session acts as a team lead. It spawns other full Claude Code sessions called teammates. Each teammate has its own context window and runs on its own. They share a task list and can message each other directly through a mailbox. You can open any teammate and talk to it yourself, without going through the lead.

That is the core difference from subagents. A subagent runs inside your session, does one job, and reports a result back to the caller. It never talks to other subagents. Teammates are peers that coordinate with each other while they work.

The feature shipped as a research preview in Claude Code v2.1.32 and is still experimental. A breaking redesign in v2.1.178 removed the old `TeamCreate` and `TeamDelete` setup tools, so now every session has one implicit team and you spawn teammates directly. Blog posts written before that change may show the older setup flow, though their speed and bug observations still hold.

## How to enable it

Set one environment variable, in `~/.claude/settings.json` or your shell:

```json
{
  "env": {
    "CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS": "1"
  }
}
```

Without it, no team is set up and Claude will not spawn teammates. After it is set, you just describe the task and the teammates you want in plain language, and Claude spawns them. You still confirm before it proceeds.

Display defaults to in-process, where teammates show up in an agent panel below the prompt. Split panes (one pane per teammate) need tmux or iTerm2 with the `it2` CLI. Set `teammateMode` to one of `auto`, `tmux`, `iterm2`, or `in-process`. Split panes do not work in the VS Code terminal, Windows Terminal, or Ghostty.

You control the teammate model. Set a default in `/config` (Default teammate model), set the `CLAUDE_CODE_SUBAGENT_MODEL` env var, or name the model in the spawn prompt ("use Sonnet for each teammate"). You can also set teammates to follow the lead's model. So you can pin teammates to a cheap tier for grunt work.

## Teams vs subagents

| | Subagents | Agent teams |
|---|---|---|
| Context | Own window, result returns to caller | Own window, fully independent |
| Talk to each other | No | Yes, peer to peer |
| Coordination | Main agent runs everything | Shared task list, self-claimed |
| Best for | Focused work where only the result matters | Work that needs discussion between workers |
| Token cost | Lower, results summarized back | Higher, each teammate is a full session |

Anthropic's own rule: use subagents when workers just need to do a job and report back. Use teams when workers need to share findings, challenge each other, and coordinate on their own. For sequential work, same-file edits, or heavily dependent tasks, a single session or subagents win.

## Do people like it

Mixed, leaning cautiously positive for the right narrow use. Anthropic frames it as experimental on purpose, not as a general upgrade over subagents. Most concrete evidence comes from a handful of firsthand blog posts and GitHub issues, not a large public consensus. Reddit and Hacker News threads on it were thin.

What people praise, from firsthand reports:

- **Live coordination beats hand-off for coupled work.** On an OAuth feature, a team produced zero bugs on first pass in about half the time of subagents, because the frontend teammate got exact callback shapes from the backend teammate as it worked instead of guessing and fixing later ([charlesjones.dev](https://charlesjones.dev/blog/claude-code-agent-teams-vs-subagents-parallel-development)).
- **Faster parallel investigation.** An SRE cut incident work from 30 to 45 minutes down to about 10 minutes wall-clock, at roughly 4x the token cost ([magarcia.io](https://magarcia.io/using-claude-code-agent-teams-for-incident-investigation/)).
- **Bias isolation.** Running one agent per hypothesis, or one per review lens (security, performance, tests), stops one early finding from anchoring the rest ([getpushtoprod.substack.com](https://getpushtoprod.substack.com/p/30-tips-for-claude-code-agent-teams)).
- **Clean lead context.** Teammates absorb the noisy raw work and hand back summaries, so the lead stays uncluttered.

## Known problems and maturity

Treat it as experimental in the literal sense, not marketing caution.

- **Mailbox delivery bugs.** The best-corroborated complaint. Three separate GitHub issues describe teammates that spawn but never read their inbox, so they sit idle or run as lone agents with no instructions ([#23415](https://github.com/anthropics/claude-code/issues/23415), [#24108](https://github.com/anthropics/claude-code/issues/24108), [#58762](https://github.com/anthropics/claude-code/issues/58762)).
- **Anthropic's own limitations list is long.** No session resumption (`/resume` and `/rewind` do not restore in-process teammates), task status can lag and block dependent tasks, slow shutdown, no nested teams, one team per session, and file-overwrite risk when two teammates touch the same file. You have to partition file ownership yourself.
- **Silent fallback.** Even with the flag set, Claude sometimes spawns plain subagents instead of a team. The agent panel alone does not confirm a team formed. Ask again and request a team explicitly.
- **Cost is always higher.** Every source agrees teams cost more than a single session or subagents. Estimates run from 3x to 7x tokens, all self-reported, none from a controlled test. Anthropic's docs confirm the direction, not the size.

Verdict: usable today for bounded, well-scoped tasks if you are willing to babysit setup and file ownership. Not something to trust unattended, and not usable where you need session resumption.

## When it is worth reaching for

Good fits, per the docs and the field reports:

- Parallel research or review where teammates share and challenge findings.
- New modules or features where each teammate owns a separate piece.
- Debugging with competing hypotheses, where teammates try to disprove each other.
- Cross-layer changes (frontend, backend, tests) that benefit from live agreement on a shared contract.

Poor fits: sequential work, same-file edits, tightly dependent tasks, or anything trivial. Start with 3 to 5 teammates. More adds coordination overhead faster than it adds speed.

## What this means for my setup

For a solo, cost-conscious default, the answer is subagents plus the advisor pattern, not teams. Teams are strictly more expensive and more coordination-heavy, and still experimental. They do not help the "orchestrator by default" goal, which is about keeping the main context lean and pushing cheap work to cheap models. Enabling teams is a separate, situational choice.

Keep teams in your back pocket for the specific shapes above (parallel review, competing-hypothesis debugging, a genuinely cross-layer feature). Flip the flag on when a task fits, not as a standing default. See [orchestration-patterns.md](orchestration-patterns.md) for the subagent and advisor patterns that should be your everyday default.

**How this differs from what you already do.** Your `council` skill already runs five agents in parallel in isolated context, synthesized by a Chairman. That is parallel multi-agent work, but the agents never message each other. Peer messaging is the exact line agent teams cross. Your fixed-role reviewer subagents (design-reviewer, test-reviewer, and so on) are the report-back kind. Nothing you run today needs teams.

**What is already wired vs what is new.** The advisor half of "orchestrator by default" is already live through `advisorModel` in your settings, so that pattern is not new. If you run the `opusplan` model, you also already get Opus for planning and Sonnet for execution. The only genuinely new habit the CLAUDE.md rule adds is defaulting to cheap subagents for exploration and search so the main context stays lean.

**Where the rule lives.** It belongs in the global CLAUDE.md Workflow defaults, next to the plan-mode rule. It is a standing cross-project behavioral default, not sometimes-needed domain knowledge, so it does not belong in a skill. The when-and-why detail stays here in research. Note that delegating exploration is a context-isolation move first: the subagent absorbs the noisy raw work and hands back a short summary, which saves main-session tokens no matter what model it runs on. A cheaper model is a bonus on top, not the main reason to delegate.

---

## Sources

**Official**
- [Orchestrate teams of Claude Code sessions - Claude Code Docs](https://code.claude.com/docs/en/agent-teams)
- [Building a C compiler with a team of parallel Claudes - Anthropic](https://www.anthropic.com/engineering/building-c-compiler)

**Firsthand write-ups**
- [Agent Teams vs Subagents, OAuth comparison - charlesjones.dev](https://charlesjones.dev/blog/claude-code-agent-teams-vs-subagents-parallel-development)
- [Agent Teams for incident investigation - magarcia.io](https://magarcia.io/using-claude-code-agent-teams-for-incident-investigation/)
- [Trying out Claude Code teams - medium.com/@itsHabib](https://medium.com/@itsHabib/trying-out-claude-code-teams-e4c2a0eaf72f)
- [30 tips for Claude Code agent teams - getpushtoprod.substack.com](https://getpushtoprod.substack.com/p/30-tips-for-claude-code-agent-teams)

**GitHub issues (anthropics/claude-code)**
- [#23415](https://github.com/anthropics/claude-code/issues/23415), [#24108](https://github.com/anthropics/claude-code/issues/24108), [#58762](https://github.com/anthropics/claude-code/issues/58762) - mailbox delivery failures
- [#34750](https://github.com/anthropics/claude-code/issues/34750) - silent fallback to subagents
- [#56449](https://github.com/anthropics/claude-code/issues/56449) - unavailable on Claude Code web

**Cost and tips (secondary)**
- [builder.io - Claude Agent Teams explained](https://www.builder.io/blog/claude-agent-teams-explained-what-it-is-and-how-to-actually-use-it)
- [cloudzero.com - Claude Code agents cost analysis](https://www.cloudzero.com/blog/claude-code-agents/)
- [mindstudio.ai - Agent Teams vs Sub-Agents](https://www.mindstudio.ai/blog/claude-code-agent-teams-vs-sub-agents)

**Gap:** No substantive Reddit threads surfaced despite repeated search passes. If Reddit sentiment matters, it needs a manual logged-in pass.
