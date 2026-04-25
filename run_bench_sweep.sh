#!/usr/bin/env bash
set -euo pipefail

# bench usage:
#   ./bench START_UID END_UID REPEATS
#
# This wrapper sweeps:
#   cycles = 10..300 step 10
#   uid ranges = 1-50, 1-100, 1-200, 1-400, 1-800
#
# Usage:
#   ./run_bench_grid.sh [bench_path] [repeats_per_call] [out_csv]
#
# Example:
#   ./run_bench_grid.sh ./bench 100 bench_grid.csv

BENCH_PATH="${1:-./bench}"
REPEATS_PER_CALL="${2:-100}"
OUT_CSV="${3:-bench_grid.csv}"

if [[ ! -x "$BENCH_PATH" ]]; then
  echo "ERROR: bench not found or not executable: $BENCH_PATH" >&2
  exit 1
fi

extract_elapsed_seconds() {
  awk 'match($0, /elapsed=([0-9]+(\.[0-9]+)?) seconds/, m) { print m[1]; found=1 }
       END { if (!found) exit 1 }'
}

echo "ts_iso,cycles_setting,range_start,range_end,exit_code,elapsed_seconds,raw_output" > "$OUT_CSV"

START_UID=1
ENDS=(50 100 200 400)

for cycles_setting in $(seq 10 40 200); do
  for end_uid in "${ENDS[@]}"; do
      ts="$(date -Iseconds)"

      set +e
      out="$("$BENCH_PATH" "$START_UID" "$end_uid" "$cycles_setting" 2>&1)"
      ec=$?
      set -e

      elapsed=""
      if elapsed="$(printf '%s\n' "$out" | extract_elapsed_seconds 2>/dev/null)"; then :; fi

      raw_csv="$(printf '%s' "$out" | tr '\n' ' ' | sed 's/"/""/g')"

      printf '%s,%s,%s,%s,%s,%s,%s,%s,"%s"\n' \
        "$ts" "$cycles_setting" "$START_UID" "$end_uid" "$ec" "$elapsed" "$raw_csv" \
        >> "$OUT_CSV"
    done
  done

echo "Wrote $OUT_CSV"