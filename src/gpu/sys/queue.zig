const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const CommandBuffer = @import("command.zig").CommandBuffer;
const Buffer = @import("buffer.zig").Buffer;
const Texture = @import("texture.zig").Texture;

const ImageCopyTexture = types.ImageCopyTexture;
const ImageCopyExternalTexture = types.ImageCopyExternalTexture;
const Extent3D = types.Extent3D;
const CopyTextureForBrowserOptions = types.CopyTextureForBrowserOptions;

pub const Queue = opaque {
    pub const WorkDoneCallback = *const fn (status: WorkDoneStatus, userdata: ?*anyopaque) void;

    pub const WorkDoneStatus = enum { success, err, unknown, device_lost };

    pub const Descriptor = struct {
        label: [:0]const u8 = "unnamed",
    };

    pub inline fn copyExternalTextureForBrowser(self: *Queue, source: *const ImageCopyExternalTexture, destination: *const ImageCopyTexture, copy_size: *const Extent3D, options: *const CopyTextureForBrowserOptions) void {
        const queue: *impl.Queue = @alignCast(@ptrCast(self));
        _ = queue; // autofix
        _ = source; // autofix
        _ = destination; // autofix
        _ = copy_size; // autofix
        _ = options; // autofix
        unreachable;
    }

    pub inline fn copyTextureForBrowser(self: *Queue, source: *const ImageCopyTexture, destination: *const ImageCopyTexture, copy_size: *const Extent3D, options: *const CopyTextureForBrowserOptions) void {
        const queue: *impl.Queue = @alignCast(@ptrCast(self));
        _ = queue; // autofix
        _ = source; // autofix
        _ = destination; // autofix
        _ = copy_size; // autofix
        _ = options; // autofix
        unreachable;
    }

    pub inline fn onSubmittedWorkDone(
        self: *Queue,
        signal_value: u64,
        context: anytype,
        comptime callback: fn (ctx: @TypeOf(context), status: WorkDoneStatus) callconv(.Inline) void,
    ) void {
        const queue: *impl.Queue = @alignCast(@ptrCast(self));
        _ = queue; // autofix
        _ = signal_value; // autofix
        _ = callback; // autofix
        unreachable;
    }

    pub inline fn submit(self: *Queue, commands_: []const *const CommandBuffer) !void {
        const queue: *impl.Queue = @alignCast(@ptrCast(self));
        const commands: []const *impl.CommandBuffer = @ptrCast(commands_[0..]);
        try queue.submit(commands);
    }

    pub inline fn writeBuffer(self: *Queue, buffer: *Buffer, buffer_offset_bytes: u64, data_slice: anytype) void {
        const queue: *impl.Queue = @alignCast(@ptrCast(self));
        _ = queue; // autofix
        _ = buffer; // autofix
        _ = buffer_offset_bytes; // autofix
        _ = data_slice; // autofix
        unreachable;
    }

    pub inline fn writeTexture(self: *Queue, destination: *const ImageCopyTexture, data_layout: *const Texture.DataLayout, write_size: *const Extent3D, data_slice: anytype) void {
        const queue: *impl.Queue = @alignCast(@ptrCast(self));
        _ = queue; // autofix
        _ = destination; // autofix
        _ = data_layout; // autofix
        _ = write_size; // autofix
        _ = data_slice; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *Queue, label: [:0]const u8) void {
        const queue: *impl.Queue = @alignCast(@ptrCast(self));
        queue.setLabel(label);
    }

    pub inline fn reference(self: *Queue) void {
        const queue: *impl.Queue = @alignCast(@ptrCast(self));
        queue.manager.reference();
    }

    pub inline fn release(self: *Queue) void {
        const queue: *impl.Queue = @alignCast(@ptrCast(self));
        queue.manager.release();
    }
};
