const std = @import("std");
const builtin = @import("builtin");
const math = @import("../math.zig");
const dxgi = @import("../zwindows/dxgi.zig");
const d3d11 = @import("../zwindows/d3d11.zig");
const d3dcommon = @import("../zwindows/d3dcommon.zig");
const d3dcompiler = @import("../zwindows/d3dcompiler.zig");
const w32 = @import("../zwindows/windows.zig");
const gpu = @import("../gpu.zig");

const Color = @import("../Color.zig").Color;
const List = std.ArrayListUnmanaged;

const StoredInputLayout = struct {
    shader_hash: u32,
    format: gpu.VertexFormat,
    layout: *d3d11.IInputLayout,
};

const StoredBlendState = struct {
    blend: gpu.BlendMode,
    state: *d3d11.IBlendState,
};

const StoredRasterizer = struct {
    cull: gpu.Cull,
    state: *d3d11.IRasterizerState,
};

const StoredSampler = struct {
    sampler: gpu.TextureSampler,
    state: *d3d11.ISamplerState,
};

const StoredDepthStencil = struct {
    depth: gpu.Compare,
    state: *d3d11.IDepthStencilState,
};

const allocator = gpu.allocator;

// render state
var device: *d3d11.IDevice = undefined;
var context: *d3d11.IDeviceContext = undefined;
var swap_chain: *dxgi.ISwapChain = undefined;
var backbuffer_view: ?*d3d11.IRenderTargetView = null;
var drawable_size: math.Point = undefined;
var last_window_size: math.Point = undefined;

var layout_cache: List(StoredInputLayout) = .empty;
var blend_cache: List(StoredBlendState) = .empty;
var rasterizer_cache: List(StoredRasterizer) = .empty;
var sampler_cache: List(StoredSampler) = .empty;
var depthstencil_cache: List(StoredDepthStencil) = .empty;

pub fn init(size: math.Point, handle: *anyopaque) !void {
    last_window_size = size;

    const desc = std.mem.zeroInit(dxgi.SWAP_CHAIN_DESC, .{
        .BufferDesc = .{
            .RefreshRate = .{ .Numerator = 0, .Denominator = 1 },
            .Format = .B8G8R8A8_UNORM,
        },
        .SampleDesc = .{ .Count = 1, .Quality = 0 },
        .BufferUsage = .{ .RENDER_TARGET_OUTPUT = true },
        .BufferCount = 1,
        .OutputWindow = @ptrCast(handle),
        .Windowed = 1,
    });

    const flags = d3d11.CREATE_DEVICE_FLAG{
        .SINGLETHREADED = true,
        .DEBUG = builtin.mode == .Debug,
    };

    var feature_level: d3dcommon.FEATURE_LEVEL = undefined;
    vhr(d3d11.D3D11CreateDeviceAndSwapChain(
        null,
        .HARDWARE,
        null,
        flags,
        null,
        0,
        d3d11.SDK_VERSION,
        &desc,
        @ptrCast(&swap_chain),
        @ptrCast(&device),
        @ptrCast(&feature_level),
        @ptrCast(&context),
    ));

    var framebuffer: *d3d11.ITexture2D = undefined;
    vhr(swap_chain.GetBuffer(0, &d3d11.IID_ITexture2D, @ptrCast(&framebuffer)));
    defer _ = framebuffer.Release();

    var tdesc: d3d11.TEXTURE2D_DESC = undefined;
    framebuffer.GetDesc(&tdesc);
    drawable_size = .{ .x = @intCast(tdesc.Width), .y = @intCast(tdesc.Height) };

    vhr(device.CreateRenderTargetView(@ptrCast(framebuffer), null, @ptrCast(&backbuffer_view)));
}

pub fn applyPipeline(pipeline: *Pipeline, shader: *Shader) void {
    if (getRasterizer(pipeline.cull)) |rs| context.RSSetState(rs);

    if (getDepthstencil(pipeline.depth)) |ds| context.OMSetDepthStencilState(ds, 0);
    if (getBlend(&pipeline.blend)) |blend| {
        const color = Color.rgba(pipeline.blend.rgba);
        const factor = [4]f32{ asF32(color.r) / 255.0, asF32(color.g) / 255.0, asF32(color.b) / 255.0, asF32(color.a) / 255.0 };
        const mask = 0xFFFFFFFF;
        context.OMSetBlendState(blend, &factor, mask);
    } else {
        context.OMSetBlendState(null, null, 0);
    }

    context.IASetPrimitiveTopology(.TRIANGLELIST);
    const layout = getLayout(shader, &pipeline.vertex_format);
    context.IASetInputLayout(layout);

    context.VSSetShader(unreachable, unreachable, unreachable);
    context.VSSetConstantBuffers(unreachable, unreachable, unreachable);

    context.PSSetShader(unreachable, unreachable, unreachable);
    context.PSSetConstantBuffers(unreachable, unreachable, unreachable);
}

pub fn applyBindings(bindings: gpu.Bindings) void {
    _ = bindings; // autofix
    // IASetVertexBuffers
    // IASetIndexBuffer
    // VSSetShaderResources
    // PSSetShaderResources
    // VSSetSamplers
    // PSSetSamplers
    unreachable;
}

pub fn applyViewport(x: i32, y: i32, w: i32, h: i32) void {
    const rect = d3d11.VIEWPORT{
        .TopLeftX = @floatFromInt(x),
        .TopLeftY = @floatFromInt(y),
        .Width = @floatFromInt(w),
        .Height = @floatFromInt(h),
        .MinDepth = 0,
        .MaxDepth = 1,
    };

    context.RSSetViewports(1, @ptrCast(&rect));
}

pub fn applyScissor(x: i32, y: i32, w: i32, h: i32) void {
    const rect = d3d11.RECT{
        .left = x,
        .top = y,
        .right = x + w,
        .bottom = y + h,
    };

    context.RSSetScissorRects(1, @ptrCast(&rect));
}

pub fn draw(base: u32, elements: u32, instances: u32) void {
    std.debug.assert(instances == 0); // TODO
    context.DrawIndexed(elements, base, 0);
}

pub fn applyUniforms() void {
    // UpdateSubresource
    unreachable;
}

pub const Buffer = struct {
    raw: *d3d11.IBuffer,
    len: usize,
    cap: usize,
    stride: u32,
    format: gpu.BufferFormat,

    pub fn create(desc: gpu.BufferDesc) Buffer {
        const stride = switch (desc.format) {
            .vertex => |v| v.stride,
            .index => |i| switch (i) {
                .u16 => 2,
                .u32 => 4,
            },
        };
        const buffer_desc = d3d11.BUFFER_DESC{
            .ByteWidth = desc.size_in_bytes,
            .Usage = .DYNAMIC,
            .BindFlags = .{
                .VERTEX_BUFFER = desc.format == .vertex,
                .INDEX_BUFFER = desc.format == .index,
            },
            .CPUAccessFlags = .{ .WRITE = true },
        };

        const res_data = d3d11.SUBRESOURCE_DATA{ .pSysMem = @ptrCast(desc.content) };

        var buffer: *d3d11.IBuffer = undefined;
        const hr = device.CreateBuffer(&buffer_desc, &res_data, @ptrCast(&buffer));
        std.debug.assert(hr == 0);

        return .{
            .raw = buffer,
            .len = if (desc.content) |cnt| cnt.len * desc.size_in_bytes else 0,
            .cap = desc.size_in_bytes,
            .stride = stride,
            .format = desc.format,
        };
    }

    pub fn update(self: *Buffer, bytes: []const u8) void {
        var map: d3d11.MAPPED_SUBRESOURCE = undefined;
        const hr = context.Map(@ptrCast(self.raw), 0, .WRITE_DISCARD, .{}, &map);
        std.debug.assert(hr == 0);
        defer context.Unmap(@ptrCast(self.raw), 0);

        @memcpy(@as([*]u8, @ptrCast(map.pData)), bytes);
    }

    // TODO: append? resize? reconfigure
};

pub const Shader = struct {
    vertex: *d3d11.IVertexShader,
    fragment: *d3d11.IPixelShader,
    vertex_blob: *d3dcommon.IBlob,
    fragment_blob: *d3dcommon.IBlob,
    vertex_uniform_buffers: []*d3d11.IBuffer,
    fragment_uniform_buffers: []*d3d11.IBuffer,
    vertex_uniform_values: []List(f32),
    fragment_uniform_values: []List(f32),
    attributes: std.BoundedArray(gpu.ShaderData.HLSLAttribute, 16),
    uniform_list: []gpu.UniformInfo,
    hash: u32,

    pub fn create(data: gpu.ShaderDesc) !Shader {
        var vertex: *d3d11.IVertexShader = undefined;
        var fragment: *d3d11.IPixelShader = undefined;

        const vertex_blob = compile(data.vertex, "vs_main", "vs_5_0");
        const fragment_blob = compile(data.fragment, "ps_main", "ps_5_0");

        _ = device.CreateVertexShader(vertex_blob.GetBufferPointer(), vertex_blob.GetBufferSize(), null, @ptrCast(&vertex));
        _ = device.CreatePixelShader(fragment_blob.GetBufferPointer(), fragment_blob.GetBufferSize(), null, @ptrCast(&fragment));

        var uniform_list = std.ArrayList(gpu.UniformInfo).init(allocator);
        const vertex_uniform_buffers = try reflect_uniforms(&uniform_list, vertex_blob, .vertex);
        const fragment_uniform_buffers = try reflect_uniforms(&uniform_list, fragment_blob, .fragment);

        checkUniforms(uniform_list.items);

        const vertex_uniform_values = try allocator.alloc(List(f32), vertex_uniform_buffers.items.len);
        const fragment_uniform_values = try allocator.alloc(List(f32), fragment_uniform_buffers.items.len);

        @memset(vertex_uniform_values, .empty);
        @memset(fragment_uniform_values, .empty);

        return .{
            .vertex = vertex,
            .fragment = fragment,
            .vertex_blob = vertex_blob,
            .fragment_blob = fragment_blob,
            .vertex_uniform_buffers = vertex_uniform_buffers,
            .fragment_uniform_buffers = fragment_uniform_buffers,
            .vertex_uniform_values = vertex_uniform_values,
            .fragment_uniform_values = fragment_uniform_values,
            .attributes = data.hlsl_attributes,
            .uniform_list = try uniform_list.toOwnedSlice(),
            .hash = calcHash(data.hlsl_attributes.constSlice()),
        };
    }

    fn compile(data: []const u8, entrypoint: w32.LPCSTR, target: w32.LPCSTR) *d3dcommon.IBlob {
        var code_blob: *d3dcommon.IBlob = undefined;
        var error_blob: *d3dcommon.IBlob = undefined;
        const hr = d3dcompiler.D3DCompile(
            data.ptr,
            data.len,
            null,
            null,
            null,
            entrypoint,
            target,
            d3dcompiler.COMPILE_ENABLE_STRICTNESS | d3dcompiler.COMPILE_DEBUG,
            0,
            &code_blob,
            &error_blob,
        );

        if (hr != 0) {
            std.debug.panic("{s}", .{@as([*]const u8, @ptrCast(error_blob.GetBufferPointer()))[0..error_blob.GetBufferSize()]});
        }

        return code_blob;
    }

    fn checkUniforms(items: []const gpu.UniformInfo) void {
        // combine uniforms that were in both lists
        for (0..items.len) |i| {
            for (i + 1..items.len) |j| {
                if (std.mem.eql(u8, items[i].name, items[j].name)) {
                    if (items[i].type == items[j].type) {
                        unreachable;
                    }
                }
            }
        }
    }

    fn calcHash(attrs: []gpu.ShaderDesc.HLSLAttribute) u32 {
        var hash: u32 = 5381;
        for (attrs) |attr| {
            for (attr.name) |c| {
                hash = ((hash << 5) +% hash) +% c;
            }
            hash = (@as(u32, attr.index) << 5) +% hash;
        }
        return hash;
    }

    fn reflect_uniforms(append_uniforms_to: *std.ArrayList(gpu.UniformInfo), shader: *d3dcommon.IBlob, shader_type: gpu.ShaderType) !std.ArrayList(*d3d11.IBuffer) {
        var append_buffers_to = std.ArrayList(*d3d11.IBuffer).init(allocator);

        var reflector: *d3d11.IShaderReflection = undefined;
        vhr(d3dcompiler.D3DReflect(shader.GetBufferPointer(), shader.GetBufferSize(), &d3d11.IID_IShaderReflection, @ptrCast(&reflector)));

        var shader_desc: d3d11.SHADER_DESC = undefined;
        vhr(reflector.GetDesc(&shader_desc));

        for (0..shader_desc.BoundResources) |i| {
            var desc: d3d11.SHADER_INPUT_BIND_DESC = undefined;
            vhr(reflector.GetResourceBindingDesc(@intCast(i), &desc));

            if (desc.Type == .TEXTURE and desc.Dimension == .TEXTURE2D) {
                const uniform = try append_uniforms_to.addOne();
                uniform.* = gpu.UniformInfo{
                    .name = std.mem.span(desc.Name),
                    .shader = shader_type,
                    .register_index = @intCast(desc.BindPoint),
                    .buffer_index = 0,
                    .array_length = @intCast(@max(1, desc.BindCount)),
                    .type = .texture_2d,
                };
            } else if (desc.Type == .SAMPLER) {
                const uniform = try append_uniforms_to.addOne();
                uniform.* = gpu.UniformInfo{
                    .name = std.mem.span(desc.Name),
                    .shader = shader_type,
                    .register_index = @intCast(desc.BindPoint),
                    .buffer_index = 0,
                    .array_length = @intCast(@max(1, desc.BindCount)),
                    .type = .sampler_2d,
                };
            }
        }

        for (0..shader_desc.ConstantBuffers) |i| {
            var desc: d3d11.SHADER_BUFFER_DESC = undefined;
            const cb = reflector.GetConstantBufferByIndex(@intCast(i));
            cb.GetDesc(&desc);

            // create the constant buffer for assigning data later
            {
                const buffer_desc = d3d11.BUFFER_DESC{
                    .ByteWidth = desc.Size,
                    .Usage = .DYNAMIC,
                    .BindFlags = .{ .CONSTANT_BUFFER = true },
                    .CPUAccessFlags = .{ .WRITE = true },
                };

                var buffer: *d3d11.IBuffer = undefined;
                vhr(device.CreateBuffer(&buffer_desc, null, @ptrCast(&buffer)));
                try append_buffers_to.append(buffer);
            }

            for (0..desc.Variables) |j| {
                var var_desc: d3d11.SHADER_VARIABLE_DESC = undefined;
                var type_desc: d3d11.SHADER_TYPE_DESC = undefined;

                const var_ = cb.GetVariableByIndex(@intCast(j));
                vhr(var_.GetDesc(&var_desc));

                const type_ = var_.GetType();
                vhr(type_.GetDesc(&type_desc));

                const uniform = try append_uniforms_to.addOne();
                uniform.* = gpu.UniformInfo{
                    .name = std.mem.span(var_desc.Name),
                    .shader = shader_type,
                    .register_index = 0,
                    .buffer_index = @intCast(i),
                    .array_length = @intCast(@max(1, type_desc.Elements)),
                    .type = .none,
                };

                if (type_desc.Type == .FLOAT) {
                    if (type_desc.Rows == 1) {
                        switch (type_desc.Columns) {
                            1 => uniform.type = .float,
                            2 => uniform.type = .float2,
                            3 => uniform.type = .float3,
                            4 => uniform.type = .float4,
                            else => {},
                        }
                    } else if (type_desc.Rows == 2 and type_desc.Columns == 3) {
                        uniform.type = .mat3x2;
                    } else if (type_desc.Rows == 4 and type_desc.Columns == 4) {
                        uniform.type = .mat4x4;
                    }
                }
            }
        }

        return append_buffers_to;
    }
};

pub const Texture = struct {
    width: u32,
    height: u32,
    format: gpu.TextureFormat,
    dxgi_format: dxgi.FORMAT,
    size: u32,

    raw: *d3d11.ITexture2D,
    staging: ?*d3d11.ITexture2D,
    view: ?*d3d11.IShaderResourceView,

    pub fn create(data: gpu.TextureDesc) Texture {
        const depth = data.format == .depth_stencil;
        const size = data.format.size(data.width, data.height);
        const desc = d3d11.TEXTURE2D_DESC{
            .Width = data.width,
            .Height = data.height,
            .MipLevels = 1,
            .ArraySize = 1,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .Usage = .DEFAULT,
            .CPUAccessFlags = .{},
            .MiscFlags = .{},
            .BindFlags = .{ .SHADER_RESOURCE = !depth, .DEPTH_STENCIL = depth },
            .Format = texture_format(data.format),
        };

        var texture: *d3d11.ITexture2D = undefined;
        vhr(device.CreateTexture2D(&desc, data.content, @ptrCast(&texture)));

        var view: ?*d3d11.IShaderResourceView = null;
        if (!depth) {
            vhr(device.CreateShaderResourceView(@ptrCast(texture), null, @ptrCast(&view)));
        }

        return .{
            .width = data.width,
            .height = data.height,
            .format = data.format,
            .dxgi_format = desc.Format,
            .size = size,
            .raw = texture,
            .staging = null,
            .view = view,
        };
    }

    pub fn update(self: *Texture, x: u32, y: u32, width: u32, height: u32, bytes: []const u8) void {
        var box = d3d11.BOX{
            .left = x,
            .right = x + width,
            .top = y,
            .bottom = y + height,
            .front = 0,
            .back = 1,
        };

        const pitch = width * self.format.stride();
        context.UpdateSubresource(
            @ptrCast(self.raw),
            0,
            &box,
            @ptrCast(bytes.ptr),
            pitch,
            0,
        );
    }
};

pub const Pipeline = struct {
    shader: gpu.ShaderId,
    depth: gpu.Compare,
    cull: gpu.Cull,
    blend: gpu.BlendMode,
    format: gpu.VertexFormat,

    pub fn create(desc: gpu.PipelineDesc) Pipeline {
        return .{
            .shader = desc.shader,
            .depth = desc.depth,
            .cull = desc.cull,
            .blend = desc.blend,
        };
    }
};

// TODO remove
fn vhr(hr: w32.HRESULT) void {
    if (hr != 0) std.debug.panic("HRESULT error! 0x{X:0>8}", .{@as(u32, @bitCast(hr))});
}

fn texture_format(format: gpu.TextureFormat) dxgi.FORMAT {
    return switch (format) {
        .none => unreachable,
        .r => .R8_UNORM,
        .rg => .R8G8_UNORM,
        .rgba => .R8G8B8A8_UNORM,
        .depth_stencil => .D24_UNORM_S8_UINT,
    };
}

fn getRasterizer(cull: gpu.Cull) ?*d3d11.IRasterizerState {
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
    const hr = device.CreateRasterizerState(&desc, @ptrCast(&result));
    std.debug.assert(hr == 0);

    const entry = rasterizer_cache.addOne(allocator) catch unreachable;
    entry.* = .{
        .cull = cull,
        .state = result,
    };
    return result;
}

fn getDepthstencil(depth: gpu.Compare) ?*d3d11.IDepthStencilState {
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
    const hr = device.CreateDepthStencilState(&desc, @ptrCast(&result));
    std.debug.assert(hr == 0);

    const entry = depthstencil_cache.addOne(allocator) catch unreachable;
    entry.* = .{
        .depth = depth,
        .state = result,
    };
    return result;
}

fn blend_op(op: gpu.BlendOp) d3d11.BLEND_OP {
    return switch (op) {
        .add => .ADD,
        .subtract => .SUBTRACT,
        .reverse_subtract => .REV_SUBTRACT,
        .min => .MIN,
        .max => .MAX,
    };
}

fn blend_factor(factor: gpu.BlendFactor) d3d11.BLEND {
    return switch (factor) {
        .zero => .ZERO,
        .one => .ONE,
        .src_color => .SRC_COLOR,
        .one_minus_src_color => .INV_SRC_COLOR,
        .dst_color => .DEST_COLOR,
        .one_minus_dst_color => .INV_DEST_COLOR,
        .src_alpha => .SRC_ALPHA,
        .one_minus_src_alpha => .INV_SRC_ALPHA,
        .dst_alpha => .DEST_ALPHA,
        .one_minus_dst_alpha => .INV_DEST_ALPHA,
        .constant_color => .BLEND_FACTOR,
        .one_minus_constant_color => .INV_BLEND_FACTOR,
        .constant_alpha => .BLEND_FACTOR,
        .one_minus_constant_alpha => .INV_BLEND_FACTOR,
        .src_alpha_saturate => .SRC_ALPHA_SAT,
        .src1_color => .SRC1_COLOR,
        .one_minus_src1_color => .INV_SRC1_COLOR,
        .src1_alpha => .SRC1_ALPHA,
        .one_minus_src1_alpha => .INV_SRC1_ALPHA,
    };
}

fn getBlend(blend: *const gpu.BlendMode) ?*d3d11.IBlendState {
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
        desc.RenderTarget[0].BlendOp = blend_op(blend.color_op);
        desc.RenderTarget[0].SrcBlend = blend_factor(blend.color_src);
        desc.RenderTarget[0].DestBlend = blend_factor(blend.color_dst);

        desc.RenderTarget[0].BlendOpAlpha = blend_op(blend.alpha_op);
        desc.RenderTarget[0].SrcBlendAlpha = blend_factor(blend.alpha_src);
        desc.RenderTarget[0].DestBlendAlpha = blend_factor(blend.alpha_dst);
    }

    for (1..8) |i| {
        desc.RenderTarget[i] = desc.RenderTarget[0];
    }

    var blend_state: *d3d11.IBlendState = undefined;
    const hr = device.CreateBlendState(&desc, @ptrCast(&blend_state));
    std.debug.assert(hr == 0);

    const entry = blend_cache.addOne(allocator) catch unreachable;
    entry.* = .{
        .blend = blend.*,
        .state = blend_state,
    };
    return blend_state;
}

inline fn asF32(x: anytype) f32 {
    return @floatFromInt(x);
}

fn getLayout(shader: *Shader, format: *const gpu.VertexFormat) ?*d3d11.IInputLayout {
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
    const hr = device.CreateInputLayout(
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
