const std = @import("std");
const prism = @import("../prism.zig");
const platform = @import("../platform/platform.zig");

const allocator = prism.allocator;

pub const Implementation = enum { d3d12 };

pub const Backend = struct {
    ptr: *anyopaque,
    vtable: struct {
        destroy: *const fn (*anyopaque) void,
        create_device: *const fn (*anyopaque, window: *platform.Window) anyerror!Device,
    },

    pub fn create(comptime impl: Implementation) !Backend {
        _ = impl; // autofix
        unreachable;
    }

    pub fn destroy(self: *Backend) void {
        (self.vtable.destroy)(self.ptr);
    }

    pub fn createDevice(self: *Backend, window: *platform.Window) !Device {
        return try (self.vtable.create_device)(self.ptr, window);
    }
};

pub const Device = struct {
    ptr: *anyopaque,
    vtable: struct {
        destroy: *const fn (*anyopaque) void,
    },

    pub fn destroy(self: *Device) void {
        (self.vtable.destroy)(self.ptr);
    }
};
