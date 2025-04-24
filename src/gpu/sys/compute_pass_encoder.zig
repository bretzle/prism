const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;

const Buffer = @import("buffer.zig").Buffer;
const BindGroup = @import("bind_group.zig").BindGroup;
const ComputePipeline = @import("compute_pipeline.zig").ComputePipeline;
const QuerySet = @import("query_set.zig").QuerySet;

pub const ComputePassEncoder = opaque {
    pub inline fn dispatchWorkgroups(self: *ComputePassEncoder, x: u32, y: u32, z: u32) void {
        _ = self; // autofix
        _ = x; // autofix
        _ = y; // autofix
        _ = z; // autofix
        unreachable;
    }

    pub inline fn dispatchWorkgroupsIndirect(self: *ComputePassEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void {
        _ = self; // autofix
        _ = indirect_buffer; // autofix
        _ = indirect_offset; // autofix
        unreachable;
    }

    pub inline fn end(self: *ComputePassEncoder) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn insertDebugMarker(self: *ComputePassEncoder, marker_label: [*:0]const u8) void {
        _ = self; // autofix
        _ = marker_label; // autofix
        unreachable;
    }

    pub inline fn popDebugGroup(self: *ComputePassEncoder) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn pushDebugGroup(self: *ComputePassEncoder, group_label: [*:0]const u8) void {
        _ = self; // autofix
        _ = group_label; // autofix
        unreachable;
    }

    /// Default `dynamic_offsets`: null
    pub inline fn setBindGroup(self: *ComputePassEncoder, group_index: u32, group: *BindGroup, dynamic_offsets: ?[]const u32) void {
        _ = self; // autofix
        _ = group_index; // autofix
        _ = group; // autofix
        _ = dynamic_offsets; // autofix
        unreachable;
    }

    pub inline fn setPipeline(self: *ComputePassEncoder, pipeline: *ComputePipeline) void {
        _ = self; // autofix
        _ = pipeline; // autofix
        unreachable;
    }

    pub inline fn writeTimestamp(self: *ComputePassEncoder, query_set: *QuerySet, query_index: u32) void {
        _ = self; // autofix
        _ = query_set; // autofix
        _ = query_index; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *ComputePassEncoder, label: [:0]const u8) void {
        _ = self; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *ComputePassEncoder) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn release(self: *ComputePassEncoder) void {
        _ = self; // autofix
        unreachable;
    }
};
