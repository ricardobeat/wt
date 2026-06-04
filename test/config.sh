#!/usr/bin/env bash
# Tests for config_set: creates the toml on first write, updates a key in
# place, and appends new keys without clobbering existing ones.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
load_wt

ROOT=$(mktemp -d); _TMP_ROOTS+=("$ROOT")
CONFIG_FILE="$ROOT/cfg/wt.toml"   # dir does not exist yet — config_set must mkdir

config_set prepare "npm install"
assert_eq "0" "$([[ -f "$CONFIG_FILE" ]]; echo $?)" "config file created"
assert_contains "$(cat "$CONFIG_FILE")" 'prepare = "npm install"' "key written"

# Update in place: old value gone, new value present, still a single line.
config_set prepare "pnpm install"
body=$(cat "$CONFIG_FILE")
assert_contains     "$body" 'prepare = "pnpm install"' "key updated"
assert_not_contains "$body" 'prepare = "npm install"'  "old value removed"
assert_eq "1" "$(grep -c '^prepare' "$CONFIG_FILE")"   "no duplicate prepare line"

# Append a different key, leaving the first intact.
config_set editor "vim"
body=$(cat "$CONFIG_FILE")
assert_contains "$body" 'prepare = "pnpm install"' "existing key preserved on append"
assert_contains "$body" 'editor = "vim"'           "new key appended"

summary
