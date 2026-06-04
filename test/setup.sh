#!/usr/bin/env bash
# Tests for setup: copies untracked paths from main into the worktree based on
# the default pattern list, extended by a `copy =` config entry. Tracked files
# and unmatched untracked files are left alone; existing files aren't clobbered.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
load_wt
build_world

# Seed the main worktree with a mix of tracked and untracked content.
git -C "$MAIN" worktree add -q "$ROOT/spare" -b spare   # unrelated, keep main clean
printf 'SECRET=1\n'   > "$MAIN/.env"
printf 'LOCAL=1\n'    > "$MAIN/.env.local"
mkdir -p "$MAIN/node_modules/dep" && printf 'x\n' > "$MAIN/node_modules/dep/index.js"
mkdir -p "$MAIN/.venv"            && printf 'y\n' > "$MAIN/.venv/pyvenv.cfg"
printf 'log\n'        > "$MAIN/debug.log"            # untracked, not in any pattern
printf 'tracked\n'    > "$MAIN/src.txt"
git -C "$MAIN" add src.txt && git -C "$MAIN" commit -qm src

WT="$ROOT/wt-target"
mkdir -p "$WT"

run_setup() { ( cd "$WT" && setup ) >/dev/null 2>&1; }

# --- defaults: .env* only ---
CONFIG_FILE="$ROOT/none.toml"   # no config file -> defaults only
rm -f "$CONFIG_FILE"
run_setup
assert_eq "0" "$([[ -f "$WT/.env" ]];                 echo $?)" ".env copied by default"
assert_eq "0" "$([[ -f "$WT/.env.local" ]];           echo $?)" ".env.local copied (.env* glob)"
assert_eq "1" "$([[ -e "$WT/node_modules" ]];         echo $?)" "node_modules not copied by default"
assert_eq "1" "$([[ -e "$WT/.venv" ]];                echo $?)" ".venv not copied without copy="
assert_eq "1" "$([[ -e "$WT/debug.log" ]];            echo $?)" "unmatched untracked file skipped"
assert_eq "1" "$([[ -e "$WT/src.txt" ]];              echo $?)" "tracked file not copied"

# --- copy= extends the defaults ---
rm -rf "$WT"; mkdir -p "$WT"
CONFIG_FILE="$ROOT/cfg.toml"
config_set copy "node_modules .venv"
run_setup
assert_eq "0" "$([[ -f "$WT/node_modules/dep/index.js" ]]; echo $?)" "node_modules copied via copy="
assert_eq "0" "$([[ -f "$WT/.venv/pyvenv.cfg" ]];     echo $?)" ".venv copied via copy="
assert_eq "0" "$([[ -f "$WT/.env" ]];                echo $?)" "defaults still apply with copy="

# --- existing files are not clobbered ---
rm -rf "$WT"; mkdir -p "$WT"
printf 'KEEP=ME\n' > "$WT/.env"
run_setup
assert_contains "$(cat "$WT/.env")" "KEEP=ME" "existing .env left untouched"

summary
