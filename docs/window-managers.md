# Tiling window managers

Roon runs through XWayland with the stable main-window identity
`class/app-id=steam_app_0`, `title=Roon`. Rules intentionally require both
values so they do not affect unrelated Proton applications. Only the main Roon
window is forced to tile; dialogs and transient popups keep their compositor
defaults.

Packaged snippets are installed under `/usr/share/roon-proton/wm`.

## Niri

Add this line to `~/.config/niri/config.kdl`:

```kdl
include "/usr/share/roon-proton/wm/roon-proton.niri.kdl"
```

The main window opens tiled at 80% column width. Niri can reload the config
without restarting the session.

## Hyprland through 0.54

Add this line to `~/.config/hypr/hyprland.conf`:

```ini
source = /usr/share/roon-proton/wm/roon-proton.hyprland.conf
```

## Hyprland 0.55 and newer

Hyprland 0.55 moved configuration to Lua. Load
`/usr/share/roon-proton/wm/roon-proton.hyprland.lua` from the main Lua config
after importing the Hyprland API as `hl`.

Use `niri msg windows`, `niri msg pick-window`, or `hyprctl clients` to verify
the identity if a future Proton release changes it.
