#!/usr/bin/env bash

set -Eeuo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
preset="$script_dir/current-layout.json"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
shell_config="$config_home/omarchy/shell.json"

if ! command -v jq >/dev/null 2>&1; then
  printf 'The jq command is required to apply the layout preset.\n' >&2
  exit 127
fi

if ! jq -e '
  (.bar | type == "object") and
  (.bar.layout | type == "object") and
  (.bar.layout.left | type == "array") and
  (.bar.layout.center | type == "array") and
  (.bar.layout.right | type == "array") and
  (.bar.position | type == "string") and
  (.bar.transparent | type == "boolean")
' "$preset" >/dev/null; then
  printf 'Layout preset is invalid: %s\n' "$preset" >&2
  exit 2
fi

if [[ ! -r "$shell_config" ]]; then
  printf 'Cannot apply the preset: no readable shell config at %s\n' "$shell_config" >&2
  exit 2
fi

if ! jq -e 'type == "object"' "$shell_config" >/dev/null; then
  printf 'Cannot apply the preset: shell config is not valid JSON: %s\n' "$shell_config" >&2
  exit 2
fi

temporary_config="$(mktemp "${shell_config}.tmp.XXXXXXXX")"
backup=""
cleanup() {
  rm -f -- "$temporary_config"
  # Remove the backup placeholder if we bail out before it holds a real copy.
  if [[ -n $backup && ! -s $backup ]]; then
    rm -f -- "$backup"
  fi
}
trap cleanup EXIT

if ! jq --slurpfile preset "$preset" '.bar = $preset[0].bar' "$shell_config" > "$temporary_config"; then
  printf 'Failed to prepare the preset; shell config was not changed.\n' >&2
  exit 1
fi

if ! chmod --reference="$shell_config" "$temporary_config"; then
  printf 'Failed to preserve shell config permissions; config was not changed.\n' >&2
  exit 1
fi

backup="$(mktemp "${shell_config}.bak.XXXXXXXX")"
if ! cp -- "$shell_config" "$backup"; then
  printf 'Failed to back up shell config; config was not changed.\n' >&2
  exit 1
fi

if ! mv -- "$temporary_config" "$shell_config"; then
  printf 'Failed to apply preset. Original config is at %s\n' "$backup" >&2
  exit 1
fi

printf 'Applied current-layout preset. Backup: %s\n' "$backup"
