const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const Buffer = @import("buffer.zig").Buffer;
const ComputePipeline = @import("pipeline.zig").ComputePipeline;
const BindGroup = @import("bind_group.zig").BindGroup;
const RenderPipeline = @import("pipeline.zig").RenderPipeline;
const Texture = @import("texture.zig").Texture;
const QuerySet = @import("query_set.zig").QuerySet;

const Color = types.Color;
const IndexFormat = types.IndexFormat;

pub const RenderPassEncoder = opaque {
    pub inline fn beginOcclusionQuery(self: *RenderPassEncoder, query_index: u32) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = query_index; // autofix
        unreachable;
    }

    /// Default `instance_count`: 1
    /// Default `first_vertex`: 0
    /// Default `first_instance`: 0
    pub inline fn draw(self: *RenderPassEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) !void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        try encoder.draw(vertex_count, instance_count, first_vertex, first_instance);
    }

    /// Default `instance_count`: 1
    /// Default `first_index`: 0
    /// Default `base_vertex`: 0
    /// Default `first_instance`: 0
    pub inline fn drawIndexed(self: *RenderPassEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = index_count; // autofix
        _ = instance_count; // autofix
        _ = first_index; // autofix
        _ = base_vertex; // autofix
        _ = first_instance; // autofix
        unreachable;
    }

    pub inline fn drawIndexedIndirect(self: *RenderPassEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = indirect_buffer; // autofix
        _ = indirect_offset; // autofix
        unreachable;
    }

    pub inline fn drawIndirect(self: *RenderPassEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = indirect_buffer; // autofix
        _ = indirect_offset; // autofix
        unreachable;
    }

    pub inline fn end(self: *RenderPassEncoder) !void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        try encoder.end();
    }

    pub inline fn endOcclusionQuery(self: *RenderPassEncoder) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        unreachable;
    }

    pub inline fn executeBundles(self: *RenderPassEncoder, bundles: []*const RenderBundle) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = bundles; // autofix
        unreachable;
    }

    pub inline fn insertDebugMarker(self: *RenderPassEncoder, marker_label: [:0]const u8) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = marker_label; // autofix
        unreachable;
    }

    pub inline fn popDebugGroup(self: *RenderPassEncoder) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        unreachable;
    }

    pub inline fn pushDebugGroup(self: *RenderPassEncoder, group_label: [:0]const u8) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = group_label; // autofix
        unreachable;
    }

    /// Default `dynamic_offsets_count`: 0
    /// Default `dynamic_offsets`: `null`
    pub inline fn setBindGroup(self: *RenderPassEncoder, group_index: u32, group: *BindGroup, dynamic_offsets: ?[]const u32) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = group_index; // autofix
        _ = group; // autofix
        _ = dynamic_offsets; // autofix
        unreachable;
    }

    pub inline fn setBlendConstant(self: *RenderPassEncoder, color: *const Color) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = color; // autofix
        unreachable;
    }

    /// Default `offset`: 0
    /// Default `size`: `gpu.whole_size`
    pub inline fn setIndexBuffer(self: *RenderPassEncoder, buffer: *Buffer, format: IndexFormat, offset: u64, size: u64) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = buffer; // autofix
        _ = format; // autofix
        _ = offset; // autofix
        _ = size; // autofix
        unreachable;
    }

    pub inline fn setPipeline(self: *RenderPassEncoder, pipeline_: *RenderPipeline) !void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        const pipeline: *impl.RenderPipeline = @alignCast(@ptrCast(pipeline_));
        try encoder.setPipeline(pipeline);
    }

    pub inline fn setScissorRect(self: *RenderPassEncoder, x: u32, y: u32, width: u32, height: u32) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = x; // autofix
        _ = y; // autofix
        _ = width; // autofix
        _ = height; // autofix
        unreachable;
    }

    pub inline fn setStencilReference(self: *RenderPassEncoder, _reference: u32) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = _reference; // autofix
        unreachable;
    }

    /// Default `offset`: 0
    /// Default `size`: `gpu.whole_size`
    pub inline fn setVertexBuffer(self: *RenderPassEncoder, slot: u32, buffer: *Buffer, offset: u64, size: u64) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = slot; // autofix
        _ = buffer; // autofix
        _ = offset; // autofix
        _ = size; // autofix
        unreachable;
    }

    pub inline fn setViewport(self: *RenderPassEncoder, x: f32, y: f32, width: f32, height: f32, min_depth: f32, max_depth: f32) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = x; // autofix
        _ = y; // autofix
        _ = width; // autofix
        _ = height; // autofix
        _ = min_depth; // autofix
        _ = max_depth; // autofix
        unreachable;
    }

    pub inline fn writeTimestamp(self: *RenderPassEncoder, query_set: *QuerySet, query_index: u32) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = query_set; // autofix
        _ = query_index; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *RenderPassEncoder, label: [:0]const u8) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *RenderPassEncoder) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        encoder.manager.reference();
    }

    pub inline fn release(self: *RenderPassEncoder) void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        encoder.manager.release();
    }
};

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

    pub inline fn insertDebugMarker(self: *ComputePassEncoder, marker_label: [:0]const u8) void {
        _ = self; // autofix
        _ = marker_label; // autofix
        unreachable;
    }

    pub inline fn popDebugGroup(self: *ComputePassEncoder) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn pushDebugGroup(self: *ComputePassEncoder, group_label: [:0]const u8) void {
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

pub const RenderBundleEncoder = opaque {
    pub const Descriptor = extern struct {
        label: ?[:0]const u8 = null,
        color_formats: ?[]const Texture.Format = null,
        depth_stencil_format: Texture.Format = .undefined,
        sample_count: u32 = 1,
        depth_read_only: bool = false,
        stencil_read_only: bool = false,
    };

    /// Default `instance_count`: 1
    /// Default `first_vertex`: 0
    /// Default `first_instance`: 0
    pub inline fn draw(self: *RenderBundleEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) void {
        _ = self; // autofix
        _ = vertex_count; // autofix
        _ = instance_count; // autofix
        _ = first_vertex; // autofix
        _ = first_instance; // autofix
        unreachable;
    }

    /// Default `instance_count`: 1
    /// Default `first_index`: 0
    /// Default `base_vertex`: 0
    /// Default `first_instance`: 0
    pub inline fn drawIndexed(self: *RenderBundleEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) void {
        _ = self; // autofix
        _ = index_count; // autofix
        _ = instance_count; // autofix
        _ = first_index; // autofix
        _ = base_vertex; // autofix
        _ = first_instance; // autofix
        unreachable;
    }

    pub inline fn drawIndexedIndirect(self: *RenderBundleEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void {
        _ = self; // autofix
        _ = indirect_buffer; // autofix
        _ = indirect_offset; // autofix
        unreachable;
    }

    pub inline fn drawIndirect(self: *RenderBundleEncoder, indirect_buffer: *Buffer, indirect_offset: u64) void {
        _ = self; // autofix
        _ = indirect_buffer; // autofix
        _ = indirect_offset; // autofix
        unreachable;
    }

    pub inline fn finish(self: *RenderBundleEncoder, descriptor: ?*const RenderBundle.Descriptor) *RenderBundle {
        _ = self; // autofix
        _ = descriptor; // autofix
        unreachable;
    }

    pub inline fn insertDebugMarker(self: *RenderBundleEncoder, marker_label: [:0]const u8) void {
        _ = self; // autofix
        _ = marker_label; // autofix
        unreachable;
    }

    pub inline fn popDebugGroup(self: *RenderBundleEncoder) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn pushDebugGroup(self: *RenderBundleEncoder, group_label: [:0]const u8) void {
        _ = self; // autofix
        _ = group_label; // autofix
        unreachable;
    }

    /// Default `dynamic_offsets`: `null`
    pub inline fn setBindGroup(self: *RenderBundleEncoder, group_index: u32, group: *BindGroup, dynamic_offsets: ?[]const u32) void {
        _ = self; // autofix
        _ = group_index; // autofix
        _ = group; // autofix
        _ = dynamic_offsets; // autofix
        unreachable;
    }

    /// Default `offset`: 0
    /// Default `size`: `gpu.whole_size`
    pub inline fn setIndexBuffer(self: *RenderBundleEncoder, buffer: *Buffer, format: IndexFormat, offset: u64, size: u64) void {
        _ = self; // autofix
        _ = buffer; // autofix
        _ = format; // autofix
        _ = offset; // autofix
        _ = size; // autofix
        unreachable;
    }

    pub inline fn setPipeline(self: *RenderBundleEncoder, pipeline: *RenderPipeline) void {
        _ = self; // autofix
        _ = pipeline; // autofix
        unreachable;
    }

    /// Default `offset`: 0
    /// Default `size`: `gpu.whole_size`
    pub inline fn setVertexBuffer(self: *RenderBundleEncoder, slot: u32, buffer: *Buffer, offset: u64, size: u64) void {
        _ = self; // autofix
        _ = slot; // autofix
        _ = buffer; // autofix
        _ = offset; // autofix
        _ = size; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *RenderBundleEncoder, label: [:0]const u8) void {
        _ = self; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *RenderBundleEncoder) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn release(self: *RenderBundleEncoder) void {
        _ = self; // autofix
        unreachable;
    }
};
