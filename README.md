# FISHYLAYOUT

One private Omarchy shell plugin that places the selected community feature
icons directly in the bar and includes a small layout dashboard. It bundles:

- Plugin Manager
- Quick Drawer
- Omarchy Taskbar
- Workspace Peek
- GPU Monitor
- Cursor Accent
- Better Media
- Glass & Blur
- Glass Alt+Tab

The optional `omarchy-fx` plugin from the old installer is not included; it was
a separate add-on, not part of the main plugin list.

## Apply the preview bar layout

The preview bar layout is saved at `presets/current-layout.json`. Applying it
replaces the bar layout (but preserves other settings in `shell.json`) and
creates a backup first:

| Anime wallpaper | Misty forest | Abstract wave |
|---|---|---|
| ![Omarchy desktop with anime wallpaper](./presets/layout-anime-wallpaper.png) | ![Omarchy desktop with misty forest wallpaper](./presets/layout-misty-forest.png) | ![Omarchy desktop with abstract wave wallpaper](./presets/layout-wave.png) |

```bash
./presets/apply-current-layout.sh
```

The script replaces only the `bar` object in `~/.config/omarchy/shell.json`,
preserves other shell settings, and creates a uniquely named backup first.
You can apply the same preset using **Apply bar preset** in the FISHYLAYOUT
dashboard. The preset places Quick Drawer, Plugin Manager, Glass & Blur, workspace preview,
and the FISHYLAYOUT dashboard button on the left; media beside the centered
clock; and the GPU readout, display, audio, network, and system-tray drawer on
the right. Each FISHYLAYOUT bar feature is a separate bar item, so you can drag
it independently to another section or reorder it beside other widgets.

Applying this preset is not an Omarchy-default reset. Keep the printed backup
path if you may want to restore the previous shell config later.

## Install

Run these commands on your Omarchy machine:

```bash
omarchy plugin add https://github.com/wwoooho2-gif/FISHYLAYOUT.git --enable
bash ~/.config/omarchy/plugins/furina.omarchy-suite/presets/install-bar-widgets.sh
```

The setup script adds the FISHYLAYOUT dashboard, standalone feature widgets,
and Omarchy's system tray for background app icons. Media is placed in
`centerBegin`, beside the clock. It preserves other bar entries, creates a
backup before changing `shell.json`, and can be run again safely. Drag each
bar item on the bar to move or reorder it individually. Removing the plugin
does not automatically restore your previous bar layout; use the backup
created by the script if you want to restore the whole prior shell config.

The taskbar and Alt+Tab are loaded through the plugin's panel entry point.
Alt+Tab writes a generated Hyprland toggle loader under
`~/.local/state/omarchy/toggles/hypr/` when the panel loads. Delete that loader
and run `hyprctl reload` to restore Omarchy's built-in Alt+Tab behavior.
Quick Drawer toggles use Omarchy's own toggle commands. The media controls
appear on the bar when an MPRIS-compatible player is publishing playback
metadata.
The cursor theme-follow hooks are opt-in. After installation, run:

```bash
~/.config/omarchy/plugins/furina.omarchy-suite/features/cursor-accent/tools/install-cursor-hook.sh
```

## Optional: OmaWarden

OmaWarden is a separate upstream plugin and is not installed with FISHYLAYOUT.
Install it only if you want Bitwarden controls:

```bash
omarchy plugin add https://github.com/salemsayed/omawarden.git --enable
```

When enabled, OmaWarden appears as a tile in Quick Drawer and its separate bar
button is hidden while the drawer hosts it. If OmaWarden is not installed and
enabled, the tile is hidden. It remains optional and is not required by the
suite.

## Notes

The suite dashboard, Quick Drawer, Plugin Manager, Glass & Blur, workspace
preview, GPU monitor, and Better Media each occupy their own bar entry. The
media entry starts beside the clock and can be dragged elsewhere.

Bundled source and its license/notice files are under `features/`:

| Feature | Upstream project |
|---|---|
| Plugin Manager | [fross100/omaplug](https://github.com/fross100/omaplug) |
| Quick Drawer | [KaplanHalil/omarchy-quick-drawer](https://github.com/KaplanHalil/omarchy-quick-drawer) |
| Taskbar | [gsus67/omarchy-taskbar](https://github.com/gsus67/omarchy-taskbar) |
| Workspace Preview | [AnoopLamba/omarchy-workspace-preview](https://github.com/AnoopLamba/omarchy-workspace-preview) |
| GPU Monitor | [candycrabmusic/gpu-monitor](https://github.com/candycrabmusic/gpu-monitor) |
| Cursor Accent | [SmoothPixels/cursor-accent](https://github.com/SmoothPixels/cursor-accent) |
| Better Media | [BibekBhusal0/omarchy-better-media](https://github.com/BibekBhusal0/omarchy-better-media) |
| Glass & Blur | [lutfi-zain/omarchy-glass-blur](https://github.com/lutfi-zain/omarchy-glass-blur) |
| Alt+Tab | [hugorolimf/omarchy-alttab](https://github.com/hugorolimf/omarchy-alttab) |

Licensing varies by feature; refer to each bundled `LICENSE` and `NOTICE.md`.

Some upstream features rely on Omarchy, Hyprland, or optional tools already
being available. Cursor Accent's automatic theme-follow behavior also needs
its upstream hook installer run once from this plugin's installed directory.

Plugins execute as your user inside the long-lived Omarchy shell. Review the
bundled source and its dependencies before enabling it.
