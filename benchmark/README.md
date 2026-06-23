# Claude Code Configuration Benchmark

This benchmark measures the behavioral difference between bare Claude Code (no configuration) and Claude Code with this toolkit deployed. It runs the real Claude Code CLI so hooks fire, skills load, and CLAUDE.md is active.

## Approach

Most AI benchmarks operate at the API level: they send prompts to a model and judge the responses. That approach cannot test configuration toolkits, because hooks, skills, and CLAUDE.md are CLI-layer behaviors that the API never sees.

This benchmark uses headless Claude Code (`claude -p`) inside Docker containers instead. Two images run the same tasks: one with an empty `~/.claude/`, one with this repo's config deployed. The delta between them is what the toolkit actually does.

For background on the broader evaluation landscape and why we chose this approach over promptfoo or direct API testing, see:

- [`../research/ai-benchmarking.md`](../research/ai-benchmarking.md) — current benchmarks, eval frameworks, LLM-as-judge tradeoffs
- [`../research/prose-linting.md`](../research/prose-linting.md) — why Vale is used for writing quality checks

Results are scored deterministically where possible (binary hook pass/fail, line counts, Vale violations) and with LLM-as-judge only where no deterministic check exists. The scoring methodology is documented in [`PLAN.md`](PLAN.md).

## Tasks

| # | Task | Tests | Scoring method |
|---|---|---|---|
| 01 | Secret hook | Pre-tool hook blocks `.env` read | Binary pass/fail |
| 02 | CLAUDE.md quality | Output follows `claudemd-conventions` rules | Line count + grep for banned patterns |
| 03 | Writing style | Output follows `writing-voice` rules | Vale with custom rule set |
| 04 | Control task | Write a utility function with tests | Timing only — neither environment has an advantage |

The control task (04) calibrates the scorer: if configured scores meaningfully higher on it, the rubric is biased toward the configured output for reasons unrelated to the toolkit.

Published results live at [`../docs/benchmarks/data/`](../docs/benchmarks/data/) and are displayed at the [Benchmarks page](https://amphro.github.io/ai-optimizations/benchmarks/).

---

## How to run

### Prerequisites

- Docker Desktop running
- `ANTHROPIC_API_KEY` set in your environment
- Vale installed: `brew install vale` (or [vale.sh/docs/vale-cli/installation](https://vale.sh/docs/vale-cli/installation/))

### Step 1: Build images

```sh
docker compose -f benchmark/docker/docker-compose.yml build
```

This builds two images from the repo root:
- `benchmark-clean` — Claude Code, empty config
- `benchmark-configured` — Claude Code, this repo's config deployed

### Step 2: Run tasks

```sh
ANTHROPIC_API_KEY=your-key ./benchmark/run.sh
```

Runs 5 trials of each task in both containers. Output goes to `benchmark/results/<timestamp>/`. Each run captures:
- The exact input prompt (`prompt.md`)
- The exact output (`run-N-benchmark-clean.md`, `run-N-benchmark-configured.md`)
- Timing in milliseconds (`run-N-benchmark-clean-timing-ms.txt`, etc.)

### Step 3: Score

```sh
./benchmark/score.sh <timestamp>
```

Writes `score.json` to each task directory. Runs Vale on writing-style outputs if Vale is installed; falls back to a note in the JSON if not.

### Step 4: Review and publish

Results are gitignored until you manually review them. After confirming no secrets leaked into outputs:

```sh
# Copy to docs (powers the GitHub Pages display)
cp -r benchmark/results/<timestamp> docs/benchmarks/data/<timestamp>

# Update the run index
# Edit docs/benchmarks/data/index.json and add the timestamp to the "runs" array

git add docs/benchmarks/data/<timestamp> docs/benchmarks/data/index.json
git commit -m "Add benchmark results <timestamp>"
git push
```

The GitHub Pages benchmarks page reads from `docs/benchmarks/data/` and renders the comparison automatically.

---

## Regression check

Once you have two or more committed result sets, compare median scores across timestamps to spot regressions. A change to the toolkit that reduces the delta on tasks 01-03 is a regression. The control task (04) delta should stay near zero across all runs.

Automated regression gating (GitHub Actions) is tracked in [PLAN.md](PLAN.md) as a follow-on phase.
