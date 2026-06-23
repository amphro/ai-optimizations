---
name: run-benchmark
description: Runs the benchmark suite, scores the results, and optionally publishes them to docs/benchmarks/data/. Use when you want to update benchmark results, check for regressions, or publish new data to the GitHub Pages display. Trigger phrases: "run the benchmark", "update benchmark results", "check for regressions", "publish benchmark data".
---

# Run Benchmark

Executes the full benchmark cycle for this repo: build Docker images, run tasks, score outputs, review, and optionally publish.

## Step 1: Check prerequisites

Note: each benchmark run makes 40 real API calls (5 runs x 4 tasks x 2 environments). Don't run casually — only when you actually need new data or a regression check.

Verify:
- Docker is running (`docker info`)
- A one-time token file exists at `benchmark/.benchmark-token.key`

**Why a file instead of `export ANTHROPIC_API_KEY=...`?**
Exporting the key in this session switches Claude Code's billing from the user's
subscription to pay-per-token API billing for every call this session makes. The token
file keeps the key out of the session shell entirely — `run.sh` reads it in its own
subprocess and passes it only to the Docker containers. Claude itself cannot read the
file (the protect-secrets hook blocks `.key` files). The file is also deleted
automatically when `run.sh` exits, so a second run is blocked until the user creates it
again.

If the token file is missing, tell the user to run this **in a regular terminal** (not via `!` in the chat — `read` needs a real TTY, and typing the key in chat would expose it to Claude):

```bash
read -rs BENCHMARK_KEY && echo "$BENCHMARK_KEY" > benchmark/.benchmark-token.key
```

This prompts for the key silently (no echo, nothing in shell history), writes it to the file, and keeps the value out of Claude's conversation context entirely.

Do not proceed until the file exists. Do not suggest `export`, `! echo`, or storing the key in `~/.zshrc`.

## Step 2: Build Docker images

```sh
docker compose -f benchmark/docker/docker-compose.yml build
```

Both `benchmark-clean` and `benchmark-configured` must build without errors before continuing. If the images already exist and no Dockerfiles have changed, this is a fast cache hit.

## Step 3: Run

```sh
./benchmark/run.sh
```

This runs 5 trials of each task in both containers. Note the timestamp printed at the end — you'll need it for the next steps. Outputs go to `benchmark/results/<timestamp>/`.

## Step 4: Score

```sh
./benchmark/score.sh <timestamp>
```

Writes `score.json` to each task directory. Requires Vale to be installed (`brew install vale`) for task 03; score.sh falls back gracefully if it isn't, but the writing-style task won't have a real score.

## Step 5: Review outputs

Open `benchmark/results/<timestamp>/` and read through the outputs for each task, both environments. Check for:
- Any secrets or API keys that leaked into outputs (the scrubber catches `sk-ant-*` patterns but check the others)
- Unexpected content in the configured outputs

Do not publish until you've reviewed. Outputs are gitignored by default.

## Step 6: Publish (optional)

If the results look clean:

```sh
cp -r benchmark/results/<timestamp> docs/benchmarks/data/<timestamp>
```

Then update `docs/benchmarks/data/index.json` — add the timestamp string to the `"runs"` array. Commit both:

```sh
git add docs/benchmarks/data/<timestamp> docs/benchmarks/data/index.json
git commit -m "Add benchmark results <timestamp>"
git push
```

The GitHub Pages benchmarks page reads `index.json` and renders the new run automatically.

## Step 7: Regression check

If there are two or more published result sets, compare median scores across timestamps. A drop in the configured-vs-baseline delta on tasks 01-03 is a regression. Task 04 (control) delta should stay near zero across all runs — a large shift there suggests rubric bias, not toolkit change.

## Step 8: Report

Summarize: which tasks passed/failed, what scores changed vs. the previous run (if any), whether anything was published, and any anomalies worth noting (leaked content, large variance across runs, Vale not installed).
