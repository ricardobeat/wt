#!/usr/bin/env bash
# Tests for list_worktrees: every branch worktree is listed (none dropped),
# known tools are tagged, and unknown-location worktrees appear untagged.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
load_wt
build_world

OUT=$(list_worktrees | strip_ansi)

# Helper: the rendered line for a given branch (display column).
line_for() { printf '%s\n' "$OUT" | grep -F " $1" | head -1; }

# Nothing is dropped: all five branches plus main are present.
for b in main feature claude/work codex/work ricardo/loose orphan; do
  assert_contains "$OUT" "$b" "lists worktree: $b"
done

# Known tools get tagged.
assert_contains "$(line_for claude/work)" "[claude]" "claude worktree tagged"
assert_contains "$(line_for codex/work)"  "[codex]"  "codex worktree tagged"

# Codex tag shows the hash dir (with the trailing repo name stripped).
assert_contains "$(line_for codex/work)" "ab12" "codex row shows hash dir"
assert_not_contains "$(line_for codex/work)" "ab12/repo" "codex row strips /repo suffix"

# Path beats branch name: a codex worktree on a non-codex/ branch is still codex.
assert_contains "$(line_for ricardo/loose)" "[codex]" "codex classified by path, not branch prefix"

# Own and unknown worktrees are untagged.
assert_not_contains "$(line_for feature)" "[claude]" "own worktree not tagged claude"
assert_not_contains "$(line_for feature)" "[codex]"  "own worktree not tagged codex"
assert_not_contains "$(line_for orphan)"  "[claude]" "unknown worktree not tagged claude"
assert_not_contains "$(line_for orphan)"  "[codex]"  "unknown worktree not tagged codex"

# main is present and untagged.
assert_not_contains "$(line_for main)" "[claude]" "main not tagged"

summary
