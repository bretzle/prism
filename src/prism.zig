const std = @import("std");
const builtin = @import("builtin");
const root = @import("root");

const platform = switch (builtin.os.tag) {
    .windows => @import("platform/win32.zig"),
    else => unreachable,
};

pub const gpu = @import("gpu.zig");
pub const file = @import("file.zig");
pub const math = @import("math.zig");
pub const input = @import("input.zig");
pub const Color = @import("Color.zig").Color;
pub const ui = @import("oui.zig");

pub const allocator: std.mem.Allocator = if (@hasDecl(root, "allocator"))
    root.allocator
else if (builtin.is_test)
    std.testing.allocator
else
    std.heap.smp_allocator;

pub const log = std.log.scoped(.prism);

pub const Icon = struct {
    width: u16,
    height: u16,
    pixels: []const u8,
};

pub const Config = struct {
    // window
    title: [:0]const u8 = "prism",
    size: math.Point = .{ .x = 800, .y = 600 },
    resizable: bool = true,
    fullscreen: bool = false,
    enable_clipboard: bool = false,
    enable_dragndrop: bool = false,
    image: ?Icon = null,

    // video
    enable_gpu: bool = true,
    vsync: bool = true,

    // audio
    enable_audio: bool = true,
};

pub const Application = struct {
    const Self = @This();

    config: Config,

    is_running: bool,
    is_exiting: bool,
    is_minimized: bool,

    impl: platform.Application,
    input: input.Input = .{},

    pub fn start(self: *Application, config: Config) !void {
        self.* = .{
            .config = config,
            .is_running = true,
            .is_exiting = false,
            .is_minimized = false,
            .impl = undefined,
        };

        // initialize platform
        try self.impl.init();

        // initialize graphics
        if (config.enable_gpu) try gpu.init(config.size, config.vsync, self.impl.hwnd);

        // initialize audio
        if (config.enable_audio) {} // TODO

        // startup
        try root.init();

        // display window
        self.impl.ready();

        // main loop
        while (!self.is_exiting) {
            self.step();
        }

        // root.cleanup();
        // gpu.cleanup();
        // self.impl.cleanup();
        // allocator.destroy(self);
        // self.* = undefined;
    }

    fn step(self: *Self) void {
        self.impl.step();

        if (!self.is_minimized) {
            root.update();

            gpu.resizeFramebuffer(self.getSize());
            root.render();
            gpu.commit();
        }

        self.input.step();
    }

    pub fn exit(self: *Self) void {
        if (!self.is_exiting and self.is_running) {
            self.is_exiting = true;
        }
    }

    pub fn getSize(self: *const Self) math.Point {
        return self.impl.getSize();
    }
};

test {
    std.testing.refAllDeclsRecursive(gpu);
    std.testing.refAllDeclsRecursive(file);
    std.testing.refAllDeclsRecursive(ui);
}
