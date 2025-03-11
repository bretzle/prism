const std = @import("std");
const gpu = @import("../gpu.zig");
const d3d11 = @import("../zwindows/d3d11.zig");

const impl = @import("d3d11.zig");
const conv = @import("d3d11_conv.zig");

const List = std.ArrayListUnmanaged;

const allocator = gpu.allocator;

const CachedInputLayout = struct {
    shader_hash: u32,
    format: gpu.VertexFormat,
    layout: *d3d11.IInputLayout,
};

const CachedBlendState = struct {
    blend: gpu.BlendMode,
    state: *d3d11.IBlendState,
};

const CachedRasterizer = struct {
    cull: gpu.Cull,
    state: *d3d11.IRasterizerState,
};

const CachedSampler = struct {
    sampler: gpu.TextureSampler,
    state: *d3d11.ISamplerState,
};

const CachedDepthStencil = struct {
    depth: gpu.Compare,
    state: *d3d11.IDepthStencilState,
};

var layout_cache: List(CachedInputLayout) = .empty;
var blend_cache: List(CachedBlendState) = .empty;
var rasterizer_cache: List(CachedRasterizer) = .empty;
var sampler_cache: List(CachedSampler) = .empty;
var depthstencil_cache: List(CachedDepthStencil) = .empty;

pub fn getLayout(shader: *impl.Shader, format: *const gpu.VertexFormat) ?*d3d11.IInputLayout {
    for (layout_cache.items) |it| {
        if (it.shader_hash == shader.hash and it.format.stride == format.stride and it.format.attributes.len == format.attributes.len) {
            var same_format = true;
            for (0..format.attributes.len) |n| {
                if (it.format.attributes.buffer[n].index != format.attributes.buffer[n].index or
                    it.format.attributes.buffer[n].type != format.attributes.buffer[n].type or
                    it.format.attributes.buffer[n].normalized != format.attributes.buffer[n].normalized)
                {
                    same_format = false;
                    break;
                }
            }

            if (same_format) return it.layout;
        }
    }

    var descs = std.BoundedArray(d3d11.INPUT_ELEMENT_DESC, 16){};
    for (0..shader.attributes.len) |i| {
        const it = descs.addOne() catch unreachable;
        it.SemanticName = shader.attributes.buffer[i].name.ptr;
        it.SemanticIndex = shader.attributes.buffer[i].index;

        if (!format.attributes.buffer[i].normalized) {
            it.Format = switch (format.attributes.buffer[i].type) {
                .none => unreachable,
                .float => .R32_FLOAT,
                .float2 => .R32G32_FLOAT,
                .float3 => .R32G32B32_FLOAT,
                .float4 => .R32G32B32A32_FLOAT,
                .byte4 => .R8G8B8A8_SINT,
                .ubyte4 => .R8G8B8A8_UINT,
                .short2 => .R16G16_SINT,
                .ushort2 => .R16G16_UINT,
                .short4 => .R16G16B16A16_SINT,
                .ushort4 => .R16G16B16A16_UINT,
            };
        } else {
            it.Format = switch (format.attributes.buffer[i].type) {
                .none => unreachable,
                .float => .R32_FLOAT,
                .float2 => .R32G32_FLOAT,
                .float3 => .R32G32B32_FLOAT,
                .float4 => .R32G32B32A32_FLOAT,
                .byte4 => .R8G8B8A8_SNORM,
                .ubyte4 => .R8G8B8A8_UNORM,
                .short2 => .R16G16_SNORM,
                .ushort2 => .R16G16_UNORM,
                .short4 => .R16G16B16A16_SNORM,
                .ushort4 => .R16G16B16A16_UNORM,
            };
        }

        it.InputSlot = 0;
        it.AlignedByteOffset = if (i == 0) 0 else d3d11.APPEND_ALIGNED_ELEMENT;
        it.InputSlotClass = .INPUT_PER_VERTEX_DATA;
        it.InstanceDataStepRate = 0;
    }

    var layout: *d3d11.IInputLayout = undefined;
    const hr = impl.device.CreateInputLayout(
        &descs.buffer,
        @intCast(descs.len),
        shader.vertex_blob.GetBufferPointer(),
        shader.vertex_blob.GetBufferSize(),
        @ptrCast(&layout),
    );
    std.debug.assert(hr == 0);

    const entry = layout_cache.addOne(allocator) catch unreachable;
    entry.* = .{
        .shader_hash = shader.hash,
        .format = format.*,
        .layout = layout,
    };
    return layout;
}

pub fn getBlend(blend: *const gpu.BlendMode) ?*d3d11.IBlendState {
    for (blend_cache.items) |it| {
        if (it.blend.eq(blend.*)) {
            return it.state;
        }
    }

    var desc = std.mem.zeroInit(d3d11.BLEND_DESC, .{
        .AlphaToCoverageEnable = 0,
        .IndependentBlendEnable = 0,
    });

    desc.RenderTarget[0].BlendEnable = @intFromBool(!(blend.color_src == .one and blend.color_dst == .zero and
        blend.alpha_src == .one and blend.alpha_dst == .zero));

    desc.RenderTarget[0].RenderTargetWriteMask = .{
        .RED = blend.mask.red,
        .GREEN = blend.mask.green,
        .BLUE = blend.mask.blue,
        .ALPHA = blend.mask.alpha,
    };

    if (desc.RenderTarget[0].BlendEnable != 0) {
        desc.RenderTarget[0].BlendOp = conv.blend_op(blend.color_op);
        desc.RenderTarget[0].SrcBlend = conv.blend_factor(blend.color_src);
        desc.RenderTarget[0].DestBlend = conv.blend_factor(blend.color_dst);

        desc.RenderTarget[0].BlendOpAlpha = conv.blend_op(blend.alpha_op);
        desc.RenderTarget[0].SrcBlendAlpha = conv.blend_factor(blend.alpha_src);
        desc.RenderTarget[0].DestBlendAlpha = conv.blend_factor(blend.alpha_dst);
    }

    for (1..8) |i| {
        desc.RenderTarget[i] = desc.RenderTarget[0];
    }

    var blend_state: *d3d11.IBlendState = undefined;
    const hr = impl.device.CreateBlendState(&desc, @ptrCast(&blend_state));
    std.debug.assert(hr == 0);

    const entry = blend_cache.addOne(allocator) catch unreachable;
    entry.* = .{
        .blend = blend.*,
        .state = blend_state,
    };
    return blend_state;
}

pub fn getRasterizer(cull: gpu.Cull) ?*d3d11.IRasterizerState {
    for (rasterizer_cache.items) |it| {
        if (it.cull == cull) {
            return it.state;
        }
    }

    const desc = d3d11.RASTERIZER_DESC{
        .FillMode = .SOLID,
        .CullMode = switch (cull) {
            .none => .NONE,
            .front => .FRONT,
            .back => .BACK,
        },
        .FrontCounterClockwise = 1,
        .DepthBias = 0,
        .DepthBiasClamp = 0,
        .SlopeScaledDepthBias = 0,
        .DepthClipEnable = 0,
        .ScissorEnable = 1,
        .MultisampleEndable = 0,
        .AntialiasedLineEnable = 0,
    };

    var result: *d3d11.IRasterizerState = undefined;
    const hr = impl.device.CreateRasterizerState(&desc, @ptrCast(&result));
    std.debug.assert(hr == 0);

    const entry = rasterizer_cache.addOne(allocator) catch unreachable;
    entry.* = .{
        .cull = cull,
        .state = result,
    };
    return result;
}

pub fn getSampler(sampler: gpu.TextureSampler) ?*d3d11.ISamplerState {
    for (sampler_cache.items) |it| {
        if (it.sampler.eq(sampler)) {
            return it.state;
        }
    }

    const desc = d3d11.SAMPLER_DESC{
        .Filter = switch (sampler.filter) {
            .none, .nearest => .MIN_MAG_MIP_POINT,
            .linear => .MIN_MAG_MIP_LINEAR,
        },
        .AddressU = switch (sampler.wrap_x) {
            .none, .repeat => .WRAP,
            .clamp => .CLAMP,
        },
        .AddressV = switch (sampler.wrap_y) {
            .none, .repeat => .WRAP,
            .clamp => .CLAMP,
        },
        .AddressW = .WRAP,
        .ComparisonFunc = .NEVER,
    };

    var result: *d3d11.ISamplerState = undefined;
    const hr = impl.device.CreateSamplerState(&desc, @ptrCast(&result));
    std.debug.assert(hr == 0);

    const entry = sampler_cache.addOne(allocator) catch unreachable;
    entry.* = .{
        .sampler = sampler,
        .state = result,
    };
    return result;
}

pub fn getDepthstencil(depth: gpu.Compare) ?*d3d11.IDepthStencilState {
    for (depthstencil_cache.items) |it| {
        if (it.depth == depth) {
            return it.state;
        }
    }

    const desc = d3d11.DEPTH_STENCIL_DESC{
        .DepthEnable = @intFromBool(depth != .none),
        .DepthWriteMask = .ALL,
        .DepthFunc = switch (depth) {
            .none => .NEVER,
            .always => unreachable,
            .never => unreachable,
            .less => unreachable,
            .equal => unreachable,
            .less_or_equal => unreachable,
            .greater => unreachable,
            .not_equal => unreachable,
            .greater_or_equal => unreachable,
        },
    };

    var result: *d3d11.IDepthStencilState = undefined;
    const hr = impl.device.CreateDepthStencilState(&desc, @ptrCast(&result));
    std.debug.assert(hr == 0);

    const entry = depthstencil_cache.addOne(allocator) catch unreachable;
    entry.* = .{
        .depth = depth,
        .state = result,
    };
    return result;
}
