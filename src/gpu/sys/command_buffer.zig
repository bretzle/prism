const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;

pub const CommandBuffer = opaque {
    pub const Descriptor = struct {
        label: ?[:0]const u8 = null,
    };

    pub inline fn setLabel(self: *CommandBuffer, label: [:0]const u8) void {
        const buffer: *impl.CommandBuffer = @alignCast(@ptrCast(self));
        _ = buffer; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *CommandBuffer) void {
        const buffer: *impl.CommandBuffer = @alignCast(@ptrCast(self));
        buffer.manager.reference();
    }

    pub inline fn release(self: *CommandBuffer) void {
        const buffer: *impl.CommandBuffer = @alignCast(@ptrCast(self));
        buffer.manager.release();
    }
};
