const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;

const BindGroupLayout = @import("bind_group_layout.zig").BindGroupLayout;

pub const PipelineLayout = opaque {
    pub const Descriptor = struct {
        label: ?[:0]const u8 = null,
        bind_group_layouts: []const *BindGroupLayout = &.{},
    };

    pub inline fn setLabel(self: *PipelineLayout, label: [:0]const u8) void {
        _ = self; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *PipelineLayout) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn release(self: *PipelineLayout) void {
        _ = self; // autofix
        unreachable;
    }
};
