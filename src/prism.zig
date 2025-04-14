const std = @import("std");
const platform = @import("platform/platform.zig");
const backend = @import("graphics/backend.zig");

pub var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();

pub const Prism = struct {
    ctx: ?*platform.Context,
    backend: ?backend.Backend,

    pub fn create() !Prism {
        return .{
            .ctx = null,
            .backend = null,
        };
    }

    pub fn destroy(self: *Prism) void {
        if (self.ctx) |ctx| ctx.destroy();
        if (self.backend) |_| self.backend.?.destroy();
    }

    pub fn createWindow(self: *Prism, width: u32, height: u32, title: []const u8) !*platform.Window {
        if (self.ctx == null) self.ctx = try platform.Context.create();
        return try self.ctx.?.createWindow(title, width, height);
    }

    pub fn createGPUDevice(self: *Prism, window: *platform.Window) !*GPUDevice {
        if (self.backend == null) self.backend = try .create(.d3d12);
        var backend_device = try self.backend.?.createDevice(window);
        errdefer backend_device.destroy();
        return try GPUDevice.create(window, backend_device);
    }
};

pub const GPUDevice = struct {
    window: *platform.Window,
    backend: backend.Device,

    fn create(window: *platform.Window, backend_device: backend.Device) !*GPUDevice {
        const self = try allocator.create(GPUDevice);
        self.* = .{ .window = window, .backend = backend_device };
        return self;
    }

    pub fn destroy(self: *GPUDevice) void {
        self.backend.destroy();
        allocator.destroy(self);
    }

    pub fn acquireCommandBuffer(self: *GPUDevice) !*backend.CommandBuffer {
        _ = self; // autofix
        unreachable;
    }
};
