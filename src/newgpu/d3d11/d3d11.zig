const std = @import("std");
const gpu = @import("../gpu.zig");
const conv = @import("conv.zig");

const w32 = @import("w32");
const dxgi = w32.dxgi;
const d3d11 = w32.d3d11;
const d3dcommon = w32.d3dcommon;
const d3dcompiler = w32.d3dcompiler;

const Manager = @import("../../util.zig").Manager;

const debug = true;
const back_buffer_count = 2;
const allocator = @import("../../prism.zig").allocator;

pub const Instance = struct {
    manager: Manager(Instance) = .{},
    factory: *dxgi.IFactory4,
    allow_tearing: bool,

    pub fn create() !*Instance {
        var factory: *dxgi.IFactory4 = undefined;
        _ = dxgi.CreateDXGIFactory2(@intFromBool(debug), &dxgi.IFactory4.IID, @ptrCast(&factory));

        const self = try allocator.create(Instance);
        self.* = .{
            .factory = factory,
            .allow_tearing = true, // TODO check feature support
        };

        return self;
    }

    pub fn deinit(self: *Instance) void {
        _ = self.factory.release();
        allocator.destroy(self);
    }
};

pub const Surface = struct {
    manager: Manager(Surface) = .{},
    hwnd: w32.HWND,

    pub fn create(_: *Instance, desc: gpu.Surface.Descriptor) !*Surface {
        const self = try allocator.create(Surface);
        self.* = .{ .hwnd = desc.windows };

        return self;
    }

    pub fn deinit(self: *Surface) void {
        allocator.destroy(self);
    }
};

pub const Adapter = struct {
    manager: Manager(Adapter) = .{},
    instance: *Instance,
    adapter: *dxgi.IAdapter1,
    device: *d3d11.IDevice,
    context: *d3d11.IDeviceContext,

    desc: dxgi.ADAPTER_DESC1,
    description: [256:0]u8 = undefined,
    adapter_type: gpu.Adapter.Type,

    pub fn create(instance: *Instance, desired: gpu.Adapter.Descriptor) !*Adapter {
        var desc: dxgi.ADAPTER_DESC1 = undefined;
        var last_desc: dxgi.ADAPTER_DESC1 = undefined;
        var last_adapter: ?*dxgi.IAdapter1 = null;
        var last_adapter_type: gpu.Adapter.Type = .unknown;

        const flags = d3d11.CREATE_DEVICE_FLAG{
            .DEBUG = debug,
            .BGRA_SUPPORT = true,
        };

        var i: u32 = 0;
        var adapter: *dxgi.IAdapter1 = undefined;
        while (instance.factory.enumAdapters1(i, @ptrCast(&adapter)) == 0) : (i += 1) {
            _ = adapter.getDesc1(&desc);

            var description: [256:0]u8 = undefined;
            const len = try std.unicode.utf16LeToUtf8(&description, &desc.Description);
            description[len] = 0;

            if (desc.Flags.SOFTWARE) {
                _ = adapter.release();
                continue;
            }

            const adapter_type: gpu.Adapter.Type = blk: {
                var device: *d3d11.IDevice = undefined;

                const hr = d3d11.D3D11CreateDevice(@ptrCast(adapter), .UNKNOWN, null, flags, null, 0, d3d11.SDK_VERSION, @ptrCast(&device), null, null);
                if (hr == 0) {
                    defer _ = device.release();

                    var arch = d3d11.FEATURE_DATA_ARCHITECTURE{};
                    _ = device.checkFeatureSupport(.ARCHITECTURE, &arch, @sizeOf(@TypeOf(arch)));

                    break :blk if (arch.UMA == 0) .discrete_gpu else .integrated_gpu;
                }

                break :blk .unknown;
            };

            if (last_adapter == null) {
                last_adapter = adapter;
                last_desc = desc;
                last_adapter_type = adapter_type;
                continue;
            }

            if ((desired.power_preference == .performance and adapter_type == .discrete_gpu) or (desired.power_preference == .efficient and adapter_type != .discrete_gpu)) {
                if (last_adapter) |last| {
                    _ = last.release();
                }
                last_adapter = adapter;
                last_desc = desc;
                last_adapter_type = adapter_type;
            }
        }

        if (last_adapter) |selected| {
            var device: *d3d11.IDevice = undefined;
            var context: *d3d11.IDeviceContext = undefined;

            const hr = d3d11.D3D11CreateDevice(@ptrCast(adapter), .HARDWARE, null, flags, null, 0, d3d11.SDK_VERSION, @ptrCast(&device), null, @ptrCast(&context));
            if (hr == 0) {
                _ = selected.addRef();

                const self = try allocator.create(Adapter);
                self.* = .{
                    .instance = instance,
                    .adapter = selected,
                    .device = device,
                    .context = context,
                    .desc = last_desc,
                    .adapter_type = last_adapter_type,
                };

                const len = try std.unicode.utf16LeToUtf8(&self.description, &last_desc.Description);
                self.description[len] = 0;

                return self;
            }
        }

        return error.NoAdapterFound;
    }

    pub fn deinit(_: *Adapter) void {
        unreachable;
    }
};

pub const Device = struct {
    manager: Manager(Device) = .{},
    adapter: *Adapter,
    device: *d3d11.IDevice,
    context: *d3d11.IDeviceContext,
    debug_controller: ?*d3d11.IDebug = null,
    debug_info_queue: ?*d3d11.IInfoQueue = null,

    pub fn create(adapter: *Adapter) !*Device {
        const self = try allocator.create(Device);
        self.* = .{
            .adapter = adapter,
            .device = adapter.device,
            .context = adapter.context,
        };

        if (debug) {
            const hr1 = adapter.device.queryInterface(&d3d11.IDebug.IID, @ptrCast(&self.debug_controller));
            if (hr1 != 0) {
                unreachable;
            }

            const hr2 = adapter.device.queryInterface(&d3d11.IInfoQueue.IID, @ptrCast(&self.debug_info_queue));
            if (hr2 != 0) {
                unreachable;
            }

            _ = self.debug_info_queue.?.setBreakOnSeverity(.CORRUPTION, 1);
            _ = self.debug_info_queue.?.setBreakOnSeverity(.ERROR, 1);
        }

        return self;
    }

    pub fn deinit(_: *Device) void {
        unreachable;
    }

    pub fn submit(self: *Device, commands: []const *CommandBuffer) !void {
        if (debug) {
            if (self.debug_info_queue) |queue| {
                const count = queue.getNumStoredMessagesAllowedByRetrievalFilter();

                for (0..count) |i| {
                    var len: usize = 0;
                    _ = queue.getMessage(i, null, &len);

                    var message: *d3d11.MESSAGE = try allocator.create(d3d11.MESSAGE);
                    defer allocator.destroy(message);

                    _ = queue.getMessage(i, message, &len);
                    std.log.debug("{s}", .{message.pDescription[0..message.DescriptionByteLength]});
                }

                queue.clearStoredMessages();
            }
        }

        var command_lists = try std.ArrayListUnmanaged(*d3d11.ICommandList).initCapacity(allocator, commands.len);
        defer command_lists.deinit(allocator);

        for (commands) |command| {
            const list = command_lists.addOneAssumeCapacity();
            const hr = command.dcontext.finishCommandList(0, @ptrCast(list));
            if (hr != 0) {
                unreachable;
            }
        }

        for (command_lists.items) |list| {
            self.context.executeCommandList(list, 0);
            _ = list.release();
        }
    }
};

pub const Swapchain = struct {
    manager: Manager(Swapchain) = .{},
    device: *Device,
    surface: *Surface,
    swapchain: *dxgi.ISwapChain3,

    sync_interval: u32,
    present_flags: dxgi.PRESENT_FLAG,
    buffer_index: u32 = 0,
    textures: *Texture,
    views: *TextureView,

    pub fn create(device: *Device, surface: *Surface, desc: gpu.Swapchain.Descriptor) !*Swapchain {
        const instance = device.adapter.instance;

        var swapchain_desc = dxgi.SWAP_CHAIN_DESC1{
            .Width = desc.width,
            .Height = desc.height,
            .Format = conv.dxgiFormatForTexture(desc.format),
            .Stereo = 0,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .BufferUsage = conv.dxgiUsage(desc.usage),
            .BufferCount = back_buffer_count,
            .Scaling = .STRETCH,
            .SwapEffect = .FLIP_DISCARD,
            .AlphaMode = .UNSPECIFIED,
            .Flags = .{ .ALLOW_TEARING = instance.allow_tearing },
        };

        var swapchain: *dxgi.ISwapChain3 = undefined;
        _ = instance.factory.createSwapChainForHwnd(@ptrCast(device.device), surface.hwnd, &swapchain_desc, null, null, @ptrCast(&swapchain));
        errdefer _ = swapchain.release();

        var buffer: *d3d11.ITexture2D = undefined;
        const hr = swapchain.getBuffer(0, &d3d11.ITexture2D.IID, @ptrCast(&buffer));
        if (hr != 0) {
            std.debug.panic("{X}", .{@as(u32, @bitCast(hr))});
        }

        const texture = try Texture.createForSwapchain(device, desc, buffer);
        const view = try TextureView.create(texture, .{});

        const self = try allocator.create(Swapchain);
        self.* = .{
            .device = device,
            .surface = surface,
            .swapchain = swapchain,
            .sync_interval = if (desc.present_mode == .immediate) 0 else 1,
            .present_flags = .{ .ALLOW_TEARING = desc.present_mode == .immediate and instance.allow_tearing },
            .textures = texture,
            .views = view,
        };

        return self;
    }

    pub fn deinit(_: *Swapchain) void {
        unreachable;
    }

    pub fn getCurrentTextureView(self: *Swapchain) !*TextureView {
        const index = self.swapchain.getCurrentBackBufferIndex();
        self.buffer_index = index;
        self.views.manager.reference();
        return self.views;
    }

    pub fn resize(self: *Swapchain, width: u32, height: u32) !void {
        _ = self.textures.resource.release();

        _ = self.swapchain.resizeBuffers(back_buffer_count, width, height, .UNKNOWN, .{});

        var buffer: *d3d11.ITexture2D = undefined;
        _ = self.swapchain.getBuffer(0, &d3d11.ITexture2D.IID, @ptrCast(&buffer));
        self.textures.resource = buffer;
    }

    pub fn present(self: *Swapchain) !void {
        const hr = self.swapchain.present(self.sync_interval, self.present_flags);
        if (hr != 0) {
            return error.PresentFailed;
        }
    }
};

pub const Buffer = struct {
    manager: Manager(Buffer) = .{},

    pub fn create() !*Buffer {
        unreachable;
    }

    pub fn deinit(_: *Buffer) void {
        unreachable;
    }
};

pub const Texture = struct {
    manager: Manager(Texture) = .{},
    device: *Device,
    resource: *d3d11.ITexture2D,

    usage: gpu.Texture.UsageFlags,
    dimension: gpu.Texture.Dimension,
    size: gpu.types.Extent3D,
    format: gpu.Texture.Format,
    mip_level_count: u32,
    sample_count: u32,

    pub fn create(device: *Device, desc: gpu.Texture.Descriptor) !*Texture {
        _ = device; // autofix
        _ = desc; // autofix
        unreachable;
    }

    pub fn createForSwapchain(device: *Device, desc: gpu.Swapchain.Descriptor, resource: *d3d11.ITexture2D) !*Texture {
        const texture = try allocator.create(Texture);
        texture.* = .{
            .device = device,
            .resource = resource,
            .usage = desc.usage,
            .dimension = .@"2d",
            .size = .{ .width = desc.width, .height = desc.height, .depth_or_array_layers = 1 },
            .format = desc.format,
            .mip_level_count = 1,
            .sample_count = 1,
        };

        return texture;
    }

    pub fn deinit(_: *Texture) void {
        unreachable;
    }

    fn calcSubresource(texture: *Texture, mip_level: u32, array_slice: u32) u32 {
        return mip_level + (array_slice * texture.mip_level_count);
    }
};

pub const TextureView = struct {
    manager: Manager(TextureView) = .{},
    texture: *Texture,
    format: gpu.Texture.Format,
    dimension: gpu.TextureView.Dimension,
    base_mip_level: u32,
    mip_level_count: u32,
    base_array_layer: u32,
    array_layer_count: u32,
    aspect: gpu.Texture.Aspect,
    base_subresource: u32,

    pub fn create(texture: *Texture, desc: gpu.TextureView.Descriptor) !*TextureView {
        texture.manager.reference();

        const texture_dimension: gpu.TextureView.Dimension = switch (texture.dimension) {
            .@"1d" => .@"1d",
            .@"2d" => .@"2d",
            .@"3d" => .@"3d",
        };

        const self = try allocator.create(TextureView);
        self.* = .{
            .texture = texture,
            .format = if (desc.format != .undefined) desc.format else texture.format,
            .dimension = if (desc.dimension != .undefined) desc.dimension else texture_dimension,
            .base_mip_level = desc.base_mip_level,
            .mip_level_count = desc.mip_level_count,
            .base_array_layer = desc.base_array_layer,
            .array_layer_count = desc.array_layer_count,
            .aspect = desc.aspect,
            .base_subresource = texture.calcSubresource(desc.base_mip_level, desc.base_array_layer),
        };

        return self;
    }

    pub fn deinit(_: *TextureView) void {
        unreachable;
    }

    fn width(self: *TextureView) u32 {
        return @max(1, self.texture.size.width >> @intCast(self.base_mip_level));
    }

    fn height(self: *TextureView) u32 {
        return @max(1, self.texture.size.height >> @intCast(self.base_mip_level));
    }
};

pub const ShaderModule = struct {
    manager: Manager(ShaderModule) = .{},
    code: []const u8,

    pub fn create(_: *Device, data: []const u8) !*ShaderModule {
        const self = try allocator.create(ShaderModule);
        self.* = .{ .code = try allocator.dupe(u8, data) };
        return self;
    }

    pub fn deinit(self: *ShaderModule) void {
        allocator.free(self.code);
        allocator.destroy(self);
    }

    fn compile(self: *ShaderModule, entrypoint: [:0]const u8, target: [:0]const u8) !*d3dcommon.IBlob {
        var bytecode: *d3dcommon.IBlob = undefined;
        var errors: ?*d3dcommon.IBlob = null;

        const hr = d3dcompiler.D3DCompile(
            self.code.ptr,
            self.code.len,
            null,
            null,
            null,
            entrypoint,
            target,
            d3dcompiler.COMPILE_ENABLE_STRICTNESS | d3dcompiler.COMPILE_DEBUG,
            0,
            @ptrCast(&bytecode),
            @ptrCast(&errors),
        );

        if (errors) |err| {
            const message: [*:0]const u8 = @ptrCast(err.getBufferPointer());
            std.log.err("{s}", .{message});
            _ = err.release();
        }

        if (hr != 0) {
            return error.CompileShaderFailed;
        }

        return bytecode;
    }
};

pub const RenderPipeline = struct {
    manager: Manager(RenderPipeline) = .{},
    device: *Device,

    rasterizer: *d3d11.IRasterizerState,
    depth_stencil_state: ?*d3d11.IDepthStencilState,
    blend_state: ?*d3d11.IBlendState,
    blend_factor: [4]f32,
    sample_mask: u32,
    topology: d3dcommon.PRIMITIVE_TOPOLOGY,
    layout: ?*d3d11.IInputLayout,
    vertex_shader: *d3d11.IVertexShader,
    pixel_shader: *d3d11.IPixelShader,

    pub fn create(device: *Device, desc: gpu.RenderPipeline.Descriptor) !*RenderPipeline {
        var rasterizer: *d3d11.IRasterizerState = undefined;
        var depth_stencil_state: ?*d3d11.IDepthStencilState = null;
        var blend_state: ?*d3d11.IBlendState = null;
        var vertex_shader: *d3d11.IVertexShader = undefined;
        var pixel_shader: *d3d11.IPixelShader = undefined;
        var layout: ?*d3d11.IInputLayout = null;

        var vertex_blob: *d3dcommon.IBlob = undefined;

        {
            const rasterizer_desc = d3d11.RASTERIZER_DESC{
                .FillMode = .SOLID,
                .CullMode = conv.CullMode(desc.primitive.cull_mode),
                .FrontCounterClockwise = conv.FrontCounterClockwise(desc.primitive.front_face),
                .DepthBias = if (desc.depth_stencil) |ds| ds.depth_bias else 0,
                .DepthBiasClamp = if (desc.depth_stencil) |ds| ds.depth_bias_clamp else 0.0,
                .SlopeScaledDepthBias = if (desc.depth_stencil) |ds| ds.depth_bias_slope_scale else 0.0,
                .DepthClipEnable = @intFromBool(if (desc.primitive.primitive_depth_clip_control) |x| x.unclipped_depth == false else true),
                .MultisampleEnable = @intFromBool(desc.multisample.count > 1),
                .ScissorEnable = 1,
                .AntialiasedLineEnable = 0,
            };

            const hr = device.device.createRasterizerState(&rasterizer_desc, @ptrCast(&rasterizer));
            if (hr != 0) {
                unreachable;
            }
        }

        {
            const depth_desc: d3d11.DEPTH_STENCIL_DESC = if (desc.depth_stencil) |ds|
                .{
                    .DepthEnable = @intFromBool(ds.depth_compare != .always or ds.depth_write_enabled == true),
                    .DepthWriteMask = if (ds.depth_write_enabled == true) .ALL else .ZERO,
                    .DepthFunc = conv.ComparisonFunc(ds.depth_compare),
                    .StencilEnable = @intFromBool(conv.stencilEnable(ds.stencil_front) or conv.stencilEnable(ds.stencil_back)),
                    .StencilReadMask = @intCast(ds.stencil_read_mask & 0xff),
                    .StencilWriteMask = @intCast(ds.stencil_write_mask & 0xff),
                    .FrontFace = conv.DepthStencilOpDesc(ds.stencil_front),
                    .BackFace = conv.DepthStencilOpDesc(ds.stencil_back),
                }
            else
                .{
                    .DepthEnable = 0,
                    .DepthWriteMask = .ZERO,
                    .DepthFunc = .LESS,
                    .StencilEnable = 0,
                    .StencilReadMask = 0xff,
                    .StencilWriteMask = 0xff,
                    .FrontFace = conv.DepthStencilOpDesc(null),
                    .BackFace = conv.DepthStencilOpDesc(null),
                };

            const hr = device.device.createDepthStencilState(&depth_desc, @ptrCast(&depth_stencil_state));
            if (hr != 0) {
                unreachable;
            }
        }

        {
            var targets = [_]d3d11.RENDER_TARGET_BLEND_DESC{conv.RenderTargetBlendDesc(null)} ** 8;
            for (desc.fragment.targets, 0..) |target, i| {
                targets[i] = conv.RenderTargetBlendDesc(target);
            }

            const blend_desc = d3d11.BLEND_DESC{
                .AlphaToCoverageEnable = @intFromBool(desc.multisample.alpha_to_coverage_enabled == true),
                .IndependentBlendEnable = 1,
                .RenderTarget = targets,
            };

            const hr = device.device.createBlendState(&blend_desc, @ptrCast(&blend_state));
            if (hr != 0) {
                unreachable;
            }
        }

        {
            const vertex_module: *ShaderModule = @alignCast(@ptrCast(desc.vertex.module));
            vertex_blob = try vertex_module.compile(desc.vertex.entrypoint, "vs_5_0");

            const hr = device.device.createVertexShader(vertex_blob.getBufferPointer(), vertex_blob.getBufferSize(), null, @ptrCast(&vertex_shader));
            if (hr != 0) {
                unreachable;
            }
        }

        {
            const pixel_module: *ShaderModule = @alignCast(@ptrCast(desc.fragment.module));
            const pixel_blob = try pixel_module.compile(desc.fragment.entrypoint, "ps_5_0");

            const hr = device.device.createPixelShader(pixel_blob.getBufferPointer(), pixel_blob.getBufferSize(), null, @ptrCast(&pixel_shader));
            if (hr != 0) {
                unreachable;
            }
        }

        {
            // var descs = std.BoundedArray(d3d11.INPUT_ELEMENT_DESC, 16){};

            // d3d11.INPUT_ELEMENT_DESC{

            // };

            // const hr = device.device.createInputLayout(&descs.buffer, @intCast(descs.len), vertex_blob.getBufferPointer(), vertex_blob.getBufferSize(), @ptrCast(&layout));
            // if (hr != 0) {
            //     unreachable;
            // }

            layout = null;
        }

        const self = try allocator.create(RenderPipeline);
        self.* = .{
            .device = device,
            .rasterizer = rasterizer,
            .depth_stencil_state = depth_stencil_state,
            .blend_state = blend_state,
            .blend_factor = .{ 1, 1, 1, 1 },
            .sample_mask = 0xFFFFFFFF,
            .topology = conv.PrimitiveTopologyType(desc.primitive.topology),
            .layout = layout,
            .vertex_shader = vertex_shader,
            .pixel_shader = pixel_shader,
        };
        return self;
    }

    pub fn deinit(self: *RenderPipeline) void {
        allocator.destroy(self);
    }
};

pub const CommandEncoder = struct {
    manager: Manager(CommandEncoder) = .{},
    device: *Device,
    command_buffer: *CommandBuffer,
    reference_tracker: *ReferenceTracker,

    pub fn create(device: *Device) !*CommandEncoder {
        const command_buffer = try CommandBuffer.create(device);

        const self = try allocator.create(CommandEncoder);
        self.* = .{
            .device = device,
            .command_buffer = command_buffer,
            .reference_tracker = command_buffer.reference_tracker,
        };

        return self;
    }

    pub fn deinit(self: *CommandEncoder) void {
        allocator.destroy(self);
    }

    pub fn beginRenderPass(self: *CommandEncoder, desc: gpu.types.RenderPassDescriptor) !*RenderPassEncoder {
        return try RenderPassEncoder.create(self, desc);
    }

    pub fn finish(self: *CommandEncoder) !*CommandBuffer {
        return self.command_buffer;
    }
};

pub const CommandBuffer = struct {
    manager: Manager(CommandBuffer) = .{},
    device: *Device,
    reference_tracker: *ReferenceTracker,
    dcontext: *d3d11.IDeviceContext,

    pub fn create(device: *Device) !*CommandBuffer {
        const reference_tracker = try ReferenceTracker.create();
        errdefer reference_tracker.deinit();

        var context: *d3d11.IDeviceContext = undefined;
        const hr = device.device.createDeferredContext(0, @ptrCast(&context));
        if (hr != 0) {
            return error.CreateDeferredContextFailed;
        }

        const self = try allocator.create(CommandBuffer);
        self.* = .{
            .device = device,
            .reference_tracker = reference_tracker,
            .dcontext = context,
        };

        return self;
    }

    pub fn deinit(self: *CommandBuffer) void {
        _ = self.dcontext.release();
        self.reference_tracker.deinit();
        allocator.destroy(self);
    }
};

pub const RenderPassEncoder = struct {
    manager: Manager(RenderPassEncoder) = .{},
    reference_tracker: *ReferenceTracker,
    dcontext: *d3d11.IDeviceContext,

    pub fn create(encoder: *CommandEncoder, desc: gpu.types.RenderPassDescriptor) !*RenderPassEncoder {
        var width: u32 = 0;
        var height: u32 = 0;

        var render_targets: std.BoundedArray(*d3d11.IRenderTargetView, 8) = .{};

        for (desc.color_attachments) |attach| {
            if (attach.view) |raw| {
                const view: *TextureView = @alignCast(@ptrCast(raw));
                const texture = view.texture;

                try encoder.reference_tracker.referenceTexture(texture);

                width = view.width();
                height = view.height();

                const render_target = render_targets.addOneAssumeCapacity();
                const hr = encoder.device.device.createRenderTargetView(@ptrCast(texture.resource), null, @ptrCast(render_target));
                if (hr != 0) {
                    return error.CreateRenderTargetViewFailed;
                }
            } else {
                unreachable;
            }
        }

        const self = try allocator.create(RenderPassEncoder);
        self.* = .{
            .reference_tracker = encoder.reference_tracker,
            .dcontext = encoder.command_buffer.dcontext,
        };

        const viewport = d3d11.VIEWPORT{
            .TopLeftX = 0,
            .TopLeftY = 0,
            .Width = @floatFromInt(width),
            .Height = @floatFromInt(height),
            .MinDepth = 0,
            .MaxDepth = 1,
        };
        const scissor = w32.RECT{
            .left = 0,
            .top = 0,
            .right = @intCast(width),
            .bottom = @intCast(height),
        };

        std.debug.assert(render_targets.len != 0);
        self.dcontext.omSetRenderTargets(@intCast(render_targets.len), @ptrCast(&render_targets.buffer), null); // TODO depth
        self.dcontext.rsSetViewports(1, @ptrCast(&viewport));
        self.dcontext.rsSetScissorRects(1, @ptrCast(&scissor));
        self.dcontext.clearRenderTargetView(render_targets.buffer[0], &[4]f32{ 0.1, 0.1, 0.1, 1.0 });

        return self;
    }

    pub fn deinit(self: *RenderPassEncoder) void {
        allocator.destroy(self);
    }

    pub fn setPipeline(self: *RenderPassEncoder, pipeline: *RenderPipeline) !void {
        try self.reference_tracker.referenceRenderPipeline(pipeline);

        self.dcontext.rsSetState(pipeline.rasterizer);
        self.dcontext.omSetDepthStencilState(pipeline.depth_stencil_state, 0);
        self.dcontext.omSetBlendState(pipeline.blend_state, &pipeline.blend_factor, pipeline.sample_mask);
        self.dcontext.iaSetPrimitiveTopology(pipeline.topology);
        self.dcontext.iaSetInputLayout(pipeline.layout);

        self.dcontext.vsSetShader(pipeline.vertex_shader, null, 0);
        self.dcontext.psSetShader(pipeline.pixel_shader, null, 0);
    }

    pub fn draw(self: *RenderPassEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) !void {
        self.dcontext.drawInstanced(vertex_count, instance_count, first_vertex, first_instance);
    }

    pub fn end(_: *RenderPassEncoder) !void {
        // Do nothing
    }
};

// implementation details
// ----------------------

const ReferenceTracker = struct {
    render_pipelines: std.ArrayListUnmanaged(*RenderPipeline) = .empty,
    textures: std.ArrayListUnmanaged(*Texture) = .empty,

    fn create() !*ReferenceTracker {
        const self = try allocator.create(ReferenceTracker);
        self.* = .{};
        return self;
    }

    fn deinit(self: *ReferenceTracker) void {
        for (self.render_pipelines.items) |pipeline| {
            pipeline.manager.release();
        }

        for (self.textures.items) |texture| {
            texture.manager.release();
        }

        self.render_pipelines.deinit(allocator);
        self.textures.deinit(allocator);
        allocator.destroy(self);
    }

    fn referenceRenderPipeline(self: *ReferenceTracker, pipeline: *RenderPipeline) !void {
        pipeline.manager.reference();
        try self.render_pipelines.append(allocator, pipeline);
    }

    fn referenceTexture(self: *ReferenceTracker, texture: *Texture) !void {
        texture.manager.reference();
        try self.textures.append(allocator, texture);
    }
};
