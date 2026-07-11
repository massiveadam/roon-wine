# Architecture

## Boundary

Roon's desktop client is proprietary, so this is a managed compatibility layer,
not a source-level port. Roon Server and Roon Bridge remain native Linux services.

The Windows desktop app provides two roles inside one managed Wine prefix:

1. **Control** discovers and controls a Roon Server over the LAN.
2. **Output** publishes the desktop's Wine audio device as a Roon audio zone.

## Display path

`auto` prefers Wine's native Wayland driver in a Wayland session. The launcher
unsets `DISPLAY` when starting native Wayland because Wine otherwise prefers its
X11 driver. `xwayland` remains the compatibility fallback.

## Audio path

The default route is:

```text
Roon.exe -> Wine PulseAudio driver -> pipewire-pulse -> PipeWire -> device
```

PulseAudio uses the same Wine driver without the PipeWire compatibility layer.
ALSA switches the Wine registry driver directly and is an advanced mode.

## Test matrix

Each release should record install, launch, discovery, playback, device switching,
sleep/resume, HiDPI, and upgrade results across:

- GNOME/Mutter, KDE/KWin, Sway/wlroots, and Hyprland
- AMD, Intel, and NVIDIA graphics
- native Wayland and XWayland
- PipeWire and PulseAudio
- the current Arch Wine package plus the last known-good Wine major release

