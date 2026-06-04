#!/usr/bin/env bash
# End-to-end test for the `wt setup` subcommand: it should both copy untracked
# files AND re-run the prepare hook. This drives the real script (not just the
# loaded functions) so the dispatcher wiring is covered.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
load_wt          # only for build_world; the actual run is via $WT
build_world

WTREE="$MAIN/.worktrees/feature"
printf 'SECRET=1\n' > "$MAIN/.env"

# Configure through the real CLI so CONFIG_FILE resolves to the same path the
# `setup` run will read ($HOME + repo slug are shared via the env build_world set).
( cd "$MAIN" && bash "$WT" set prepare "touch prepared.marker" ) >/dev/null 2>&1

# Run `wt setup` from inside the worktree.
( cd "$WTREE" && bash "$WT" setup ) >/dev/null 2>&1

assert_eq "0" "$([[ -f "$WTREE/.env" ]];             echo $?)" "wt setup copies untracked .env"
assert_eq "0" "$([[ -f "$WTREE/prepared.marker" ]];  echo $?)" "wt setup runs the prepare hook"

summary
