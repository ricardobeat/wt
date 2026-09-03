#!/usr/bin/env bash
# Tests for prepare script parsing in run_prepare, including multi-line
# and literal TOML strings.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
load_wt

ROOT=$(mktemp -d); _TMP_ROOTS+=("$ROOT")
CONFIG_FILE="$ROOT/wt.toml"

# Test 1: Single-line basic string
cat > "$CONFIG_FILE" <<'TOML'
prepare = "touch single.marker"
TOML
( cd "$ROOT" && run_prepare ) >/dev/null 2>&1
assert_eq "0" "$([[ -f "$ROOT/single.marker" ]]; echo $?)" "single-line basic string runs"

# Test 2: Multi-line basic string (""")
cat > "$CONFIG_FILE" <<'TOML'
prepare = """
touch multi1.marker
touch multi2.marker
"""
TOML
( cd "$ROOT" && run_prepare ) >/dev/null 2>&1
assert_eq "0" "$([[ -f "$ROOT/multi1.marker" ]]; echo $?)" "multiline basic string runs line 1"
assert_eq "0" "$([[ -f "$ROOT/multi2.marker" ]]; echo $?)" "multiline basic string runs line 2"

# Test 3: Multi-line string with escaped newline continuation
cat > "$CONFIG_FILE" <<'TOML'
prepare = """
echo line\
continued > output.txt
"""
TOML
( cd "$ROOT" && run_prepare ) >/dev/null 2>&1
assert_contains "$(cat "$ROOT/output.txt")" 'linecontinued' "escaped newline continued"

# Test 4: Multi-line literal string (''')
cat > "$CONFIG_FILE" <<'TOML'
prepare = '''
touch literal1.marker
touch literal2.marker
'''
TOML
( cd "$ROOT" && run_prepare ) >/dev/null 2>&1
assert_eq "0" "$([[ -f "$ROOT/literal1.marker" ]]; echo $?)" "multiline literal string runs line 1"
assert_eq "0" "$([[ -f "$ROOT/literal2.marker" ]]; echo $?)" "multiline literal string runs line 2"

# Test 5: Single-line literal string (')
cat > "$CONFIG_FILE" <<'TOML'
prepare = 'touch single_literal.marker'
TOML
( cd "$ROOT" && run_prepare ) >/dev/null 2>&1
assert_eq "0" "$([[ -f "$ROOT/single_literal.marker" ]]; echo $?)" "single-line literal string runs"

summary
