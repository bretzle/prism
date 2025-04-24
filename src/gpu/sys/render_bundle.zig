const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;

pub const RenderBundle = opaque {
    pub const Descriptor = struct {
        label: ?[:0]const u8 = null,
    };

    pub inline fn setLabel(self: *RenderBundle, label: [:0]const u8) void {
        _ = self; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *RenderBundle) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn release(self: *RenderBundle) void {
        _ = self; // autofix
        unreachable;
    }
};
