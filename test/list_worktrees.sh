#!/usr/bin/env bash
# Tests for list_worktrees: every branch worktree is listed (none dropped),
# known tools are tagged, and unknown-location worktrees appear untagged.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
load_wt
build_world

# An untagged worktree whose directory name differs from its branch — e.g. one
# parked on a different branch than its slug suggests (the `.worktrees/foo` on
# `main` case). The directory must still surface so it isn't hidden as a bare
# branch name.
git -C "$MAIN" worktree add -q "$MAIN/.worktrees/parked-dir" -b parked-branch

OUT=$(list_worktrees | strip_ansi)

# Helper: the rendered display column for a given branch. list_worktrees emits
# "branch<TAB>display"; field 1 is the fzf selection key, field 2 is what the
# user sees — assert against the latter.
line_for() { printf '%s\n' "$OUT" | cut -f2- | grep -F " $1" | head -1; }

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

# Inverted layout: worktree name on the left, branch on the right — and the
# branch is shown only when it differs from the name. (tr -s squeezes the
# padding so the column order is asserted, not just co-presence.)
assert_contains "$(line_for parked-branch | tr -s ' ')" "parked-dir parked-branch" \
  "dir != branch: name left, branch right"

# When dir == branch there's nothing to disambiguate, so the branch isn't
# repeated — the row is just the name.
assert_eq "feature" "$(line_for feature | tr -s ' ' | sed 's/^ *//; s/ *$//')" \
  "dir == branch renders name once, no duplicate branch"

summary
