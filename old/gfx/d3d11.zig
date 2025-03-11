const std = @import("std");
const builtin = @import("builtin");
const math = @import("../math.zig");
const gfx = @import("../gfx.zig");
const w32 = @import("../zwindows/windows.zig");
const d3d11 = @import("../zwindows/d3d11.zig");
const dxgi = @import("../zwindows/dxgi.zig");
const d3dcommon = @import("../zwindows/d3dcommon.zig");
const d3dcompiler = @import("../zwindows/d3dcompiler.zig");

const Color = @import("../Color.zig").Color;

pub var renderer: *D3D11Renderer = undefined;

const StoredInputLayout = struct {
    shader_hash: u32,
    format: gfx.VertexFormat,
    layout: *d3d11.IInputLayout,
};

const StoredBlendState = struct {
    blend: gfx.BlendMode,
    state: *d3d11.IBlendState,
};

const StoredRasterizer = struct {
    cull: gfx.Cull,
    has_scissor: bool,
    state: *d3d11.IRasterizerState,
};

const StoredSampler = struct {
    sampler: gfx.TextureSampler,
    state: *d3d11.ISamplerState,
};

const StoredDepthStencil = struct {
    depth: gfx.Compare,
    state: *d3d11.IDepthStencilState,
};

pub const D3D11Renderer = struct {
    const Self = @This();

    device: *d3d11.IDevice,
    context: *d3d11.IDeviceContext,
    swap_chain: *dxgi.ISwapChain,
    backbuffer_view: ?*d3d11.IRenderTargetView,
    backbuffer_depth_view: ?*d3d11.IDepthStencilView,

    drawable_size: math.Point,
    last_window_size: math.Point,

    layout_cache: std.ArrayList(StoredInputLayout),
    blend_cache: std.ArrayList(StoredBlendState),
    rasterizer_cache: std.ArrayList(StoredRasterizer),
    sampler_cache: std.ArrayList(StoredSampler),
    depthstencil_cache: std.ArrayList(StoredDepthStencil),
    allocator: std.mem.Allocator,

    // var d3dDebug: *d3d11.IDebug = undefined;
    // var queue: *d3d11.IInfoQueue = undefined;

    pub fn create(allocator: std.mem.Allocator, size: math.Point, hwnd: w32.HWND) !*Self {
        const self = try allocator.create(Self);
        errdefer allocator.destroy(self);

        var device: *d3d11.IDevice = undefined;
        var context: *d3d11.IDeviceContext = undefined;
        var swap_chain: *dxgi.ISwapChain = undefined;
        var backbuffer_view: ?*d3d11.IRenderTargetView = null;
        const backbuffer_depth_view: ?*d3d11.IDepthStencilView = null;
        var drawable_size: math.Point = undefined;

        const desc = std.mem.zeroInit(dxgi.SWAP_CHAIN_DESC, .{
            .BufferDesc = .{
                .RefreshRate = .{ .Numerator = 0, .Denominator = 1 },
                .Format = .B8G8R8A8_UNORM,
            },
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .BufferUsage = .{ .RENDER_TARGET_OUTPUT = true },
            .BufferCount = 1,
            .OutputWindow = hwnd,
            .Windowed = 1,
        });

        const flags = d3d11.CREATE_DEVICE_FLAG{
            .SINGLETHREADED = true,
            .DEBUG = builtin.mode == .Debug,
        };

        var feature_level: d3dcommon.FEATURE_LEVEL = undefined;
        const hr = d3d11.D3D11CreateDeviceAndSwapChain(
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
        );
        std.debug.assert(hr == 0);

        // if (device.QueryInterface(&d3d11.IID_IDebug, @ptrCast(&d3dDebug)) == 0) {
        //     if (d3dDebug.QueryInterface(&d3d11.IID_IInfoQueue, @ptrCast(&queue)) == 0) {
        //         queue.SetMuteDebugOutput(0);
        //         vhr(queue.SetBreakOnSeverity(.CORRUPTION, 1));
        //         vhr(queue.SetBreakOnSeverity(.ERROR, 1));
        //         vhr(queue.SetBreakOnSeverity(.WARNING, 1));
        //         vhr(queue.SetBreakOnSeverity(.INFO, 1));
        //         vhr(queue.SetBreakOnSeverity(.MESSAGE, 1));
        //     }
        // }

        var framebuffer: *d3d11.ITexture2D = undefined;
        vhr(swap_chain.GetBuffer(0, &d3d11.IID_ITexture2D, @ptrCast(&framebuffer)));
        {
            var tdesc: d3d11.TEXTURE2D_DESC = undefined;
            framebuffer.GetDesc(&tdesc);
            drawable_size = .{ .x = @intCast(tdesc.Width), .y = @intCast(tdesc.Height) };

            vhr(device.CreateRenderTargetView(@ptrCast(framebuffer), null, @ptrCast(&backbuffer_view)));
            _ = framebuffer.Release();
        }

        // TODO create a depth backbuffer

        // // print driver info
        // {
        //     var dxgi_device: *dxgi.IDevice = undefined;
        //     vhr(device.QueryInterface(&dxgi.IID_IDevice, @ptrCast(&dxgi_device)));
        //
        //     var dxgi_adapter: *dxgi.IAdapter = undefined;
        //     var adapter_desc: dxgi.ADAPTER_DESC = undefined;
        //     vhr(dxgi_device.GetAdapter(@ptrCast(&dxgi_adapter)));
        //     vhr(dxgi_adapter.GetDesc(&adapter_desc));
        //
        //     const string = try std.unicode.utf16LeToUtf8Alloc(allocator, &adapter_desc.Description);
        //     defer allocator.free(string);
        //     std.log.debug("{s}", .{string});
        //
        //     _ = dxgi_device.Release();
        //     _ = dxgi_adapter.Release();
        // }

        self.* = .{
            .device = device,
            .context = context,
            .swap_chain = swap_chain,
            .backbuffer_view = backbuffer_view,
            .backbuffer_depth_view = backbuffer_depth_view,
            .drawable_size = drawable_size,
            .last_window_size = size,
            .layout_cache = .init(allocator),
            .blend_cache = .init(allocator),
            .rasterizer_cache = .init(allocator),
            .sampler_cache = .init(allocator),
            .depthstencil_cache = .init(allocator),
            .allocator = allocator,
        };

        renderer = self;

        return self;
    }

    pub fn update(self: *Self) void {
        _ = self;
    }

    pub fn beforeRender(self: *Self, size: math.Point) void {
        if (!self.last_window_size.eql(size)) {
            self.last_window_size = size;

            if (self.backbuffer_view) |view| {
                _ = view.Release();
            }

            var hr = self.swap_chain.ResizeBuffers(0, 0, 0, .B8G8R8A8_UNORM, .{});
            std.debug.assert(hr == 0);

            var framebuffer: *d3d11.ITexture2D = undefined;
            hr = self.swap_chain.GetBuffer(0, &d3d11.IID_ITexture2D, @ptrCast(&framebuffer));
            std.debug.assert(hr == 0);

            var desc: d3d11.TEXTURE2D_DESC = undefined;
            framebuffer.GetDesc(&desc);
            self.drawable_size = .{ .x = @intCast(desc.Width), .y = @intCast(desc.Height) };

            hr = self.device.CreateRenderTargetView(@ptrCast(framebuffer), null, @ptrCast(&self.backbuffer_view));
            std.debug.assert(hr == 0);
            _ = framebuffer.Release();
        }
    }

    pub fn afterRender(self: *Self) void {
        const hr = self.swap_chain.Present(1, .{});
        std.debug.assert(hr == 0);
    }

    pub fn render(self: *Self, pass: *const gfx.DrawCall) void {
        const shader = pass.material.shader;
        const mesh = pass.mesh;

        // OM
        {
            // Set the target
            if (pass.target.is_backbuffer) {
                self.context.OMSetRenderTargets(1, @ptrCast(&self.backbuffer_view), self.backbuffer_depth_view);
            } else {
                unreachable;
            }

            // Depth
            if (self.getDepthstencil(pass)) |ds| {
                self.context.OMSetDepthStencilState(ds, 0);
            }

            // Blend
            if (self.getBlend(&pass.blend)) |blend| {
                const color = Color.rgba(pass.blend.rgba);
                const factor = [4]f32{ asF32(color.r) / 255.0, asF32(color.g) / 255.0, asF32(color.b) / 255.0, asF32(color.a) / 255.0 };
                const mask = 0xFFFFFFFF;
                self.context.OMSetBlendState(blend, &factor, mask);
            } else {
                self.context.OMSetBlendState(null, null, 0);
            }
        }

        // IA
        {
            self.context.IASetPrimitiveTopology(.TRIANGLELIST);

            const layout = self.getLayout(shader, &mesh.vertex_format);
            self.context.IASetInputLayout(layout);

            var stride: u32 = mesh.vertex_format.stride;
            var offset: u32 = 0;
            self.context.IASetVertexBuffers(0, 1, @ptrCast(&mesh.vertex_buffer), @ptrCast(&stride), @ptrCast(&offset));

            const format = switch (mesh.index_format) {
                .u16 => dxgi.FORMAT.R16_UINT,
                .u32 => dxgi.FORMAT.R32_UINT,
            };
            self.context.IASetIndexBuffer(mesh.index_buffer, format, 0);
        }

        // VS
        {
            apply_uniforms(shader, pass.material, .vertex);
            self.context.VSSetShader(shader.vertex, null, 0);
            self.context.VSSetConstantBuffers(0, @intCast(shader.vertex_uniform_buffers.items.len), shader.vertex_uniform_buffers.items.ptr);
        }

        // PS
        {
            apply_uniforms(shader, pass.material, .fragment);
            self.context.PSSetShader(shader.fragment, null, 0);
            self.context.PSSetConstantBuffers(0, @intCast(shader.fragment_uniform_buffers.items.len), shader.fragment_uniform_buffers.items.ptr);

            const textures = pass.material.textures.items;
            for (textures, 0..) |tex, i| {
                if (tex) |t| {
                    self.context.PSSetShaderResources(@intCast(i), 1, @ptrCast(&t.view));
                }
            }

            const samplers = pass.material.samplers.items;
            for (samplers, 0..) |*sampler, i| {
                if (self.getSampler(sampler)) |smp| {
                    self.context.PSSetSamplers(@intCast(i), 1, @ptrCast(&smp));
                }
            }
        }

        // RS
        {
            const viewport = d3d11.VIEWPORT{
                .TopLeftX = pass.viewport.x,
                .TopLeftY = pass.viewport.y,
                .Width = pass.viewport.w,
                .Height = pass.viewport.h,
                .MinDepth = 0,
                .MaxDepth = 1,
            };
            self.context.RSSetViewports(1, @ptrCast(&viewport));

            if (pass.has_scissor) {
                unreachable;
            } else {
                self.context.RSSetScissorRects(0, null);
            }

            if (self.getRasterizer(pass)) |rasterizer| {
                self.context.RSSetState(rasterizer);
            }
        }

        // Draw
        {
            if (mesh.getInstanceCount() == 0) {
                self.context.DrawIndexed(pass.index_count, pass.index_start, 0);
            } else {
                unreachable;
            }
        }

        // Unbind shader resource
        {
            const textures = pass.material.textures.items;
            var view: ?*d3d11.IShaderResourceView = null;
            for (0..textures.len) |i| {
                self.context.PSSetShaderResources(@intCast(i), 1, @ptrCast(&view));
            }
        }
    }

    pub fn clearBackbuffer(self: *Self, params: gfx.ClearParams) void {
        if (params.mask.color) {
            const clear: [4]f32 = .{ asF32(params.color.r) / 255, asF32(params.color.g) / 255, asF32(params.color.b) / 255, asF32(params.color.a) / 255 };
            self.context.ClearRenderTargetView(self.backbuffer_view.?, &clear);
        }

        if (self.backbuffer_depth_view) |_| {
            unreachable;
        }
    }

    fn getDepthstencil(self: *Self, pass: *const gfx.DrawCall) ?*d3d11.IDepthStencilState {
        for (self.depthstencil_cache.items) |it| {
            if (it.depth == pass.depth) {
                return it.state;
            }
        }

        const desc = d3d11.DEPTH_STENCIL_DESC{
            .DepthEnable = @intFromBool(pass.depth != .none),
            .DepthWriteMask = .ALL,
            .DepthFunc = switch (pass.depth) {
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
        const hr = renderer.device.CreateDepthStencilState(&desc, @ptrCast(&result));
        std.debug.assert(hr == 0);

        const entry = self.depthstencil_cache.addOne() catch unreachable;
        entry.* = .{
            .depth = pass.depth,
            .state = result,
        };
        return result;
    }

    fn getBlend(self: *Self, blend: *const gfx.BlendMode) ?*d3d11.IBlendState {
        for (self.blend_cache.items) |it| {
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
        const hr = renderer.device.CreateBlendState(&desc, @ptrCast(&blend_state));
        std.debug.assert(hr == 0);

        const entry = self.blend_cache.addOne() catch unreachable;
        entry.* = .{
            .blend = blend.*,
            .state = blend_state,
        };
        return blend_state;
    }

    fn getLayout(self: *Self, shader: *D3D11Shader, format: *const gfx.VertexFormat) ?*d3d11.IInputLayout {
        for (self.layout_cache.items) |it| {
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
        const hr = self.device.CreateInputLayout(
            &descs.buffer,
            @intCast(descs.len),
            shader.vertex_blob.GetBufferPointer(),
            shader.vertex_blob.GetBufferSize(),
            @ptrCast(&layout),
        );
        std.debug.assert(hr == 0);

        const entry = self.layout_cache.addOne() catch unreachable;
        entry.* = .{
            .shader_hash = shader.hash,
            .format = format.*,
            .layout = layout,
        };
        return layout;
    }

    fn getSampler(self: *Self, sampler: *const gfx.TextureSampler) ?*d3d11.ISamplerState {
        for (self.sampler_cache.items) |it| {
            if (it.sampler.eq(sampler.*)) {
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
        const hr = renderer.device.CreateSamplerState(&desc, @ptrCast(&result));
        std.debug.assert(hr == 0);

        const entry = self.sampler_cache.addOne() catch unreachable;
        entry.* = .{
            .sampler = sampler.*,
            .state = result,
        };
        return result;
    }

    fn getRasterizer(self: *Self, pass: *const gfx.DrawCall) ?*d3d11.IRasterizerState {
        for (self.rasterizer_cache.items) |it| {
            if (it.cull == pass.cull and it.has_scissor == pass.has_scissor) {
                return it.state;
            }
        }

        const desc = d3d11.RASTERIZER_DESC{
            .FillMode = .SOLID,
            .CullMode = switch (pass.cull) {
                .none => .NONE,
                .front => .FRONT,
                .back => .BACK,
            },
            .FrontCounterClockwise = 1,
            .DepthBias = 0,
            .DepthBiasClamp = 0,
            .SlopeScaledDepthBias = 0,
            .DepthClipEnable = 0,
            .ScissorEnable = @intFromBool(pass.has_scissor),
            .MultisampleEndable = 0,
            .AntialiasedLineEnable = 0,
        };

        var result: *d3d11.IRasterizerState = undefined;
        const hr = renderer.device.CreateRasterizerState(&desc, @ptrCast(&result));
        std.debug.assert(hr == 0);

        const entry = self.rasterizer_cache.addOne() catch unreachable;
        entry.* = .{
            .cull = pass.cull,
            .has_scissor = pass.has_scissor,
            .state = result,
        };

        return result;
    }

    fn apply_uniforms(shader: *D3D11Shader, material: *gfx.Material, typ: gfx.ShaderType) void {
        const buffers = if (typ == .vertex) &shader.vertex_uniform_buffers else &shader.fragment_uniform_buffers;
        const values: *std.ArrayList(std.ArrayList(f32)) = if (typ == .vertex) &shader.vertex_uniform_values else &shader.fragment_uniform_values;

        for (0..buffers.items.len) |i| {
            values.items[i].items.len = 0;

            var data: [*]const f32 = material.data.items.ptr;
            for (shader.uniforms()) |it| {
                const size: u32 = switch (it.type) {
                    .none, .texture_2d, .sampler_2d => continue,
                    .float => 1,
                    .float2 => 2,
                    .float3 => 3,
                    .float4 => 4,
                    .mat3x2 => 6,
                    .mat4x4 => 16,
                };
                const length = size * it.array_length;

                if (it.buffer_index == i and it.shader == typ) {
                    const remaining = 4 - values.items[i].items.len % 4;
                    if (remaining != 4 and remaining + length > 4) {
                        unreachable;
                    }

                    const start = values.items[i].addManyAsSlice(length) catch unreachable;
                    @memcpy(start, data);
                }

                data += length;
            }

            // apply block
            var map: d3d11.MAPPED_SUBRESOURCE = undefined;
            vhr(renderer.context.Map(@ptrCast(buffers.items[i]), 0, .WRITE_DISCARD, .{}, &map));
            @memcpy(@as([*]f32, @alignCast(@ptrCast(map.pData))), values.items[i].items);
            renderer.context.Unmap(@ptrCast(buffers.items[i]), 0);
        }
    }
};

pub const D3D11Texture = struct {
    const Self = @This();

    width: u32,
    height: u32,
    format: gfx.TextureFormat,
    dxgi_format: dxgi.FORMAT,
    size: u32,

    texture: *d3d11.ITexture2D,
    staging: ?*d3d11.ITexture2D,
    view: ?*d3d11.IShaderResourceView,

    pub fn create(allocator: std.mem.Allocator, width: u32, height: u32, format: gfx.TextureFormat) !*Self {
        const self = try allocator.create(Self);

        const size = switch (format) {
            .none => unreachable,
            .r => width * height,
            .rg => width * height * 2,
            .rgba => width * height * 4,
            .depth_stencil => width * height * 4,
        };

        const desc = d3d11.TEXTURE2D_DESC{
            .Width = width,
            .Height = height,
            .MipLevels = 1,
            .ArraySize = 1,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .Usage = .DEFAULT,
            .CPUAccessFlags = .{},
            .MiscFlags = .{},
            .BindFlags = .{
                .SHADER_RESOURCE = format != .depth_stencil,
                .DEPTH_STENCIL = format == .depth_stencil,
            },
            .Format = switch (format) {
                .none => unreachable,
                .r => .R8_UNORM,
                .rg => .R8G8_UNORM,
                .rgba => .R8G8B8A8_UNORM,
                .depth_stencil => .D24_UNORM_S8_UINT,
            },
        };

        var texture: *d3d11.ITexture2D = undefined;
        vhr(renderer.device.CreateTexture2D(&desc, null, @ptrCast(&texture)));

        var view: ?*d3d11.IShaderResourceView = null;
        if (format != .depth_stencil) {
            vhr(renderer.device.CreateShaderResourceView(@ptrCast(texture), null, @ptrCast(&view)));
        }

        self.* = .{
            .width = width,
            .height = height,
            .format = format,
            .dxgi_format = desc.Format,
            .size = size,
            .texture = texture,
            .staging = null,
            .view = view,
        };

        return self;
    }

    pub fn destroy(self: *Self) void {
        _ = self.texture.Release();
        if (self.staging) |staging| _ = staging.Release();
        if (self.view) |view| _ = view.Release();
    }

    pub fn update(self: *Self, bytes: []const u8) void {
        self.updatePart(0, 0, self.width, self.height, bytes);
    }

    pub fn updatePart(self: *Self, x: u32, y: u32, width: u32, height: u32, bytes: []const u8) void {
        var box = d3d11.BOX{
            .left = x,
            .right = x + width,
            .top = y,
            .bottom = y + height,
            .front = 0,
            .back = 1,
        };

        const pitch = (self.size / (self.width * self.height)) * width;
        renderer.context.UpdateSubresource(
            @ptrCast(self.texture),
            0,
            &box,
            @ptrCast(bytes.ptr),
            pitch,
            0,
        );
    }
};

pub const D3D11Target = struct {
    const Self = @This();

    is_backbuffer: bool = false,

    pub fn clear(self: *Self, params: gfx.ClearParams) void {
        if (self.is_backbuffer) {
            renderer.clearBackbuffer(params);
        } else {
            unreachable;
        }
    }

    pub fn getWidth(self: *const Self) u32 {
        if (self.is_backbuffer) {
            return @intCast(renderer.drawable_size.x);
        } else {
            unreachable;
        }
    }

    pub fn getHeight(self: *const Self) u32 {
        if (self.is_backbuffer) {
            return @intCast(renderer.drawable_size.y);
        } else {
            unreachable;
        }
    }
};

pub const D3D11Shader = struct {
    const Self = @This();

    vertex: *d3d11.IVertexShader,
    fragment: *d3d11.IPixelShader,
    vertex_blob: *d3dcommon.IBlob,
    fragment_blob: *d3dcommon.IBlob,
    vertex_uniform_buffers: std.ArrayList(*d3d11.IBuffer),
    fragment_uniform_buffers: std.ArrayList(*d3d11.IBuffer),
    vertex_uniform_values: std.ArrayList(std.ArrayList(f32)),
    fragment_uniform_values: std.ArrayList(std.ArrayList(f32)),
    attributes: std.BoundedArray(gfx.ShaderData.HLSLAttribute, 16),
    uniform_list: std.ArrayList(gfx.UniformInfo),
    hash: u32,

    pub fn create(allocator: std.mem.Allocator, data: *const gfx.ShaderData) !*Self {
        const self = try allocator.create(Self);
        errdefer allocator.destroy(self);

        const flags = d3dcompiler.COMPILE_ENABLE_STRICTNESS | d3dcompiler.COMPILE_DEBUG;
        var vertex_blob: *d3dcommon.IBlob = undefined;
        var fragment_blob: *d3dcommon.IBlob = undefined;
        var error_blob: *d3dcommon.IBlob = undefined;
        var vertex: *d3d11.IVertexShader = undefined;
        var fragment: *d3d11.IPixelShader = undefined;

        {
            const hr = d3dcompiler.D3DCompile(
                data.vertex.ptr,
                data.vertex.len,
                null,
                null,
                null,
                "vs_main",
                "vs_5_0",
                flags,
                0,
                &vertex_blob,
                &error_blob,
            );
            if (hr != 0) {
                std.debug.panic("{s}", .{@as([*]const u8, @ptrCast(error_blob.GetBufferPointer()))[0..error_blob.GetBufferSize()]});
            }
        }

        {
            const hr = d3dcompiler.D3DCompile(
                data.fragment.ptr,
                data.fragment.len,
                null,
                null,
                null,
                "ps_main",
                "ps_5_0",
                flags,
                0,
                &fragment_blob,
                &error_blob,
            );
            if (hr != 0) {
                std.debug.panic("{s}", .{@as([*]const u8, @ptrCast(error_blob.GetBufferPointer()))[0..error_blob.GetBufferSize()]});
            }
        }

        {
            const hr = renderer.device.CreateVertexShader(vertex_blob.GetBufferPointer(), vertex_blob.GetBufferSize(), null, @ptrCast(&vertex));
            std.debug.assert(hr == 0);
        }

        {
            const hr = renderer.device.CreatePixelShader(fragment_blob.GetBufferPointer(), fragment_blob.GetBufferSize(), null, @ptrCast(&fragment));
            std.debug.assert(hr == 0);
        }

        var uniform_list = std.ArrayList(gfx.UniformInfo).init(allocator);
        var vertex_uniform_buffers = std.ArrayList(*d3d11.IBuffer).init(allocator);
        var fragment_uniform_buffers = std.ArrayList(*d3d11.IBuffer).init(allocator);

        try reflect_uniforms(&uniform_list, &vertex_uniform_buffers, vertex_blob, .vertex);
        try reflect_uniforms(&uniform_list, &fragment_uniform_buffers, fragment_blob, .fragment);

        // combine uniforms that were in both lists
        for (0..uniform_list.items.len) |i| {
            for (i + 1..uniform_list.items.len) |j| {
                if (std.mem.eql(u8, uniform_list.items[i].name, uniform_list.items[j].name)) {
                    if (uniform_list.items[i].type == uniform_list.items[j].type) {
                        unreachable;
                    }
                }
            }
        }

        var vertex_uniform_values = std.ArrayList(std.ArrayList(f32)).init(allocator);
        var fragment_uniform_values = std.ArrayList(std.ArrayList(f32)).init(allocator);

        const vertex_values = try vertex_uniform_values.addManyAsSlice(vertex_uniform_buffers.items.len);
        const fragment_values = try fragment_uniform_values.addManyAsSlice(fragment_uniform_buffers.items.len);

        for (vertex_values) |*p| p.* = .init(allocator);
        for (fragment_values) |*p| p.* = .init(allocator);

        const attributes = data.hlsl_attributes;

        var hash: u32 = 5381;
        for (attributes.constSlice()) |attr| {
            for (attr.name) |c| {
                hash = ((hash << 5) +% hash) +% c;
            }
            hash = (@as(u32, attr.index) << 5) +% hash;
        }

        self.* = .{
            .vertex = vertex,
            .fragment = fragment,
            .vertex_blob = vertex_blob,
            .fragment_blob = fragment_blob,
            .vertex_uniform_buffers = vertex_uniform_buffers,
            .fragment_uniform_buffers = fragment_uniform_buffers,
            .vertex_uniform_values = vertex_uniform_values,
            .fragment_uniform_values = fragment_uniform_values,
            .attributes = attributes,
            .uniform_list = uniform_list,
            .hash = hash,
        };

        return self;
    }

    pub fn destroy(_: *Self) void {
        unreachable;
    }

    pub fn uniforms(self: *Self) []gfx.UniformInfo {
        return self.uniform_list.items;
    }

    fn reflect_uniforms(append_uniforms_to: *std.ArrayList(gfx.UniformInfo), append_buffers_to: *std.ArrayList(*d3d11.IBuffer), shader: *d3dcommon.IBlob, shader_type: gfx.ShaderType) !void {
        var reflector: *d3d11.IShaderReflection = undefined;
        vhr(d3dcompiler.D3DReflect(shader.GetBufferPointer(), shader.GetBufferSize(), &d3d11.IID_IShaderReflection, @ptrCast(&reflector)));

        var shader_desc: d3d11.SHADER_DESC = undefined;
        vhr(reflector.GetDesc(&shader_desc));

        for (0..shader_desc.BoundResources) |i| {
            var desc: d3d11.SHADER_INPUT_BIND_DESC = undefined;
            vhr(reflector.GetResourceBindingDesc(@intCast(i), &desc));

            if (desc.Type == .TEXTURE and desc.Dimension == .TEXTURE2D) {
                const uniform = try append_uniforms_to.addOne();
                uniform.* = gfx.UniformInfo{
                    .name = std.mem.span(desc.Name),
                    .shader = shader_type,
                    .register_index = @intCast(desc.BindPoint),
                    .buffer_index = 0,
                    .array_length = @intCast(@max(1, desc.BindCount)),
                    .type = .texture_2d,
                };
            } else if (desc.Type == .SAMPLER) {
                const uniform = try append_uniforms_to.addOne();
                uniform.* = gfx.UniformInfo{
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
                vhr(renderer.device.CreateBuffer(&buffer_desc, null, @ptrCast(&buffer)));
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
                uniform.* = gfx.UniformInfo{
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
    }
};

pub const D3D11Mesh = struct {
    const Self = @This();

    vertex_count: usize = 0,
    vertex_capacity: usize = 0,
    index_count: usize = 0,
    index_capacity: usize = 0,

    vertex_buffer: ?*d3d11.IBuffer = null,
    vertex_format: gfx.VertexFormat = .{},
    index_buffer: ?*d3d11.IBuffer = null,
    index_format: gfx.IndexFormat = .u16,
    index_stride: u32 = 0,

    pub fn create(allocator: std.mem.Allocator) !*Self {
        const self = try allocator.create(Self);
        self.* = .{};
        return self;
    }

    pub inline fn getInstanceCount(_: *const Self) u32 {
        return 0;
    }

    pub fn indexData(self: *Self, format: gfx.IndexFormat, data: ?[]const u8, count: usize) void {
        self.index_count = count;

        if (self.index_format != format or self.index_buffer == null or self.index_count > self.index_capacity) {
            self.index_format = format;
            self.index_capacity = @max(self.index_capacity, self.index_count);
            self.index_stride = switch (format) {
                .u16 => @sizeOf(u16),
                .u32 => @sizeOf(u32),
            };

            if (self.index_buffer) |ib| {
                _ = ib.Release();
                self.index_buffer = null;
            }

            if (self.index_capacity == 0) return;
            if (data) |indices| {
                const desc = d3d11.BUFFER_DESC{
                    .ByteWidth = @intCast(self.index_stride * self.index_capacity),
                    .Usage = .DYNAMIC,
                    .BindFlags = .{ .INDEX_BUFFER = true },
                    .CPUAccessFlags = .{ .WRITE = true },
                };

                const res_data = d3d11.SUBRESOURCE_DATA{ .pSysMem = indices.ptr };

                const hr = renderer.device.CreateBuffer(&desc, &res_data, @ptrCast(&self.index_buffer));
                std.debug.assert(hr == 0);
            }
        } else if (data) |indices| {
            var map: d3d11.MAPPED_SUBRESOURCE = undefined;
            const hr = renderer.context.Map(@ptrCast(self.index_buffer), 0, .WRITE_DISCARD, .{}, &map);
            std.debug.assert(hr == 0);

            const size = self.index_stride * count;
            std.debug.assert(size == indices.len);
            @memcpy(@as([*]u8, @ptrCast(map.pData))[0..size], indices[0..size]);
            renderer.context.Unmap(@ptrCast(self.index_buffer), 0);
        }
    }

    pub fn vertexData(self: *Self, format: gfx.VertexFormat, data: ?[]const u8, count: usize) void {
        std.debug.assert(format.stride != 0);
        self.vertex_count = count;

        if (self.vertex_format.stride != format.stride or self.vertex_buffer == null or self.vertex_count > self.vertex_capacity) {
            self.vertex_capacity = @max(self.vertex_capacity, self.vertex_count);
            self.vertex_format = format;

            if (self.vertex_buffer) |vb| {
                _ = vb.Release();
                self.vertex_buffer = null;
            }

            if (self.vertex_capacity == 0) return;
            if (data) |vertices| {
                const desc = d3d11.BUFFER_DESC{
                    .ByteWidth = @intCast(format.stride * self.vertex_capacity),
                    .Usage = .DYNAMIC,
                    .BindFlags = .{ .VERTEX_BUFFER = true },
                    .CPUAccessFlags = .{ .WRITE = true },
                };

                const res_data = d3d11.SUBRESOURCE_DATA{ .pSysMem = vertices.ptr };

                const hr = renderer.device.CreateBuffer(&desc, &res_data, @ptrCast(&self.vertex_buffer));
                std.debug.assert(hr == 0);
            }
        } else if (data) |vertices| {
            var map: d3d11.MAPPED_SUBRESOURCE = undefined;
            const hr = renderer.context.Map(@ptrCast(self.vertex_buffer), 0, .WRITE_DISCARD, .{}, &map);
            std.debug.assert(hr == 0);

            const size = self.vertex_format.stride * count;
            std.debug.assert(size == vertices.len);
            @memcpy(@as([*]u8, @ptrCast(map.pData))[0..size], vertices[0..size]);
            renderer.context.Unmap(@ptrCast(self.vertex_buffer), 0);
        }
    }
};

inline fn asF32(x: anytype) f32 {
    return @floatFromInt(x);
}

fn blend_op(op: gfx.BlendOp) d3d11.BLEND_OP {
    return switch (op) {
        .add => .ADD,
        .subtract => .SUBTRACT,
        .reverse_subtract => .REV_SUBTRACT,
        .min => .MIN,
        .max => .MAX,
    };
}

fn blend_factor(factor: gfx.BlendFactor) d3d11.BLEND {
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

fn vhr(hr: w32.HRESULT) void {
    if (hr != 0) std.debug.panic("HRESULT error! 0x{X:0>8}", .{@as(u32, @bitCast(hr))});
}
