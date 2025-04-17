const std = @import("std");
const platform = @import("platform/platform.zig");
const gpu = @import("gpu/gpu.zig");

pub var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();

pub const Prism = struct {
    ctx: ?*platform.Context,
    backend: ?gpu.Context,

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

    // pub fn createGPUDevice(self: *Prism, window: *platform.Window) !*GPUDevice {
    //     if (self.backend == null) self.backend = try .create(.d3d12);
    //     var backend_device = try self.backend.?.createDevice(window);
    //     errdefer backend_device.destroy();
    //     return try GPUDevice.create(window, backend_device);
    // }

    pub fn createGpuDevice(self: *Prism, window: *platform.Window) !*gpu.Device {
        if (self.backend == null) self.backend = try .create(.d3d12);
        return try self.backend.?.createDevice(window);
    }
};

// pub const Color = packed struct {
//     r: f32,
//     g: f32,
//     b: f32,
//     a: f32,
// };

// pub const LoadOp = enum { load, clear, dontcare };
// pub const StoreOp = enum { store, dontcare, resolve, resolve_and_store };
// pub const ColorTargetInfo = struct {
//     texture: *backend.Texture,
//     mip_level: u32 = 0,
//     layer_or_depth_plane: u32 = 0,
//     clear_color: Color,
//     load_op: LoadOp,
//     store_op: StoreOp,
//     resolve_texture: ?*backend.Texture = null,
//     resolve_mip_level: u32 = 0,
//     resolve_layer: u32 = 0,
//     cycle: bool = false,
//     cycle_resolve_texture: bool = false,
// };
