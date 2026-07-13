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

## Quick install from the AUR

`umu-launcher` is in Arch's `multilib` repository. CachyOS normally enables it,
but a fresh plain-Arch installation may not. If `yay` reports that
`umu-launcher` cannot be found, uncomment these two lines in `/etc/pacman.conf`
and run `sudo pacman -Syu` before continuing:

```ini
[multilib]
Include = /etc/pacman.d/mirrorlist
```

On a minimal Arch installation, pacman may also ask which Vulkan providers to
install for UMU. Select the entries matching the actual GPU—typically
`vulkan-radeon`/`lib32-vulkan-radeon` for AMD,
`vulkan-intel`/`lib32-vulkan-intel` for Intel, or the matching NVIDIA packages.
Do not blindly accept the first provider, which may target different hardware.

On a PipeWire desktop, install the package and run the automated setup with:

```sh
yay -S roon-proton
sudo modprobe snd-aloop pcm_substreams=1
roon-proton setup
```

The package makes `snd-aloop` load automatically on future boots; the `modprobe`
command only makes it available immediately after the first installation. After
a reboot, only `roon-proton setup` is needed. That command installs Roon in the
user account, configures the recommended endpoint, and launches the controller.

For a controller-only installation, a PulseAudio desktop, or a system without
systemd user services, use `roon-proton setup desktop`. This package does not
silently replace PulseAudio with PipeWire. The desktop-following System Output
mode requires the optional `pipewire-audio`, `pipewire-pulse`, and `wireplumber`
packages; install them deliberately if the system does not already use them.

Pacman cannot safely perform the per-user setup itself: package install hooks run
as root, while the proprietary Roon download, prefix, services, and GUI belong to
the logged-in desktop user. Keeping that boundary also prevents the AUR package
from redistributing Roon.

When Roon opens, go to **Settings → Audio**, enable the first **Loopback PCM**,
and name it **System Output (PipeWire)**. Leave the second Loopback PCM disabled.
That is the only manual audio step. This zone follows the output selected by the
Linux desktop, including speakers, wired headphones, USB audio, and Bluetooth.

Package page: [AUR — roon-proton](https://aur.archlinux.org/packages/roon-proton)

### Temporary GitHub fallback

If the new package has not reached your AUR helper's search index yet, build the
same package directly from its GitHub checkout:

```sh
sudo pacman -S --needed git base-devel
git clone --depth=1 https://github.com/massiveadam/roon-wine.git
cd roon-wine
yay -Bi --needed .
```

Then continue with `modprobe` and `roon-proton setup` from the main installation
block above.

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

## Compatibility status

The current evidence and remaining gaps are:

- **CachyOS, Niri, Wayland + XWayland:** live-tested controller, tiling, and
  PipeWire System Output on the Framework laptop.
- **Plain Arch x86_64:** the complete dependency transaction, clean package
  build, package install, UMU 1.4.0 compatibility path, and CLI diagnostics are
  tested in a current Arch container with `multilib` enabled. A container cannot
  validate a real GPU, compositor, Bluetooth device, or sound card.
- **Traditional X11:** selected automatically when `XDG_SESSION_TYPE=x11`; the
  environment and failure paths are tested, but the Roon UI has not yet been
  live-tested in a real X11 login.
- **GNOME, KDE Plasma, Sway, and Hyprland:** expected to use the same XWayland
  controller path. Niri and Hyprland rules are included; only Niri has been
  live-tested. Other compositors use their normal window behavior.
- **EndeavourOS and Garuda:** expected to follow the plain-Arch requirements,
  including `multilib`, but are not yet live-tested.
- **Manjaro:** best-effort only. Its repositories can lag Arch; the package now
  requires UMU 1.4.0 or newer rather than accepting an untested older launcher.
- **Artix/non-systemd:** controller-only mode is the supported path. The native
  endpoint automation uses systemd user services and now exits with a clear
  explanation instead of failing midway.
- **PulseAudio-only systems:** controller-only mode is supported without forcing
  an audio-stack replacement. PipeWire System Output is unavailable until the
  user deliberately migrates to PipeWire.
- **Forced native Wayland:** experimental. The tested Proton build fails Roon's
  second OpenGL context there, so `auto` deliberately chooses XWayland.

Roon Server is out of scope because Roon provides a native Linux build. This
package manages the desktop controller and can install the official native Roon
Bridge as the recommended local audio endpoint.

## Updating or removing

An AUR installation updates normally through `yay`:

```sh
yay -Syu
```

If you used the temporary GitHub checkout, update it with:

```sh
cd roon-wine
git pull --ff-only
yay -Bi --needed .
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
roon-proton setup [system|desktop|direct] install, configure, and launch Roon
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

Arch currently ships UMU 1.4.0, whose command-launcher service can end the Roon
process as soon as the launcher returns. The package includes a narrow 1.4.0
compatibility runner that disables that service, matching upstream UMU 1.4.1's
default behavior. The current Roon NSIS bootstrapper also crashes under Proton;
the package therefore extracts its bundled 64-bit controller directly after
verifying the complete upstream installer against the pinned SHA-512 hash.

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

The container enables Arch `multilib`, resolves every hard dependency, builds
and installs the package, and runs its CLI smoke test without installing system
Wine. A full Roon test requires an x86_64 Linux VM with a graphical desktop and
audio devices; containers cannot faithfully exercise that path.

On the development Mac, the dedicated Colima runtime is stored under
`/Volumes/NVMe/Roon Arch Linux Test`. The test automatically uses that runtime
when its Docker socket is available. Set `ROON_ARCH_DOCKER_SOCKET` to override
the socket path; on other systems the active Docker context is used.

See [docs/architecture.md](docs/architecture.md) for design boundaries and the
planned test matrix. See [docs/testing.md](docs/testing.md) for recorded results
and the physical-hardware release smoke test. See
[docs/window-managers.md](docs/window-managers.md) for tested Niri and Hyprland
tiling rules.
