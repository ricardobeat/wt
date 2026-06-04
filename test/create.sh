#!/usr/bin/env bash
# Tests for create: the destination is resolved from the branch via
# `git worktree list`, independent of the path-classification table. This is
# why an unknown-location (untagged) worktree is still fully cd-able.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
load_wt
build_world

# `wt` is always invoked from inside the target repo, so create's `git worktree
# add` (which has no -C) operates on cwd's repo. Mirror that here.
cd "$MAIN"

# Neutralise the side effects of create so we can observe where it lands.
setup()       { :; }
run_prepare() { :; }
enter_shell() { printf 'LANDED:%s\n' "$PWD"; }

# Existing worktree in our own location.
assert_contains "$(create feature 2>/dev/null)" \
  "LANDED:$MAIN/.worktrees/feature" "jumps to existing own worktree"

# Existing worktree in a tool location.
assert_contains "$(create codex/work 2>/dev/null)" \
  "LANDED:$HOME/.codex/worktrees/ab12/repo" "jumps to existing codex worktree"

# Existing worktree in an unrecognised location — the key case: untagged but
# still resolvable and cd-able by branch.
assert_contains "$(create orphan 2>/dev/null)" \
  "LANDED:$ROOT/external/orphan" "jumps to existing unknown-location worktree"

# A brand-new name creates a worktree under our own .worktrees root.
out=$(create brandnew 2>/dev/null)
assert_contains "$out" "LANDED:$MAIN/.worktrees/brandnew" "new name lands in .worktrees"
assert_eq "0" "$([[ -d "$MAIN/.worktrees/brandnew" ]]; echo $?)" "new worktree directory created"
assert_contains "$(git -C "$MAIN" branch --list brandnew)" "brandnew" "new branch created"

summary
