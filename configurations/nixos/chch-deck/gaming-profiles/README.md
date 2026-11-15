# Steam Deck gaming profiles

Host-local integration for **chch-deck / Steam Deck LCD**, Jovian Game Mode and
ordinary Steam games. Emulator configuration is unchanged. No rebuild is needed
when a screen, charger or game changes.

## Configuration

Defaults live in [profiles.nix](profiles.nix); application code is separate.

| Active screen | Power | Game target | Physical output | Filter | APU cap |
| --- | --- | --- | --- | --- | --- |
| Internal | Battery | 1280×800 | 1280×800 | Linear, no enlargement | 12 W |
| Internal | External | 1280×800 | 1280×800 | Linear, no enlargement | 15 W |
| External | Battery | 1280×720 | 1920×1080, 60 Hz | Gamescope FSR | 12 W |
| External | External | 1600×900 | 1920×1080, 60 Hz | Gamescope FSR | 15 W |

Override individual fields in the host's NixOS configuration:

```nix
services.deck-gaming-profiles.settings = {
  profiles.handheld-battery.watts = 11;
  games = {
    "12345" = {
      resolution = {
        handheld = { width = 1280; height = 720; };
        external = { width = 1280; height = 720; };
      };
      power.battery = 15;
    };
    "67890" = {
      resolution.external = { width = 1920; height = 1080; };
      filter = "linear";
    };
  };
};
```

AppIDs above are examples, not bundled game exceptions. Unspecified fields keep
the selected base profile's values. `resolution.external` applies on either power
source; `power.battery` and `power.ac` are independent. Filters are `linear`,
`nearest` and `fsr`. Power is an integer number of watts, at most **15**; the
driver's bounds must also permit it. At 1:1 (including letterboxing) the
controller does not request FSR. The LCD's internal physical mode stays fixed at
1280×800 / 60 Hz; its rotated DRM mode can read as 800×1280. Handheld game
resolution is configurable independently.

To disable declaratively:

```nix
services.deck-gaming-profiles.enable = false;
```

Rebuild and reboot after enabling/disabling: this also installs/removes TDP
permissions on already-present hardware. For a temporary Game Mode pause, stop
the user controller; the power broker restores the previous limits:

```sh
systemctl --user stop deck-gaming-profiles.service
systemctl --user start deck-gaming-profiles.service
```

## One-time Steam and game setup

For each managed game, set its Steam launch options to:

```text
deck-gaming-profiles launch %command%
```

Select **Native** rather than a fixed resolution in Steam's game properties;
remove conflicting fixed-resolution launch arguments. In the game, select
borderless fullscreen/current desktop resolution when available. A game with
its own fixed-resolution setting needs that setting changed once, or its
documented resolution launch arguments. The wrapper does not edit game files,
invent engine-specific arguments, or change in-game upscalers/render scale.

The wrapper asks the already-running controller to expose the selected mode on
the game's actual Xwayland display **before** executing the original command.
It does not start a second compositor. Outside Game Mode it passes through.
If automation is unavailable, it reports the failure and starts the game anyway.
Without this launch option, system changes still work, but a game's startup
resolution is not guaranteed.

Live profile changes update the physical output, power cap, scaling and virtual
screen immediately. Games responding to RandR/borderless desktop resizing can
adapt; games that ignore it continue at their existing resolution. Their next
wrapped launch uses the new virtual mode. No game is forcibly restarted.

**A virtual screen size is not evidence of the game's frame size.** Even an X11
window size does not prove internal rendering resolution. Verify the output
swapchain/frame size with a compatible game's diagnostics or graphics overlay;
check internal render scale separately. Native Wayland games and games ignoring
the selected Xwayland mode require their own supported resolution mechanism.

## Ownership and session lifetime

The user controller belongs to `gamescope-session.target`, not the desktop's
generic graphical target. It reads Jovian's runtime `gamescope-environment`
handoff, including the actual `DISPLAY` and `GAMESCOPE_WAYLAND_DISPLAY`. The user
comes from `jovian.steam.user`. Polling re-reads actual state after hotplug, game
changes and wake, including devices already connected at startup. External power
uses power-supply `online`, not the battery's Charging status: full charge and
charge thresholds do not select the battery profile.

The controller owns game-mode resolution/scaling and APU caps. Leave Steam's
manual TDP limiter disabled and remove conflicting per-game resolution/scaling
overrides. Disable Decky TDP/power plugins and other privileged cap writers.
There is no safe way to arbitrate arbitrary root plugins. Steam still owns FPS
limits; automatic CPU/GPU clocks are untouched. This is neither overclocking nor
undervolting.

Failed TDP requests and individual display operations retry with capped
exponential backoff. Successful display submissions are not repeated just because
another operation failed. Recovery clears the corresponding stale error; resume
allows the current profile to be reapplied. Repeated TDP drift after a successful
correction is reported as a competing-writer conflict instead of starting a
continuous write fight; a target change or resume allows a new correction.

The correction budget belongs to the numeric watt target: switching between two
12 W profiles does not replenish it. The conflict message reports repeated drift,
not proof of a particular writer.

While enabled, unprivileged direct writes to AMDGPU `power1_cap`/`power2_cap` are
blocked; Steam's GPU-control permissions remain available. These permissions do
not exclude other root services or privileged D-Bus setters such as SteamOS
Manager's TDP interface. The broker accepts only bounded
numeric requests from the Jovian user, converts watts to microwatts, and verifies
both cap readbacks. Before its first change it saves the existing values. On
controller disconnect/Game Mode exit it restores those values, **not an assumed
maximum**. Root service cleanup also attempts recovery after failure. Niri thus
does not inherit a battery cap set by this controller. Read restoration errors
in the root service journal; a failed restoration is not reported as success.
Unprivileged direct TDP writes remain blocked in Niri while this module is enabled;
restoration returns the previous budget, not Steam's write permissions.

## Pinned Gamescope interfaces

The effective Jovian Gamescope is **3.17.0**, not Chaotic's separate Git package.
The implementation uses the existing embedded compositor:

- Active screen: `GAMESCOPE_DISPLAY_IS_EXTERNAL`; supported modes:
  `GAMESCOPE_DISPLAY_MODE_LIST_EXTERNAL`; display identity: `gamescopectl`.
- Physical output: the display's entry in `GAMESCOPE_MODE_SAVE_FILE`, followed
  by `GAMESCOPE_DISPLAY_MODE_NUDGE`. Existing unrelated entries and the optional
  broadcast-RGB field are preserved. This is separate from Xwayland resizing.
  Display identity follows Gamescope's exact key, including the trailing space
  in `"ACME "` when the manufacturer is known but the EDID model name is empty.
- Game display: `GAMESCOPE_XWAYLAND_MODE_CONTROL` with the correct server index.
  Read the index from that display's `GAMESCOPE_XWAYLAND_SERVER_ID` root
  property and require its `GAMESCOPE_PID` to match the controller's compositor.
  The pinned Jovian session starts two Xwayland servers. A display number such
  as `:1`, matching geometry, or a container's Wayland socket name is not proof
  of its index. Steam display environment variables are not required: Jovian
  starts Steam separately using a handoff that does not guarantee those values.
- Scaling: Gamescope scaling properties, aspect-preserving fit, and
  `GAMESCOPE_FSR_FEEDBACK` for FSR activity.
- Physical confirmation: read-only DRM connector/CRTC query, not the supported
  mode list or virtual desktop dimensions.

The external mode selector prefers the requested mode, otherwise a supported
mode within the configured width, height and refresh limits. It never chooses
4K just because a TV supports it. An unavailable safe mode is an error, not
permission to claim that 1080p was applied. Mode fallback and unconfirmed results
are visible in status/journal. Steam can also write compositor properties: avoid
conflicting settings rather than relying on a continuous write fight.
If a fallback output is smaller than the requested game mode, the virtual game
mode stays independent: FIT can downscale it without FSR. Only explicitly
configured game dimensions are requested; this never introduces an automatic
4K game target.

Source references for the current lock: Jovian
[`6d21db8`](https://github.com/Jovian-Experiments/Jovian-NixOS/tree/6d21db8ad755a73cc5df076e80fa80b714f555a6),
Gamescope [`3.17.0`](https://github.com/ValveSoftware/gamescope/tree/3.17.0)
(`src/steamcompmgr.cpp`, `src/Backends/DRMBackend.cpp`, `src/main.hpp`), and
Jovian's `pkgs/gamescope-session` environment/readiness integration. Recheck
these private interfaces when updating the lock.

## Status and logs

Run as the Jovian user, including from an SSH shell with its runtime directory:

```sh
deck-gaming-profiles status
journalctl --user -u deck-gaming-profiles.service -b
sudo journalctl -u deck-gaming-power.service -b
```

Status distinguishes detected screen/power/AppID, selected policy, requested
values, observed physical mode, virtual screen, X11 window size, FSR feedback,
power readbacks and errors. Unknown values are not confirmations. Always check
that the controller is running and the status is current.
An already-matching virtual geometry does not clear pending resolution while
the display mapping is unverified or the mode submission has failed. A verified
submission and matching virtual size still do not prove the game's frame size.
`game_mapping` reports the verified compositor PID and server index;
`virtual_resolution_submitted` separately reports the matching mode submission.

### Diagnosing unexplained TDP drift

Power diagnostics record events rather than every unchanged poll. The root
broker records authorized connection identity, snapshots, cap-write attempts and
readbacks, and restoration reasons/results. The controller records apply/retry/
correction decisions, connection changes and correction-budget exhaustion. Use
their monotonic timestamps and boot-scoped journals to correlate events:

```sh
journalctl --user -u deck-gaming-profiles.service -b -o short-monotonic
sudo journalctl -u deck-gaming-power.service -b -o short-monotonic
```

A write request or `cap-write-success` only establishes intent or a completed
write call, respectively; use `cap-readback` to check the observed values. The
broker can restore a baseline on connection loss without either service
restarting. Stable PIDs and an empty error journal therefore do not exclude
lease churn. These logs
can expose our own writes/restores, but cannot identify every external writer or
prove a firmware reset. Do not reset the guard or disable a service solely to
turn a failing acceptance result into a pass.

Deploying instrumentation and reproducing dock-power changes on a device require
separate approval. During an approved reproduction, retain both journals from
before the transition, current status and independent reads of both caps; keep
the existing correction policy unchanged. Narrow privileged writer/D-Bus tracing
is a separate diagnostic step if broker/controller events remain inconclusive.

## Software and device verification

Software checks (no Deck required):

```sh
nix eval .#nixosConfigurations.chch-deck.config.system.build.toplevel.drvPath
nix build .#nixosConfigurations.chch-deck.config.system.build.deck-gaming-profiles
nix flake check --no-build
nix develop -c pre-commit run --all-files
```

The runtime package runs its Python unit tests during its build. Source-backed
interfaces and mocked tests do **not** establish on-device acceptance.

On the Deck, rebuild/reboot, configure one compatible borderless Steam game as
above, then keep status and both journals open:

1. Internal/battery: expect game target 1280×800, both caps 12,000,000 µW.
2. Attach only power: same target, both caps 15,000,000 µW. Repeat at full charge
   or a charge threshold; the source must remain external power.
3. Attach a powered dock: confirm DRM output 1920×1080 near 60 Hz, target
   1600×900 and active FSR while a smaller frame is presented. Independently
   confirm the compatible game's actual output frame is 1600×900.
4. Remove power while keeping the screen: target 1280×720 / 12 W; verify a
   compatible game adapts. A non-adapting game must continue; exit and relaunch
   it through the wrapper and verify the new mode.
5. Remove the screen with and without power: expect handheld 800p with 15/12 W
   respectively. Repeat with an AppID override and after the game exits.
6. Open Steam's overlay; the running game's exception must not disappear.
   Start Game Mode already docked, suspend/resume, and repeat hotplug bursts.
7. Try a display lacking 1080p/60: inspect the supported fallback and actual
   DRM readback. A 4K TV must not cause 4K selection.
8. Record caps before entering Game Mode; exit to Niri and confirm controller
   stopped and both original values restored. Test stopping/restarting the
   controller and inspect restoration after a controller failure.
9. Check Steam FPS controls and automatic clocks still work; verify Steam cannot
   overwrite caps and no privileged Decky plugin is changing them.

Record these hardware results separately from successful software checks in the
PR; they have not been performed merely by building this package.
