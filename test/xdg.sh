#!/usr/bin/env bash
# Verifies config path resolution honours XDG_CONFIG_HOME, falling back to
# ~/.config. Drives the real script (the path is computed at top level, which
# the function loader strips), via `wt set` which writes config and exits.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
load_wt          # for build_world; the actual runs are via $WT
build_world

# --- XDG_CONFIG_HOME set: config lands under it ---
export XDG_CONFIG_HOME="$ROOT/xdg"
( cd "$MAIN" && bash "$WT" set prepare "from-xdg" ) >/dev/null 2>&1
xdg_file=$(find "$XDG_CONFIG_HOME/wt" -name wt.toml 2>/dev/null | head -1)
assert_eq "0" "$([[ -n "$xdg_file" ]]; echo $?)" "config written under XDG_CONFIG_HOME"
assert_contains "$(cat "$xdg_file" 2>/dev/null)" 'prepare = "from-xdg"' "XDG config has the value"

# --- XDG_CONFIG_HOME unset: falls back to ~/.config ---
unset XDG_CONFIG_HOME
( cd "$MAIN" && bash "$WT" set prepare "from-home" ) >/dev/null 2>&1
home_file=$(find "$HOME/.config/wt" -name wt.toml 2>/dev/null | head -1)
assert_eq "0" "$([[ -n "$home_file" ]]; echo $?)" "config falls back to ~/.config"
assert_contains "$(cat "$home_file" 2>/dev/null)" 'prepare = "from-home"' "fallback config has the value"

summary
