const std = @import("std");
const platform = @import("platform/win32.zig");

pub const math = @import("math.zig");
pub const Color = @import("Color.zig").Color;
pub const Batch = @import("Batch.zig");

pub const gpu = @import("gpu.zig");

pub const Flags = packed struct {
    // fixed_timestamp: bool = false,
    // vsync: bool = false,
    // fullscreen: bool = false,
    // resizable: bool = false,
    // audio_enabled: bool = false,

    pub const defaults = Flags{};
};

pub const Config = struct {
    name: [:0]const u8 = "prism",
    size: math.Point = .{ .x = 800, .y = 600 },
    target_framerate: u32 = 60,
    audio_frequency: u32 = 44100,
    flags: Flags = .defaults,
};

pub fn Application(comptime T: type) type {
    return struct {
        const Self = @This();

        config: Config,
        userdata: T = undefined,
        allocator: std.mem.Allocator,

        is_running: bool,
        is_exiting: bool,

        impl: platform.Application(Self, T),

        pub fn create(allocator: std.mem.Allocator, config: Config) !*Self {
            const self = try allocator.create(Self);
            errdefer allocator.destroy(self);

            self.* = .{
                .config = config,
                .userdata = undefined,
                .is_running = true,
                .is_exiting = false,
                .allocator = allocator,

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
            try self.userdata.init(self);

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

        fn step(self: *Self) void {
            self.impl.step();
            if (std.meta.hasMethod(T, "update")) self.userdata.update();

            gpu.resizeFramebuffer(self.getSize());
            self.userdata.render(self);
            gpu.commit();
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
}
