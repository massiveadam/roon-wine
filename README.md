# Roon Proton for Arch Linux

An Arch-oriented compatibility package for running the Windows Roon desktop app
as both a **Roon Control** and a **local audio Output** on Linux. It uses a pinned
GE-Proton runtime through UMU for the controller and Roon's native Linux Bridge
for reliable endpoint playback, with system Wine as a diagnostic fallback.

The package and primary command are named `roon-proton`. The legacy
`roon-wine` command remains as a compatibility alias and uses the same existing
configuration and prefix data.

This project does not redistribute Roon. The installer is downloaded directly
from Roon Labs when the user runs `roon-proton install`.

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

Then create the isolated Proton prefix and install Roon:

```sh
roon-proton install
roon-proton doctor
roon-proton run
```

After pulling or editing a newer checkout, rerun:

```sh
yay -Bi .
```

Remove the packaged launcher with `yay -Rns roon-proton`. User data is deliberately
left in `${XDG_DATA_HOME:-~/.local/share}/roon-wine`; remove that directory only
when you intentionally want to discard the Roon prefix and its settings.

## Install with makepkg

```sh
makepkg -si
roon-proton install
roon-proton run
```

The prefix is stored in `${XDG_DATA_HOME:-~/.local/share}/roon-wine/prefix`.
Configuration is stored in `${XDG_CONFIG_HOME:-~/.config}/roon-wine/config`.

## Commands

```text
roon-proton install              create or repair the prefix and install Roon
roon-proton run                  launch Roon
roon-proton doctor               report display, audio, Wine, and prefix state
roon-proton configure            apply the configured display/audio backends
roon-proton winecfg              open Wine configuration for the managed prefix
roon-proton set display auto     auto, wayland, or xwayland
roon-proton set audio pipewire   pipewire, pulse, or alsa
roon-proton set scale 1.5        positive decimal scale factor
roon-proton set runner proton    proton (default) or wine fallback
roon-proton runtime              download and verify the pinned Proton runtime
roon-proton endpoint install     install/start the native Linux audio endpoint
roon-proton endpoint status      show endpoint service status
roon-proton endpoint release     stop playback and release the ALSA device
roon-proton kill                 stop processes in the managed prefix
```

The default `display=auto` uses XWayland with the pinned Proton runtime. Testing
found that Proton 10 avoids Wine 11's Roon crash, while XWayland avoids Proton
10's second-OpenGL-context failure on native Wayland. The native endpoint uses
Roon Bridge with direct ALSA hardware access, keeping playback outside Wine's
incomplete WASAPI format negotiation. Direct access can temporarily reserve the
device while Roon is playing; stop playback before another desktop app needs it.

This dedicated path is the recommended audiophile mode: Roon talks to the native
RAAT endpoint, which opens the hardware ALSA device without a desktop mixer or
Wine audio layer. It is intentionally independent of the controller window and
will not appear as a PipeWire media session. Use `roon-proton endpoint release` if
the controller has closed while the core is still playing or another app needs
the device.

To make the desktop a Roon endpoint:

```sh
roon-proton endpoint install
```

If UFW blocks discovery, allow only your trusted LAN (adjust the subnet):

```sh
sudo ufw allow from 192.168.12.0/24
```

Direct ALSA mode is intended for experimentation with dedicated devices. It may
conflict with PipeWire device ownership and is not assumed to provide exclusive
or bit-perfect playback. Those properties must be verified in Roon's signal path
and against the selected Linux device.

With the fallback runner selected, use `roon-proton winecfg` after installation when manual Wine device, graphics,
desktop-integration, or library settings are needed. It always opens the prefix
managed by this package rather than the user's default Wine prefix.

## Runtime policy

The launcher pins and verifies GE-Proton 10 rather than following an untested
`latest` release. The roughly 500 MiB runtime archive is cached under
`${XDG_CACHE_HOME:-~/.cache}/roon-wine`; the extracted runtime and prefix live
under `${XDG_DATA_HOME:-~/.local/share}/roon-wine`. `roon-proton set runner wine`
is available for diagnosis, but current Wine/Proton 11 aborts in Roon's volume
enumeration because `wminet_utils.GetErrorInfo` is not implemented.

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
and the physical-hardware release smoke test. See
[docs/window-managers.md](docs/window-managers.md) for tested Niri and Hyprland
tiling rules.
