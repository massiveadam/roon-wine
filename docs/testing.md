# Compatibility testing

## 2026-07-10: native Wayland hardware

On an x86_64 CachyOS/Arch laptop running Niri, PipeWire, and native Wayland,
Roon build 1671 remained running under UMU 1.4 and GE-Proton11-1, reached normal
update/network activity, and rendered with Wayland app ID `roon.exe`. The same
build aborts under system Wine 11.12 in the unimplemented
`wminet_utils.GetErrorInfo` function. Installing the legacy .NET Framework 4.x
chain was rejected as a default because it was slow, error-prone, and did not
address the Wine implementation gap.

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
4. Playback succeeds through `pipewire-pulse`.
5. The Roon signal path and PipeWire device route match expectations.
6. Native Wayland and XWayland fallback both launch.
