# Plan: Claude Code Benchmark System

## What this builds

A repeatable benchmark that runs the same coding tasks against two environments: bare Claude Code with no configuration, and Claude Code with this repo's full config deployed. Outputs are captured, scored, and committed. A GitHub Pages page displays the comparison.

The benchmark runs the real Claude Code CLI (`claude -p`), so hooks fire and skills load. This is the only approach that measures what the toolkit actually does.

---

## Constraint: headless mode

`claude -p` runs non-interactively. Tasks must be designed around **output artifacts** the CLI produces, not around interaction patterns like "does it ask first?" Interactive behaviors (plan confirmation, commit approval) cannot be tested this way. Every task must be checkable by reading the output file alone.

---

## Tasks (MVP set)

| # | Name | What it tests | How it's scored |
|---|---|---|---|
| 01 | Secret hook | Pre-tool hook blocks `.env` read | Pass/fail: did the read succeed? |
| 02 | CLAUDE.md quality | Writing a CLAUDE.md for a new project | Rubric: line count, no standard conventions, passes the "would removing this cause a mistake?" test |
| 03 | Writing style | Writing a README for a small library | Rubric: no em dashes, no filler words, sentence length variation, no forced summaries |
| 04 | Control task | Write a utility function with tests | Rubric: functional correctness only. Neither baseline nor configured has an advantage. This task validates the scoring system isn't always favorable to configured. |

Task 01 is deterministic (hook either fires or doesn't). Tasks 02-04 use LLM-as-judge with rubric-anchored scoring. The control task (04) should produce similar scores in both environments — if configured scores dramatically higher on it, the judge rubric is biased.

Each task file (`benchmarks/tasks/NN-name.md`) contains:
- The exact prompt
- The scoring rubric (checklist, weighted)
- Notes on what constitutes a pass at each rubric item

---

## File structure

```
benchmarks/
  tasks/
    01-secret-hook.md
    02-claudemd-quality.md
    03-writing-style.md
    04-control-task.md
  docker/
    clean.Dockerfile
    configured.Dockerfile
    docker-compose.yml
  run.sh
  score.sh
  results/
    2026-06-22T143012/
      01-secret-hook/
        run-1.md
        run-2.md
        run-3.md
        score.json
      ...
  .gitignore         # results/ gitignored until manually reviewed
  README.md

docs/benchmarks/
  index.html
  data/
    2026-06-22T143012.json   # manually committed after review
```

Results are gitignored by default and manually committed after a human review pass, so no accidental secret exposure can happen.

---

## Docker

Two images, both pinning the same Claude Code CLI version by npm package digest.

**`clean.Dockerfile`**
- Node.js + Claude Code at pinned version
- Empty `~/.claude/`
- No `ANTHROPIC_API_KEY` in the image

**`configured.Dockerfile`**
- Same base
- Installs `jq` (required by `protect-secrets.sh`, fails open without it)
- Explicitly maps toolkit files to their deployed names:
  - `tools/claude-code/user-settings.json` → `~/.claude/settings.json`
  - `tools/claude-code/user-CLAUDE.md` → `~/.claude/CLAUDE.md`
  - `tools/claude-code/hooks/` → `~/.claude/hooks/`
  - `tools/claude-code/agents/` → `~/.claude/agents/`
  - `tools/claude-code/skills/` → `~/.claude/skills/`
- Excludes `tools/claude-code/scratch/` and the repo's own `.claude/`
- Makes hook scripts executable with `chmod +x`

`ANTHROPIC_API_KEY` is injected at runtime only, never baked into any image.

`docker-compose.yml` mounts `benchmarks/tasks/` read-only and `benchmarks/results/` read-write.

---

## Runner (`run.sh`)

```
run.sh exits immediately if ANTHROPIC_API_KEY is unset.

For each task:
  For each run (1..3):
    Run claude -p inside clean container, capture stdout
    Scrub sk-ant-* patterns from output before writing to disk
    Save to results/TIMESTAMP/TASK/run-N-baseline.md

    Run same command inside configured container
    Scrub sk-ant-* patterns
    Save to results/TIMESTAMP/TASK/run-N-configured.md

    Log stderr to results/TIMESTAMP/TASK/run-N-stderr.log (not committed)
```

Three runs per task. Scoring uses all three; the judge reports median score and flags if variance across runs is high (a signal that the task is too non-deterministic to be useful).

---

## Scoring (`score.sh`)

Reads each task rubric and all six output files (3 baseline + 3 configured), calls the Anthropic API with an LLM-as-judge prompt per run pair, aggregates to `score.json`:

```json
{
  "task": "02-claudemd-quality",
  "timestamp": "2026-06-22T143012",
  "runs": [
    { "baseline": 3, "configured": 9, "delta": 6 },
    { "baseline": 4, "configured": 8, "delta": 4 },
    { "baseline": 3, "configured": 9, "delta": 6 }
  ],
  "median_baseline": 3,
  "median_configured": 9,
  "median_delta": 6,
  "variance_flag": false
}
```

Task 01 (secret hook) is scored by the runner, not the judge — pass/fail based on whether the file read succeeded.

---

## GitHub Pages display (`docs/benchmarks/index.html`)

Static page, same CSS as the rest of the site. Loads committed JSON files from `docs/benchmarks/data/` via `fetch()`.

Shows per task:
- Task name and prompt
- Baseline output vs. configured output (tabbed, not side-by-side — mobile-friendly)
- Rubric items and how each output scored on them
- Score bar: baseline / configured / delta

Shows overall:
- Average delta across tasks 01-03 (the toolkit-affected tasks)
- Control task (04) score comparison — shown separately as a calibration check
- A disclosure note: "Rubrics were written by the toolkit author and scored by Claude. Results reflect intended behaviors, not independent evaluation."

---

## Security

- `ANTHROPIC_API_KEY` is runtime-only. `run.sh` checks for it and exits if unset.
- All output is scrubbed for `sk-ant-` patterns before writing to disk.
- `results/` is gitignored. Files are only committed after manual review.
- Task 01 uses a dummy `.env` fixture with a fake key. The fixture is included in `benchmarks/tasks/fixtures/` but contains no real credentials.
- The configured image contains hook shell scripts from `tools/claude-code/hooks/`. Those are already reviewed and committed in the repo.
- `jq` is installed in the configured image so `protect-secrets.sh` does not fail open.

---

## Regression detection (not in MVP)

Once there are three or more committed result sets, a regression check becomes meaningful: compare the current median delta against the historical median. Until then, single-run variance dominates. Regression detection is deferred to a follow-on phase.

---

## Out of scope for MVP

- promptfoo / YAML harness
- CI/CD automation (GitHub Actions)
- PR gating on score
- Regression detection
- More than 4 tasks

---

## Build order

1. Write 4 task files with rubrics and the `.env` fixture
2. Write `clean.Dockerfile` and `configured.Dockerfile`
3. Write `docker-compose.yml`
4. Write `run.sh` with output scrubbing
5. Write `score.sh` with judge prompt and aggregation
6. Run once manually, review output, commit to `docs/benchmarks/data/`
7. Write `benchmarks/README.md`
8. Build `docs/benchmarks/index.html`
