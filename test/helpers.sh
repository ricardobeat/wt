#!/usr/bin/env bash
# Shared test harness for the `wt` script.
#
# Tests load `wt`'s functions in isolation (without running its argument
# dispatcher) and exercise them against throwaway git repositories whose
# $HOME and $MAIN are pointed at temp dirs, so the three worktree roots
# (.worktrees, .claude/worktrees, ~/.codex/worktrees) can all be populated.

HELPER_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
WT="${WT:-$HELPER_DIR/../wt}"

TESTS_RUN=0
TESTS_FAILED=0
_TMP_ROOTS=()

# Load the function definitions from `wt` without executing the top-level
# variable setup (which probes the real cwd) or the case dispatcher at the
# bottom. We control MAIN / HOME / CONFIG_FILE ourselves in each test.
load_wt() {
  source <(sed \
    -e '/^set -euo pipefail$/d' \
    -e '/^MAIN=/d' \
    -e '/^CONFIG_SLUG=/d' \
    -e '/^CONFIG_FILE=/d' \
    -e '/^case ${1:-} in/,$d' \
    "$WT")
}

# Build a disposable world: a git repo at $MAIN plus worktrees in each of the
# locations `wt` knows about, and one in an unrecognised location.
#   $MAIN/.worktrees/feature                  -> own            (branch: feature)
#   $MAIN/.claude/worktrees/eager-name        -> claude         (branch: claude/work)
#   $HOME/.codex/worktrees/ab12/repo          -> codex          (branch: codex/work)
#   $HOME/.codex/worktrees/cd34/repo          -> codex          (branch: ricardo/loose) [non-codex/ branch]
#   $ROOT/external/orphan                     -> unknown        (branch: orphan)
# Sets globals ROOT, HOME, MAIN, MAIN_NAME for the caller.
build_world() {
  ROOT=$(mktemp -d)
  ROOT=$(cd "$ROOT" && pwd -P)   # resolve /var -> /private/var on macOS
  _TMP_ROOTS+=("$ROOT")

  export HOME="$ROOT/home"
  mkdir -p "$HOME"
  export GIT_CONFIG_GLOBAL="$ROOT/gitconfig"
  export GIT_CONFIG_SYSTEM=/dev/null
  git config --file "$GIT_CONFIG_GLOBAL" user.email "test@test"
  git config --file "$GIT_CONFIG_GLOBAL" user.name  "test"
  git config --file "$GIT_CONFIG_GLOBAL" init.defaultBranch main

  MAIN="$ROOT/repo"
  MAIN_NAME=repo
  mkdir -p "$MAIN"
  git -C "$MAIN" init -q
  printf 'init\n' > "$MAIN/README"
  git -C "$MAIN" add README
  git -C "$MAIN" commit -qm init

  git -C "$MAIN" worktree add -q "$MAIN/.worktrees/feature"            -b feature
  git -C "$MAIN" worktree add -q "$MAIN/.claude/worktrees/eager-name"  -b claude/work
  mkdir -p "$HOME/.codex/worktrees"
  git -C "$MAIN" worktree add -q "$HOME/.codex/worktrees/ab12/repo"    -b codex/work
  git -C "$MAIN" worktree add -q "$HOME/.codex/worktrees/cd34/repo"    -b ricardo/loose
  git -C "$MAIN" worktree add -q "$ROOT/external/orphan"               -b orphan
}

cleanup_worlds() {
  local r
  for r in "${_TMP_ROOTS[@]}"; do
    [[ -n "$r" && -d "$r" ]] && rm -rf "$r"
  done
}
trap cleanup_worlds EXIT

# Strip ANSI colour codes so assertions match plain text.
strip_ansi() { sed $'s/\033\\[[0-9;]*m//g'; }

_pass() { TESTS_RUN=$((TESTS_RUN + 1)); printf '  \033[32mok\033[0m   %s\n' "$1"; }
_fail() {
  TESTS_RUN=$((TESTS_RUN + 1))
  TESTS_FAILED=$((TESTS_FAILED + 1))
  printf '  \033[31mFAIL\033[0m %s\n' "$1"
  [[ -n "${2:-}" ]] && printf '       %s\n' "$2"
}

assert_eq() { # expected actual msg
  if [[ "$1" == "$2" ]]; then _pass "$3"; else _fail "$3" "expected [$1] got [$2]"; fi
}

assert_contains() { # haystack needle msg
  if [[ "$1" == *"$2"* ]]; then _pass "$3"; else _fail "$3" "[$2] not found in: $1"; fi
}

assert_not_contains() { # haystack needle msg
  if [[ "$1" != *"$2"* ]]; then _pass "$3"; else _fail "$3" "[$2] unexpectedly present in: $1"; fi
}

summary() {
  printf '\n%d run, %d failed\n' "$TESTS_RUN" "$TESTS_FAILED"
  [[ $TESTS_FAILED -eq 0 ]]
}
