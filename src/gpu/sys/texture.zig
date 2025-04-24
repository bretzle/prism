const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const Origin2D = types.Origin2D;
const Extent2D = types.Extent2D;
const Extent3D = types.Extent3D;

pub const Texture = opaque {
    pub const Aspect = enum { all, stencil_only, depth_only, plane0_only, plane1_only };

    pub const Dimension = enum { @"1d", @"2d", @"3d" };

    pub const SampleType = enum { undefined, float, unfilterable_float, depth, sint, uint };

    pub const Format = enum {
        undefined,
        r8_unorm,
        r8_snorm,
        r8_uint,
        r8_sint,
        r16_uint,
        r16_sint,
        r16_float,
        rg8_unorm,
        rg8_snorm,
        rg8_uint,
        rg8_sint,
        r32_float,
        r32_uint,
        r32_sint,
        rg16_uint,
        rg16_sint,
        rg16_float,
        rgba8_unorm,
        rgba8_unorm_srgb,
        rgba8_snorm,
        rgba8_uint,
        rgba8_sint,
        bgra8_unorm,
        bgra8_unorm_srgb,
        rgb10_a2_unorm,
        rg11_b10_ufloat,
        rgb9_e5_ufloat,
        rg32_float,
        rg32_uint,
        rg32_sint,
        rgba16_uint,
        rgba16_sint,
        rgba16_float,
        rgba32_float,
        rgba32_uint,
        rgba32_sint,
        stencil8,
        depth16_unorm,
        depth24_plus,
        depth24_plus_stencil8,
        depth32_float,
        depth32_float_stencil8,
        bc1_rgba_unorm,
        bc1_rgba_unorm_srgb,
        bc2_rgba_unorm,
        bc2_rgba_unorm_srgb,
        bc3_rgba_unorm,
        bc3_rgba_unorm_srgb,
        bc4_runorm,
        bc4_rsnorm,
        bc5_rg_unorm,
        bc5_rg_snorm,
        bc6_hrgb_ufloat,
        bc6_hrgb_float,
        bc7_rgba_unorm,
        bc7_rgba_unorm_srgb,
        etc2_rgb8_unorm,
        etc2_rgb8_unorm_srgb,
        etc2_rgb8_a1_unorm,
        etc2_rgb8_a1_unorm_srgb,
        etc2_rgba8_unorm,
        etc2_rgba8_unorm_srgb,
        eacr11_unorm,
        eacr11_snorm,
        eacrg11_unorm,
        eacrg11_snorm,
        astc4x4_unorm,
        astc4x4_unorm_srgb,
        astc5x4_unorm,
        astc5x4_unorm_srgb,
        astc5x5_unorm,
        astc5x5_unorm_srgb,
        astc6x5_unorm,
        astc6x5_unorm_srgb,
        astc6x6_unorm,
        astc6x6_unorm_srgb,
        astc8x5_unorm,
        astc8x5_unorm_srgb,
        astc8x6_unorm,
        astc8x6_unorm_srgb,
        astc8x8_unorm,
        astc8x8_unorm_srgb,
        astc10x5_unorm,
        astc10x5_unorm_srgb,
        astc10x6_unorm,
        astc10x6_unorm_srgb,
        astc10x8_unorm,
        astc10x8_unorm_srgb,
        astc10x10_unorm,
        astc10x10_unorm_srgb,
        astc12x10_unorm,
        astc12x10_unorm_srgb,
        astc12x12_unorm,
        astc12x12_unorm_srgb,
        r8_bg8_biplanar420_unorm,
    };

    pub const UsageFlags = packed struct(u32) {
        copy_src: bool = false,
        copy_dst: bool = false,
        texture_binding: bool = false,
        storage_binding: bool = false,
        render_attachment: bool = false,
        transient_attachment: bool = false,
        _padding: u26 = 0,

        pub const none = UsageFlags{};
    };

    pub const BindingLayout = struct {
        sample_type: SampleType = .undefined,
        view_dimension: TextureView.Dimension = .undefined,
        multisampled: bool = false,
    };

    pub const DataLayout = struct {
        offset: u64 = 0,
        bytes_per_row: u32 = types.copy_stride_undefined,
        rows_per_image: u32 = types.copy_stride_undefined,
    };

    pub const Descriptor = struct {
        label: ?[:0]const u8 = null,
        usage: UsageFlags,
        dimension: Dimension = .@"2d",
        size: Extent3D,
        format: Format,
        mip_level_count: u32 = 1,
        sample_count: u32 = 1,
        view_formats: ?[]const Format = null,
    };

    pub inline fn createView(self: *Texture, desc: ?TextureView.Descriptor) *TextureView {
        _ = self; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub inline fn destroy(self: *Texture) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn getDepthOrArrayLayers(self: *Texture) u32 {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn getDimension(self: *Texture) Dimension {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn getFormat(self: *Texture) Format {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn getHeight(self: *Texture) u32 {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn getMipLevelCount(self: *Texture) u32 {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn getSampleCount(self: *Texture) u32 {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn getUsage(self: *Texture) UsageFlags {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn getWidth(self: *Texture) u32 {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *Texture, label: [:0]const u8) void {
        _ = self; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *Texture) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn release(self: *Texture) void {
        _ = self; // autofix
        unreachable;
    }
};

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

pub const ExternalTexture = opaque {
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
