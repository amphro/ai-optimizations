#!/usr/bin/env bash
set -euo pipefail

# Usage: ./benchmark/run.sh
# Requires: benchmark/.benchmark-token.key, Docker running, images built
#   docker compose -f benchmark/docker/docker-compose.yml build

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BENCHMARK_DIR="$REPO_ROOT/benchmark"
TASKS_DIR="$BENCHMARK_DIR/tasks"
RESULTS_BASE="$BENCHMARK_DIR/results"
RUNS=5

TOKEN_FILE="$BENCHMARK_DIR/.benchmark-token.key"
trap 'rm -f "$TOKEN_FILE"' EXIT
if [[ -f "$TOKEN_FILE" ]]; then
  ANTHROPIC_API_KEY="$(cat "$TOKEN_FILE")"
elif [[ -t 0 ]]; then
  read -rsp "Paste ANTHROPIC_API_KEY (one-time, not stored): " ANTHROPIC_API_KEY
  echo
else
  echo "ERROR: no $TOKEN_FILE and no TTY." >&2
  echo "Create it first:  read -rs KEY && echo \"\$KEY\" > benchmark/.benchmark-token.key" >&2
  exit 1
fi
if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "ERROR: token file was empty" >&2; exit 1
fi

now_ms() { python3 -c 'import time;print(int(time.time()*1000))'; }

TIMESTAMP=$(date +%Y-%m-%dT%H%M%S)
RUN_DIR="$RESULTS_BASE/$TIMESTAMP"
mkdir -p "$RUN_DIR"

RUN_START_MS=$(now_ms)

echo "Run: $TIMESTAMP"
echo "Results: $RUN_DIR"
echo ""

TASKS=(
  "01-secret-hook"
  "02-claudemd-quality"
  "03-writing-style"
  "04-control-task"
)

run_task() {
  local task="$1"
  local image="$2"
  local run_num="$3"
  local out_dir="$4"

  local prompt
  prompt="$(cat "$TASKS_DIR/${task}.md")"

  # Per-run work dir mounted as /app — artifacts written by Claude survive the container
  local work_host="$out_dir/work-${run_num}-${image}"
  mkdir -p "$work_host"
  chmod 777 "$work_host"

  # Task 01: seed .env fixture into work dir before Claude runs
  if [[ "$task" == "01-secret-hook" ]]; then
    cp "$TASKS_DIR/fixtures/fake.env" "$work_host/.env"
  fi

  local output_file="$out_dir/run-${run_num}-${image}.md"
  local timing_file="$out_dir/run-${run_num}-${image}-timing-ms.txt"
  local stderr_file="$out_dir/run-${run_num}-${image}-stderr.log"

  local start_ms end_ms duration_ms
  start_ms=$(now_ms)

  # Prompt passed directly as argv — no shell re-interpretation, backticks are safe
  docker run --rm \
    -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
    -v "$work_host:/app" \
    "$image" \
    claude -p --dangerously-skip-permissions "$prompt" \
    > "$output_file" \
    2> "$stderr_file" \
    || echo "[run exited non-zero — see stderr log]" >> "$output_file"

  end_ms=$(now_ms)
  duration_ms=$(( end_ms - start_ms ))
  echo "$duration_ms" > "$timing_file"

  # Scrub any real-looking API key patterns from output before writing
  sed -i '' 's/sk-ant-[A-Za-z0-9_-]*/[REDACTED]/g' "$output_file" 2>/dev/null \
    || sed -i 's/sk-ant-[A-Za-z0-9_-]*/[REDACTED]/g' "$output_file"

  echo "    run $run_num [$image]: ${duration_ms}ms"
}

for task in "${TASKS[@]}"; do
  task_dir="$RUN_DIR/$task"
  mkdir -p "$task_dir"
  cp "$TASKS_DIR/${task}.md" "$task_dir/prompt.md"

  echo "Task: $task"

  for run in $(seq 1 "$RUNS"); do
    run_task "$task" "benchmark-clean"      "$run" "$task_dir"
    run_task "$task" "benchmark-configured" "$run" "$task_dir"
  done

  echo ""
done

RUN_END_MS=$(now_ms)
echo "$RUN_START_MS $RUN_END_MS" > "$RUN_DIR/run-meta.txt"

echo "Done. Next steps:"
echo "  ./benchmark/score.sh $TIMESTAMP"
