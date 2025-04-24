const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const Texture = @import("texture.zig").Texture;
const Buffer = @import("buffer.zig").Buffer;
const BindGroup = @import("bind_group.zig").BindGroup;
const RenderPipeline = @import("render_pipeline.zig").RenderPipeline;
const RenderBundle = @import("render_bundle.zig").RenderBundle;

const IndexFormat = types.IndexFormat;

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
