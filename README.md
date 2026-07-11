# Roon on Arch Linux

An Arch-oriented compatibility package for running the Windows Roon desktop app
as both a **Roon Control** and a **local audio Output** on Linux.

This project does not redistribute Roon. The installer is downloaded directly
from Roon Labs when the user runs `roon-wine install`.

## Status

Early development. The initial target matrix is:

- GNOME and KDE Plasma on Wayland
- Sway and Hyprland
- X11/XWayland fallback
- PipeWire through `pipewire-pulse` (default)
- PulseAudio
- direct ALSA as an advanced compatibility mode

Roon Server and Roon Bridge are deliberately out of scope: Roon provides native
Linux builds for those components. This package manages only the desktop app.

## Install from this checkout with yay

From the project directory:

```sh
git clone https://github.com/massiveadam/roon-wine.git
cd roon-wine
yay -Bi --needed .
```

This asks `yay` to build the local `PKGBUILD`, resolve dependencies (including
AUR dependencies), and install the resulting package through `pacman`. It does
not require this project to be published in the AUR.

Then create the Wine prefix and install Roon:

```sh
roon-wine install
roon-wine doctor
roon-wine run
```

After pulling or editing a newer checkout, rerun:

```sh
yay -Bi .
```

Remove the packaged launcher with `yay -Rns roon-wine`. User data is deliberately
left in `${XDG_DATA_HOME:-~/.local/share}/roon-wine`; remove that directory only
when you intentionally want to discard the Roon prefix and its settings.

## Install with makepkg

```sh
makepkg -si
roon-wine install
roon-wine run
```

The prefix is stored in `${XDG_DATA_HOME:-~/.local/share}/roon-wine/prefix`.
Configuration is stored in `${XDG_CONFIG_HOME:-~/.config}/roon-wine/config`.

## Commands

```text
roon-wine install              create or repair the prefix and install Roon
roon-wine run                  launch Roon
roon-wine doctor               report display, audio, Wine, and prefix state
roon-wine configure            apply the configured display/audio backends
roon-wine winecfg              open Wine configuration for the managed prefix
roon-wine set display auto     auto, wayland, or xwayland
roon-wine set audio pipewire   pipewire, pulse, or alsa
roon-wine set scale 1.5        positive decimal scale factor
roon-wine kill                 stop processes in the managed prefix
```

The default `display=auto` prefers native Wine Wayland when the session and Wine
support it, then falls back to XWayland. The default `audio=pipewire` uses Wine's
PulseAudio driver through PipeWire's PulseAudio compatibility service. This is
the most broadly compatible way to expose the Linux desktop as a Roon endpoint.

Direct ALSA mode is intended for experimentation with dedicated devices. It may
conflict with PipeWire device ownership and is not assumed to provide exclusive
or bit-perfect playback. Those properties must be verified in Roon's signal path
and against the selected Linux device.

Use `roon-wine winecfg` after installation when manual Wine device, graphics,
desktop-integration, or library settings are needed. It always opens the prefix
managed by this package rather than the user's default Wine prefix.

## Known compatibility concern

Wine 11 has been reported to render Roon with washed-out colors. `roon-wine
doctor` warns when Wine 11 is detected. The project will maintain a tested Wine
version matrix instead of silently changing the user's system Wine installation.

## Development

Run the static checks with:

```sh
make check
```

On macOS or Linux with Docker, build and inspect the x86_64 Arch package in a
disposable container:

```sh
make check-arch
```

The container intentionally validates packaging without installing Wine. A full
Roon test requires an x86_64 Linux VM with a graphical Wayland session and audio
devices; containers cannot faithfully exercise that path on macOS.

On the development Mac, the dedicated Colima runtime is stored under
`/Volumes/NVMe/Roon Arch Linux Test`. The test automatically uses that runtime
when its Docker socket is available. Set `ROON_ARCH_DOCKER_SOCKET` to override
the socket path; on other systems the active Docker context is used.

See [docs/architecture.md](docs/architecture.md) for design boundaries and the
planned test matrix. See [docs/testing.md](docs/testing.md) for recorded results
and the physical-hardware release smoke test.
