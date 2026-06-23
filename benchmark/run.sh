#!/usr/bin/env bash
set -euo pipefail

# Usage: ./benchmark/run.sh
# Requires: ANTHROPIC_API_KEY set, Docker running, images built
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
  echo "Create it first:  ! echo 'sk-ant-...' > benchmark/.benchmark-token.key" >&2
  exit 1
fi
if [[ -z "${ANTHROPIC_API_KEY:-}" ]]; then
  echo "ERROR: token file was empty" >&2; exit 1
fi

TIMESTAMP=$(date +%Y-%m-%dT%H%M%S)
RUN_DIR="$RESULTS_BASE/$TIMESTAMP"
mkdir -p "$RUN_DIR"

echo "Run: $TIMESTAMP"
echo "Results: $RUN_DIR"
echo ""

TASKS=(
  "01-secret-hook"
  "02-claudemd-quality"
  "03-writing-style"
  "04-control-task"
)

# Per-task setup: some tasks need fixtures mounted into the working directory
fixture_args() {
  local task="$1"
  if [[ "$task" == "01-secret-hook" ]]; then
    # Mount fixture as .env in container working directory
    echo "-v $TASKS_DIR/fixtures/fake.env:/app/.env:ro"
  else
    echo ""
  fi
}

run_task() {
  local task="$1"
  local image="$2"
  local run_num="$3"
  local out_dir="$4"

  local prompt
  prompt="$(cat "$TASKS_DIR/${task}.md")"

  local fixture
  fixture="$(fixture_args "$task")"

  local output_file="$out_dir/run-${run_num}-${image}.md"
  local timing_file="$out_dir/run-${run_num}-${image}-timing-ms.txt"
  local stderr_file="$out_dir/run-${run_num}-${image}-stderr.log"

  local start_ms end_ms duration_ms
  start_ms=$(( $(date +%s) * 1000 ))

  # shellcheck disable=SC2086
  docker run --rm \
    -e ANTHROPIC_API_KEY="$ANTHROPIC_API_KEY" \
    -v "$TASKS_DIR:/tasks:ro" \
    $fixture \
    "$image" \
    sh -c "claude -p --dangerously-skip-permissions \"$(printf '%s' "$prompt" | sed "s/\"/\\\\\"/g")\"" \
    > "$output_file" \
    2> "$stderr_file" \
    || echo "[run exited non-zero — see stderr log]" >> "$output_file"

  end_ms=$(( $(date +%s) * 1000 ))
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

  # Save exact input prompt
  cp "$TASKS_DIR/${task}.md" "$task_dir/prompt.md"

  echo "Task: $task"

  for run in $(seq 1 "$RUNS"); do
    run_task "$task" "benchmark-clean"      "$run" "$task_dir"
    run_task "$task" "benchmark-configured" "$run" "$task_dir"
  done

  echo ""
done

echo "Done. Run score.sh to generate scores:"
echo "  ./benchmark/score.sh $TIMESTAMP"
