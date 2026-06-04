#!/usr/bin/env bash
# Unit tests for detect_tool: classification is by path only, and it emits
# "<base>\t<label>" with base always non-empty (so the label can't be lost to
# IFS field-collapsing on read).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
load_wt

MAIN=/repo
export HOME=/home

# label() / base() pull the two fields back out exactly as list_worktrees does.
label() { IFS=$'\t' read -r _ l <<<"$(detect_tool "$1")"; printf '%s' "$l"; }
base()  { IFS=$'\t' read -r b _ <<<"$(detect_tool "$1")"; printf '%s' "$b"; }

assert_eq "claude" "$(label /repo/.claude/worktrees/eager-name)"      "claude worktree -> claude"
assert_eq "codex"  "$(label /home/.codex/worktrees/ab12/repo)"        "codex worktree -> codex"
assert_eq ""       "$(label /repo/.worktrees/feature)"                "own worktree -> empty label"
assert_eq ""       "$(label /somewhere/else/orphan)"                  "unknown location -> empty label"
assert_eq ""       "$(label /repo)"                                   "main worktree -> empty label"

assert_eq "/repo/.claude/worktrees/" "$(base /repo/.claude/worktrees/x)" "claude base path"
assert_eq "/home/.codex/worktrees/"  "$(base /home/.codex/worktrees/x)"  "codex base path"
assert_eq "/repo/.worktrees/"        "$(base /anything/unknown)"         "fallback base is own .worktrees"

# Regression: the leading field must never be the empty label, or read with a
# tab IFS collapses it and the path leaks into the label.
assert_not_contains "$(label /repo/.worktrees/feature)" "/repo" "empty label is not the path"

summary
