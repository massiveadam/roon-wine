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

## Audio paths

The recommended desktop-following route is:

```text
Roon Core -> native Bridge -> snd-aloop playback DEV=0
  -> PipeWire ALSA capture hw:Loopback,1 -> adaptive pw-loopback
  -> WirePlumber default sink
```

Roon initially discovers the playback side as the first `Loopback PCM`. Users
enable that device and name it **System Output (PipeWire)**. The capture half
remains disabled as a Roon zone, but must remain present for PipeWire routing.

The paired loopback sides intentionally use different ALSA device numbers.
PipeWire's clock-adaptive loopback compensates for drift between the virtual
ALSA clock and the physical or Bluetooth output clock.

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

Native Bridge does not expose this host's ALSA `pipewire`/`default` plugin as a
RAAT endpoint. It is an explicit exclusive/direct mode for fixed hardware, not
the desktop default. Do not run it alongside the Wine local endpoint: the two
components share a RAATServer rendezvous and the controller can attach to the
native server instead of starting its own local-output server.

## Test matrix

Each release should record install, launch, discovery, playback, device switching,
sleep/resume, HiDPI, and upgrade results across:

- GNOME/Mutter, KDE/KWin, Sway/wlroots, and Hyprland
- AMD, Intel, and NVIDIA graphics
- native Wayland and XWayland
- PipeWire and PulseAudio
- the current Arch Wine package plus the last known-good Wine major release
