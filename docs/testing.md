# Compatibility testing

## 2026-08-13: variable-rate PipeWire endpoint playback

The former system-output route kept the capture half of `snd-aloop` open at
48 kHz. Roon then tried to open the playback half for a 44.1 kHz/16-bit track,
and ALSA rejected `snd_pcm_hw_params_set_rate` with `EINVAL`; RAAT returned
`FORMAT_NOT_SUPPORTED` before playback could start.

Package release 0.2.0-9 keeps the first Loopback PCM as the stable Roon zone
identity but rewrites its saved output to `plug:pipewire` with software volume.
Live verification on `benji` completed setup, buffering, and playback for PCM
44.1 kHz/16-bit stereo. PipeWire exposed the active `mono-sgen` stream with both
channels connected to `MassiveEQ — Filbert`, and logged no PipeWire or
WirePlumber errors. A regression test verifies the settings transformation and
the endpoint transition order.

## 2026-08-13: Roon controller update under Proton

Roon build 1671 successfully checked for build 1683 and downloaded its Windows
installer, but the installer crashed under Proton with exit code `-1073741819`
(`0xC0000005`). Package release 0.2.0-7 could extract the verified payload, but
left the root launchers pointing at build 1671. Starting the stale launcher then
removed the newly extracted build during its normal version cleanup.

The corrected package update path stops the managed controller, installs the
numbered payload, and activates the root `Roon.exe` and `RAATServer.exe`
launchers for that build. A regression test checks build selection, app-host
path activation, configuration, and version metadata. Live verification on
`benji` started Roon 2.71 build 1683 through GE-Proton10-34; the controller
reported machine version `207101683` and the update status `UpToDate`.

## 2026-07-20: RAAT discovery recovery and endpoint handoff

On the `benji` Arch laptop, neither native Bridge nor the Proton-hosted Windows
RAATServer appeared in Roon while existing network zones remained usable. A
restart of the official Roon Server container on `sanchez` restored discovery,
which identifies stale Core-side RAAT discovery state rather than MassiveEQ or
the laptop audio route as the original outage.

A separate mode-transition defect was reproduced: if the Windows RAATServer
already owned the shared rendezvous, `roonbridge-native.service` could be active
without a native RAATServer child. The corrected transition stops all managed
UMU/Proton launchers, drains the Wine prefix, and then restarts native Bridge.
The live verification left one controller launcher and one native RAATServer.
The Core connected over LAN and Tailscale, enumerated and enabled Loopback PCM,
then completed setup and playback start at PCM 48 kHz, 32-bit, stereo.

## 2026-07-10: native Wayland hardware

On an x86_64 CachyOS/Arch laptop running Niri and PipeWire, Roon build 1671
remained running under UMU 1.4 and GE-Proton10-34 through XWayland. Fonts, album
art, colors, scaling, library/core connectivity, and animation-settled captures
rendered correctly. Native Proton 10 Wayland failed to create Roon's second GL
context. Wine/Proton 11 aborts in the unimplemented
`wminet_utils.GetErrorInfo` function.

The Windows RAAT endpoint created PipeWire streams but advertised an empty
WASAPI format set and rejected playback setup. The supported endpoint design is
therefore the official native Linux Roon Bridge. After the LAN firewall rule was
enabled, the core discovered the `benji` bridge and its ALC295 analog codec.
Playback was verified at PCM 48 kHz, 32-bit, stereo: RAAT completed setup,
created the stream, opened `hw:CARD=Generic_1,DEV=0`, and reported `Playing`
without underruns or errors. This path uses direct ALSA hardware access rather
than a PipeWire sink input.

## 2026-07-10: packaging and virtual runtime

Host: Apple Silicon macOS 26.5.1. Test data and VM disks were stored on an
external NVMe volume.

### Passed

- Clean x86_64 Arch container build with current repositories.
- All `PKGBUILD` source checksums.
- Dependency-aware build and package installation in a full x86_64 Arch VM.
- License installed at `/usr/share/licenses/roon-wine/LICENSE`.
- PipeWire 1.6.7, WirePlumber, and `pipewire-pulse` user services active.
- Pulse protocol available through PipeWire at `/run/user/501/pulse/native`.
- Weston 15 headless compositor created a working Wayland socket.
- Wine 11.12 started under full-system QEMU without the segmentation fault seen
  under QEMU user-mode container emulation.

### Not certified by this environment

- Wine prefix initialization did not complete within ten minutes under
  full-system software emulation. It remained in Wine's initial `wine.inf`
  registration step and was stopped cleanly.
- The Roon installer and .NET runtime were therefore not completed.
- Roon rendering, server discovery, and audio-zone playback were not tested.
- A virtual audio server confirms the software route exists, but cannot verify
  physical-device behavior, exclusivity, latency, or bit-perfect output.

These remaining checks require a physical x86_64 Arch host. Results from QEMU
software emulation should not be treated as evidence of a Wine compatibility
failure on native hardware.

## Release smoke test

On a physical x86_64 Arch Wayland system:

```sh
yay -Bi --needed .
roon-wine install
roon-wine doctor
roon-wine run
```

Confirm all of the following before declaring a release stable:

1. Roon renders with correct colors and scaling.
2. Roon discovers and connects to the server.
3. The Linux desktop appears as an audio zone.
4. Playback succeeds through the native endpoint's `plug:pipewire` output.
5. The Roon signal path and PipeWire device route match expectations.
6. Native Wayland and XWayland fallback both launch.
