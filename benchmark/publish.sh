#!/usr/bin/env bash
set -euo pipefail

# Usage: ./benchmark/publish.sh <TIMESTAMP>
# Copies scored results to docs/benchmarks/data/ and prepends timestamp to index.json.
# Run score.sh first. Review outputs before publishing.

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BENCHMARK_DIR="$REPO_ROOT/benchmark"
DOCS_DATA="$REPO_ROOT/docs/benchmarks/data"
TIMESTAMP="${1:-}"

if [[ -z "$TIMESTAMP" ]]; then
  echo "Usage: $0 <TIMESTAMP>" >&2
  echo "Available: $(ls "$BENCHMARK_DIR/results/" 2>/dev/null || echo 'none')" >&2
  exit 1
fi

SRC="$BENCHMARK_DIR/results/$TIMESTAMP"
DEST="$DOCS_DATA/$TIMESTAMP"

[[ -d "$SRC" ]]              || { echo "ERROR: $SRC not found" >&2; exit 1; }
[[ -f "$SRC/summary.json" ]] || { echo "ERROR: summary.json missing — run score.sh first" >&2; exit 1; }

echo "Publishing $TIMESTAMP..."
mkdir -p "$DEST"

cp "$SRC/summary.json" "$DEST/"

for task in 01-secret-hook 02-claudemd-quality 03-writing-style 04-control-task; do
  task_src="$SRC/$task"
  [[ -d "$task_src" ]] || continue
  mkdir -p "$DEST/$task"

  [[ -f "$task_src/score.json"  ]] && cp "$task_src/score.json"  "$DEST/$task/"
  [[ -f "$task_src/prompt.md"   ]] && cp "$task_src/prompt.md"   "$DEST/$task/"

  # Claude stdout responses (not stderr logs or timing files)
  for f in "$task_src"/run-*-benchmark-clean.md "$task_src"/run-*-benchmark-configured.md; do
    [[ -f "$f" ]] && cp "$f" "$DEST/$task/"
  done

  # Artifact work dirs — exclude .env seeds (secrets) and hidden files
  for work_dir in "$task_src"/work-*/; do
    [[ -d "$work_dir" ]] || continue
    dest_work="$DEST/$task/$(basename "$work_dir")"
    mkdir -p "$dest_work"
    find "$work_dir" -maxdepth 1 -type f -not -name ".*" -exec cp {} "$dest_work/" \;
  done
done

# Prepend timestamp to index.json
python3 - "$DOCS_DATA/index.json" "$TIMESTAMP" <<'PYEOF'
import json, sys
index_file, ts = sys.argv[1], sys.argv[2]
with open(index_file) as f:
    d = json.load(f)
runs = d.get('runs', [])
if ts not in runs:
    runs.insert(0, ts)
d['runs'] = runs
with open(index_file, 'w') as f:
    json.dump(d, f, indent=2)
print('Updated index.json — runs:', runs)
PYEOF

echo ""
echo "Published to $DEST"
echo ""
echo "Preview locally:"
echo "  python3 -m http.server 8000 --directory docs && open http://localhost:8000/benchmarks/"
echo ""
echo "Commit:"
echo "  git add docs/benchmarks/data/$TIMESTAMP docs/benchmarks/data/index.json"
echo "  git commit -m 'Add benchmark results $TIMESTAMP'"
