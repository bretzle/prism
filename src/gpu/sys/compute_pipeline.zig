const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const PipelineLayout = @import("pipeline_layout.zig").PipelineLayout;
const BindGroupLayout = @import("bind_group_layout.zig").BindGroupLayout;

const ProgrammableStageDescriptor = types.ProgrammableStageDescriptor;

pub const ComputePipeline = opaque {
    pub const Descriptor = extern struct {
        label: ?[:0]const u8 = null,
        layout: ?*PipelineLayout = null,
        compute: ProgrammableStageDescriptor,
    };

    pub inline fn getBindGroupLayout(self: *ComputePipeline, group_index: u32) *BindGroupLayout {
        _ = self; // autofix
        _ = group_index; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *ComputePipeline, label: [:0]const u8) void {
        _ = self; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *ComputePipeline) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn release(self: *ComputePipeline) void {
        _ = self; // autofix
        unreachable;
    }
};
