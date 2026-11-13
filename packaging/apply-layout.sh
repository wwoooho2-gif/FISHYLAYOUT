#!/bin/bash
# Apply the captured shell bar layout, with paths resolved for this user.

set -euo pipefail

if (( EUID == 0 )); then
  echo "omarchy-fish-layout: run as your normal user" >&2
  exit 1
fi

state="$HOME/.local/state/omarchy-fish-layout"
marker="$state/applied"
[[ -f $marker ]] && exit 0

template=/usr/share/omarchy-fishylayout/shell-layout.json
[[ -r $template ]] || {
  echo "omarchy-fish-layout: missing layout template $template" >&2
  exit 1
}

config_dir="$HOME/.config/omarchy"
config="$config_dir/shell.json"
mkdir -p "$config_dir"

rendered=$(mktemp)
cleanup() { rm -f -- "$rendered"; }
trap cleanup EXIT
sed "s|__HOME__|$HOME|g" "$template" >"$rendered"
jq -e . "$rendered" >/dev/null

if [[ -r $config ]] && jq -e 'type == "object"' "$config" >/dev/null 2>&1; then
  temporary=$(mktemp "$config.XXXXXX")
  if jq --slurpfile layout "$rendered" \
    '.bar = $layout[0].bar | .dock = $layout[0].dock' \
    "$config" >"$temporary"; then
    chmod --reference="$config" "$temporary"
    mv -f -- "$temporary" "$config"
  else
    rm -f -- "$temporary"
    echo "omarchy-fish-layout: could not merge the layout into $config" >&2
    exit 1
  fi
else
  cp -- "$rendered" "$config"
fi

# The shell's own settings (font size, bar transparency) live in shell.toml.
# Ship the captured copy, but never overwrite settings the user already made.
toml_template=/usr/share/omarchy-fishylayout/shell.toml
toml_config="$config_dir/shell.toml"
if [[ ! -e $toml_config && -r $toml_template ]]; then
  cp -- "$toml_template" "$toml_config"
  echo "Installed the FISHARCHY shell settings"
fi

command -v omarchy-shell >/dev/null 2>&1 &&
  omarchy-shell shell reloadConfig >/dev/null 2>&1 || true

mkdir -p "$state"
touch "$marker"
echo "Applied the FISHARCHY bar layout"
