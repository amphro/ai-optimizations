# Claude Code Configuration Benchmark

> ***🤖 Claude generated, human reviewed***

Headless evaluation comparing bare Claude Code vs Claude Code with this toolkit deployed. Two Docker images, 4 tasks, 5 runs each, scored automatically.

> **Work in progress.** Task 03 requires Sonnet to show meaningful signal (Haiku doesn't follow writing-voice instructions reliably). The LLM judge for Task 02 is new and not yet validated on a full run. See status table below.

## Approach

Most AI benchmarks operate at the API level: they send prompts to a model and judge the responses. That approach cannot test configuration toolkits, because hooks, skills, and CLAUDE.md are CLI-layer behaviors the API never sees.

This benchmark uses headless Claude Code (`claude -p`) inside Docker containers instead. Two images run the same tasks: one with an empty `~/.claude/`, one with this repo's config deployed. The delta between them is what the toolkit actually does.

## Task status

| # | Task | Signal quality | Notes |
|---|------|---------------|-------|
| 01 | Secret hook | ✅ Strong | 5/5 baseline leaks, 5/5 configured blocks. Reliable binary signal. |
| 02 | CLAUDE.md quality | ✅ Good | Baseline writes 100–270 line files; configured writes 20–40. LLM judge added to measure completeness (not just line count) — not yet validated. |
| 03 | Writing style | ⚠️ Model-dependent | Weighted scorer (em-dashes, clichés, filler words, transition spam) in place. Haiku shows no signal — use `BENCHMARK_MODEL=claude-sonnet-4-6`. |
| 04 | Code correctness | ✅ Honest null | Both environments pass. Configured self-verifies by running tests (detected via `node_modules/` presence); baseline doesn't. Timing delta reflects real verification overhead. |

## How to run

**Create the token file in a regular terminal** (not in Claude Code chat — `read` needs a real TTY):

```bash
read -rs BENCHMARK_KEY && echo "$BENCHMARK_KEY" > benchmark/.benchmark-token.key
```

Then:

```bash
# Build images (only needed after Dockerfile changes)
docker compose -f benchmark/docker/docker-compose.yml build

# Run — default: Haiku, 5 runs (~$0.50)
./benchmark/run.sh

# Task 03 requires Sonnet for meaningful writing signal (~$2.50)
BENCHMARK_MODEL=claude-sonnet-4-6 ./benchmark/run.sh

# Score (uses subscription auth, no API cost)
./benchmark/score.sh <timestamp>

# Publish
./benchmark/publish.sh <timestamp>
git add docs/benchmarks/data/<timestamp> docs/benchmarks/data/index.json
git commit -m "Add benchmark results <timestamp>"
```

Record `cost_usd` manually from console.anthropic.com into `docs/benchmarks/data/<timestamp>/summary.json` before publishing.

## What's next

- [ ] Per-task model override — run task 03 with Sonnet, others with Haiku (cost-efficient full run)
- [ ] Validate LLM judge scores for Task 02 against a Sonnet run
- [ ] Task 03: evaluate whether a harder prompt produces Haiku signal at all
- [ ] More tasks: protect-secrets hook coverage, skill loading verification
