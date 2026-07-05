#!/usr/bin/env bash
set -u
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
status=0
for test_file in "$repo_root"/tests/*_test.bash; do
  printf '\n== %s ==\n' "$(basename -- "$test_file")"
  bash "$test_file" || status=1
done
exit "$status"

