# labelle-raylib

The **raylib** rendering backend for the [labelle](https://github.com/labelle-toolkit) 2D engine, as an **out-of-tree pluggable backend** (labelle-assembler#386).

Loop-style. Desktop (raylib-zig) + WASM (emscripten). Desktop gamepad via the shared windowless-SDL source (`labelle-sdl-gamepad`); desktop-Linux routes through labelle-core's udev/evdev source. Audio via raylib's device + the shared `labelle-audio-decode`.

## Use it
```zig
.backend = .raylib,
.backend_package = .{ .name = "raylib", .repo = "github.com/labelle-toolkit/labelle-raylib", .version = "0.1.0" },
```
(With the default-flip, `.backend = .raylib` resolves here automatically.)

## Layout
- `src/` — the four backend modules (gfx/window/input/audio) + `slot_alloc.zig`
- `backend.manifest.zon` + `build_fragments/` — drive the assembler's manifest-splice codegen (desktop; WASM uses the assembler's enum path)
- `templates/desktop.txt` — the generated run-loop

## Build
```sh
zig build test   # slot-allocator + host tests (Linux; raylib-zig's xcode-frameworks dep doesn't fetch on macOS runners)
```
