const std = @import("std");
const builtin = @import("builtin");

const platform = switch (builtin.target.os.tag) {
    .windows => @import("platform/win32.zig"),
    else => unreachable,
};

pub const gpu = @import("gpu/gpu.zig");
pub const gfx = @import("gfx/gfx.zig");
pub const math = @import("math/math.zig");
pub const time = @import("time.zig");

pub var gpa: std.heap.GeneralPurposeAllocator(.{}) = .init;
pub const allocator = if (builtin.mode == .Debug) gpa.allocator() else std.heap.smp_allocator;

pub const Application = struct {
    windows: std.ArrayListUnmanaged(*Window),
    state: enum { running } = .running,

    pub fn create() !Application {
        return .{ .windows = .empty };
    }

    pub fn deinit(_: *Application) void {
        // TODO
    }

    pub fn createWindow(self: *Application, desc: Window.Descriptor) !*Window {
        const win: *Window = @ptrCast(try platform.Window.create(self, desc));
        try self.windows.append(allocator, win);
        return win;
    }
};

pub const Window = opaque {
    pub const Descriptor = struct {
        title: []const u8 = "prism ❤️",
        width: u32 = 800,
        height: u32 = 600,
    };

    pub inline fn presentFrame(self: *Window) void {
        const window: *platform.Window = @alignCast(@ptrCast(self));
        return window.presentFrame();
    }

    pub inline fn getEvents(self: *Window) []const Event {
        const window: *platform.Window = @alignCast(@ptrCast(self));
        return window.getEvents();
    }

    pub inline fn width(self: *Window) u32 {
        const window: *platform.Window = @alignCast(@ptrCast(self));
        return window.width;
    }

    pub inline fn height(self: *Window) u32 {
        const window: *platform.Window = @alignCast(@ptrCast(self));
        return window.height;
    }

    pub inline fn aspectRatio(self: *Window) f32 {
        const window: *platform.Window = @alignCast(@ptrCast(self));
        return @as(f32, @floatFromInt(window.width)) / @as(f32, @floatFromInt(window.height));
    }

    pub inline fn getDevice(self: *Window) *gpu.Device {
        const window: *platform.Window = @alignCast(@ptrCast(self));
        return window.device;
    }

    pub inline fn getInstance(self: *Window) *gpu.Instance {
        const window: *platform.Window = @alignCast(@ptrCast(self));
        return window.instance;
    }

    pub inline fn getAdapter(self: *Window) *gpu.Adapter {
        const window: *platform.Window = @alignCast(@ptrCast(self));
        return window.adapter;
    }

    pub inline fn getQueue(self: *Window) *gpu.Queue {
        const window: *platform.Window = @alignCast(@ptrCast(self));
        return window.queue;
    }

    pub inline fn getSwapchain(self: *Window) *gpu.SwapChain {
        const window: *platform.Window = @alignCast(@ptrCast(self));
        return window.swapchain;
    }

    pub inline fn getSurface(self: *Window) *gpu.Surface {
        const window: *platform.Window = @alignCast(@ptrCast(self));
        return window.surface;
    }
};

pub const EventTag = enum {
    close,
    size,
    key_repeat,
    key_press,
    key_release,
    mouse_press,
    mouse_release,
    mouse_motion,
    mouse_scroll,
    focus_gained,
    focus_lost,
};

pub const Event = union(enum) {
    close,
    size: [2]u32,
    key_repeat: KeyEvent,
    key_press: KeyEvent,
    key_release: KeyEvent,
    mouse_press: MouseButtonEvent,
    mouse_release: MouseButtonEvent,
    mouse_motion: math.Vec2,
    mouse_scroll: math.Vec2,
    focus_gained,
    focus_lost,
};

pub const KeyEvent = struct {
    key: Key,
    mods: KeyMods,
};

pub const MouseButtonEvent = struct {
    button: MouseButton,
    mods: KeyMods,
    pos: math.Vec2,
};

pub const Key = enum {
    a,
    b,
    c,
    d,
    e,
    f,
    g,
    h,
    i,
    j,
    k,
    l,
    m,
    n,
    o,
    p,
    q,
    r,
    s,
    t,
    u,
    v,
    w,
    x,
    y,
    z,

    zero,
    one,
    two,
    three,
    four,
    five,
    six,
    seven,
    eight,
    nine,

    f1,
    f2,
    f3,
    f4,
    f5,
    f6,
    f7,
    f8,
    f9,
    f10,
    f11,
    f12,
    f13,
    f14,
    f15,
    f16,
    f17,
    f18,
    f19,
    f20,
    f21,
    f22,
    f23,
    f24,
    f25,

    kp_divide,
    kp_multiply,
    kp_subtract,
    kp_add,
    kp_0,
    kp_1,
    kp_2,
    kp_3,
    kp_4,
    kp_5,
    kp_6,
    kp_7,
    kp_8,
    kp_9,
    kp_decimal,
    kp_comma,
    kp_equal,
    kp_enter,

    enter,
    escape,
    tab,
    left_shift,
    right_shift,
    left_control,
    right_control,
    left_alt,
    right_alt,
    left_super,
    right_super,
    menu,
    num_lock,
    caps_lock,
    print,
    scroll_lock,
    pause,
    delete,
    home,
    end,
    page_up,
    page_down,
    insert,
    left,
    right,
    up,
    down,
    backspace,
    space,
    minus,
    equal,
    left_bracket,
    right_bracket,
    backslash,
    semicolon,
    apostrophe,
    comma,
    period,
    slash,
    grave,

    iso_backslash,
    international1,
    international2,
    international3,
    international4,
    international5,
    lang1,
    lang2,

    unknown,
};

pub const KeyMods = packed struct(u8) {
    shift: bool,
    control: bool,
    alt: bool,
    super: bool,
    caps_lock: bool,
    num_lock: bool,
    _: u2 = 0,
};

pub const MouseButton = enum {
    left,
    right,
    middle,
    four,
    five,
    six,
    seven,
    eight,
};

test {
    std.testing.refAllDecls(@This());
}
