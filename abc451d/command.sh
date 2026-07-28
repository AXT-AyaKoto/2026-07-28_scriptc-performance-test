#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

# Bun などが console.log を色付けしないようにする
export NO_COLOR=1
export FORCE_COLOR=0

INPUT="abc451d/io/input1.txt"
EXPECTED="${INPUT/input/output}"
BIN="./dist/abc451d"

if [[ ! -x "$BIN" ]]; then
  echo "missing binary: $BIN" >&2
  echo "build first: pnpm exec scriptc build abc451d/scriptc.ts -o dist/abc451d" >&2
  exit 1
fi

if [[ ! -f "$EXPECTED" ]]; then
  echo "missing expected output: $EXPECTED" >&2
  exit 1
fi

# 末尾の空白・改行を落とし、ANSI エスケープも除去して比較する
trim() {
  local s="$1"
  # shellcheck disable=SC2001
  s="$(printf '%s' "$s" | sed $'s/\x1b\\[[0-9;]*[a-zA-Z]//g')"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

check_output() {
  local name="$1"
  local cmd="$2"
  local actual expected
  actual="$(trim "$(eval "$cmd")")"
  expected="$(trim "$(cat "$EXPECTED")")"
  if [[ "$actual" == "$expected" ]]; then
    echo "OK  $name"
  else
    echo "NG  $name" >&2
    echo "expected: $(printf '%q' "$expected")" >&2
    echo "actual:   $(printf '%q' "$actual")" >&2
    exit 1
  fi
}

echo "checking outputs against $EXPECTED ..."
check_output "scriptc" "$BIN < $INPUT"
check_output "deno"    "deno run --quiet --allow-all abc451d/deno.ts < $INPUT"
check_output "bun"     "bun run abc451d/bun.ts < $INPUT"
echo

hyperfine \
  --runs 1 \
  --export-markdown abc451d/abc451d-bench.md \
  "$BIN < $INPUT" \
  "deno run --quiet --allow-all abc451d/deno.ts < $INPUT" \
  "bun run abc451d/bun.ts < $INPUT"
