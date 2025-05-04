const gpu = @import("gpu.zig");

const Texture = gpu.Texture;
const TextureView = gpu.TextureView;
const ShaderModule = gpu.ShaderModule;

pub const array_layer_count_undefined = 0xffffffff;
// pub const copy_stride_undefined = 0xffffffff;
// pub const limit_u32_undefined = 0xffffffff;
// pub const limit_u64_undefined = 0xffffffffffffffff;
pub const mip_level_count_undefined = 0xffffffff;
// pub const whole_map_size = std.math.maxInt(usize);
// pub const whole_size = 0xffffffffffffffff;

// pub const ComputePassTimestampWrite = struct {
//     query_set: *QuerySet,
//     query_index: u32,
//     location: ComputePassTimestampLocation,
// };

pub const RenderPassDepthStencilAttachment = struct {
    view: *TextureView,
    depth_load_op: LoadOp = .undefined,
    depth_store_op: StoreOp = .undefined,
    depth_clear_value: f32 = 0,
    depth_read_only: bool = false,
    stencil_load_op: LoadOp = .undefined,
    stencil_store_op: StoreOp = .undefined,
    stencil_clear_value: u32 = 0,
    stencil_read_only: bool = false,
};

// pub const RenderPassTimestampWrite = struct {
//     query_set: *QuerySet,
//     query_index: u32,
//     location: RenderPassTimestampLocation,
// };

// pub const ComputePassDescriptor = struct {
//     label: [:0]const u8 = "unnamed",
//     timestamp_writes: []const ComputePassTimestampWrite = &.{},
// };

pub const RenderPassDescriptor = struct {
    color_attachments: []const RenderPassColorAttachment = &.{},
    depth_stencil_attachment: ?*const RenderPassDepthStencilAttachment = null,
    // occlusion_query_set: ?*QuerySet = null,
    // timestamp_writes: []const RenderPassTimestampWrite = &.{},
    // max_draw_count: ?*const RenderPassDescriptorMaxDrawCount = null,
};

// pub const AlphaMode = enum {
//     premultiplied,
//     unpremultiplied,
//     opaq,
// };

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

pub const BlendOperation = enum {
    add,
    subtract,
    reverse_subtract,
    min,
    max,
};

pub const CompareFunction = enum {
    undefined,
    never,
    less,
    less_equal,
    greater,
    greater_equal,
    equal,
    not_equal,
    always,
};

// // pub const CompilationInfoRequestStatus = enum(u32) {
// //     success = 0x00000000,
// //     err = 0x00000001,
// //     device_lost = 0x00000002,
// //     unknown = 0x00000003,
// // };

// // pub const CompilationMessageType = enum(u32) {
// //     err = 0x00000000,
// //     warning = 0x00000001,
// //     info = 0x00000002,
// // };

// pub const ComputePassTimestampLocation = enum {
//     beginning,
//     end,
// };

pub const CullMode = enum {
    none,
    front,
    back,
};

// pub const ErrorFilter = enum {
//     validation,
//     out_of_memory,
//     internal,
// };

// pub const ErrorType = enum {
//     no_error,
//     validation,
//     out_of_memory,
//     internal,
//     unknown,
//     device_lost,
// };

// pub const FeatureName = enum(u32) {
//     undefined = 0x00000000,
//     depth_clip_control = 0x00000001,
//     depth32_float_stencil8 = 0x00000002,
//     timestamp_query = 0x00000003,
//     pipeline_statistics_query = 0x00000004,
//     texture_compression_bc = 0x00000005,
//     texture_compression_etc2 = 0x00000006,
//     texture_compression_astc = 0x00000007,
//     indirect_first_instance = 0x00000008,
//     shader_f16 = 0x00000009,
//     rg11_b10_ufloat_renderable = 0x0000000A,
//     bgra8_unorm_storage = 0x0000000B,
//     float32_filterable = 0x0000000C,
//     chromium_experimental_dp4a = 0x000003ed,
//     timestamp_query_inside_passes = 0x000003EE,
//     implicit_device_synchronization = 0x000003EF,
//     surface_capabilities = 0x000003F0,
//     transient_attachments = 0x000003F1,
//     msaa_render_to_single_sampled = 0x000003F2,
//     dual_source_blending = 0x000003F3,
//     d3d11_multithread_protected = 0x000003F4,
//     anglet_exture_sharing = 0x000003F5,
//     shared_texture_memory_vk_image_descriptor = 0x0000044C,
//     shared_texture_memory_vk_dedicated_allocation_descriptor = 0x0000044D,
//     shared_texture_memory_a_hardware_buffer_descriptor = 0x0000044_E,
//     shared_texture_memory_dma_buf_descriptor = 0x0000044F,
//     shared_texture_memory_opaque_fd_descriptor = 0x00000450,
//     shared_texture_memory_zircon_handle_descriptor = 0x00000451,
//     shared_texture_memory_dxgi_shared_handle_descriptor = 0x00000452,
//     shared_texture_memory_d3_d11_texture2_d_descriptor = 0x00000453,
//     shared_texture_memory_io_surface_descriptor = 0x00000454,
//     shared_texture_memory_egl_image_descriptor = 0x00000455,
//     shared_texture_memory_initialized_begin_state = 0x000004B0,
//     shared_texture_memory_initialized_end_state = 0x000004B1,
//     shared_texture_memory_vk_image_layout_begin_state = 0x000004B2,
//     shared_texture_memory_vk_image_layout_end_state = 0x000004B3,
//     shared_fence_vk_semaphore_opaque_fd_descriptor = 0x000004B4,
//     shared_fence_vk_semaphore_opaque_fd_export_info = 0x000004B5,
//     shared_fence_vk_semaphore_sync_fd_descriptor = 0x000004B6,
//     shared_fence_vk_semaphore_sync_fd_export_info = 0x000004B7,
//     shared_fence_vk_semaphore_zircon_handle_descriptor = 0x000004B8,
//     shared_fence_vk_semaphore_zircon_handle_export_info = 0x000004B9,
//     shared_fence_dxgi_shared_handle_descriptor = 0x000004BA,
//     shared_fence_dxgi_shared_handle_export_info = 0x000004BB,
//     shared_fence_mtl_shared_event_descriptor = 0x000004BC,
//     shared_fence_mtl_shared_event_export_info = 0x000004BD,
// };

pub const FilterMode = enum {
    nearest,
    linear,
};

pub const MipmapFilterMode = enum {
    nearest,
    linear,
};

pub const FrontFace = enum {
    ccw,
    cw,
};

pub const IndexFormat = enum {
    undefined,
    uint16,
    uint32,
};

pub const LoadOp = enum {
    undefined,
    clear,
    load,
};

// // pub const LoggingType = enum(u32) {
// //     verbose = 0x00000000,
// //     info = 0x00000001,
// //     warning = 0x00000002,
// //     err = 0x00000003,
// // };

// pub const PipelineStatisticName = enum {
//     vertex_shader_invocations,
//     clipper_invocations,
//     clipper_primitives_out,
//     fragment_shader_invocations,
//     compute_shader_invocations,
// };

pub const PowerPreference = enum {
    efficient,
    performance,
};

pub const PresentMode = enum {
    immediate,
    mailbox,
    fifo,
};

pub const PrimitiveTopology = enum {
    point_list,
    line_list,
    line_strip,
    triangle_list,
    triangle_strip,
};

// pub const QueryType = enum {
//     occlusion,
//     pipeline_statistics,
//     timestamp,
// };

// pub const RenderPassTimestampLocation = enum {
//     beginning,
//     end,
// };

// pub const RequestAdapterStatus = enum {
//     success,
//     unavailable,
//     err,
//     unknown,
// };

// pub const RequestDeviceStatus = enum {
//     success,
//     err,
//     unknown,
// };

pub const StencilOperation = enum {
    keep,
    zero,
    replace,
    invert,
    increment_clamp,
    decrement_clamp,
    increment_wrap,
    decrement_wrap,
};

// pub const StorageTextureAccess = enum {
//     undefined,
//     write_only,
// };

pub const StoreOp = enum {
    undefined,
    store,
    discard,
};

pub const VertexFormat = enum {
    undefined,
    uint8x2,
    uint8x4,
    sint8x2,
    sint8x4,
    unorm8x2,
    unorm8x4,
    snorm8x2,
    snorm8x4,
    uint16x2,
    uint16x4,
    sint16x2,
    sint16x4,
    unorm16x2,
    unorm16x4,
    snorm16x2,
    snorm16x4,
    float16x2,
    float16x4,
    float32,
    float32x2,
    float32x3,
    float32x4,
    uint32,
    uint32x2,
    uint32x3,
    uint32x4,
    sint32,
    sint32x2,
    sint32x3,
    sint32x4,
};

pub const VertexStepMode = enum {
    vertex,
    instance,
    vertex_buffer_not_used,
};

pub const ColorWriteMaskFlags = packed struct(u4) {
    red: bool = false,
    green: bool = false,
    blue: bool = false,
    alpha: bool = false,

    pub const all = ColorWriteMaskFlags{
        .red = true,
        .green = true,
        .blue = true,
        .alpha = true,
    };
};

// // pub const MapModeFlags = packed struct(u32) {
// //     read: bool = false,
// //     write: bool = false,
// //     _: u30 = 0,
// // };

// pub const ShaderStageFlags = packed struct(u32) {
//     vertex: bool = false,
//     fragment: bool = false,
//     compute: bool = false,
//     _: u29 = 0,
// };

pub const BlendComponent = struct {
    operation: BlendOperation = .add,
    src_factor: BlendFactor = .one,
    dst_factor: BlendFactor = .zero,
};

pub const Color = struct {
    r: f64,
    g: f64,
    b: f64,
    a: f64,
};

// pub const Extent2D = struct {
//     width: u32,
//     height: u32,
// };

pub const Extent3D = struct {
    width: u32,
    height: u32 = 1,
    depth_or_array_layers: u32 = 1,
};

// pub const Limits = struct {
//     max_texture_dimension_1d: u32 = limit_u32_undefined,
//     max_texture_dimension_2d: u32 = limit_u32_undefined,
//     max_texture_dimension_3d: u32 = limit_u32_undefined,
//     max_texture_array_layers: u32 = limit_u32_undefined,
//     max_bind_groups: u32 = limit_u32_undefined,
//     max_bind_groups_plus_vertex_buffers: u32 = limit_u32_undefined,
//     max_bindings_per_bind_group: u32 = limit_u32_undefined,
//     max_dynamic_uniform_buffers_per_pipeline_layout: u32 = limit_u32_undefined,
//     max_dynamic_storage_buffers_per_pipeline_layout: u32 = limit_u32_undefined,
//     max_sampled_textures_per_shader_stage: u32 = limit_u32_undefined,
//     max_samplers_per_shader_stage: u32 = limit_u32_undefined,
//     max_storage_buffers_per_shader_stage: u32 = limit_u32_undefined,
//     max_storage_textures_per_shader_stage: u32 = limit_u32_undefined,
//     max_uniform_buffers_per_shader_stage: u32 = limit_u32_undefined,
//     max_uniform_buffer_binding_size: u64 = limit_u64_undefined,
//     max_storage_buffer_binding_size: u64 = limit_u64_undefined,
//     min_uniform_buffer_offset_alignment: u32 = limit_u32_undefined,
//     min_storage_buffer_offset_alignment: u32 = limit_u32_undefined,
//     max_vertex_buffers: u32 = limit_u32_undefined,
//     max_buffer_size: u64 = limit_u64_undefined,
//     max_vertex_attributes: u32 = limit_u32_undefined,
//     max_vertex_buffer_array_stride: u32 = limit_u32_undefined,
//     max_inter_stage_shader_components: u32 = limit_u32_undefined,
//     max_inter_stage_shader_variables: u32 = limit_u32_undefined,
//     max_color_attachments: u32 = limit_u32_undefined,
//     max_color_attachment_bytes_per_sample: u32 = limit_u32_undefined,
//     max_compute_workgroup_storage_size: u32 = limit_u32_undefined,
//     max_compute_invocations_per_workgroup: u32 = limit_u32_undefined,
//     max_compute_workgroup_size_x: u32 = limit_u32_undefined,
//     max_compute_workgroup_size_y: u32 = limit_u32_undefined,
//     max_compute_workgroup_size_z: u32 = limit_u32_undefined,
//     max_compute_workgroups_per_dimension: u32 = limit_u32_undefined,
// };

pub const Origin2D = struct {
    x: u32 = 0,
    y: u32 = 0,
};

pub const Origin3D = struct {
    x: u32 = 0,
    y: u32 = 0,
    z: u32 = 0,
};

// // pub const CompilationMessage = extern struct {
// //     message: ?[*:0]const u8 = null,
// //     type: CompilationMessageType,
// //     line_num: u64,
// //     line_pos: u64,
// //     offset: u64,
// //     length: u64,
// //     utf16_line_pos: u64,
// //     utf16_offset: u64,
// //     utf16_length: u64,
// // };

pub const ConstantEntry = struct {
    key: [:0]const u8,
    value: f64,
};

// pub const CopyTextureForBrowserOptions = struct {
//     flip_y: bool = false,
//     needs_color_space_conversion: bool = false,
//     src_alpha_mode: AlphaMode = .unpremultiplied,
//     src_transfer_function_parameters: ?*const [7]f32 = null,
//     conversion_matrix: ?*const [9]f32 = null,
//     dst_transfer_function_parameters: ?*const [7]f32 = null,
//     dst_alpha_mode: AlphaMode = .unpremultiplied,
//     internal_usage: bool = false,
// };

pub const MultisampleState = struct {
    count: u32 = 1,
    mask: u32 = 0xFFFFFFFF,
    alpha_to_coverage_enabled: bool = false,
};

pub const PrimitiveDepthClipControl = struct {
    unclipped_depth: bool = false,
};

pub const PrimitiveState = struct {
    primitive_depth_clip_control: ?PrimitiveDepthClipControl = null,
    topology: PrimitiveTopology = .triangle_list,
    strip_index_format: IndexFormat = .undefined,
    front_face: FrontFace = .ccw,
    cull_mode: CullMode = .none,
};

// pub const RenderPassDescriptorMaxDrawCount = struct {
//     max_draw_count: u64 = 50000000,
// };

pub const StencilFaceState = struct {
    compare: CompareFunction = .always,
    fail_op: StencilOperation = .keep,
    depth_fail_op: StencilOperation = .keep,
    pass_op: StencilOperation = .keep,
};

// pub const StorageTextureBindingLayout = struct {
//     access: StorageTextureAccess = .undefined,
//     format: Texture.Format = .undefined,
//     view_dimension: TextureView.Dimension = .undefined,
// };

pub const VertexAttribute = struct {
    format: VertexFormat,
    offset: u64,
    shader_location: u32,
};

pub const BlendState = struct {
    color: BlendComponent = .{},
    alpha: BlendComponent = .{},
};

// // pub const CompilationInfo = extern struct {
// //     message_count: usize,
// //     messages: ?[*]const CompilationMessage = null,

// //     /// Helper to get messages as a slice.
// //     pub fn getMessages(info: CompilationInfo) ?[]const CompilationMessage {
// //         if (info.messages) |messages| {
// //             return messages[0..info.message_count];
// //         }
// //         return null;
// //     }
// // };

pub const DepthStencilState = struct {
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

// pub const ImageCopyBuffer = struct {
//     layout: Texture.DataLayout,
//     buffer: *Buffer,
// };

// pub const ImageCopyExternalTexture = struct {
//     external_texture: *ExternalTexture,
//     origin: Origin3D,
//     natural_size: Extent2D,
// };

pub const ImageCopyTexture = struct {
    texture: *Texture,
    mip_level: u32 = 0,
    origin: Origin3D = .{},
    aspect: Texture.Aspect = .all,
};

// pub const ProgrammableStageDescriptor = struct {
//     module: *ShaderModule,
//     entry_point: [:0]const u8,
//     constants: []const ConstantEntry = &.{},
// };

pub const RenderPassColorAttachment = struct {
    view: ?*TextureView = null,
    resolve_target: ?*TextureView = null,
    load_op: LoadOp,
    store_op: StoreOp,
    clear_value: Color,
};

// pub const RequiredLimits = struct {
//     limits: Limits,
// };

// pub const SupportedLimits = struct {
//     limits: Limits,
// };

pub const VertexBufferLayout = struct {
    array_stride: u64,
    step_mode: VertexStepMode = .vertex,
    attributes: []const VertexAttribute = &.{},
};

pub const ColorTargetState = struct {
    format: Texture.Format,
    blend: ?*const BlendState = null,
    write_mask: ColorWriteMaskFlags = .all,
};

pub const VertexState = struct {
    module: *ShaderModule,
    entrypoint: [:0]const u8,
    // constants: []const ConstantEntry = &.{}, TODO
    // buffers: []const VertexBufferLayout = &.{}, TODO
};

pub const FragmentState = struct {
    module: *ShaderModule,
    entrypoint: [:0]const u8,
    // constants: []const ConstantEntry = &.{}, TODO
    targets: []const ColorTargetState = &.{},
};
