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

    pub fn createShader(self: *Device, code: []const u8) !*ShaderModule {
        const device: *backend.Device = @alignCast(@ptrCast(self));
        const shader = try device.createShader(code);
        return @ptrCast(shader);
    }

    pub fn createPipelineLayout(self: *Device, desc: PipelineLayout.Descriptor) !*PipelineLayout {
        const device: *backend.Device = @alignCast(@ptrCast(self));
        const layout = try device.createPipelineLayout(desc);
        return @ptrCast(layout);
    }

    pub fn createRenderPipeline(self: *Device, desc: RenderPipeline.Descriptor) !*RenderPipeline {
        const device: *backend.Device = @alignCast(@ptrCast(self));
        const pipeline = try device.createRenderPipeline(desc);
        return @ptrCast(pipeline);
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

pub const ShaderModule = opaque {
    pub fn release(self: *ShaderModule) void {
        _ = self; // autofix
        // TODO
    }
};

pub const RenderPipeline = opaque {
    pub const Descriptor = struct {
        label: ?[]const u8 = null,
        layout: *PipelineLayout, // TODO support auto layout
        vertex: VertexState,
        primitive: PrimitiveState = .{},
        depth_stencil: ?DepthStencilState = null,
        multisample: MultisampleState = .{},
        fragment: ?FragmentState = null,
    };

    pub fn release(self: *RenderPipeline) void {
        _ = self; // autofix
        // TODO
    }
};

pub const PipelineLayout = opaque {
    pub const Descriptor = extern struct {
        label: ?[*:0]const u8 = null,
        bind_group_layout_count: usize = 0,
        bind_group_layouts: ?[*]const *BindGroupLayout = null,
    };

    pub fn release(self: *PipelineLayout) void {
        _ = self; // autofix
        // TODO
    }
};

pub const BindGroupLayout = opaque {};

pub const BackendType = enum { d3d12 };

pub const PresentMode = enum { immediate, fifo };

pub const Extent3D = extern struct {
    width: u32,
    height: u32 = 1,
    depth_or_array_layers: u32 = 1,
};

pub const BlendState = struct {
    color: BlendComponent,
    alpha: BlendComponent,

    pub const default = BlendState{ .color = .{}, .alpha = .{} };
};

pub const BlendComponent = struct {
    operation: BlendOperation = .add,
    src_factor: BlendFactor = .one,
    dst_factor: BlendFactor = .zero,
};

pub const BlendOperation = enum {
    add,
    subtract,
    reverse_subtract,
    min,
    max,
};

pub const BlendFactor = enum {
    zero,
    one,
    src,
    one_minus_src,
    src_alpha,
    one_minus_src_alpha,
    dst,
    one_minus_dst,
    dst_alpha,
    one_minus_dst_alpha,
    src_alpha_saturated,
    constant,
    one_minus_constant,
    src1,
    one_minus_src1,
    src1_alpha,
    one_minus_src1_alpha,
};

pub const ColorTargetState = struct {
    format: Texture.Format,
    blend: ?*const BlendState = null,
    write_mask: ColorWriteMaskFlags = ColorWriteMaskFlags.all,
};

pub const ColorWriteMaskFlags = packed struct(u32) {
    red: bool = false,
    green: bool = false,
    blue: bool = false,
    alpha: bool = false,
    _padding: u28 = 0,

    pub const all = ColorWriteMaskFlags{ .red = true, .green = true, .blue = true, .alpha = true };
};

pub const DepthStencilState = extern struct {
    format: Texture.Format,
    depth_write_enabled: bool = false,
    depth_compare: CompareFunction = .always,
    stencil_front: StencilFaceState = .{},
    stencil_back: StencilFaceState = .{},
    stencil_read_mask: u32 = 0xFFFFFFFF,
    stencil_write_mask: u32 = 0xFFFFFFFF,
    depth_bias: i32 = 0,
    depth_bias_slope_scale: f32 = 0.0,
    depth_bias_clamp: f32 = 0.0,
};

pub const MultisampleState = struct {
    count: u32 = 1,
    mask: u32 = 0xFFFFFFFF,
    alpha_to_coverage_enabled: bool = false,
};

pub const VertexState = struct {
    module: *ShaderModule,
    entrypoint: [:0]const u8,
    constants: []const ConstantEntry = &.{},
    buffers: []const VertexBufferLayout = &.{},
};

pub const PrimitiveState = struct {
    topology: PrimitiveTopology = .triangle_list,
    strip_index_format: IndexFormat = .undefined,
    front_face: FrontFace = .ccw,
    cull_mode: CullMode = .none,
};

pub const FragmentState = struct {
    module: *ShaderModule,
    entrypoint: [:0]const u8,
    constants: []const ConstantEntry = &[0]ConstantEntry{},
    targets: []const ColorTargetState = &[0]ColorTargetState{},
};

pub const CompareFunction = enum(u32) {
    undefined = 0x00000000,
    never = 0x00000001,
    less = 0x00000002,
    less_equal = 0x00000003,
    greater = 0x00000004,
    greater_equal = 0x00000005,
    equal = 0x00000006,
    not_equal = 0x00000007,
    always = 0x00000008,
};

pub const StencilFaceState = extern struct {
    compare: CompareFunction = .always,
    fail_op: StencilOperation = .keep,
    depth_fail_op: StencilOperation = .keep,
    pass_op: StencilOperation = .keep,
};

pub const StencilOperation = enum(u32) {
    keep = 0x00000000,
    zero = 0x00000001,
    replace = 0x00000002,
    invert = 0x00000003,
    increment_clamp = 0x00000004,
    decrement_clamp = 0x00000005,
    increment_wrap = 0x00000006,
    decrement_wrap = 0x00000007,
};

pub const ConstantEntry = extern struct {
    key: [*:0]const u8,
    value: f64,
};

pub const VertexBufferLayout = extern struct {
    array_stride: u64,
    step_mode: VertexStepMode = .vertex,
    attribute_count: usize,
    attributes: ?[*]const VertexAttribute = null,
};

pub const VertexStepMode = enum(u32) {
    vertex = 0x00000000,
    instance = 0x00000001,
    vertex_buffer_not_used = 0x00000002,
};

pub const VertexAttribute = extern struct {
    format: VertexFormat,
    offset: u64,
    shader_location: u32,
};

pub const VertexFormat = enum(u32) {
    undefined = 0x00000000,
    uint8x2 = 0x00000001,
    uint8x4 = 0x00000002,
    sint8x2 = 0x00000003,
    sint8x4 = 0x00000004,
    unorm8x2 = 0x00000005,
    unorm8x4 = 0x00000006,
    snorm8x2 = 0x00000007,
    snorm8x4 = 0x00000008,
    uint16x2 = 0x00000009,
    uint16x4 = 0x0000000a,
    sint16x2 = 0x0000000b,
    sint16x4 = 0x0000000c,
    unorm16x2 = 0x0000000d,
    unorm16x4 = 0x0000000e,
    snorm16x2 = 0x0000000f,
    snorm16x4 = 0x00000010,
    float16x2 = 0x00000011,
    float16x4 = 0x00000012,
    float32 = 0x00000013,
    float32x2 = 0x00000014,
    float32x3 = 0x00000015,
    float32x4 = 0x00000016,
    uint32 = 0x00000017,
    uint32x2 = 0x00000018,
    uint32x3 = 0x00000019,
    uint32x4 = 0x0000001a,
    sint32 = 0x0000001b,
    sint32x2 = 0x0000001c,
    sint32x3 = 0x0000001d,
    sint32x4 = 0x0000001e,
};

pub const PrimitiveTopology = enum(u32) {
    point_list = 0x00000000,
    line_list = 0x00000001,
    line_strip = 0x00000002,
    triangle_list = 0x00000003,
    triangle_strip = 0x00000004,
};

pub const IndexFormat = enum(u32) {
    undefined = 0x00000000,
    uint16 = 0x00000001,
    uint32 = 0x00000002,
};

pub const FrontFace = enum(u32) {
    ccw = 0x00000000,
    cw = 0x00000001,
};

pub const CullMode = enum(u32) {
    none = 0x00000000,
    front = 0x00000001,
    back = 0x00000002,
};

pub const ShaderStageFlags = packed struct(u32) {
    vertex: bool = false,
    fragment: bool = false,
    compute: bool = false,
    _: u29 = 0,
};
