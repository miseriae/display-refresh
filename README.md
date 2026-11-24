# Display Refresh

Quick 60/120 Hz switch for an external display in the Omarchy bar.

- Shows `󰔂 EXT 120` / `󰔂 EXT 60` for the configured external output (default
  `HDMI-A-1`); the tooltip includes the output and monitor model.
- `label` (default `EXT`) is shown before the rate; set it to `HDMI`, `24"`, or
  empty if you prefer.
- `icon` (default `󰔂`, TV/external display) is shown before the label; try
  `󰍺` (multi-monitor) or `󰍹` (monitor), or set it empty.
- Left-click toggles between `highRate` (default 120) and `lowRate` (default 60).
- Middle-click refreshes immediately.
- Hides itself when the output is disconnected or disabled.
- The change is runtime-only: `hyprctl reload` or a re-login restores the mode from
  `~/.config/hypr/monitors.lua` (currently 120 Hz).

## Install from git

```sh
omarchy plugin add https://github.com/miseriae/display-refresh --enable
```

`--enable` places the widget on the bar immediately. Move it with
`omarchy bar put miseriae.display-refresh --after omarchy.monitor` if needed.

## Install (local development)

```sh
ln -s ~/Work/display-refresh ~/.config/omarchy/plugins/miseriae.display-refresh
omarchy plugin validate ~/Work/display-refresh
omarchy-shell shell rescanPlugins
omarchy plugin enable miseriae.display-refresh
omarchy bar put miseriae.display-refresh --after omarchy.monitor
```

If the widget does not appear after editing the symlinked checkout:

```sh
omarchy restart shell
```

## Settings

```sh
omarchy bar set miseriae.display-refresh output HDMI-A-1
omarchy bar set miseriae.display-refresh label EXT
omarchy bar set miseriae.display-refresh icon 󰔂
omarchy bar set miseriae.display-refresh highRate 120
omarchy bar set miseriae.display-refresh lowRate 60
omarchy bar set miseriae.display-refresh pollInterval 2
omarchy bar set miseriae.display-refresh showIcon true
```

## Notes

- The `EXT` prefix makes it clear the number is the external display's refresh
  rate, even when the widget is on the laptop bar.
- The default `󰔂` icon is a TV/external-display glyph, distinct from the built-in
  Display widget's `󰍺` multi-monitor icon.
- The built-in Display panel handles brightness, scale, and enabling/disabling
  displays; this widget handles the refresh-rate toggle.
- The mode is selected from `hyprctl monitors -j`'s `availableModes` for the
  current resolution, so 60.00 vs 59.94 is handled.
- Position, scale, and transform are preserved when switching.
- The iGPU/compositor load drops when the external display is at 60 Hz, which is
  useful while gaming on the laptop panel.
