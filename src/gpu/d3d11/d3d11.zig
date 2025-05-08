const std = @import("std");
const gpu = @import("../gpu.zig");
const conv = @import("conv.zig");

const w32 = @import("w32");
const dxgi = w32.dxgi;
const d3d11 = w32.d3d11;
const d3dcommon = w32.d3dcommon;
const d3dcompiler = w32.d3dcompiler;

const Manager = @import("../../util.zig").Manager;

const debug = false;
const back_buffer_count = 2;
const allocator = @import("../../prism.zig").allocator;

// FIXME IMPORTANT there is still another memory leak in here

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
    reference_trackers: std.ArrayListUnmanaged(*ReferenceTracker) = .empty,

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
            try self.reference_trackers.append(allocator, command.reference_tracker);
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

    pub fn processQueuedOperations(self: *Device) void {
        // TODO use fences
        for (self.reference_trackers.items) |rt| {
            rt.deinit();
        }
        self.reference_trackers.items.len = 0;

        // _ = self.debug_controller.?.reportLiveDeviceObjects(.{
        //     .detail = true,
        // });
    }
};

pub const Swapchain = struct {
    manager: Manager(Swapchain) = .{},
    device: *Device,
    surface: *Surface,
    swapchain: *dxgi.ISwapChain3,

    sync_interval: u32,
    present_flags: dxgi.PRESENT_FLAG,
    swapchain_flags: dxgi.SWAP_CHAIN_FLAG,
    buffer_index: u32 = 0,
    textures: *Texture,
    views: *TextureView,
    desc: gpu.Swapchain.Descriptor,

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
            .swapchain_flags = swapchain_desc.Flags,
            .textures = texture,
            .views = view,
            .desc = desc,
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
        self.device.processQueuedOperations();
        _ = self.textures.resource.release();

        const hr = self.swapchain.resizeBuffers(back_buffer_count, width, height, .UNKNOWN, self.swapchain_flags);
        if (hr != 0) {
            std.debug.panic("{X}", .{@as(u32, @bitCast(hr))});
        }

        var buffer: *d3d11.ITexture2D = undefined;
        _ = self.swapchain.getBuffer(0, &d3d11.ITexture2D.IID, @ptrCast(&buffer));
        self.textures.resource = @ptrCast(buffer);
        self.textures.size.width = width;
        self.textures.size.height = height;
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
    device: *Device,
    resource: *d3d11.IBuffer,
    // gpu_count: u32 = 0,

    size: u64,
    usage: gpu.Buffer.UsageFlags,

    pub fn create(device: *Device, desc: gpu.Buffer.Descriptor) !*Buffer {
        const size = std.math.ceilPowerOfTwoAssert(u32, desc.size);
        const buffer_desc = d3d11.BUFFER_DESC{
            .ByteWidth = size,
            .Usage = .DYNAMIC,
            .BindFlags = .{
                .VERTEX_BUFFER = desc.usage.vertex,
                .INDEX_BUFFER = desc.usage.index,
                .CONSTANT_BUFFER = desc.usage.uniform,
                // SHADER_RESOURCE: bool = false,
                // STREAM_OUTPUT: bool = false,
                // RENDER_TARGET: bool = false,
                // DEPTH_STENCIL: bool = false,
                // UNORDERED_ACCESS: bool = false,
                // __unused8: bool = false,
                // DECODER: bool = false,
                // VIDEO_ENCODER: bool = false,
                // __unused: u21 = 0,
            },
            .CPUAccessFlags = .{ .WRITE = true },
            .MiscFlags = .{
                // GENERATE_MIPS: bool = false,
                // SHARED: bool = false,
                // TEXTURECUBE: bool = false,
                // __unused3: bool = false,
                // DRAWINDIRECT_ARGS: bool = false,
                // BUFFER_ALLOW_RAW_VIEWS: bool = false,
                // BUFFER_STRUCTURED: bool = false,
                // RESOURCE_CLAMP: bool = false,
                // SHARED_KEYEDMUTEX: bool = false,
                // GDI_COMPATIBLE: bool = false,
                // __unused10: bool = false,
                // SHARED_NTHANDLE: bool = false,
                // RESTRICTED_CONTENT: bool = false,
                // RESTRICT_SHARED_RESOURCE: bool = false,
                // RESTRICT_SHARED_RESOURCE_DRIVER: bool = false,
                // GUARDED: bool = false,
                // __unused16: bool = false,
                // TILE_POOL: bool = false,
                // TILED: bool = false,
                // HW_PROTECTED: bool = false,
                // __unused: u12 = 0,
            },
        };

        // const initial_data = d3d11.SUBRESOURCE_DATA{ .pSysMem = @ptrCast(desc.data) };
        const data = d3d11.SUBRESOURCE_DATA{ .pSysMem = @ptrCast(desc.data) };
        const initial_data = if (desc.data == null) null else &data;

        var buffer: *d3d11.IBuffer = undefined;
        const hr = device.device.createBuffer(&buffer_desc, initial_data, @ptrCast(&buffer));
        if (hr != 0) {
            unreachable;
        }

        const self = try allocator.create(Buffer);
        self.* = .{
            .device = device,
            .resource = buffer,
            .size = size,
            .usage = desc.usage,
        };

        return self;
    }

    pub fn deinit(self: *Buffer) void {
        _ = self.resource.release();
        allocator.destroy(self);
    }
};

pub const Texture = struct {
    manager: Manager(Texture) = .{},
    device: *Device,
    resource: *d3d11.IResource,

    usage: gpu.Texture.UsageFlags,
    dimension: gpu.Texture.Dimension,
    size: gpu.types.Extent3D,
    format: gpu.Texture.Format,
    mip_level_count: u32,
    sample_count: u32,
    has_shader_view: bool,

    pub fn create(device: *Device, desc: gpu.Texture.Descriptor) !*Texture {
        var has_shader_view = false;

        const data = d3d11.SUBRESOURCE_DATA{ .pSysMem = @ptrCast(desc.data), .SysMemPitch = desc.size.width * conv.Stride(desc.format) };
        const initial_data = if (desc.data == null) null else &data;

        const resource: *d3d11.IResource = switch (desc.dimension) {
            .@"1d" => unreachable,
            .@"2d" => blk: {
                const texture_desc = d3d11.TEXTURE2D_DESC{
                    .Width = desc.size.width,
                    .Height = desc.size.height,
                    .MipLevels = desc.mip_level_count,
                    .ArraySize = desc.size.depth_or_array_layers,
                    .Format = conv.dxgiFormatForTexture(desc.format),
                    .SampleDesc = .{ .Count = desc.sample_count, .Quality = 0 },
                    .Usage = .DEFAULT,
                    .BindFlags = conv.ResourceFlagsForTexture(desc.usage, desc.format),
                    .CPUAccessFlags = .{},
                    .MiscFlags = .{},
                };

                has_shader_view = texture_desc.BindFlags.SHADER_RESOURCE;

                var texture: *d3d11.ITexture2D = undefined;
                const hr = device.device.createTexture2D(&texture_desc, initial_data, @ptrCast(&texture));
                if (hr != 0) {
                    unreachable;
                }
                break :blk @ptrCast(texture);
            },
            .@"3d" => unreachable,
        };

        const self = try allocator.create(Texture);
        self.* = .{
            .device = device,
            .resource = resource,
            .usage = desc.usage,
            .dimension = desc.dimension,
            .size = desc.size,
            .format = desc.format,
            .mip_level_count = desc.mip_level_count,
            .sample_count = desc.sample_count,
            .has_shader_view = has_shader_view,
        };

        return self;
    }

    pub fn createForSwapchain(device: *Device, desc: gpu.Swapchain.Descriptor, resource: *d3d11.ITexture2D) !*Texture {
        const texture = try allocator.create(Texture);
        texture.* = .{
            .device = device,
            .resource = @ptrCast(resource),
            .usage = desc.usage,
            .dimension = .@"2d",
            .size = .{ .width = desc.width, .height = desc.height, .depth_or_array_layers = 1 },
            .format = desc.format,
            .mip_level_count = 1,
            .sample_count = 1,
            .has_shader_view = false,
        };

        return texture;
    }

    pub fn deinit(self: *Texture) void {
        switch (self.dimension) {
            .@"1d" => unreachable,
            .@"2d" => _ = @as(*d3d11.ITexture2D, @ptrCast(self.resource)).release(),
            .@"3d" => unreachable,
        }
        allocator.destroy(self);
    }

    fn calcSubresource(texture: *Texture, mip_level: u32, array_slice: u32) u32 {
        return mip_level + (array_slice * texture.mip_level_count);
    }
};

pub const TextureView = struct {
    manager: Manager(TextureView) = .{},
    texture: *Texture,
    shader_view: ?*d3d11.IShaderResourceView,

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

        var shader_view: ?*d3d11.IShaderResourceView = null;
        if (texture.has_shader_view) {
            _ = texture.device.device.createShaderResourceView(texture.resource, null, @ptrCast(&shader_view));
        }

        const self = try allocator.create(TextureView);
        self.* = .{
            .texture = texture,
            .shader_view = shader_view,
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

    pub fn deinit(self: *TextureView) void {
        self.texture.manager.release();
        allocator.destroy(self);
    }

    pub fn width(self: *TextureView) u32 {
        return @max(1, self.texture.size.width >> @intCast(self.base_mip_level));
    }

    pub fn height(self: *TextureView) u32 {
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
            var descs = std.BoundedArray(d3d11.INPUT_ELEMENT_DESC, 16){};

            if (desc.vertex.layout) |vbl| {
                for (vbl.attributes) |attr| {
                    try descs.append(d3d11.INPUT_ELEMENT_DESC{
                        .SemanticName = attr.name.?,
                        .SemanticIndex = attr.index,
                        .Format = conv.VertexFormat(attr.format),
                        .InputSlot = 0,
                        .AlignedByteOffset = 0xFFFFFFFF,
                        .InputSlotClass = if (vbl.step_mode == .vertex) .INPUT_PER_VERTEX_DATA else .INPUT_PER_INSTANCE_DATA,
                        .InstanceDataStepRate = 0,
                    });
                }
            } else {
                var reflector: *d3dcompiler.IShaderReflection = undefined;
                var hr = d3dcompiler.D3DReflect(vertex_blob.getBufferPointer(), vertex_blob.getBufferSize(), &d3dcompiler.IShaderReflection.IID, @ptrCast(&reflector));
                if (hr != 0) {
                    unreachable;
                }

                var shader_desc: d3dcompiler.SHADER_DESC = undefined;
                hr = reflector.getDesc(&shader_desc);
                if (hr != 0) {
                    unreachable;
                }

                for (0..shader_desc.InputParameters) |i| {
                    var param_desc: d3dcompiler.SIGNATURE_PARAMETER_DESC = undefined;
                    hr = reflector.getInputParameterDesc(@intCast(i), &param_desc);
                    if (hr != 0) {
                        unreachable;
                    }

                    try descs.append(d3d11.INPUT_ELEMENT_DESC{
                        .SemanticName = param_desc.SemanticName,
                        .SemanticIndex = param_desc.SemanticIndex,
                        .Format = conv.InputElementFormat(param_desc.Mask, param_desc.ComponentType),
                        .InputSlot = 0,
                        .AlignedByteOffset = 0xFFFFFFFF,
                        .InputSlotClass = .INPUT_PER_VERTEX_DATA,
                        .InstanceDataStepRate = 0,
                    });
                }
            }

            const hr = device.device.createInputLayout(&descs.buffer, @intCast(descs.len), vertex_blob.getBufferPointer(), vertex_blob.getBufferSize(), @ptrCast(&layout));
            if (hr != 0) {
                unreachable;
            }
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

    pub fn writeBuffer(self: *CommandEncoder, buffer: *Buffer, offset: u64, ptr: [*]const u8, len: usize) !void {
        var map: d3d11.MAPPED_SUBRESOURCE = undefined;
        const hr = self.command_buffer.dcontext.map(@ptrCast(buffer.resource), 0, .WRITE_DISCARD, .{}, &map);
        if (hr != 0) {
            unreachable;
        }
        defer self.command_buffer.dcontext.unmap(@ptrCast(buffer.resource), 0);

        const dest: [*]u8 = @ptrCast(map.pData);
        @memcpy(dest[offset..][0..len], ptr[0..len]);
    }

    pub fn writeTexture(self: *CommandEncoder, texture: *Texture, ptr: [*]u8, _: usize) !void {
        const box = d3d11.BOX{
            .left = 0,
            .right = texture.size.width,
            .top = 0,
            .bottom = texture.size.height,
            .front = 0,
            .back = 1,
        };

        const pitch = texture.size.width * conv.Stride(texture.format);
        self.command_buffer.dcontext.updateSubresource(
            texture.resource,
            0,
            &box,
            @ptrCast(ptr),
            pitch,
            0,
        );
    }

    pub fn copyTexture(self: *CommandEncoder, source: gpu.types.ImageCopyTexture, destination: gpu.types.ImageCopyTexture, copy_size_raw: gpu.types.Extent3D) !void {
        const source_texture: *Texture = @alignCast(@ptrCast(source.texture));
        const destination_texture: *Texture = @alignCast(@ptrCast(destination.texture));

        try self.reference_tracker.referenceTexture(source_texture);
        try self.reference_tracker.referenceTexture(destination_texture);

        const copy_size = calcExtent(destination_texture.dimension, copy_size_raw);
        const source_origin = calcOrigin(source_texture.dimension, source.origin);
        const destination_origin = calcOrigin(destination_texture.dimension, destination.origin);

        const source_subresource_index = source_texture.calcSubresource(source.mip_level, source_origin.array_slice);
        const destination_subresource_index = destination_texture.calcSubresource(destination.mip_level, destination_origin.array_slice);

        std.debug.assert(copy_size.array_count == 1); // TODO

        self.command_buffer.dcontext.copySubresourceRegion(
            destination_texture.resource,
            destination_subresource_index,
            destination_origin.x,
            destination_origin.y,
            destination_origin.z,
            source_texture.resource,
            source_subresource_index,
            &.{
                .left = source_origin.x,
                .top = source_origin.y,
                .front = source_origin.z,
                .right = source_origin.x + copy_size.width,
                .bottom = source_origin.y + copy_size.height,
                .back = source_origin.z + copy_size.depth,
            },
        );
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
        var depth_stencil_view: ?*d3d11.IDepthStencilView = null;

        defer {
            for (render_targets.constSlice()) |rtv| {
                _ = rtv.release();
            }
            if (depth_stencil_view) |dsv| {
                _ = dsv.release();
            }
        }

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

        if (desc.depth_stencil_attachment) |attach| {
            const view: *TextureView = @alignCast(@ptrCast(attach.view));
            const texture = view.texture;

            try encoder.reference_tracker.referenceTexture(texture);

            const hr = encoder.device.device.createDepthStencilView(texture.resource, null, &depth_stencil_view);
            if (hr != 0) {
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

        self.dcontext.omSetRenderTargets(@intCast(render_targets.len), @ptrCast(&render_targets.buffer), depth_stencil_view);
        self.dcontext.rsSetViewports(1, @ptrCast(&viewport));
        self.dcontext.rsSetScissorRects(1, @ptrCast(&scissor));

        for (desc.color_attachments, 0..) |attach, i| {
            if (attach.load_op == .clear) {
                const target = render_targets.buffer[i];
                const clear_color = [4]f32{
                    @floatCast(attach.clear_value.r),
                    @floatCast(attach.clear_value.g),
                    @floatCast(attach.clear_value.b),
                    @floatCast(attach.clear_value.a),
                };

                self.dcontext.clearRenderTargetView(target, &clear_color);
            }
        }

        if (desc.depth_stencil_attachment) |attach| {
            const flags = d3d11.CLEAR_FLAGS{
                .DEPTH = attach.depth_load_op == .clear,
                .STENCIL = attach.stencil_load_op == .clear,
            };

            if (flags != d3d11.CLEAR_FLAGS{}) {
                self.dcontext.clearDepthStencilView(depth_stencil_view.?, flags, attach.depth_clear_value, attach.stencil_clear_value);
            }
        }

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

    pub fn setVertexBuffer(self: *RenderPassEncoder, slot: u32, buffer: *Buffer, offset: u32, stride: u32) !void {
        try self.reference_tracker.referenceBuffer(buffer);
        self.dcontext.iaSetVertexBuffers(slot, 1, @ptrCast(&buffer.resource), @ptrCast(&stride), @ptrCast(&offset));
    }

    pub fn setIndexBuffer(self: *RenderPassEncoder, buffer: *Buffer, format: gpu.types.IndexFormat, offset: u64) !void {
        try self.reference_tracker.referenceBuffer(buffer);
        self.dcontext.iaSetIndexBuffer(@ptrCast(buffer.resource), conv.IndexFormat(format), @intCast(offset));
    }

    pub fn setUniformBuffer(self: *RenderPassEncoder, slot: u32, buffer: *Buffer) !void {
        try self.reference_tracker.referenceBuffer(buffer);
        self.dcontext.vsSetConstantBuffers(slot, 1, @ptrCast(&buffer.resource));
    }

    pub fn setTexture(self: *RenderPassEncoder, slot: u32, view: *TextureView, sampler: *Sampler) !void {
        self.dcontext.psSetShaderResources(slot, 1, @ptrCast(&view.shader_view));
        self.dcontext.psSetSamplers(slot, 1, @ptrCast(&sampler.sampler));
    }

    pub fn draw(self: *RenderPassEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) !void {
        self.dcontext.drawInstanced(vertex_count, instance_count, first_vertex, first_instance);
    }

    pub fn drawIndexed(self: *RenderPassEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) !void {
        self.dcontext.drawIndexedInstanced(index_count, instance_count, first_index, base_vertex, first_instance);
    }

    pub fn end(_: *RenderPassEncoder) !void {
        // Do nothing
    }
};

pub const Sampler = struct {
    manager: Manager(Sampler) = .{},
    sampler: *d3d11.ISamplerState,

    pub fn create(device: *Device, desc: gpu.Sampler.Descriptor) !*Sampler {
        const sampler_desc = d3d11.SAMPLER_DESC{
            .Filter = @enumFromInt(conv.Filter(desc.mag_filter, desc.min_filter, desc.mipmap_filter, desc.max_anisotropy)),
            .AddressU = conv.TextureAddressMode(desc.address_mode_u),
            .AddressV = conv.TextureAddressMode(desc.address_mode_v),
            .AddressW = conv.TextureAddressMode(desc.address_mode_w),
            .MipLODBias = 0.0,
            .MaxAnisotropy = desc.max_anisotropy,
            .ComparisonFunc = if (desc.compare != .undefined) conv.ComparisonFunc(desc.compare) else .NEVER,
            .BorderColor = [4]f32{ 0.0, 0.0, 0.0, 0.0 },
            .MinLOD = desc.lod_min_clamp,
            .MaxLOD = desc.lod_max_clamp,
        };

        var sampler: *d3d11.ISamplerState = undefined;
        const hr = device.device.createSamplerState(&sampler_desc, @ptrCast(&sampler));
        if (hr != 0) {
            unreachable;
        }

        const self = try allocator.create(Sampler);
        self.* = .{
            .sampler = sampler,
        };

        return self;
    }

    pub fn deinit(self: *Sampler) void {
        allocator.destroy(self);
    }
};

// implementation details
// ----------------------

// TODO when should this stuff actually be freed
const ReferenceTracker = struct {
    buffers: std.ArrayListUnmanaged(*Buffer) = .empty,
    render_pipelines: std.ArrayListUnmanaged(*RenderPipeline) = .empty,
    textures: std.ArrayListUnmanaged(*Texture) = .empty,

    fn create() !*ReferenceTracker {
        const self = try allocator.create(ReferenceTracker);
        self.* = .{};
        return self;
    }

    fn deinit(self: *ReferenceTracker) void {
        for (self.buffers.items) |buffer| {
            // buffer.gpu_count -= 1;
            buffer.manager.release();
        }

        for (self.render_pipelines.items) |pipeline| {
            pipeline.manager.release();
        }

        for (self.textures.items) |texture| {
            texture.manager.release();
        }

        self.buffers.deinit(allocator);
        self.render_pipelines.deinit(allocator);
        self.textures.deinit(allocator);
        allocator.destroy(self);
    }

    fn referenceBuffer(tracker: *ReferenceTracker, buffer: *Buffer) !void {
        buffer.manager.reference();
        try tracker.buffers.append(allocator, buffer);
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

fn calcExtent(dimension: gpu.Texture.Dimension, extent: gpu.types.Extent3D) struct {
    width: u32,
    height: u32,
    depth: u32,
    array_count: u32,
} {
    return .{
        .width = extent.width,
        .height = extent.height,
        .depth = if (dimension == .@"3d") extent.depth_or_array_layers else 1,
        .array_count = if (dimension == .@"3d") 0 else extent.depth_or_array_layers,
    };
}

fn calcOrigin(dimension: gpu.Texture.Dimension, origin: gpu.types.Origin3D) struct {
    x: u32,
    y: u32,
    z: u32,
    array_slice: u32,
} {
    return .{
        .x = origin.x,
        .y = origin.y,
        .z = if (dimension == .@"3d") origin.z else 0,
        .array_slice = if (dimension == .@"3d") 0 else origin.z,
    };
}
