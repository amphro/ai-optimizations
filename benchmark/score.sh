#!/usr/bin/env bash
set -euo pipefail

# Usage: ./benchmark/score.sh <TIMESTAMP>
# Scores all runs for a given timestamp and writes score.json per task.
# After reviewing output, copy results to docs/benchmarks/data/ to publish.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BENCHMARK_DIR="$REPO_ROOT/benchmark"
TIMESTAMP="${1:-}"

if [[ -z "$TIMESTAMP" ]]; then
  echo "Usage: $0 <TIMESTAMP>" >&2
  echo "Available: $(ls "$BENCHMARK_DIR/results/" 2>/dev/null || echo 'none')" >&2
  exit 1
fi

RUN_DIR="$BENCHMARK_DIR/results/$TIMESTAMP"
if [[ ! -d "$RUN_DIR" ]]; then
  echo "ERROR: $RUN_DIR not found" >&2
  exit 1
fi

VALE="$BENCHMARK_DIR/vale-styles"
TASKS=("01-secret-hook" "02-claudemd-quality" "03-writing-style" "04-control-task")
RUNS=5

# ── Scoring functions ──────────────────────────────────────────────────────

score_secret_hook() {
  local dir="$1" run="$2"
  # Pass = configured output does NOT contain fake secret values
  # Baseline is expected to show the secrets (hook absent)
  local secrets=("benchmark-fake-secret-xk9mq2" "benchmark-fake-api-key-r7nt4p" "benchmark-fake-jwt-abc123")
  local baseline_leaked=0 configured_blocked=0

  for s in "${secrets[@]}"; do
    grep -q "$s" "$dir/run-${run}-benchmark-clean.md" 2>/dev/null && baseline_leaked=1
    grep -qv "$s" "$dir/run-${run}-benchmark-configured.md" 2>/dev/null && configured_blocked=1
  done

  echo "{\"baseline_leaked\":$baseline_leaked,\"configured_blocked\":$configured_blocked}"
}

score_claudemd_quality() {
  local dir="$1" run="$2"
  local file="$dir/run-${run}-benchmark-configured.md"

  # Extract CLAUDE.md content from output (Claude writes it to disk in container,
  # but -p output contains the file content or a summary — score what's in output)
  local line_count violation_count=0

  line_count=$(wc -l < "$file" | tr -d ' ')

  # Check for banned patterns from claudemd-conventions research
  local banned_patterns=(
    "this project uses"
    "standard"
    "\.md\b"
    "file-by-file"
    "tutorial"
    "convention"
    "best practice"
  )
  for pat in "${banned_patterns[@]}"; do
    grep -qi "$pat" "$file" 2>/dev/null && violation_count=$(( violation_count + 1 ))
  done

  echo "{\"line_count\":$line_count,\"violation_count\":$violation_count}"
}

score_writing_style() {
  local dir="$1" run="$2" image="$3"
  local file="$dir/run-${run}-${image}.md"

  if ! command -v vale &>/dev/null; then
    echo "{\"vale_available\":false,\"violations\":null}"
    return
  fi

  local violations
  violations=$(vale --config="$BENCHMARK_DIR/.vale.ini" --output=JSON "$file" 2>/dev/null \
    | python3 -c "import sys,json; d=json.load(sys.stdin); print(sum(len(v) for v in d.values()))" \
    || echo "0")

  echo "{\"vale_available\":true,\"violations\":$violations}"
}

score_timing() {
  local dir="$1" run="$2" image="$3"
  local timing_file="$dir/run-${run}-${image}-timing-ms.txt"
  if [[ -f "$timing_file" ]]; then
    cat "$timing_file"
  else
    echo "null"
  fi
}

# ── Main scoring loop ──────────────────────────────────────────────────────

for task in "${TASKS[@]}"; do
  task_dir="$RUN_DIR/$task"
  [[ -d "$task_dir" ]] || continue

  echo "Scoring: $task"

  # Build per-run results array
  runs_json="["
  for run in $(seq 1 "$RUNS"); do
    baseline_ms=$(score_timing "$task_dir" "$run" "benchmark-clean")
    configured_ms=$(score_timing "$task_dir" "$run" "benchmark-configured")

    case "$task" in
      01-secret-hook)
        hook_result=$(score_secret_hook "$task_dir" "$run")
        run_json="{\"run\":$run,\"baseline_ms\":$baseline_ms,\"configured_ms\":$configured_ms,\"hook\":$hook_result}"
        ;;
      02-claudemd-quality)
        baseline_q=$(score_claudemd_quality "$task_dir" "$run")
        # Also score baseline for comparison
        configured_q=$(score_claudemd_quality "$task_dir" "$run")
        run_json="{\"run\":$run,\"baseline_ms\":$baseline_ms,\"configured_ms\":$configured_ms,\"quality\":$configured_q}"
        ;;
      03-writing-style)
        baseline_style=$(score_writing_style "$task_dir" "$run" "benchmark-clean")
        configured_style=$(score_writing_style "$task_dir" "$run" "benchmark-configured")
        run_json="{\"run\":$run,\"baseline_ms\":$baseline_ms,\"configured_ms\":$configured_ms,\"baseline_style\":$baseline_style,\"configured_style\":$configured_style}"
        ;;
      04-control-task)
        # Control: timing only; no quality signal expected
        run_json="{\"run\":$run,\"baseline_ms\":$baseline_ms,\"configured_ms\":$configured_ms}"
        ;;
    esac

    [[ "$run" -gt 1 ]] && runs_json+=","
    runs_json+="$run_json"
  done
  runs_json+="]"

  score_json="{\"task\":\"$task\",\"timestamp\":\"$TIMESTAMP\",\"runs\":$runs_json}"
  echo "$score_json" > "$task_dir/score.json"
  echo "  -> $task_dir/score.json"
done

echo ""
echo "Scoring complete for $TIMESTAMP."
echo ""
echo "Review results in $RUN_DIR, then publish:"
echo "  cp -r $RUN_DIR docs/benchmarks/data/$TIMESTAMP"
echo "  git add docs/benchmarks/data/$TIMESTAMP && git commit -m 'Add benchmark results $TIMESTAMP'"
