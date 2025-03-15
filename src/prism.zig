const std = @import("std");
const root = @import("root");
const platform = @import("platform/win32.zig");

pub const gpu = @import("gpu.zig");
pub const file = @import("file.zig");
pub const math = @import("math.zig");
pub const input = @import("input.zig");
pub const Color = @import("Color.zig").Color;

pub const allocator: std.mem.Allocator = if (@hasDecl(root, "allocator"))
    root.allocator
else
    std.heap.smp_allocator;

pub const Config = struct {
    window: struct {
        name: [:0]const u8 = "prism",
        size: math.Point = .{ .x = 800, .y = 600 },
        resizable: bool = true,
    } = .{},
    video: struct {
        vsync: bool = true,
    } = .{},
};

pub fn Application(comptime T: type) type {
    return struct {
        const Self = @This();

        config: Config,
        userdata: T = undefined,

        is_running: bool,
        is_exiting: bool,
        is_minimized: bool,

        impl: platform.Application(Self),
        input: input.Input = .{},

        pub fn create(config: Config) !*Self {
            const self = try allocator.create(Self);
            errdefer allocator.destroy(self);

            self.* = .{
                .config = config,
                .userdata = undefined,
                .is_running = true,
                .is_exiting = false,
                .is_minimized = false,
                .impl = undefined,
            };

            // initialize platform
            try self.impl.init();

            // initialize audio

            // initialize graphics
            try gpu.init(.{ .x = 800, .y = 600 }, self.impl.hwnd);

            // apply any flags

            // input + poll the platform once

            // startup
            try self.userdata.init();

            return self;
        }

        pub fn run(self: *Self) void {
            // display window
            self.impl.ready();

            // main loop
            while (!self.is_exiting) {
                self.step();
            }

            // TODO shutdown
        }

        pub fn start(config: Config) !void {
            const self = try create(config);
            self.run();
        }

        fn step(self: *Self) void {
            self.impl.step();

            if (!self.is_minimized) {
                if (std.meta.hasMethod(T, "update")) self.userdata.update(self);

                gpu.resizeFramebuffer(self.getSize());
                self.userdata.render();
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
}

test {
    std.testing.refAllDeclsRecursive(gpu);
    std.testing.refAllDeclsRecursive(file);
}
