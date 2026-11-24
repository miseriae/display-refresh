# Display Refresh

Quick 60/120 Hz switch for an external display in the Omarchy bar.

- Shows the current refresh rate for a configured output (default `HDMI-A-1`).
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
omarchy bar set miseriae.display-refresh highRate 120
omarchy bar set miseriae.display-refresh lowRate 60
omarchy bar set miseriae.display-refresh pollInterval 2
omarchy bar set miseriae.display-refresh showIcon true
```

## Notes

- The built-in Display panel handles brightness, scale, and enabling/disabling
  displays; this widget handles the refresh-rate toggle.
- The mode is selected from `hyprctl monitors -j`'s `availableModes` for the
  current resolution, so 60.00 vs 59.94 is handled.
- Position, scale, and transform are preserved when switching.
- The iGPU/compositor load drops when the external display is at 60 Hz, which is
  useful while gaming on the laptop panel.
