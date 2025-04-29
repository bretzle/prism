const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const ComputePassEncoder = @import("pass.zig").ComputePassEncoder;
const RenderPassEncoder = @import("pass.zig").RenderPassEncoder;
const Buffer = @import("buffer.zig").Buffer;
const QuerySet = @import("query_set.zig").QuerySet;

const RenderPassDescriptor = types.RenderPassDescriptor;
const ComputePassDescriptor = types.ComputePassDescriptor;
const ImageCopyBuffer = types.ImageCopyBuffer;
const ImageCopyTexture = types.ImageCopyTexture;
const Extent3D = types.Extent3D;

pub const CommandBuffer = opaque {
    pub const Descriptor = struct {
        label: [:0]const u8 = "unnamed",
    };

    pub inline fn setLabel(self: *CommandBuffer, label: [:0]const u8) void {
        const buffer: *impl.CommandBuffer = @alignCast(@ptrCast(self));
        buffer.setLabel(label);
    }

    pub inline fn reference(self: *CommandBuffer) void {
        const buffer: *impl.CommandBuffer = @alignCast(@ptrCast(self));
        buffer.manager.reference();
    }

    pub inline fn release(self: *CommandBuffer) void {
        const buffer: *impl.CommandBuffer = @alignCast(@ptrCast(self));
        buffer.manager.release();
    }
};

pub const CommandEncoder = opaque {
    pub const Descriptor = struct {
        label: [:0]const u8 = "unnamed",
    };

    pub inline fn beginComputePass(self: *CommandEncoder, desc: ?ComputePassDescriptor) *ComputePassEncoder {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub inline fn beginRenderPass(self: *CommandEncoder, desc: RenderPassDescriptor) !*RenderPassEncoder {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        const render_pass = try encoder.beginRenderPass(desc);
        return @ptrCast(render_pass);
    }

    /// Default `offset`: 0
    /// Default `size`: `gpu.whole_size`
    pub inline fn clearBuffer(self: *CommandEncoder, buffer: *Buffer, offset: u64, size: u64) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = buffer; // autofix
        _ = offset; // autofix
        _ = size; // autofix
        unreachable;
    }

    pub inline fn copyBufferToBuffer(self: *CommandEncoder, source: *Buffer, source_offset: u64, destination: *Buffer, destination_offset: u64, size: u64) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = source; // autofix
        _ = source_offset; // autofix
        _ = destination; // autofix
        _ = destination_offset; // autofix
        _ = size; // autofix
        unreachable;
    }

    pub inline fn copyBufferToTexture(self: *CommandEncoder, source: *const ImageCopyBuffer, destination: *const ImageCopyTexture, copy_size: *const Extent3D) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = source; // autofix
        _ = destination; // autofix
        _ = copy_size; // autofix
        unreachable;
    }

    pub inline fn copyTextureToBuffer(self: *CommandEncoder, source: *const ImageCopyTexture, destination: *const ImageCopyBuffer, copy_size: *const Extent3D) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = source; // autofix
        _ = destination; // autofix
        _ = copy_size; // autofix
        unreachable;
    }

    pub inline fn copyTextureToTexture(self: *CommandEncoder, source: *const ImageCopyTexture, destination: *const ImageCopyTexture, copy_size: *const Extent3D) !void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        try encoder.copyTextureToTexture(source, destination, copy_size);
    }

    pub inline fn finish(self: *CommandEncoder, desc: CommandBuffer.Descriptor) !*CommandBuffer {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        const command_buffer = try encoder.finish(desc);
        command_buffer.manager.reference();
        return @ptrCast(command_buffer);
    }

    pub inline fn injectValidationError(self: *CommandEncoder, message: [:0]const u8) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = message; // autofix
        unreachable;
    }

    pub inline fn insertDebugMarker(self: *CommandEncoder, marker_label: [:0]const u8) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = marker_label; // autofix
        unreachable;
    }

    pub inline fn popDebugGroup(self: *CommandEncoder) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        unreachable;
    }

    pub inline fn pushDebugGroup(self: *CommandEncoder, group_label: [:0]const u8) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = group_label; // autofix
        unreachable;
    }

    pub inline fn resolveQuerySet(self: *CommandEncoder, query_set: *QuerySet, first_query: u32, query_count: u32, destination: *Buffer, destination_offset: u64) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = query_set; // autofix
        _ = first_query; // autofix
        _ = query_count; // autofix
        _ = destination; // autofix
        _ = destination_offset; // autofix
        unreachable;
    }

    pub inline fn writeBuffer(self: *CommandEncoder, buffer: *Buffer, buffer_offset_bytes: u64, data_slice: anytype) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = buffer; // autofix
        _ = buffer_offset_bytes; // autofix
        _ = data_slice; // autofix
        unreachable;
    }

    pub inline fn writeTimestamp(self: *CommandEncoder, query_set: *QuerySet, query_index: u32) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        _ = encoder; // autofix
        _ = query_set; // autofix
        _ = query_index; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *CommandEncoder, label: [:0]const u8) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        encoder.setLabel(label);
    }

    pub inline fn reference(self: *CommandEncoder) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        encoder.manager.reference();
    }

    pub inline fn release(self: *CommandEncoder) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        encoder.manager.release();
    }
};
