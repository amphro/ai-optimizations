# Claude Code Toolkit

> ***🤖 Claude generated, human verified***

**AI Attribution Scale** — used throughout this repo:

| Badge | Meaning |
|---|---|
| 🤖 Claude generated, unverified | Published as Claude produced it. No human has read or checked it. |
| 🤖 Claude generated, human reviewed | A human read it and may have made minor corrections. Claims not deeply verified. |
| 🤖 Claude generated, human verified | A human verified the claims, iterated on the output, and stands behind it. |

A personal config kit for Claude Code: researched settings, reusable agents and skills, and meta-skills to keep it from going stale.

Figuring out the best Claude Code setup takes real research, and that research has a shelf life. This repo is where it lives, along with the config it produced, so nothing has to be re-derived from scratch.

## What's in here

- **`research/`** Snapshots on the AI model landscape, prompting patterns, Claude Code setup, hooks, skill authoring, and usage limits. Each file is dated. Check the "Last updated" line before relying on specifics.
- **`tools/claude-code/`** The deployable starting point: `settings.json`, `CLAUDE.md`, a statusline script, three hooks, seven reviewer subagents, and five skills. Nothing in here is project-specific. Once deployed, it's available across all your projects.
- **`.claude/skills/`** Three skills for maintaining this repo itself (see below).

## Templates: what's included

**Skills**

| Skill | What it does |
|---|---|
| `smart-review` | Routes code to the right reviewer subagents based on what changed |
| `claudemd-conventions` | Rules for keeping CLAUDE.md files lean |
| `audit-claudemd` | Flags bloat and skill-extraction candidates in an existing CLAUDE.md |
| `mine-session-skills` | Proposes new skills after a task wraps up |
| `writing-voice` | Applies a named voice (Simple, Technical, Explanatory, Formal, Concise) to prose and docs |

**Hooks**

| Hook | What it does |
|---|---|
| `protect-secrets.sh` | Blocks reads and writes of `.env`, SSH keys, AWS credentials, and `.pem` files, including via Bash |
| `session-start-context.sh` | Injects current git branch and status at session start |
| `no-dashes.sh` | **Opt-in, not registered by default.** Blocks writes that introduce an em or en dash, and uses that as the trigger to make Claude re-apply the whole `writing-voice` base style |

The first two are registered in `user-settings.json` because nearly everyone wants them. `no-dashes.sh` is not, because it blocks writes over a style opinion rather than a safety issue. It also only ever blocks *newly introduced* dashes, so editing a legacy file full of them is fine.

To turn it on, add this to the `PreToolUse` array in your `~/.claude/settings.json`:

```json
{
  "matcher": "Edit|Write|MultiEdit|Bash",
  "hooks": [
    { "type": "command", "command": "~/.claude/hooks/no-dashes.sh" }
  ]
}
```

To turn it off again without unregistering it, set `"CLAUDE_ALLOW_DASHES": "1"` in the `env` block of the same file. Note that an `export` inside a session does not reach it, since hooks are spawned from Claude Code's own environment.

The banned characters are hardcoded, but the pattern generalizes. Any rule you can detect mechanically can work the same way: block on the detectable violation, then use the block message to ask for a full style pass rather than a one-character fix. `research/prose-linting.md` covers the reasoning and the tradeoffs.

**Subagents:** staff engineer, security, product, design, test quality, Cloudflare specialist, generic domain expert.

## Maintenance skills

These run inside this repo only, not as part of your global setup.

- **`update-research`** Re-checks research against current sources. Run this periodically; snapshots drift.
- **`update-templates`** Brings `tools/claude-code/` in line with the research. Run after `update-research`, or any time you learn something worth baking into the starting point.
- **`deploy-config`** Copies `tools/claude-code/` to `~/.claude/`. Safe to run more than once: missing files get created, identical files are skipped, and anything that already exists and differs gets flagged for your decision.

## Getting started

1. Clone the repo and open it in Claude Code.
2. Look through `tools/claude-code/` and cut what does not fit your workflow.
3. Ask Claude to run the `deploy-config` skill to install everything to `~/.claude/`.
4. Later, run `update-research` then `update-templates` to stay current.

## See also

- [awesome-claude-code](https://github.com/hesreallyhim/awesome-claude-code) Curated directory of Claude Code hooks, MCP servers, slash commands, and agent collections.
- [my-claude-code-setup](https://github.com/centminmod/my-claude-code-setup) A multi-file CLAUDE.md "memory bank" pattern worth a look if a single CLAUDE.md is not enough for your project.

Note: there is a CLI tool called `claude-code-templates` by davila7. Different project; the name overlaps with this repo's `tools/claude-code/` folder.
