const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const TextureView = @import("texture_view.zig").TextureView;
const Origin2D = types.Origin2D;
const Extent2D = types.Extent2D;

pub const ExternalTexture = opaque {
    // pub const BindingEntry = extern struct {
    //     chain: ChainedStruct = .{ .next = null, .s_type = .external_texture_binding_entry },
    //     external_texture: *ExternalTexture,
    // };

    // pub const BindingLayout = extern struct {
    //     chain: ChainedStruct = .{ .next = null, .s_type = .external_texture_binding_layout },
    // };

    pub const Rotation = enum { @"0", @"90", @"180", @"270" };

    pub const Descriptor = extern struct {
        label: ?[:0]const u8 = null,
        plane0: *TextureView,
        plane1: ?*TextureView = null,
        visible_origin: Origin2D,
        visible_size: Extent2D,
        do_yuv_to_rgb_conversion_only: bool = false,
        yuv_to_rgb_conversion_matrix: ?*const [12]f32 = null,
        src_transform_function_parameters: *const [7]f32,
        dst_transform_function_parameters: *const [7]f32,
        gamut_conversion_matrix: *const [9]f32,
        flip_y: bool,
        rotation: Rotation,
    };

    pub inline fn destroy(self: *ExternalTexture) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *ExternalTexture, label: [:0]const u8) void {
        _ = self; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *ExternalTexture) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn release(self: *ExternalTexture) void {
        _ = self; // autofix
        unreachable;
    }
};
