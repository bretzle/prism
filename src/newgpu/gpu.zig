const std = @import("std");
const options = @import("options");

pub const types = @import("types.zig");

const impl = switch (options.backend) {
    .dummy => unreachable,
    .d3d11 => @import("d3d11/d3d11.zig"),
};

pub const Instance = opaque {
    pub fn create() !*Instance {
        const instance = try impl.Instance.create();
        return @ptrCast(instance);
    }

    pub fn createSurface(self: *Instance, desc: Surface.Descriptor) !*Surface {
        const instance: *impl.Instance = @alignCast(@ptrCast(self));
        return @ptrCast(try impl.Surface.create(instance, desc));
    }

    pub fn createAdapter(self: *Instance, desc: Adapter.Descriptor) !*Adapter {
        const instance: *impl.Instance = @alignCast(@ptrCast(self));
        return @ptrCast(try impl.Adapter.create(instance, desc));
    }
};

pub const Surface = opaque {
    pub const Descriptor = union {
        windows: std.os.windows.HWND,
    };

    pub fn reference(self: *Surface) void {
        const surface: *impl.Surface = @alignCast(@ptrCast(self));
        surface.manager.reference();
    }

    pub fn release(self: *Surface) void {
        const surface: *impl.Surface = @alignCast(@ptrCast(self));
        surface.manager.release();
    }
};

pub const Adapter = opaque {
    pub const Type = enum { discrete_gpu, integrated_gpu, cpu, unknown };

    pub const Descriptor = struct {
        surface: ?*Surface = null,
        power_preference: types.PowerPreference = .efficient,
    };

    pub fn createDevice(self: *Adapter) !*Device {
        const adapter: *impl.Adapter = @alignCast(@ptrCast(self));
        return @ptrCast(try impl.Device.create(adapter));
    }
};

pub const Device = opaque {
    pub fn createSwapchain(self: *Device, surface: *Surface, desc: Swapchain.Descriptor) !*Swapchain {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        const surface_: *impl.Surface = @alignCast(@ptrCast(surface));
        return @ptrCast(try impl.Swapchain.create(device, surface_, desc));
    }

    pub fn createShaderModule(self: *Device, kind: enum { hlsl }, data: []const u8) !*ShaderModule {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        return @ptrCast(switch (kind) {
            .hlsl => try impl.ShaderModule.create(device, data),
        });
    }

    pub fn createBuffer(self: *Device, desc: Buffer.Descriptor) !*Buffer {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        return @ptrCast(try impl.Buffer.create(device, desc));
    }

    pub fn createTexture(self: *Device, desc: Texture.Descriptor) !*Texture {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        return @ptrCast(try impl.Texture.create(device, desc));
    }

    pub fn createSampler(self: *Device, desc: Sampler.Descriptor) !*Sampler {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        return @ptrCast(try impl.Sampler.create(device, desc));
    }

    pub fn createRenderPipeline(self: *Device, desc: RenderPipeline.Descriptor) !*RenderPipeline {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        return @ptrCast(try impl.RenderPipeline.create(device, desc));
    }

    pub fn createCommandEncoder(self: *Device) !*CommandEncoder {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        return @ptrCast(try impl.CommandEncoder.create(device));
    }

    pub fn submit(self: *Device, commands: []const *CommandBuffer) !void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        const buffers: []const *impl.CommandBuffer = @ptrCast(commands);
        try device.submit(buffers);
    }

    pub fn tick(self: *Device) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        device.processQueuedOperations();
    }

    pub fn reference(self: *Device) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        device.manager.reference();
    }

    pub fn release(self: *Device) void {
        const device: *impl.Device = @alignCast(@ptrCast(self));
        device.manager.release();
    }
};

pub const Swapchain = opaque {
    pub const Descriptor = struct {
        usage: Texture.UsageFlags,
        format: Texture.Format,
        width: u32,
        height: u32,
        present_mode: types.PresentMode,
    };

    pub fn getCurrentTextureView(self: *Swapchain) !*TextureView {
        const swapchain: *impl.Swapchain = @alignCast(@ptrCast(self));
        return @ptrCast(try swapchain.getCurrentTextureView());
    }

    pub fn resize(self: *Swapchain, width: u32, height: u32) !void {
        const swapchain: *impl.Swapchain = @alignCast(@ptrCast(self));
        try swapchain.resize(width, height);
    }

    pub fn present(self: *Swapchain) !void {
        const swapchain: *impl.Swapchain = @alignCast(@ptrCast(self));
        try swapchain.present();
    }

    pub fn reference(self: *Swapchain) void {
        const swapchain: *impl.Swapchain = @alignCast(@ptrCast(self));
        swapchain.manager.reference();
    }

    pub fn release(self: *Swapchain) void {
        const swapchain: *impl.Swapchain = @alignCast(@ptrCast(self));
        swapchain.manager.release();
    }
};

pub const Texture = opaque {
    pub const Descriptor = struct {
        usage: UsageFlags,
        dimension: Dimension = .@"2d",
        size: types.Extent3D,
        format: Format,
        mip_level_count: u32 = 1,
        sample_count: u32 = 1,

        data: ?[]const u8 = null,
    };

    pub const Aspect = enum { all, stencil_only, depth_only, plane0_only, plane1_only };

    pub const Dimension = enum { @"1d", @"2d", @"3d" };

    pub const UsageFlags = packed struct(u8) {
        copy_src: bool = false,
        copy_dst: bool = false,
        texture_binding: bool = false,
        storage_binding: bool = false,
        render_attachment: bool = false,
        transient_attachment: bool = false,
        _: u2 = 0,
    };

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

    pub fn createView(self: *Texture, desc: TextureView.Descriptor) !*TextureView {
        const texture: *impl.Texture = @alignCast(@ptrCast(self));
        const view = try impl.TextureView.create(texture, desc);
        return @ptrCast(view);
    }

    pub fn reference(self: *Texture) void {
        const texture: *impl.Texture = @alignCast(@ptrCast(self));
        texture.manager.reference();
    }

    pub fn release(self: *Texture) void {
        const texture: *impl.Texture = @alignCast(@ptrCast(self));
        texture.manager.release();
    }
};

pub const TextureView = opaque {
    pub const Descriptor = struct {
        format: Texture.Format = .undefined,
        dimension: Dimension = .undefined,
        base_mip_level: u32 = 0,
        mip_level_count: u32 = types.mip_level_count_undefined,
        base_array_layer: u32 = 0,
        array_layer_count: u32 = types.array_layer_count_undefined,
        aspect: Texture.Aspect = .all,
    };

    pub const Dimension = enum { undefined, @"1d", @"2d", @"2d_array", cube, cube_array, @"3d" };

    pub fn reference(self: *TextureView) void {
        const view: *impl.TextureView = @alignCast(@ptrCast(self));
        view.manager.reference();
    }

    pub fn release(self: *TextureView) void {
        const view: *impl.TextureView = @alignCast(@ptrCast(self));
        view.manager.release();
    }
};

pub const ShaderModule = opaque {
    pub fn reference(self: *ShaderModule) void {
        const shader: *impl.ShaderModule = @alignCast(@ptrCast(self));
        shader.manager.reference();
    }

    pub fn release(self: *ShaderModule) void {
        const shader: *impl.ShaderModule = @alignCast(@ptrCast(self));
        shader.manager.release();
    }
};

pub const RenderPipeline = opaque {
    pub const Descriptor = struct {
        vertex: types.VertexState,
        fragment: types.FragmentState,
        primitive: types.PrimitiveState = .{},
        depth_stencil: ?types.DepthStencilState = null,
        multisample: types.MultisampleState = .{},
    };

    pub fn reference(self: *RenderPipeline) void {
        const pipeline: *impl.RenderPipeline = @alignCast(@ptrCast(self));
        pipeline.manager.reference();
    }

    pub fn release(self: *RenderPipeline) void {
        const pipeline: *impl.RenderPipeline = @alignCast(@ptrCast(self));
        pipeline.manager.release();
    }
};

pub const CommandEncoder = opaque {
    pub fn writeBuffer(self: *CommandEncoder, buffer: *Buffer, offset: u64, slice: anytype) !void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        const buffer_: *impl.Buffer = @alignCast(@ptrCast(buffer));
        const data = std.mem.sliceAsBytes(slice);
        try encoder.writeBuffer(buffer_, offset, data.ptr, data.len);
    }

    pub inline fn copyTexture(self: *CommandEncoder, source: types.ImageCopyTexture, destination: types.ImageCopyTexture, copy_size: types.Extent3D) !void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        try encoder.copyTexture(source, destination, copy_size);
    }

    pub fn beginRenderPass(self: *CommandEncoder, desc: types.RenderPassDescriptor) !*RenderPassEncoder {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        return @ptrCast(try encoder.beginRenderPass(desc));
    }

    pub inline fn finish(self: *CommandEncoder) !*CommandBuffer {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        const buffer = try encoder.finish();
        // buffer.manager.reference();
        return @ptrCast(buffer);
    }

    pub fn reference(self: *CommandEncoder) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        encoder.manager.reference();
    }

    pub fn release(self: *CommandEncoder) void {
        const encoder: *impl.CommandEncoder = @alignCast(@ptrCast(self));
        encoder.manager.release();
    }
};

pub const CommandBuffer = opaque {
    pub fn reference(self: *CommandBuffer) void {
        const buffer: *impl.CommandBuffer = @alignCast(@ptrCast(self));
        buffer.manager.reference();
    }

    pub fn release(self: *CommandBuffer) void {
        const buffer: *impl.CommandBuffer = @alignCast(@ptrCast(self));
        buffer.manager.release();
    }
};

pub const RenderPassEncoder = opaque {
    pub fn setPipeline(self: *RenderPassEncoder, pipeline: *RenderPipeline) !void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        const pipeline_: *impl.RenderPipeline = @alignCast(@ptrCast(pipeline));
        try encoder.setPipeline(pipeline_);
    }

    pub fn setVertexBuffer(self: *RenderPassEncoder, slot: u32, buffer: *Buffer, offset: u32, stride: u32) !void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        const buffer_: *impl.Buffer = @alignCast(@ptrCast(buffer));
        try encoder.setVertexBuffer(slot, buffer_, offset, stride);
    }

    pub fn setUniformBuffer(self: *RenderPassEncoder, slot: u32, buffer: *Buffer) !void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        const buffer_: *impl.Buffer = @alignCast(@ptrCast(buffer));
        try encoder.setUniformBuffer(slot, buffer_);
    }

    pub fn setTexture(self: *RenderPassEncoder, slot: u32, view: *TextureView, sampler: *Sampler) !void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        const view_: *impl.TextureView = @alignCast(@ptrCast(view));
        const sampler_: *impl.Sampler = @alignCast(@ptrCast(sampler));
        try encoder.setTexture(slot, view_, sampler_);
    }

    pub fn draw(self: *RenderPassEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) !void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        try encoder.draw(vertex_count, instance_count, first_vertex, first_instance);
    }

    pub fn end(self: *RenderPassEncoder) !void {
        const encoder: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        try encoder.end();
    }

    pub fn reference(self: *RenderPassEncoder) void {
        const pass: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        pass.manager.reference();
    }

    pub fn release(self: *RenderPassEncoder) void {
        const pass: *impl.RenderPassEncoder = @alignCast(@ptrCast(self));
        pass.manager.release();
    }
};

pub const Buffer = opaque {
    pub const Descriptor = struct {
        usage: UsageFlags,
        size: u32,
        data: ?[]const u8 = null,
    };

    pub const UsageFlags = packed struct(u16) {
        map_read: bool = false,
        map_write: bool = false,
        copy_src: bool = false,
        copy_dst: bool = false,
        index: bool = false,
        vertex: bool = false,
        uniform: bool = false,
        storage: bool = false,
        indirect: bool = false,
        query_resolve: bool = false,
        _: u6 = 0,
    };

    pub inline fn reference(self: *Buffer) void {
        const buffer: *impl.Buffer = @alignCast(@ptrCast(self));
        buffer.manager.reference();
    }

    pub inline fn release(self: *Buffer) void {
        const buffer: *impl.Buffer = @alignCast(@ptrCast(self));
        buffer.manager.release();
    }
};

pub const Sampler = opaque {
    pub const Descriptor = struct {
        address_mode_u: AddressMode = .clamp_to_edge,
        address_mode_v: AddressMode = .clamp_to_edge,
        address_mode_w: AddressMode = .clamp_to_edge,
        mag_filter: types.FilterMode = .nearest,
        min_filter: types.FilterMode = .nearest,
        mipmap_filter: types.MipmapFilterMode = .nearest,
        lod_min_clamp: f32 = 0.0,
        lod_max_clamp: f32 = 32.0,
        compare: types.CompareFunction = .undefined,
        max_anisotropy: u16 = 1,
    };

    pub const AddressMode = enum { repeat, mirror_repeat, clamp_to_edge };

    // pub const BindingType = enum { undefined, filtering, non_filtering, comparison };

    // pub const BindingLayout = struct {
    //     type: BindingType = .undefined,
    // };

    pub fn reference(self: *Sampler) void {
        const sampler: *impl.Sampler = @alignCast(@ptrCast(self));
        sampler.manager.reference();
    }

    pub fn release(self: *Sampler) void {
        const sampler: *impl.Sampler = @alignCast(@ptrCast(self));
        sampler.manager.release();
    }
};
