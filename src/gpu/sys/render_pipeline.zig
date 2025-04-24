const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const PipelineLayout = @import("pipeline_layout.zig").PipelineLayout;
const BindGroupLayout = @import("bind_group_layout.zig").BindGroupLayout;

const DepthStencilState = types.DepthStencilState;
const MultisampleState = types.MultisampleState;
const VertexState = types.VertexState;
const PrimitiveState = types.PrimitiveState;
const FragmentState = types.FragmentState;

pub const RenderPipeline = opaque {
    pub const Descriptor = struct {
        label: ?[:0]const u8 = null,
        layout: ?*PipelineLayout = null,
        vertex: VertexState,
        primitive: PrimitiveState = .{},
        depth_stencil: ?*const DepthStencilState = null,
        multisample: MultisampleState = .{},
        fragment: ?*const FragmentState = null,
    };

    pub inline fn getBindGroupLayout(self: *RenderPipeline, group_index: u32) *BindGroupLayout {
        const pipeline: *impl.RenderPipeline = @alignCast(@ptrCast(self));
        _ = pipeline; // autofix
        _ = group_index; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *RenderPipeline, label: [:0]const u8) void {
        const pipeline: *impl.RenderPipeline = @alignCast(@ptrCast(self));
        _ = pipeline; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *RenderPipeline) void {
        const pipeline: *impl.RenderPipeline = @alignCast(@ptrCast(self));
        pipeline.manager.reference();
    }

    pub inline fn release(self: *RenderPipeline) void {
        const pipeline: *impl.RenderPipeline = @alignCast(@ptrCast(self));
        pipeline.manager.release();
    }
};
