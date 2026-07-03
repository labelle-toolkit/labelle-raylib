//! Connected-pad identity registry.
//!
//! Live button/axis state comes from polling the engine forwarders each
//! frame (see `gamepad_hud.zig`), but polling can't surface the *device
//! name* or *type hint* — those only arrive on the engine `gamepad_connected`
//! event. The hook in `hooks/gamepad_hooks.zig` writes them here on connect
//! and clears them on disconnect; the HUD reads them back via `nameFor` /
//! `typeHintFor`.
//!
//! Process-global fixed array (raylib tracks at most 4 slots). No allocator,
//! no lifecycle — a slot is "known" only between its connect and disconnect
//! events.

const MAX_GAMEPADS: usize = 4;
const NAME_CAP: usize = 64;

const Entry = struct {
    known: bool = false,
    // NAME_CAP name bytes + 1 reserved for the sentinel NUL, so `name[name_len]`
    // (name_len ≤ NAME_CAP) is always in bounds for the `[:0]` slice in `nameFor`.
    // A plain [NAME_CAP]u8 panicked (safe) / was UB (ReleaseFast) on a device
    // name that exactly filled it — the sentinel read `name[NAME_CAP]` off the end.
    name: [NAME_CAP + 1]u8 = [_]u8{0} ** (NAME_CAP + 1),
    name_len: usize = 0,
    type_hint: [:0]const u8 = "unknown",
};

var entries: [MAX_GAMEPADS]Entry = [_]Entry{.{}} ** MAX_GAMEPADS;

/// Record a connect: store the device name + type hint for `id`.
pub fn record(id: u32, name: []const u8, type_hint: [:0]const u8) void {
    if (id >= MAX_GAMEPADS) return;
    var e = &entries[id];
    e.known = true;
    const n = @min(name.len, NAME_CAP);
    @memcpy(e.name[0..n], name[0..n]);
    e.name[n] = 0; // sentinel NUL — always in bounds (buffer is NAME_CAP + 1)
    e.name_len = n;
    e.type_hint = type_hint;
}

/// Forget a disconnected pad.
pub fn forget(id: u32) void {
    if (id >= MAX_GAMEPADS) return;
    entries[id] = .{};
}

/// Best-known device name for `id`. Falls back to a generic label when the
/// pad is live (polling says available) but no connect event was captured —
/// e.g. a pad already plugged in at launch on a backend that reports it via
/// a one-shot the demo missed.
pub fn nameFor(id: u32) [:0]const u8 {
    if (id >= MAX_GAMEPADS) return "Gamepad";
    const e = &entries[id];
    if (!e.known or e.name_len == 0) return "Gamepad";
    // `record` wrote the sentinel NUL at `name[name_len]`, and the buffer
    // reserves room for it (NAME_CAP + 1), so this slice never reads off the end.
    return e.name[0..e.name_len :0];
}

/// Type hint string for `id` (e.g. "xbox", "playstation", "unknown").
pub fn typeHintFor(id: u32) [:0]const u8 {
    if (id >= MAX_GAMEPADS) return "unknown";
    return entries[id].type_hint;
}
