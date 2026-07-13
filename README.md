# Roon Proton for Arch Linux

An Arch-oriented compatibility package for running the Windows Roon desktop app
as both a **Roon Control** and a **local audio Output** on Linux. It uses a pinned
GE-Proton runtime through UMU for the controller. The recommended laptop output
uses native Roon Bridge, an ALSA loopback, and PipeWire so playback follows the
desktop's currently selected speakers, headphones, USB DAC, or Bluetooth sink.

The package and primary command are named `roon-proton`. The legacy
`roon-wine` command remains as a compatibility alias and uses the same existing
configuration and prefix data.

This project does not redistribute Roon. The installer is downloaded directly
from Roon Labs when the user runs `roon-proton install`.

## Security model

The launcher and its user services never request root privileges. Pacman only
installs the package-owned launcher, display rules, PipeWire configuration, and
the `snd-aloop` module-load setting. Configuration files are parsed as data and
are never sourced or evaluated as shell code.

The Proton runtime, Roon installer, and Roon Bridge archive are restricted to
HTTPS and verified against package-pinned SHA-512 hashes before execution or
extraction. The pinned Windows installer was also checked for its Harman
International Authenticode signature when the package hash was updated.

Roon and Roon Bridge remain proprietary network applications running with the
desktop user's permissions; Wine/Proton is a compatibility layer, not a security
sandbox. Roon's own subsequent auto-updates are controlled by Roon Labs rather
than this package. Users requiring isolation should run Roon under a separately
tested sandbox or dedicated user account.

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
roon-proton set display auto     auto, wayland, x11, or xwayland
roon-proton set audio pipewire   pipewire, pulse, or alsa
roon-proton set scale 1.5        positive decimal scale factor
roon-proton set runner proton    proton (default) or wine fallback
roon-proton runtime              download and verify the pinned Proton runtime
roon-proton endpoint install     install the optional native Linux endpoint
roon-proton endpoint status      show endpoint service status
roon-proton endpoint release     stop playback and release the ALSA device
roon-proton endpoint mode desktop use Wine System Output through PipeWire
roon-proton endpoint mode system  use System Output (PipeWire) (recommended)
roon-proton endpoint mode direct  enable native Bridge for direct ALSA devices
roon-proton kill                 stop processes in the managed prefix
```

The default `display=auto` uses XWayland with the pinned Proton runtime. Testing
found that Proton 10 avoids Wine 11's Roon crash, while XWayland avoids Proton
10's second-OpenGL-context failure on native Wayland. In a traditional X11
session, `auto` uses X11 directly. Forced Wayland and X11/XWayland modes fail
with a clear diagnostic when their required display socket is unavailable.

For normal laptop use, install the native endpoint and activate system mode:

```sh
roon-proton endpoint install
roon-proton endpoint mode system
```

Then enable the first **Loopback PCM** device in Roon Settings > Audio, name it
**System Output (PipeWire)**, and use it as the laptop zone. The route is:

```text
Roon Core -> native Roon Bridge -> snd-aloop DEV=0
          -> adaptive PipeWire capture -> WirePlumber default output
```

It follows the currently selected laptop speakers, wired headphones, USB audio,
or Bluetooth device and appears in normal PipeWire media and volume controls.
The package loads `snd-aloop` at boot and pins the bridge to 48 kHz stereo with
clock-adaptive resampling to prevent drift and dropouts.

For a clean zone picker, leave only **System Output (PipeWire)** enabled for this computer.
Disable the second Loopback PCM, Wine **System Output**, direct laptop audio,
and unused HDMI devices in Roon Settings > Audio. Roon will still list those
ALSA devices on the Settings page because it discovers host hardware itself;
disabled devices do not appear as playback zones. The second loopback device
cannot safely be hidden at the system level because it is the capture half of
the paired virtual audio device used by this route.

`endpoint mode desktop` retains the Wine `System Output` path as a compatibility
option. Some Wine/Proton combinations reject ordinary PCM formats on that path.

Native Roon Bridge enumerates kernel ALSA `hw:` devices, not this host's
`pipewire` or `default` ALSA plugin PCMs. It therefore bypasses WirePlumber,
does not follow the desktop output, and can reserve the device while playing.

In optional direct mode, Roon talks to the native
RAAT endpoint, which opens the hardware ALSA device without a desktop mixer or
Wine audio layer. It is intentionally independent of the controller window and
will not appear as a PipeWire media session. Use `roon-proton endpoint release` if
the controller has closed while the core is still playing or another app needs
the device.

To install and activate the optional direct endpoint:

```sh
roon-proton endpoint install
roon-proton endpoint mode direct
```

The desktop, system, and direct modes are mutually exclusive in one user session. Both
components use the same RAATServer rendezvous; when native Bridge is running,
the Windows controller can connect to it instead of starting its own local
output server. Switch back with `roon-proton endpoint mode desktop`, then relaunch
Roon.

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
is available for diagnosis. The launcher disables Wine's incomplete
`wminet_utils` helper, but the pinned Proton path remains the tested default.

If Roon replaces one of its mutable download URLs, installation stops safely
until the package maintainer reviews the new artifact and publishes updated
hashes.

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
