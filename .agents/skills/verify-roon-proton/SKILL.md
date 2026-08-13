---
name: verify-roon-proton
description: Verify the Roon Proton controller, native RAAT ownership, and shared PipeWire System Output route on a live Arch desktop.
---

# Verify Roon Proton

## Launch

Run from the repository root on the logged-in desktop user's machine. Use the
checkout launcher while reviewing unreleased changes:

```sh
bash ./roon-wine doctor
```

For an installed release, use `roon-proton doctor` instead.

## Doctor

Run `./.agents/skills/verify-roon-proton/verify-system-output.sh`. It is
read-only and checks the native service, RAAT port owner, saved PipeWire output,
and legacy relay state.

## Drive

To exercise the user path, run `bash ./roon-wine endpoint mode system`, relaunch
the controller with `roon-proton run`, select **System Output (PipeWire)**, and
play a 44.1 kHz stereo track. Do not drive an unknown shared Roon instance.

## Evidence

Capture all of these before calling the route clean:

- RAAT logs show `opening [plug:pipewire]`, a `start` request, and `Playing`.
- `wpctl status` shows `PipeWire ALSA [mono-sgen]` linked to the intended sink or
  filter on both channels.
- `pw-top` reports zero errors for the active Roon and downstream nodes.
- The old `roon-system-output.service` is inactive.

## Cleanup

The doctor script makes no changes. After a driven check, leave the controller
and native endpoint running. Stop only scratch log watchers created for the
check; do not stop playback, reset Roon settings, or restart PipeWire unless the
user asks.

## Main features

- Controller launch and Roon Server connection.
- Pinned controller update activation.
- Native RAAT endpoint ownership of TCP 9200.
- Shared PipeWire System Output at common source rates.
- Desktop sink switching and filter routing, including MassiveEQ when present.
- Direct ALSA mode as an opt-in alternative.
