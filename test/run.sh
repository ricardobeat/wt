#!/usr/bin/env bash
# Run every test/*.sh file (except this runner and the shared helpers) and
# report an aggregate pass/fail. Exits non-zero if any file fails.
set -uo pipefail

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
failed=0

for f in "$DIR"/*.sh; do
  case $(basename "$f") in
    run.sh|helpers.sh) continue ;;
  esac
  printf '\033[1m%s\033[0m\n' "$(basename "$f")"
  if bash "$f"; then :; else failed=$((failed + 1)); fi
  printf '\n'
done

if [[ $failed -eq 0 ]]; then
  printf '\033[32mall test files passed\033[0m\n'
else
  printf '\033[31m%d test file(s) failed\033[0m\n' "$failed"
fi
exit $failed
