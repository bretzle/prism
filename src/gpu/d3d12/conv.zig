const gpu = @import("../gpu.zig");
const dxgi = w32.dxgi;
const d3d12 = w32.d3d12;
const w32 = @import("w32");
const types = gpu.types;

fn stencilEnable(stencil: types.StencilFaceState) bool {
    return stencil.compare != .always or stencil.fail_op != .keep or stencil.depth_fail_op != .keep or stencil.pass_op != .keep;
}

pub fn d3d12Blend(factor: types.BlendFactor) d3d12.BLEND {
    return switch (factor) {
        .zero => .ZERO,
        .one => .ONE,
        .src => .SRC_COLOR,
        .one_minus_src => .INV_SRC_COLOR,
        .src_alpha => .SRC_ALPHA,
        .one_minus_src_alpha => .INV_SRC_ALPHA,
        .dst => .DEST_COLOR,
        .one_minus_dst => .INV_DEST_COLOR,
        .dst_alpha => .DEST_ALPHA,
        .one_minus_dst_alpha => .INV_DEST_ALPHA,
        .src_alpha_saturated => .SRC_ALPHA_SAT,
        .constant => .BLEND_FACTOR,
        .one_minus_constant => .INV_BLEND_FACTOR,
        .src1 => .SRC1_COLOR,
        .one_minus_src1 => .INV_SRC1_COLOR,
        .src1_alpha => .SRC1_ALPHA,
        .one_minus_src1_alpha => .INV_SRC1_ALPHA,
    };
}

pub fn d3d12BlendDesc(desc: gpu.RenderPipeline.Descriptor) d3d12.BLEND_DESC {
    var d3d12_targets = [_]d3d12.RENDER_TARGET_BLEND_DESC{d3d12RenderTargetBlendDesc(null)} ** 8;
    if (desc.fragment) |frag| {
        for (0..frag.targets.len) |i| {
            const target = frag.targets[i];
            d3d12_targets[i] = d3d12RenderTargetBlendDesc(target);
        }
    }

    return .{
        .AlphaToCoverageEnable = @intFromBool(desc.multisample.alpha_to_coverage_enabled == true),
        .IndependentBlendEnable = 1,
        .RenderTarget = d3d12_targets,
    };
}

pub fn d3d12BlendOp(op: types.BlendOperation) d3d12.BLEND_OP {
    return switch (op) {
        .add => .ADD,
        .subtract => .SUBTRACT,
        .reverse_subtract => .REV_SUBTRACT,
        .min => .MIN,
        .max => .MAX,
    };
}

pub fn d3d12ComparisonFunc(func: types.CompareFunction) d3d12.COMPARISON_FUNC {
    return switch (func) {
        .undefined => unreachable,
        .never => .NEVER,
        .less => .LESS,
        .less_equal => .LESS_EQUAL,
        .greater => .GREATER,
        .greater_equal => .GREATER_EQUAL,
        .equal => .EQUAL,
        .not_equal => .NOT_EQUAL,
        .always => .ALWAYS,
    };
}

pub fn d3d12CullMode(mode: types.CullMode) d3d12.CULL_MODE {
    return switch (mode) {
        .none => .NONE,
        .front => .FRONT,
        .back => .BACK,
    };
}

pub fn d3d12DepthStencilDesc(depth_stencil: ?*const types.DepthStencilState) d3d12.DEPTH_STENCIL_DESC {
    return if (depth_stencil) |ds| .{
        .DepthEnable = @intFromBool(ds.depth_compare != .always or ds.depth_write_enabled == true),
        .DepthWriteMask = if (ds.depth_write_enabled == true) .ALL else .ZERO,
        .DepthFunc = d3d12ComparisonFunc(ds.depth_compare),
        .StencilEnable = @intFromBool(stencilEnable(ds.stencil_front) or stencilEnable(ds.stencil_back)),
        .StencilReadMask = @intCast(ds.stencil_read_mask & 0xff),
        .StencilWriteMask = @intCast(ds.stencil_write_mask & 0xff),
        .FrontFace = d3d12DepthStencilOpDesc(ds.stencil_front),
        .BackFace = d3d12DepthStencilOpDesc(ds.stencil_back),
    } else .{
        .DepthEnable = 0,
        .DepthWriteMask = .ZERO,
        .DepthFunc = .LESS,
        .StencilEnable = 0,
        .StencilReadMask = 0xff,
        .StencilWriteMask = 0xff,
        .FrontFace = d3d12DepthStencilOpDesc(null),
        .BackFace = d3d12DepthStencilOpDesc(null),
    };
}

pub fn d3d12DepthStencilOpDesc(opt_stencil: ?types.StencilFaceState) d3d12.DEPTH_STENCILOP_DESC {
    return if (opt_stencil) |stencil| .{
        .StencilFailOp = d3d12StencilOp(stencil.fail_op),
        .StencilDepthFailOp = d3d12StencilOp(stencil.depth_fail_op),
        .StencilPassOp = d3d12StencilOp(stencil.pass_op),
        .StencilFunc = d3d12ComparisonFunc(stencil.compare),
    } else .{
        .StencilFailOp = .KEEP,
        .StencilDepthFailOp = .KEEP,
        .StencilPassOp = .KEEP,
        .StencilFunc = .ALWAYS,
    };
}

pub fn d3d12DescriptorRangeType(entry: gpu.BindGroupLayout.Entry) d3d12.DESCRIPTOR_RANGE_TYPE {
    if (entry.buffer.type != .undefined) {
        return switch (entry.buffer.type) {
            .undefined => unreachable,
            .uniform => .CBV,
            .storage => .UAV,
            .read_only_storage => .SRV,
        };
    } else if (entry.sampler.type != .undefined) {
        return .SAMPLER;
    } else if (entry.texture.sample_type != .undefined) {
        return .SRV;
    } else {
        // storage_texture
        return .UAV;
    }

    unreachable;
}

pub fn d3d12FilterType(filter: types.FilterMode) u32 {
    return switch (filter) {
        .nearest => d3d12.FILTER_TYPE_POINT,
        .linear => d3d12.FILTER_TYPE_LINEAR,
    };
}

pub fn d3d12FilterTypeForMipmap(filter: types.MipmapFilterMode) u32 {
    return switch (filter) {
        .nearest => d3d12.FILTER_TYPE_POINT,
        .linear => d3d12.FILTER_TYPE_LINEAR,
    };
}

pub fn d3d12Filter(mag_filter: types.FilterMode, min_filter: types.FilterMode, mipmap_filter: types.MipmapFilterMode, max_anisotropy: u16) u32 {
    var filter: u32 = 0;
    filter |= d3d12FilterType(min_filter) << d3d12.MIN_FILTER_SHIFT;
    filter |= d3d12FilterType(mag_filter) << d3d12.MAG_FILTER_SHIFT;
    filter |= d3d12FilterTypeForMipmap(mipmap_filter) << d3d12.MIP_FILTER_SHIFT;
    // filter |= d3d12.FILTER_REDUCTION_TYPE_STANDARD << d3d12.FILTER_REDUCTION_TYPE_SHIFT;
    if (max_anisotropy > 1)
        filter |= d3d12.ANISOTROPIC_FILTERING_BIT;
    return filter;
}

pub fn d3d12FrontCounterClockwise(face: types.FrontFace) w32.BOOL {
    return switch (face) {
        .ccw => 1,
        .cw => 0,
    };
}

pub fn d3d12HeapType(usage: gpu.Buffer.UsageFlags) d3d12.HEAP_TYPE {
    return if (usage.map_write)
        .UPLOAD
    else if (usage.map_read)
        .READBACK
    else
        .DEFAULT;
}

pub fn d3d12IndexBufferStripCutValue(strip_index_format: types.IndexFormat) d3d12.INDEX_BUFFER_STRIP_CUT_VALUE {
    return switch (strip_index_format) {
        .undefined => .DISABLED,
        .uint16 => .OxFFFF,
        .uint32 => .OxFFFFFFFF,
    };
}

pub fn d3d12InputClassification(mode: types.VertexStepMode) d3d12.INPUT_CLASSIFICATION {
    return switch (mode) {
        .vertex => .PER_VERTEX_DATA,
        .instance => .PER_INSTANCE_DATA,
        .vertex_buffer_not_used => undefined,
    };
}

pub fn d3d12InputElementDesc(
    buffer_index: usize,
    layout: types.VertexBufferLayout,
    attr: types.VertexAttribute,
) d3d12.INPUT_ELEMENT_DESC {
    return .{
        .SemanticName = "ATTR",
        .SemanticIndex = attr.shader_location,
        .Format = dxgiFormatForVertex(attr.format),
        .InputSlot = @intCast(buffer_index),
        .AlignedByteOffset = @intCast(attr.offset),
        .InputSlotClass = d3d12InputClassification(layout.step_mode),
        .InstanceDataStepRate = if (layout.step_mode == .instance) 1 else 0,
    };
}

pub fn d3d12PrimitiveTopology(topology: types.PrimitiveTopology) d3d12.PRIMITIVE_TOPOLOGY {
    return switch (topology) {
        .point_list => .POINTLIST,
        .line_list => .LINELIST,
        .line_strip => .LINESTRIP,
        .triangle_list => .TRIANGLELIST,
        .triangle_strip => .TRIANGLESTRIP,
    };
}

pub fn d3d12PrimitiveTopologyType(topology: types.PrimitiveTopology) d3d12.PRIMITIVE_TOPOLOGY_TYPE {
    return switch (topology) {
        .point_list => .POINT,
        .line_list, .line_strip => .LINE,
        .triangle_list, .triangle_strip => .TRIANGLE,
    };
}

pub fn d3d12RasterizerDesc(desc: gpu.RenderPipeline.Descriptor) d3d12.RASTERIZER_DESC {
    return .{
        .FillMode = .SOLID,
        .CullMode = d3d12CullMode(desc.primitive.cull_mode),
        .FrontCounterClockwise = d3d12FrontCounterClockwise(desc.primitive.front_face),
        .DepthBias = if (desc.depth_stencil) |ds| ds.depth_bias else 0,
        .DepthBiasClamp = if (desc.depth_stencil) |ds| ds.depth_bias_clamp else 0.0,
        .SlopeScaledDepthBias = if (desc.depth_stencil) |ds| ds.depth_bias_slope_scale else 0.0,
        .DepthClipEnable = @intFromBool(if (desc.primitive.primitive_depth_clip_control) |x| x.unclipped_depth == false else true),
        .MultisampleEnable = @intFromBool(desc.multisample.count > 1),
        .AntialiasedLineEnable = 0,
        .ForcedSampleCount = 0,
        .ConservativeRaster = .OFF,
    };
}

pub fn d3d12RenderTargetBlendDesc(opt_target: ?types.ColorTargetState) d3d12.RENDER_TARGET_BLEND_DESC {
    var desc = d3d12.RENDER_TARGET_BLEND_DESC{
        .BlendEnable = 0,
        .LogicOpEnable = 0,
        .SrcBlend = .ONE,
        .DestBlend = .ZERO,
        .BlendOp = .ADD,
        .SrcBlendAlpha = .ONE,
        .DestBlendAlpha = .ZERO,
        .BlendOpAlpha = .ADD,
        .LogicOp = .NOOP,
        .RenderTargetWriteMask = .ALL,
    };
    if (opt_target) |target| {
        desc.RenderTargetWriteMask = d3d12RenderTargetWriteMask(target.write_mask);
        if (target.blend) |blend| {
            desc.BlendEnable = 1;
            desc.SrcBlend = d3d12Blend(blend.color.src_factor);
            desc.DestBlend = d3d12Blend(blend.color.dst_factor);
            desc.BlendOp = d3d12BlendOp(blend.color.operation);
            desc.SrcBlendAlpha = d3d12Blend(blend.alpha.src_factor);
            desc.DestBlendAlpha = d3d12Blend(blend.alpha.dst_factor);
            desc.BlendOpAlpha = d3d12BlendOp(blend.alpha.operation);
        }
    }

    return desc;
}

pub fn d3d12RenderTargetWriteMask(mask: types.ColorWriteMaskFlags) d3d12.COLOR_WRITE_ENABLE {
    return .{
        .RED = mask.red,
        .GREEN = mask.green,
        .BLUE = mask.blue,
        .ALPHA = mask.alpha,
    };
}

pub fn d3d12ResourceSizeForBuffer(size: u64, usage: gpu.Buffer.UsageFlags) u64 {
    return if (usage.uniform)
        alignUp(size, 256)
    else
        size;
}

pub fn d3d12ResourceStatesInitial(heap_type: d3d12.HEAP_TYPE, read_state: d3d12.RESOURCE_STATES) d3d12.RESOURCE_STATES {
    return switch (heap_type) {
        .UPLOAD => .GENERIC_READ,
        .READBACK => .{ .COPY_DEST = true },
        else => read_state,
    };
}

pub fn d3d12ResourceStatesForBufferRead(usage: gpu.Buffer.UsageFlags) d3d12.RESOURCE_STATES {
    return d3d12.RESOURCE_STATES{
        .COPY_SOURCE = usage.copy_src,
        .INDEX_BUFFER = usage.index,
        .VERTEX_AND_CONSTANT_BUFFER = usage.vertex or usage.uniform,
        .NON_PIXEL_SHADER_RESOURCE = usage.storage,
        .PIXEL_SHADER_RESOURCE = usage.storage,
        .INDIRECT_ARGUMENT_OR_PREDICATION = usage.indirect,
    };
}

pub fn d3d12ResourceStatesForTextureRead(usage: gpu.Texture.UsageFlags) d3d12.RESOURCE_STATES {
    return d3d12.RESOURCE_STATES{
        .COPY_SOURCE = usage.copy_src,
        .NON_PIXEL_SHADER_RESOURCE = usage.texture_binding or usage.storage_binding,
        .PIXEL_SHADER_RESOURCE = usage.texture_binding or usage.storage_binding,
    };
}

pub fn d3d12ResourceFlagsForBuffer(usage: gpu.Buffer.UsageFlags) d3d12.RESOURCE_FLAGS {
    return .{
        .ALLOW_UNORDERED_ACCESS = usage.storage,
    };
}

pub fn d3d12ResourceFlagsForTexture(usage: gpu.Texture.UsageFlags, format: gpu.Texture.Format) d3d12.RESOURCE_FLAGS {
    return d3d12.RESOURCE_FLAGS{
        .ALLOW_DEPTH_STENCIL = usage.render_attachment and formatHasDepthOrStencil(format),
        .ALLOW_RENDER_TARGET = usage.render_attachment and !formatHasDepthOrStencil(format),
        .ALLOW_UNORDERED_ACCESS = usage.storage_binding,
        .DENY_SHADER_RESOURCE = !usage.texture_binding and usage.render_attachment and formatHasDepthOrStencil(format),
    };
}

pub fn d3d12ResourceDimension(dimension: gpu.Texture.Dimension) d3d12.RESOURCE_DIMENSION {
    return switch (dimension) {
        .@"1d" => .TEXTURE1D,
        .@"2d" => .TEXTURE2D,
        .@"3d" => .TEXTURE3D,
    };
}

pub fn d3d12RootParameterType(entry: gpu.BindGroupLayout.Entry) d3d12.ROOT_PARAMETER_TYPE {
    return switch (entry.buffer.type) {
        .undefined => unreachable,
        .uniform => .CBV,
        .storage => .UAV,
        .read_only_storage => .SRV,
    };
}

pub fn d3d12ShaderBytecode(opt_blob: ?*d3d12.IBlob) d3d12.SHADER_BYTECODE {
    return if (opt_blob) |blob| .{
        .pShaderBytecode = blob.getBufferPointer(),
        .BytecodeLength = blob.getBufferSize(),
    } else .{ .pShaderBytecode = null, .BytecodeLength = 0 };
}

pub fn d3d12SrvDimension(dimension: gpu.TextureView.Dimension, sample_count: u32) d3d12.SRV_DIMENSION {
    return switch (dimension) {
        .undefined => unreachable,
        .@"1d" => .TEXTURE1D,
        .@"2d" => if (sample_count == 1) .TEXTURE2D else .TEXTURE2DMS,
        .@"2d_array" => if (sample_count == 1) .TEXTURE2DARRAY else .TEXTURE2DMSARRAY,
        .cube => .TEXTURECUBE,
        .cube_array => .TEXTURECUBEARRAY,
        .@"3d" => .TEXTURE3D,
    };
}

pub fn d3d12StencilOp(op: types.StencilOperation) d3d12.STENCIL_OP {
    return switch (op) {
        .keep => .KEEP,
        .zero => .ZERO,
        .replace => .REPLACE,
        .invert => .INVERT,
        .increment_clamp => .INCR_SAT,
        .decrement_clamp => .DECR_SAT,
        .increment_wrap => .INCR,
        .decrement_wrap => .DECR,
    };
}

pub fn d3d12StreamOutputDesc() d3d12.STREAM_OUTPUT_DESC {
    return .{
        .pSODeclaration = null,
        .NumEntries = 0,
        .pBufferStrides = null,
        .NumStrides = 0,
        .RasterizedStream = 0,
    };
}

pub fn d3d12TextureAddressMode(address_mode: gpu.Sampler.AddressMode) d3d12.TEXTURE_ADDRESS_MODE {
    return switch (address_mode) {
        .repeat => .WRAP,
        .mirror_repeat => .MIRROR,
        .clamp_to_edge => .CLAMP,
    };
}

pub fn d3d12UavDimension(dimension: gpu.TextureView.Dimension) d3d12.UAV_DIMENSION {
    return switch (dimension) {
        .dimension_undefined => unreachable,
        .dimension_1d => d3d12.UAV_DIMENSION_TEXTURE1D,
        .dimension_2d => d3d12.UAV_DIMENSION_TEXTURE2D,
        .dimension_2d_array => d3d12.UAV_DIMENSION_TEXTURE2DARRAY,
        .dimension_3d => d3d12.UAV_DIMENSION_TEXTURE3D,
        else => unreachable, // TODO - UAV cube maps?
    };
}

pub fn dxgiFormatForIndex(format: types.IndexFormat) dxgi.FORMAT {
    return switch (format) {
        .undefined => unreachable,
        .uint16 => .R16_UINT,
        .uint32 => .R32_UINT,
    };
}

pub fn dxgiFormatForTexture(format: gpu.Texture.Format) dxgi.FORMAT {
    return switch (format) {
        .undefined => unreachable,
        .r8_unorm => .R8_UNORM,
        .r8_snorm => .R8_SNORM,
        .r8_uint => .R8_UINT,
        .r8_sint => .R8_SINT,
        .r16_uint => .R16_UINT,
        .r16_sint => .R16_SINT,
        .r16_float => .R16_FLOAT,
        .rg8_unorm => .R8G8_UNORM,
        .rg8_snorm => .R8G8_SNORM,
        .rg8_uint => .R8G8_UINT,
        .rg8_sint => .R8G8_SINT,
        .r32_float => .R32_FLOAT,
        .r32_uint => .R32_UINT,
        .r32_sint => .R32_SINT,
        .rg16_uint => .R16G16_UINT,
        .rg16_sint => .R16G16_SINT,
        .rg16_float => .R16G16_FLOAT,
        .rgba8_unorm => .R8G8B8A8_UNORM,
        .rgba8_unorm_srgb => .R8G8B8A8_UNORM_SRGB,
        .rgba8_snorm => .R8G8B8A8_SNORM,
        .rgba8_uint => .R8G8B8A8_UINT,
        .rgba8_sint => .R8G8B8A8_SINT,
        .bgra8_unorm => .B8G8R8A8_UNORM,
        .bgra8_unorm_srgb => .B8G8R8A8_UNORM_SRGB,
        .rgb10_a2_unorm => .R10G10B10A2_UNORM,
        .rg11_b10_ufloat => .R11G11B10_FLOAT,
        .rgb9_e5_ufloat => .R9G9B9E5_SHAREDEXP,
        .rg32_float => .R32G32_FLOAT,
        .rg32_uint => .R32G32_UINT,
        .rg32_sint => .R32G32_SINT,
        .rgba16_uint => .R16G16B16A16_UINT,
        .rgba16_sint => .R16G16B16A16_SINT,
        .rgba16_float => .R16G16B16A16_FLOAT,
        .rgba32_float => .R32G32B32A32_FLOAT,
        .rgba32_uint => .R32G32B32A32_UINT,
        .rgba32_sint => .R32G32B32A32_SINT,
        .stencil8 => .D24_UNORM_S8_UINT,
        .depth16_unorm => .D16_UNORM,
        .depth24_plus => .D24_UNORM_S8_UINT,
        .depth24_plus_stencil8 => .D24_UNORM_S8_UINT,
        .depth32_float => .D32_FLOAT,
        .depth32_float_stencil8 => .D32_FLOAT_S8X24_UINT,
        .bc1_rgba_unorm => .BC1_UNORM,
        .bc1_rgba_unorm_srgb => .BC1_UNORM_SRGB,
        .bc2_rgba_unorm => .BC2_UNORM,
        .bc2_rgba_unorm_srgb => .BC2_UNORM_SRGB,
        .bc3_rgba_unorm => .BC3_UNORM,
        .bc3_rgba_unorm_srgb => .BC3_UNORM_SRGB,
        .bc4_runorm => .BC4_UNORM,
        .bc4_rsnorm => .BC4_SNORM,
        .bc5_rg_unorm => .BC5_UNORM,
        .bc5_rg_snorm => .BC5_SNORM,
        .bc6_hrgb_ufloat => .BC6H_UF16,
        .bc6_hrgb_float => .BC6H_SF16,
        .bc7_rgba_unorm => .BC7_UNORM,
        .bc7_rgba_unorm_srgb => .BC7_UNORM_SRGB,
        .etc2_rgb8_unorm,
        .etc2_rgb8_unorm_srgb,
        .etc2_rgb8_a1_unorm,
        .etc2_rgb8_a1_unorm_srgb,
        .etc2_rgba8_unorm,
        .etc2_rgba8_unorm_srgb,
        .eacr11_unorm,
        .eacr11_snorm,
        .eacrg11_unorm,
        .eacrg11_snorm,
        .astc4x4_unorm,
        .astc4x4_unorm_srgb,
        .astc5x4_unorm,
        .astc5x4_unorm_srgb,
        .astc5x5_unorm,
        .astc5x5_unorm_srgb,
        .astc6x5_unorm,
        .astc6x5_unorm_srgb,
        .astc6x6_unorm,
        .astc6x6_unorm_srgb,
        .astc8x5_unorm,
        .astc8x5_unorm_srgb,
        .astc8x6_unorm,
        .astc8x6_unorm_srgb,
        .astc8x8_unorm,
        .astc8x8_unorm_srgb,
        .astc10x5_unorm,
        .astc10x5_unorm_srgb,
        .astc10x6_unorm,
        .astc10x6_unorm_srgb,
        .astc10x8_unorm,
        .astc10x8_unorm_srgb,
        .astc10x10_unorm,
        .astc10x10_unorm_srgb,
        .astc12x10_unorm,
        .astc12x10_unorm_srgb,
        .astc12x12_unorm,
        .astc12x12_unorm_srgb,
        => unreachable,
        .r8_bg8_biplanar420_unorm => .NV12,
    };
}

pub fn dxgiFormatForTextureResource(format: gpu.Texture.Format, usage: gpu.Texture.UsageFlags, view_format_count: usize) dxgi.FORMAT {
    _ = usage;
    return if (view_format_count > 0)
        dxgiFormatTypeless(format)
    else
        dxgiFormatForTexture(format);
}

pub fn dxgiFormatForTextureView(format: gpu.Texture.Format, aspect: gpu.Texture.Aspect) dxgi.FORMAT {
    return switch (aspect) {
        .all => switch (format) {
            .stencil8 => .X24_TYPELESS_G8_UINT,
            .depth16_unorm => .R16_UNORM,
            .depth24_plus => .R24_UNORM_X8_TYPELESS,
            .depth32_float => .R32_FLOAT,
            else => dxgiFormatForTexture(format),
        },
        .stencil_only => switch (format) {
            .stencil8 => .X24_TYPELESS_G8_UINT,
            .depth24_plus_stencil8 => .X24_TYPELESS_G8_UINT,
            .depth32_float_stencil8 => .X32_TYPELESS_G8X24_UINT,
            else => unreachable,
        },
        .depth_only => switch (format) {
            .depth16_unorm => .R16_UNORM,
            .depth24_plus => .R24_UNORM_X8_TYPELESS,
            .depth24_plus_stencil8 => .R24_UNORM_X8_TYPELESS,
            .depth32_float => .R32_FLOAT,
            .depth32_float_stencil8 => .R32_FLOAT_X8X24_TYPELESS,
            else => unreachable,
        },
        .plane0_only => unreachable,
        .plane1_only => unreachable,
    };
}

pub fn dxgiFormatForVertex(format: types.VertexFormat) dxgi.FORMAT {
    return switch (format) {
        .undefined => unreachable,
        .uint8x2 => .R8G8_UINT,
        .uint8x4 => .R8G8B8A8_UINT,
        .sint8x2 => .R8G8_SINT,
        .sint8x4 => .R8G8B8A8_SINT,
        .unorm8x2 => .R8G8_UNORM,
        .unorm8x4 => .R8G8B8A8_UNORM,
        .snorm8x2 => .R8G8_SNORM,
        .snorm8x4 => .R8G8B8A8_SNORM,
        .uint16x2 => .R16G16_UINT,
        .uint16x4 => .R16G16B16A16_UINT,
        .sint16x2 => .R16G16_SINT,
        .sint16x4 => .R16G16B16A16_SINT,
        .unorm16x2 => .R16G16_UNORM,
        .unorm16x4 => .R16G16B16A16_UNORM,
        .snorm16x2 => .R16G16_SNORM,
        .snorm16x4 => .R16G16B16A16_SNORM,
        .float16x2 => .R16G16_FLOAT,
        .float16x4 => .R16G16B16A16_FLOAT,
        .float32 => .R32_FLOAT,
        .float32x2 => .R32G32_FLOAT,
        .float32x3 => .R32G32B32_FLOAT,
        .float32x4 => .R32G32B32A32_FLOAT,
        .uint32 => .R32_UINT,
        .uint32x2 => .R32G32_UINT,
        .uint32x3 => .R32G32B32_UINT,
        .uint32x4 => .R32G32B32A32_UINT,
        .sint32 => .R32_SINT,
        .sint32x2 => .R32G32_SINT,
        .sint32x3 => .R32G32B32_SINT,
        .sint32x4 => .R32G32B32A32_SINT,
    };
}

pub fn dxgiFormatTypeless(format: gpu.Texture.Format) dxgi.FORMAT {
    return switch (format) {
        .undefined => unreachable,
        .r8_unorm, .r8_snorm, .r8_uint, .r8_sint => .R8_TYPELESS,
        .r16_uint, .r16_sint, .r16_float => .R16_TYPELESS,
        .rg8_unorm, .rg8_snorm, .rg8_uint, .rg8_sint => .R8G8_TYPELESS,
        .r32_float, .r32_uint, .r32_sint => .R32_TYPELESS,
        .rg16_uint, .rg16_sint, .rg16_float => .R16G16_TYPELESS,
        .rgba8_unorm, .rgba8_unorm_srgb, .rgba8_snorm, .rgba8_uint, .rgba8_sint => .R8G8B8A8_TYPELESS,
        .bgra8_unorm, .bgra8_unorm_srgb => .B8G8R8A8_TYPELESS,
        .rgb10_a2_unorm => .R10G10B10A2_TYPELESS,
        .rg11_b10_ufloat => .R11G11B10_FLOAT,
        .rgb9_e5_ufloat => .R9G9B9E5_SHAREDEXP,
        .rg32_float, .rg32_uint, .rg32_sint => .R32G32_TYPELESS,
        .rgba16_uint, .rgba16_sint, .rgba16_float => .R16G16B16A16_TYPELESS,
        .rgba32_float, .rgba32_uint, .rgba32_sint => .R32G32B32A32_TYPELESS,
        .stencil8 => .R24G8_TYPELESS,
        .depth16_unorm => .R16_TYPELESS,
        .depth24_plus => .R24G8_TYPELESS,
        .depth24_plus_stencil8 => .R24G8_TYPELESS,
        .depth32_float => .R32_TYPELESS,
        .depth32_float_stencil8 => .R32G8X24_TYPELESS,
        .bc1_rgba_unorm, .bc1_rgba_unorm_srgb => .BC1_TYPELESS,
        .bc2_rgba_unorm, .bc2_rgba_unorm_srgb => .BC2_TYPELESS,
        .bc3_rgba_unorm, .bc3_rgba_unorm_srgb => .BC3_TYPELESS,
        .bc4_runorm, .bc4_rsnorm => .BC4_TYPELESS,
        .bc5_rg_unorm, .bc5_rg_snorm => .BC5_TYPELESS,
        .bc6_hrgb_ufloat, .bc6_hrgb_float => .BC6H_TYPELESS,
        .bc7_rgba_unorm, .bc7_rgba_unorm_srgb => .BC7_TYPELESS,
        .etc2_rgb8_unorm,
        .etc2_rgb8_unorm_srgb,
        .etc2_rgb8_a1_unorm,
        .etc2_rgb8_a1_unorm_srgb,
        .etc2_rgba8_unorm,
        .etc2_rgba8_unorm_srgb,
        .eacr11_unorm,
        .eacr11_snorm,
        .eacrg11_unorm,
        .eacrg11_snorm,
        .astc4x4_unorm,
        .astc4x4_unorm_srgb,
        .astc5x4_unorm,
        .astc5x4_unorm_srgb,
        .astc5x5_unorm,
        .astc5x5_unorm_srgb,
        .astc6x5_unorm,
        .astc6x5_unorm_srgb,
        .astc6x6_unorm,
        .astc6x6_unorm_srgb,
        .astc8x5_unorm,
        .astc8x5_unorm_srgb,
        .astc8x6_unorm,
        .astc8x6_unorm_srgb,
        .astc8x8_unorm,
        .astc8x8_unorm_srgb,
        .astc10x5_unorm,
        .astc10x5_unorm_srgb,
        .astc10x6_unorm,
        .astc10x6_unorm_srgb,
        .astc10x8_unorm,
        .astc10x8_unorm_srgb,
        .astc10x10_unorm,
        .astc10x10_unorm_srgb,
        .astc12x10_unorm,
        .astc12x10_unorm_srgb,
        .astc12x12_unorm,
        .astc12x12_unorm_srgb,
        => unreachable,
        .r8_bg8_biplanar420_unorm => .NV12,
    };
}

pub fn dxgiFormatIsTypeless(format: dxgi.FORMAT) bool {
    return switch (format) {
        .R32G32B32A32_TYPELESS,
        .R32G32B32_TYPELESS,
        .R16G16B16A16_TYPELESS,
        .R32G32_TYPELESS,
        .R32G8X24_TYPELESS,
        .R32_FLOAT_X8X24_TYPELESS,
        .R10G10B10A2_TYPELESS,
        .R8G8B8A8_TYPELESS,
        .R16G16_TYPELESS,
        .R32_TYPELESS,
        .R24G8_TYPELESS,
        .R8G8_TYPELESS,
        .R16_TYPELESS,
        .R8_TYPELESS,
        .BC1_TYPELESS,
        .BC2_TYPELESS,
        .BC3_TYPELESS,
        .BC4_TYPELESS,
        .BC5_TYPELESS,
        .B8G8R8A8_TYPELESS,
        .BC6H_TYPELESS,
        .BC7_TYPELESS,
        => true,
        else => false,
    };
}

pub fn dxgiUsage(usage: gpu.Texture.UsageFlags) dxgi.USAGE {
    return .{
        .SHADER_INPUT = usage.texture_binding,
        .UNORDERED_ACCESS = usage.storage_binding,
        .RENDER_TARGET_OUTPUT = usage.render_attachment,
    };
}

pub fn alignUp(x: usize, a: usize) usize {
    return (x + a - 1) / a * a;
}

pub const FormatType = enum {
    float,
    unorm,
    unorm_srgb,
    snorm,
    uint,
    sint,
    depth,
    stencil,
    depth_stencil,
};

pub fn textureFormatType(format: gpu.Texture.Format) FormatType {
    return switch (format) {
        .undefined => unreachable,
        .r8_unorm => .unorm,
        .r8_snorm => .snorm,
        .r8_uint => .uint,
        .r8_sint => .sint,
        .r16_uint => .uint,
        .r16_sint => .sint,
        .r16_float => .float,
        .rg8_unorm => .unorm,
        .rg8_snorm => .snorm,
        .rg8_uint => .uint,
        .rg8_sint => .sint,
        .r32_float => .float,
        .r32_uint => .uint,
        .r32_sint => .sint,
        .rg16_uint => .uint,
        .rg16_sint => .sint,
        .rg16_float => .float,
        .rgba8_unorm => .unorm,
        .rgba8_unorm_srgb => .unorm_srgb,
        .rgba8_snorm => .snorm,
        .rgba8_uint => .uint,
        .rgba8_sint => .sint,
        .bgra8_unorm => .unorm,
        .bgra8_unorm_srgb => .unorm_srgb,
        .rgb10_a2_unorm => .unorm,
        .rg11_b10_ufloat => .float,
        .rgb9_e5_ufloat => .float,
        .rg32_float => .float,
        .rg32_uint => .uint,
        .rg32_sint => .sint,
        .rgba16_uint => .uint,
        .rgba16_sint => .sint,
        .rgba16_float => .float,
        .rgba32_float => .float,
        .rgba32_uint => .uint,
        .rgba32_sint => .sint,
        .stencil8 => .stencil,
        .depth16_unorm => .depth,
        .depth24_plus => .depth,
        .depth24_plus_stencil8 => .depth_stencil,
        .depth32_float => .depth,
        .depth32_float_stencil8 => .depth_stencil,
        .bc1_rgba_unorm => .unorm,
        .bc1_rgba_unorm_srgb => .unorm_srgb,
        .bc2_rgba_unorm => .unorm,
        .bc2_rgba_unorm_srgb => .unorm_srgb,
        .bc3_rgba_unorm => .unorm,
        .bc3_rgba_unorm_srgb => .unorm_srgb,
        .bc4_runorm => .unorm,
        .bc4_rsnorm => .snorm,
        .bc5_rg_unorm => .unorm,
        .bc5_rg_snorm => .snorm,
        .bc6_hrgb_ufloat => .float,
        .bc6_hrgb_float => .float,
        .bc7_rgba_unorm => .unorm,
        .bc7_rgba_unorm_srgb => .snorm,
        .etc2_rgb8_unorm => .unorm,
        .etc2_rgb8_unorm_srgb => .unorm_srgb,
        .etc2_rgb8_a1_unorm => .unorm_srgb,
        .etc2_rgb8_a1_unorm_srgb => .unorm,
        .etc2_rgba8_unorm => .unorm,
        .etc2_rgba8_unorm_srgb => .unorm_srgb,
        .eacr11_unorm => .unorm,
        .eacr11_snorm => .snorm,
        .eacrg11_unorm => .unorm,
        .eacrg11_snorm => .snorm,
        .astc4x4_unorm => .unorm,
        .astc4x4_unorm_srgb => .unorm_srgb,
        .astc5x4_unorm => .unorm,
        .astc5x4_unorm_srgb => .unorm_srgb,
        .astc5x5_unorm => .unorm,
        .astc5x5_unorm_srgb => .unorm_srgb,
        .astc6x5_unorm => .unorm,
        .astc6x5_unorm_srgb => .unorm_srgb,
        .astc6x6_unorm => .unorm,
        .astc6x6_unorm_srgb => .unorm_srgb,
        .astc8x5_unorm => .unorm,
        .astc8x5_unorm_srgb => .unorm_srgb,
        .astc8x6_unorm => .unorm,
        .astc8x6_unorm_srgb => .unorm_srgb,
        .astc8x8_unorm => .unorm,
        .astc8x8_unorm_srgb => .unorm_srgb,
        .astc10x5_unorm => .unorm,
        .astc10x5_unorm_srgb => .unorm_srgb,
        .astc10x6_unorm => .unorm,
        .astc10x6_unorm_srgb => .unorm_srgb,
        .astc10x8_unorm => .unorm,
        .astc10x8_unorm_srgb => .unorm_srgb,
        .astc10x10_unorm => .unorm,
        .astc10x10_unorm_srgb => .unorm_srgb,
        .astc12x10_unorm => .unorm,
        .astc12x10_unorm_srgb => .unorm_srgb,
        .astc12x12_unorm => .unorm,
        .astc12x12_unorm_srgb => .unorm_srgb,
        .r8_bg8_biplanar420_unorm => .unorm,
    };
}

pub fn formatHasDepthOrStencil(format: gpu.Texture.Format) bool {
    return switch (textureFormatType(format)) {
        .depth, .stencil, .depth_stencil => true,
        else => false,
    };
}
