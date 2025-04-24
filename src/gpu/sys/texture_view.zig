const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const Texture = @import("texture.zig").Texture;

pub const TextureView = opaque {
    pub const Dimension = enum { undefined, @"1d", @"2d", @"2d_array", cube, cube_array, @"3d" };

    pub const Descriptor = struct {
        label: ?[:0]const u8 = null,
        format: Texture.Format = .undefined,
        dimension: Dimension = .undefined,
        base_mip_level: u32 = 0,
        mip_level_count: u32 = types.mip_level_count_undefined,
        base_array_layer: u32 = 0,
        array_layer_count: u32 = types.array_layer_count_undefined,
        aspect: Texture.Aspect = .all,
    };

    pub inline fn setLabel(self: *TextureView, label: [:0]const u8) void {
        const view: *impl.TextureView = @alignCast(@ptrCast(self));
        _ = view; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *TextureView) void {
        const view: *impl.TextureView = @alignCast(@ptrCast(self));
        view.manager.reference();
    }

    pub inline fn release(self: *TextureView) void {
        const view: *impl.TextureView = @alignCast(@ptrCast(self));
        view.manager.release();
    }
};
