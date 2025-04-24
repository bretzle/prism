const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;

const Surface = @import("surface.zig").Surface;
const Adapter = @import("adapter.zig").Adapter;

pub const Instance = opaque {
    pub const Descriptor = struct {};

    pub inline fn create(desc: Descriptor) !*Instance {
        const instance = try impl.Instance.create(desc);
        return @ptrCast(instance);
    }

    pub inline fn createSurface(self: *Instance, desc: Surface.Descriptor) !*Surface {
        const instance: *impl.Instance = @alignCast(@ptrCast(self));
        const surface = try impl.Surface.create(instance, desc);
        return @ptrCast(surface);
    }

    pub inline fn createAdapter(self: *Instance, desc: Adapter.Descriptor) !*Adapter {
        const instance: *impl.Instance = @alignCast(@ptrCast(self));
        const adapter = try impl.Adapter.create(instance, desc);
        return @ptrCast(adapter);
    }

    pub inline fn processEvents(self: *Instance) void {
        const instance: *impl.Instance = @alignCast(@ptrCast(self));
        _ = instance; // autofix
        unreachable;
    }

    pub inline fn reference(self: *Instance) void {
        const instance: *impl.Instance = @alignCast(@ptrCast(self));
        instance.manager.reference();
    }

    pub inline fn release(self: *Instance) void {
        const instance: *impl.Instance = @alignCast(@ptrCast(self));
        instance.manager.release();
    }
};
