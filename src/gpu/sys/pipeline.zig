const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const BindGroupLayout = @import("bind_group.zig").BindGroupLayout;

const DepthStencilState = types.DepthStencilState;
const MultisampleState = types.MultisampleState;
const VertexState = types.VertexState;
const PrimitiveState = types.PrimitiveState;
const FragmentState = types.FragmentState;
const ProgrammableStageDescriptor = types.ProgrammableStageDescriptor;

pub const PipelineLayout = opaque {
    pub const Descriptor = struct {
        label: [:0]const u8 = "unnamed",
        bind_group_layouts: []const *BindGroupLayout = &.{},
    };

    pub inline fn setLabel(self: *PipelineLayout, label: [:0]const u8) void {
        const layout: *impl.PipelineLayout = @alignCast(@ptrCast(self));
        layout.setLabel(label);
    }

    pub inline fn reference(self: *PipelineLayout) void {
        const layout: *impl.PipelineLayout = @alignCast(@ptrCast(self));
        layout.manager.reference();
    }

    pub inline fn release(self: *PipelineLayout) void {
        const layout: *impl.PipelineLayout = @alignCast(@ptrCast(self));
        layout.manager.release();
    }
};

pub const RenderPipeline = opaque {
    pub const Descriptor = struct {
        label: [:0]const u8 = "unnamed",
        layout: ?*PipelineLayout = null,
        vertex: VertexState,
        primitive: PrimitiveState = .{},
        depth_stencil: ?*const DepthStencilState = null,
        multisample: MultisampleState = .{},
        fragment: ?*const FragmentState = null,
    };

    pub inline fn getBindGroupLayout(self: *RenderPipeline, group_index: u32) *BindGroupLayout {
        const pipeline: *impl.RenderPipeline = @alignCast(@ptrCast(self));
        const layout = pipeline.getBindGroupLayout(group_index);
        return @ptrCast(layout);
    }

    pub inline fn setLabel(self: *RenderPipeline, label: [:0]const u8) void {
        const pipeline: *impl.RenderPipeline = @alignCast(@ptrCast(self));
        pipeline.setLabel(label);
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

pub const ComputePipeline = opaque {
    pub const Descriptor = extern struct {
        label: [:0]const u8 = "unnamed",
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
