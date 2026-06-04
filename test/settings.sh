#!/usr/bin/env bash
# Tests for settings: opens the repo config in $EDITOR, seeding a commented
# template when the file does not exist yet, and leaving an existing file as-is.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/helpers.sh"
load_wt

ROOT=$(mktemp -d); _TMP_ROOTS+=("$ROOT")
CONFIG_FILE="$ROOT/cfg/wt.toml"   # neither file nor dir exists yet

# Fake editor: a script that records the path it was handed.
OPENED="$ROOT/opened"
cat > "$ROOT/fake-editor" <<EOF
#!/usr/bin/env bash
printf '%s' "\$1" > "$OPENED"
EOF
chmod +x "$ROOT/fake-editor"
export EDITOR="$ROOT/fake-editor"

# --- no file yet: template is created and the editor is pointed at it ---
settings
assert_eq "0" "$([[ -f "$CONFIG_FILE" ]]; echo $?)" "config file created"
assert_eq "$CONFIG_FILE" "$(cat "$OPENED")" "editor opened the config path"
body=$(cat "$CONFIG_FILE")
assert_contains "$body" "# prepare ="    "template documents prepare"
assert_contains "$body" "# copy ="       "template documents copy"
# Template keys are commented, so nothing is actually configured.
assert_eq "" "$(sed -n 's/^prepare[[:space:]]*=.*//p' "$CONFIG_FILE")" "template prepare is inert"

# --- existing file: left untouched, just reopened ---
printf 'copy = "node_modules"\n' > "$CONFIG_FILE"
settings
assert_eq 'copy = "node_modules"' "$(cat "$CONFIG_FILE")" "existing file not overwritten by template"
assert_eq "$CONFIG_FILE" "$(cat "$OPENED")" "editor reopened existing config"

# --- VISUAL wins over EDITOR ---
VOPENED="$ROOT/vopened"
cat > "$ROOT/fake-visual" <<EOF
#!/usr/bin/env bash
printf 'visual' > "$VOPENED"
EOF
chmod +x "$ROOT/fake-visual"
export VISUAL="$ROOT/fake-visual"
settings
assert_eq "visual" "$(cat "$VOPENED")" "VISUAL preferred over EDITOR"

summary
