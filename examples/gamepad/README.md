# Gamepad input demo (raylib + imgui)

A small reference demo for the LaBelle toolkit's gamepad support. It shows
connected gamepads, reacts live to connect / disconnect, and displays which
buttons are pressed plus stick / trigger values — all in a Dear ImGui HUD.

## What it exercises

- **Engine input-mixin gamepad forwarders** (engine ≥ 1.65.0):
  `game.isGamepadAvailable(id)`, `game.isGamepadButtonDown(id, btn)`,
  `game.isGamepadButtonPressed(id, btn)`, `game.getGamepadAxisValue(id, axis)`.
- **Engine gamepad hotplug events** `gamepad_connected` / `gamepad_disconnected`
  (handled in `hooks/gamepad_hooks.zig`) to capture each device's name + type
  hint, which polling alone can't surface.
- **raylib gamepad backend** polling (`pollGamepadEvents`, `isGamepad*`).

## How state is displayed

`scripts/gamepad_hud.zig` (`drawGui`) runs every frame and, for each of the
up-to-4 raylib gamepad slots:

- polls `isGamepadAvailable` to build the live connected list (hotplug-aware);
- shows a clean empty state ("No gamepad connected - plug one in") when none
  are present;
- per connected pad, draws a collapsible panel titled `Pad <id>: <name> [<type>]`
  (name / type from the connect event via `scripts/connected_pads.zig`);
- highlights pressed buttons in green vs. grey idle — face buttons (A/B/X/Y),
  d-pad, shoulders (LB/RB), thumbs (L3/R3), select/start;
- renders left/right stick X/Y and the analog triggers (LT/RT) as bars.

## Run it

```sh
labelle run                 # generate + build + run (raylib desktop)
labelle run --timeout=10s   # auto-quit (handy for CI / screenshots)
```

Or the raw recipe the CI uses:

```sh
labelle generate
cd .labelle/raylib_desktop && zig build
./zig-out/bin/game
```

## Notes

- The HUD is drawn with the `imgui` GUI plugin (rlImGui raylib bridge). It
  uses the assembler's **bundled** plugin
  (`.gui = .{ .path = "../../../labelle-assembler/plugins/imgui" }`), not the
  published `labelle-imgui` package: only the bundled copy pins the rlImGui
  raylib bridge at a Zig-0.16-compatible raylib-zig (6.0.0). The published
  package's raylib bridge still pins raylib-zig 5.6.0-dev, whose build.zig
  uses APIs removed in Zig 0.16 (`std.mem.trimLeft` /
  `std.process.getEnvVarOwned`). The script reaches the full cimgui API via
  `@import("gui_backend").ig`.
- The raylib backend itself is THIS repo (`backend_package` `local:../..`),
  so the example builds the repo's own backend source. `core`/`engine`/`gfx`
  are pinned to released versions and fetched on demand.
