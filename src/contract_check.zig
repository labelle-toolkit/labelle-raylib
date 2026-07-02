//! Compile-proof that this backend satisfies labelle-core's contracts
//! (labelle-assembler#502). Mirrors the check the assembler emits into every
//! generated main.zig (assembler src/codegen/blocks/imports.zig).
const core = @import("labelle_core");
const window = @import("window");
const input = @import("input");
const gfx = @import("gfx");

comptime {
    // Decl-shape proof: the required method NAMES exist.
    core.assertWindow(window);
    core.assertInput(input);
    core.assertBackend(gfx);

    // Type/signature proof: instantiate the typed wrappers the generated adapter
    // actually uses, so a decl whose SIGNATURE drifts from the contract value
    // types (e.g. a backend re-exporting its own DecodedImage ABI) fails HERE
    // rather than only later in a generated game (codex/#502 review). Compile-only
    // — no runtime, no file I/O.
    _ = core.Window(window);
    _ = core.InputInterface(input);
    _ = core.Backend(gfx);
}

// Loop-style backend: shouldQuit must be present (drives ownsLoop() and the
// splice's loop-vs-callback entry choice, in step with manifest loop_style).
comptime {
    if (!@hasDecl(window, "shouldQuit")) @compileError("loop-style backend must declare shouldQuit");
}

test "behavioral window conformance" {
    try core.conformance.runWindowSuite(window);
}
