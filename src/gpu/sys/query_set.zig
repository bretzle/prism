const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const QueryType = types.QueryType;
const PipelineStatisticName = types.PipelineStatisticName;

pub const QuerySet = opaque {
    pub const Descriptor = extern struct {
        label: ?[:0]const u8 = null,
        type: QueryType,
        count: u32,
        pipeline_statistics: ?[]const PipelineStatisticName = null,
    };

    pub inline fn destroy(self: *QuerySet) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn getCount(self: *QuerySet) u32 {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn getType(self: *QuerySet) QueryType {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *QuerySet, label: [:0]const u8) void {
        _ = self; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *QuerySet) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn release(self: *QuerySet) void {
        _ = self; // autofix
        unreachable;
    }
};
