const sysgpu = @import("../gpu.zig");
const w32 = @import("w32");
const dxgi = w32.dxgi;
const d3d12 = w32.d3d12;

pub fn formatToTexture(self: sysgpu.Texture.Format) dxgi.FORMAT {
    return switch (self) {
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

pub fn usage(self: sysgpu.Texture.UsageFlags) dxgi.USAGE {
    return .{
        .SHADER_INPUT = self.texture_binding,
        .UNORDERED_ACCESS = self.storage_binding,
        .RENDER_TARGET_OUTPUT = self.render_attachment,
    };
}

pub fn streamOutputDesc() d3d12.STREAM_OUTPUT_DESC {
    return .{
        .pSODeclaration = null,
        .NumEntries = 0,
        .pBufferStrides = null,
        .NumStrides = 0,
        .RasterizedStream = 0,
    };
}

pub fn shaderBytecode(blob: *d3d12.IBlob) d3d12.SHADER_BYTECODE {
    return .{
        .pShaderBytecode = blob.getBufferPointer(),
        .BytecodeLength = blob.getBufferSize(),
    };
}

pub fn blendDesc(desc: sysgpu.RenderPipeline.Descriptor) d3d12.BLEND_DESC {
    var targets = [_]d3d12.RENDER_TARGET_BLEND_DESC{renderTargetBlendDesc(null)} ** 8;
    if (desc.fragment) |frag| {
        for (frag.targets, 0..) |target, i| {
            targets[i] = renderTargetBlendDesc(target);
        }
    }

    return .{
        .AlphaToCoverageEnable = @intFromBool(desc.multisample.alpha_to_coverage_enabled),
        .IndependentBlendEnable = 1,
        .RenderTarget = targets,
    };
}

pub fn renderTargetBlendDesc(opt_target: ?sysgpu.ColorTargetState) d3d12.RENDER_TARGET_BLEND_DESC {
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
        desc.RenderTargetWriteMask = renderTargetWriteMask(target.write_mask);
        if (target.blend) |b| {
            desc.BlendEnable = 1;
            desc.SrcBlend = blend(b.color.src_factor);
            desc.DestBlend = blend(b.color.dst_factor);
            desc.BlendOp = blendOp(b.color.operation);
            desc.SrcBlendAlpha = blend(b.alpha.src_factor);
            desc.DestBlendAlpha = blend(b.alpha.dst_factor);
            desc.BlendOpAlpha = blendOp(b.alpha.operation);
        }
    }

    return desc;
}

pub fn renderTargetWriteMask(mask: sysgpu.ColorWriteMaskFlags) d3d12.COLOR_WRITE_ENABLE {
    return .{
        .RED = mask.red,
        .GREEN = mask.green,
        .BLUE = mask.blue,
        .ALPHA = mask.alpha,
    };
}

pub fn blend(factor: sysgpu.BlendFactor) d3d12.BLEND {
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

pub fn blendOp(op: sysgpu.BlendOperation) d3d12.BLEND_OP {
    return switch (op) {
        .add => .ADD,
        .subtract => .SUBTRACT,
        .reverse_subtract => .REV_SUBTRACT,
        .min => .MIN,
        .max => .MAX,
    };
}
