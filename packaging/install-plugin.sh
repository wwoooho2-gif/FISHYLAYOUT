#!/bin/bash
# Install the bundled FISHYLAYOUT plugin into the user's plugin directory.

set -euo pipefail

if (( EUID == 0 )); then
  echo "omarchy-fishylayout-install: run as your normal user" >&2
  exit 1
fi

state="$HOME/.local/state/omarchy-fishylayout"
marker="$state/plugin-installed"
[[ -f $marker ]] && exit 0

src=/usr/share/omarchy-fishylayout/plugin
dst="$HOME/.config/omarchy/plugins/furina.omarchy-suite"

[[ -d $src ]] || {
  echo "omarchy-fishylayout-install: packaged plugin missing at $src" >&2
  exit 1
}

mkdir -p "$(dirname -- "$dst")"
if [[ -e $dst || -L $dst ]]; then
  # A user-installed copy wins; leave it alone.
  echo "FISHYLAYOUT is already installed at $dst"
else
  cp -a -- "$src" "$dst"
  echo "Installed FISHYLAYOUT into $dst"
fi

command -v omarchy-shell >/dev/null 2>&1 &&
  omarchy-shell shell rescanPlugins >/dev/null 2>&1 || true

mkdir -p "$state"
touch "$marker"
