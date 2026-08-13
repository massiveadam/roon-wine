# Architecture

## Boundary

Roon's desktop client is proprietary, so this is a managed compatibility layer,
not a source-level port. Roon Server and Roon Bridge remain native Linux services.

The Windows desktop app provides two roles inside one managed Wine prefix:

1. **Control** discovers and controls a Roon Server over the LAN.
2. **Output** publishes the desktop's Wine audio device as a Roon audio zone.

## Display path

With Proton, `auto` uses XWayland in a Wayland session because Roon's second GL
context is not reliable with Proton's native Wayland driver. In a traditional
X11 session, `auto` uses X11 directly. The Wine fallback may use native Wayland
when supported; the launcher unsets `DISPLAY` so Wine does not select X11.
Explicit modes validate that their required display socket is available.

## Audio paths

The recommended desktop-following route is:

```text
Roon Core -> native Bridge -> ALSA plug:pipewire
  -> PipeWire -> filters and the desktop default sink
```

Roon initially discovers the playback side as the first `Loopback PCM`. Users
enable that device and name it **System Output (PipeWire)**. System mode keeps
its Roon identity and rewrites the saved RAAT output to `plug:pipewire` with
software volume. The loopback card is therefore only a stable discoverable
identity; audio does not traverse its fixed-format virtual cable.

The Wine compatibility route is:

```text
Roon.exe -> Wine PulseAudio driver -> pipewire-pulse -> PipeWire -> device
```

This follows WirePlumber's selected output, including laptop speakers, wired
headphones, USB devices, and Bluetooth. PulseAudio uses the same Wine driver
without the PipeWire compatibility layer. ALSA switches the Wine registry driver
directly and is an advanced mode.

The optional native Bridge route is:

```text
Roon Core -> native Roon Bridge/RAATServer -> ALSA hw: device
```

Native Bridge does not list this host's ALSA `pipewire`/`default` plugin as a
separate endpoint. System mode redirects the stable Loopback PCM settings to
that plugin; direct mode remains available for fixed hardware. The native and
Windows endpoints share a RAATServer
rendezvous, so mode transitions stop the managed prefix and restart native
Bridge before the controller is relaunched. The stop includes the UMU/Proton
launcher processes so they cannot recreate the Windows RAATServer during the
handoff. Without that ordering, Bridge can appear active while attached to the
Windows RAATServer instead of owning its own native RAATServer child.

## Test matrix

Each release should record install, launch, discovery, playback, device switching,
sleep/resume, HiDPI, and upgrade results across:

- GNOME/Mutter, KDE/KWin, Sway/wlroots, and Hyprland
- AMD, Intel, and NVIDIA graphics
- native Wayland and XWayland
- PipeWire and PulseAudio
- the current Arch Wine package plus the last known-good Wine major release
