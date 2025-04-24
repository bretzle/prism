const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const Buffer = @import("buffer.zig").Buffer;
const RenderBundle = @import("render_bundle.zig").RenderBundle;
const BindGroup = @import("bind_group.zig").BindGroup;
const RenderPipeline = @import("render_pipeline.zig").RenderPipeline;
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
