const std = @import("std");
const builtin = @import("builtin");
const prism = @import("../prism.zig");

const w32 = @import("w32");

const backend = switch (builtin.os.tag) {
    .windows => @import("d3d12/d3d12.zig"),
    else => unreachable,
};

const allocator = prism.allocator;

pub const Instance = opaque {
    pub const Descriptor = struct {};

    pub fn create(desc: Instance.Descriptor) !*Instance {
        const instance = try backend.Instance.create(desc);
        return @ptrCast(instance);
    }

    pub fn createSurface(self: *Instance, desc: Surface.Descriptor) !*Surface {
        const instance: *backend.Instance = @alignCast(@ptrCast(self));
        const surface = try instance.createSurface(desc);
        return @ptrCast(surface);
    }

    pub fn createAdapter(self: *Instance, options: Adapter.Options) !*Adapter {
        const instance: *backend.Instance = @alignCast(@ptrCast(self));
        const adapter = try instance.createAdapter(options);
        return @ptrCast(adapter);
    }
};

pub const Adapter = opaque {
    pub const Type = enum { unknown, discrete_gpu, integrated_gpu };

    pub const Options = struct {
        surface: *Surface,
        power_preference: enum { efficent, performance },
    };

    pub const Properties = struct {
        vendor_id: u32,
        vendor_name: [*:0]const u8,
        architecture: [*:0]const u8,
        device_id: u32,
        name: [*:0]const u8,
        driver_description: [*:0]const u8,
        adapter_type: Type,
        backend_type: BackendType,
    };

    pub fn getProperties(self: *Adapter) Properties {
        const adapter: *backend.Adapter = @alignCast(@ptrCast(self));
        return adapter.getProperties();
    }

    pub fn createDevice(self: *Adapter, desc: Device.Descriptor) !*Device {
        const adapter: *backend.Adapter = @alignCast(@ptrCast(self));
        const device = try adapter.createDevice(desc);
        return @ptrCast(device);
    }
};

pub const Device = opaque {
    pub const Descriptor = struct {
        label: ?[*:0]const u8 = null,
    };

    pub fn getQueue(self: *Device) !*Queue {
        const device: *backend.Device = @alignCast(@ptrCast(self));
        const queue = try device.getQueue();
        queue.manager.reference();
        return @ptrCast(queue);
    }

    pub fn createSwapchain(self: *Device, surface_: *Surface, desc: SwapChain.Descriptor) !*SwapChain {
        const device: *backend.Device = @alignCast(@ptrCast(self));
        const surface: *backend.Surface = @alignCast(@ptrCast(surface_));
        const swapchain = try device.createSwapchain(surface, desc);
        return @ptrCast(swapchain);
    }
};

pub const Queue = opaque {};

pub const SwapChain = opaque {
    pub const Descriptor = struct {
        label: ?[*:0]const u8 = null,
        usage: Texture.UsageFlags,
        format: Texture.Format,
        width: u32,
        height: u32,
        present_mode: PresentMode,
    };

    pub fn present(self: *SwapChain) !void {
        const swapchain: *backend.SwapChain = @alignCast(@ptrCast(self));
        try swapchain.present();
    }
};

pub const Surface = opaque {
    pub const Descriptor = union {
        windows: struct { hwnd: w32.HWND },
    };
};

pub const Texture = opaque {
    pub const Aspect = enum(u32) {
        all,
        stencil_only,
        depth_only,
        plane0_only,
        plane1_only,
    };

    pub const Dimension = enum(u32) {
        @"1d",
        @"2d",
        @"3d",
    };

    pub const Format = enum(u32) {
        undefined = 0x00000000,
        r8_unorm = 0x00000001,
        r8_snorm = 0x00000002,
        r8_uint = 0x00000003,
        r8_sint = 0x00000004,
        r16_uint = 0x00000005,
        r16_sint = 0x00000006,
        r16_float = 0x00000007,
        rg8_unorm = 0x00000008,
        rg8_snorm = 0x00000009,
        rg8_uint = 0x0000000a,
        rg8_sint = 0x0000000b,
        r32_float = 0x0000000c,
        r32_uint = 0x0000000d,
        r32_sint = 0x0000000e,
        rg16_uint = 0x0000000f,
        rg16_sint = 0x00000010,
        rg16_float = 0x00000011,
        rgba8_unorm = 0x00000012,
        rgba8_unorm_srgb = 0x00000013,
        rgba8_snorm = 0x00000014,
        rgba8_uint = 0x00000015,
        rgba8_sint = 0x00000016,
        bgra8_unorm = 0x00000017,
        bgra8_unorm_srgb = 0x00000018,
        rgb10_a2_unorm = 0x00000019,
        rg11_b10_ufloat = 0x0000001a,
        rgb9_e5_ufloat = 0x0000001b,
        rg32_float = 0x0000001c,
        rg32_uint = 0x0000001d,
        rg32_sint = 0x0000001e,
        rgba16_uint = 0x0000001f,
        rgba16_sint = 0x00000020,
        rgba16_float = 0x00000021,
        rgba32_float = 0x00000022,
        rgba32_uint = 0x00000023,
        rgba32_sint = 0x00000024,
        stencil8 = 0x00000025,
        depth16_unorm = 0x00000026,
        depth24_plus = 0x00000027,
        depth24_plus_stencil8 = 0x00000028,
        depth32_float = 0x00000029,
        depth32_float_stencil8 = 0x0000002a,
        bc1_rgba_unorm = 0x0000002b,
        bc1_rgba_unorm_srgb = 0x0000002c,
        bc2_rgba_unorm = 0x0000002d,
        bc2_rgba_unorm_srgb = 0x0000002e,
        bc3_rgba_unorm = 0x0000002f,
        bc3_rgba_unorm_srgb = 0x00000030,
        bc4_runorm = 0x00000031,
        bc4_rsnorm = 0x00000032,
        bc5_rg_unorm = 0x00000033,
        bc5_rg_snorm = 0x00000034,
        bc6_hrgb_ufloat = 0x00000035,
        bc6_hrgb_float = 0x00000036,
        bc7_rgba_unorm = 0x00000037,
        bc7_rgba_unorm_srgb = 0x00000038,
        etc2_rgb8_unorm = 0x00000039,
        etc2_rgb8_unorm_srgb = 0x0000003a,
        etc2_rgb8_a1_unorm = 0x0000003b,
        etc2_rgb8_a1_unorm_srgb = 0x0000003c,
        etc2_rgba8_unorm = 0x0000003d,
        etc2_rgba8_unorm_srgb = 0x0000003e,
        eacr11_unorm = 0x0000003f,
        eacr11_snorm = 0x00000040,
        eacrg11_unorm = 0x00000041,
        eacrg11_snorm = 0x00000042,
        astc4x4_unorm = 0x00000043,
        astc4x4_unorm_srgb = 0x00000044,
        astc5x4_unorm = 0x00000045,
        astc5x4_unorm_srgb = 0x00000046,
        astc5x5_unorm = 0x00000047,
        astc5x5_unorm_srgb = 0x00000048,
        astc6x5_unorm = 0x00000049,
        astc6x5_unorm_srgb = 0x0000004a,
        astc6x6_unorm = 0x0000004b,
        astc6x6_unorm_srgb = 0x0000004c,
        astc8x5_unorm = 0x0000004d,
        astc8x5_unorm_srgb = 0x0000004e,
        astc8x6_unorm = 0x0000004f,
        astc8x6_unorm_srgb = 0x00000050,
        astc8x8_unorm = 0x00000051,
        astc8x8_unorm_srgb = 0x00000052,
        astc10x5_unorm = 0x00000053,
        astc10x5_unorm_srgb = 0x00000054,
        astc10x6_unorm = 0x00000055,
        astc10x6_unorm_srgb = 0x00000056,
        astc10x8_unorm = 0x00000057,
        astc10x8_unorm_srgb = 0x00000058,
        astc10x10_unorm = 0x00000059,
        astc10x10_unorm_srgb = 0x0000005a,
        astc12x10_unorm = 0x0000005b,
        astc12x10_unorm_srgb = 0x0000005c,
        astc12x12_unorm = 0x0000005d,
        astc12x12_unorm_srgb = 0x0000005e,
        r8_bg8_biplanar420_unorm = 0x0000005f,
    };

    pub const SampleType = enum(u32) { float, unfilterable_float, depth, sint, uint };

    pub const UsageFlags = packed struct(u32) {
        copy_src: bool = false,
        copy_dst: bool = false,
        texture_binding: bool = false,
        storage_binding: bool = false,
        render_attachment: bool = false,
        transient_attachment: bool = false,
        _: u26 = 0,
    };
};

pub const TextureView = opaque {
    pub const Descriptor = struct {
        label: ?[*:0]const u8 = null,
        format: Texture.Format = .undefined,
        dimension: Dimension = .undefined,
        base_mip_level: u32 = 0,
        mip_level_count: u32 = 0xffffffff,
        base_array_layer: u32 = 0,
        array_layer_count: u32 = 0xffffffff,
        aspect: Texture.Aspect = .all,
    };

    pub const Dimension = enum {
        undefined,
        @"1d",
        @"2d",
        @"2d_array",
        cube,
        cube_array,
        @"3d",
    };
};

pub const BackendType = enum { d3d12 };

pub const PresentMode = enum { immediate, fifo };

pub const Extent3D = extern struct {
    width: u32,
    height: u32 = 1,
    depth_or_array_layers: u32 = 1,
};
