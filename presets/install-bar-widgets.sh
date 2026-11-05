#!/usr/bin/env bash

set -Eeuo pipefail

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
shell_config="$config_home/omarchy/shell.json"
plugin_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd -P)"

if ! command -v jq >/dev/null 2>&1; then
  printf 'The jq command is required to add the bar widgets.\n' >&2
  exit 127
fi

if [[ ! -r "$shell_config" ]]; then
  printf 'Cannot add the bar widgets: no readable shell config at %s\n' "$shell_config" >&2
  exit 2
fi

if ! jq -e '
  type == "object" and
  (.bar | type == "object") and
  (.bar.layout | type == "object")
' "$shell_config" >/dev/null; then
  printf 'Cannot add the bar widgets: invalid shell config: %s\n' "$shell_config" >&2
  exit 2
fi

temporary_config="$(mktemp "${shell_config}.tmp.XXXXXXXX")"
cleanup() {
  rm -f -- "$temporary_config"
}
trap cleanup EXIT

if ! jq \
  --arg plugin_dir "$plugin_dir" \
  --arg standalone_source "$plugin_dir/features/bar-widgets/Standalone.qml" \
  '
  def has_id($id):
    any(.bar.layout | to_entries[] | .value[]?; .id == $id);

  def widget($id; $feature; $section; $items):
    {
      id: $id,
      type: "qml",
      source: $standalone_source,
      featurePath: ($plugin_dir + "/" + $feature)
    }
    + (if $items == null then {} else {items: $items} end);

  def add_widget($id; $feature; $section; $items):
    if has_id($id) then .
    else .bar.layout[$section] += [widget($id; $feature; $section; $items)]
    end;

  .bar.layout |= with_entries(
    if .key == "left" then
      .value |= map(
        if .id == "furina.omarchy-suite" and (.segment // "left") == "left"
          then {"id": "furina.omarchy-suite"}
        else .
        end
      )
    else
      .value |= map(select(
        .id != "furina.omarchy-suite" or (.segment // "left") == "left"
      ))
    end
  )
  | if has_id("furina.omarchy-suite") then .
    else .bar.layout.left += [{"id": "furina.omarchy-suite"}]
    end
  | add_widget(
      "furina.omarchy-suite.quick-drawer";
      "features/quick-drawer/Indicators.qml";
      "left";
      ["caffeine", "nightlight", "dnd", "screensaver", "suspend", "ext:io.github.salemsayed.omawarden"]
    )
  | add_widget(
      "furina.omarchy-suite.plugin-manager";
      "features/plugin-manager/BarWidget.qml";
      "left";
      null
    )
  | add_widget(
      "furina.omarchy-suite.glass-blur";
      "features/glass-blur/Panel.qml";
      "left";
      null
    )
  | add_widget(
      "furina.omarchy-suite.workspace-preview";
      "features/workspace-preview/WorkspacePreview.qml";
      "left";
      null
    )
  | add_widget(
      "furina.omarchy-suite.gpu-monitor";
      "features/gpu-monitor/BarWidget.qml";
      "right";
      null
    )
  | add_widget(
      "furina.omarchy-suite.media";
      "features/better-media/BarWidget.qml";
      "centerBegin";
      null
    )
  | (
      [ .bar.layout | to_entries[] | .value[]? | select(.id == "omarchy.tray") ][0]
      // {"id": "omarchy.tray"}
    ) as $tray
  | .bar.layout.right = (
      (.bar.layout.right // [] | map(select(.id != "omarchy.tray")))
      + [$tray]
    )
  | .bar.layout |= with_entries(
      if .key == "right" then .
      else .value |= map(select(.id != "omarchy.tray"))
      end
    )
' "$shell_config" > "$temporary_config"; then
  printf 'Failed to prepare the bar widgets; shell config was not changed.\n' >&2
  exit 1
fi

if cmp -s -- "$shell_config" "$temporary_config"; then
  printf 'FISHYLAYOUT standalone widgets and system tray are already configured.\n'
  exit 0
fi

backup="$(mktemp "${shell_config}.bak.XXXXXXXX")"
if ! chmod --reference="$shell_config" "$temporary_config"; then
  printf 'Failed to preserve shell config permissions; config was not changed.\n' >&2
  exit 1
fi

if ! cp -- "$shell_config" "$backup"; then
  printf 'Failed to back up shell config; config was not changed.\n' >&2
  exit 1
fi

if ! mv -- "$temporary_config" "$shell_config"; then
  printf 'Failed to add bar widgets. Original config is at %s\n' "$backup" >&2
  exit 1
fi

printf 'Added independently movable FISHYLAYOUT widgets. Backup: %s\n' "$backup"
