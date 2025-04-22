const std = @import("std");
const sysgpu = @import("../gpu.zig");
const conv = @import("conv.zig");
const w32 = @import("w32");
const dxgi = w32.dxgi;
const d3d12 = w32.d3d12;
const Manager = @import("../../util.zig").Manager;

const allocator = @import("../../prism.zig").allocator;
const general_heap_size = 1024;
const general_block_size = 16;
const sampler_heap_size = 1024;
const sampler_block_size = 16;
const rtv_heap_size = 1024;
const rtv_block_size = 16;
const dsv_heap_size = 1024;
const dsv_block_size = 1;

const debug = false;
var cookie: u32 = 0;

pub const Instance = struct {
    manager: Manager(Instance) = .{},
    factory: *dxgi.IFactory4,
    allow_tearing: bool,

    pub fn create(_: sysgpu.Instance.Descriptor) !*Instance {
        var factory: *dxgi.IFactory4 = undefined;
        _ = dxgi.CreateDXGIFactory2(@intFromBool(debug), &dxgi.IFactory4.IID, @ptrCast(&factory));

        // TODO check feature support

        if (debug) {
            var controller: *d3d12.IDebug1 = undefined;
            const hr = d3d12.D3D12GetDebugInterface(&d3d12.IDebug1.IID, @ptrCast(&controller));
            if (hr == 0) {
                defer _ = controller.release();
                controller.enableDebugLayer();
                controller.setEnableGPUBasedValidation(1);
            }
        }

        const self = try allocator.create(Instance);
        self.* = .{
            .factory = factory,
            .allow_tearing = false,
        };

        return self;
    }

    pub fn deinit(self: *Instance) void {
        _ = self.factory.release();
        allocator.destroy(self);
    }

    pub const createSurface = Surface.create;
    pub const createAdapter = Adapter.create;
};

pub const Surface = struct {
    manager: Manager(Surface) = .{},
    hwnd: w32.HWND,

    fn create(_: *Instance, desc: sysgpu.Surface.Descriptor) !*Surface {
        const self = try allocator.create(Surface);
        self.* = .{
            .hwnd = desc.windows.hwnd,
        };

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
    device: *d3d12.IDevice,
    desc: dxgi.ADAPTER_DESC1,
    description: [256:0]u8 = undefined,
    adapter_type: sysgpu.Adapter.Type,

    fn create(instance: *Instance, options: sysgpu.Adapter.Options) !*Adapter {
        var desc: dxgi.ADAPTER_DESC1 = undefined;
        var last_desc: dxgi.ADAPTER_DESC1 = undefined;
        var last_adapter: ?*dxgi.IAdapter1 = null;
        var last_adapter_type: sysgpu.Adapter.Type = .unknown;

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

            const adapter_type: sysgpu.Adapter.Type = blk: {
                var device: *d3d12.IDevice = undefined;
                const hr = d3d12.D3D12CreateDevice(@ptrCast(adapter), .@"11_0", &d3d12.IDevice.IID, @ptrCast(&device));
                if (hr == 0) {
                    defer _ = device.release();

                    var arch = d3d12.FEATURE_DATA_ARCHITECTURE{};
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

            if ((options.power_preference == .performance and adapter_type == .discrete_gpu) or (options.power_preference == .efficent and adapter_type != .discrete_gpu)) {
                if (last_adapter) |last| {
                    _ = last.release();
                }
                last_adapter = adapter;
                last_desc = desc;
                last_adapter_type = adapter_type;
            }
        }

        if (last_adapter) |selected| {
            var device: *d3d12.IDevice = undefined;
            const hr = d3d12.D3D12CreateDevice(@ptrCast(selected), .@"11_0", &d3d12.IDevice.IID, @ptrCast(&device));
            if (hr == 0) {
                _ = selected.addRef();

                const self = try allocator.create(Adapter);
                self.* = .{
                    .instance = instance,
                    .adapter = selected,
                    .device = device,
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

    pub fn getProperties(self: *Adapter) sysgpu.Adapter.Properties {
        return .{
            .vendor_id = self.desc.VendorId,
            .vendor_name = "", // TODO
            .architecture = "", // TODO
            .device_id = self.desc.DeviceId,
            .name = &self.description,
            .driver_description = "", // TODO
            .adapter_type = self.adapter_type,
            .backend_type = .d3d12,
        };
    }

    pub const createDevice = Device.create;
};

pub const Device = struct {
    manager: Manager(Device) = .{},
    adapter: *Adapter,
    device: *d3d12.IDevice,
    queue: *Queue,
    general_heap: DescriptorHeap = undefined,
    sampler_heap: DescriptorHeap = undefined,
    rtv_heap: DescriptorHeap = undefined,
    dsv_heap: DescriptorHeap = undefined,
    command_manager: CommandManager = undefined,
    // streaming_manager: StreamingManager = undefined,
    // reference_trackers: std.ArrayListUnmanaged(*ReferenceTracker) = .{},

    fn create(adapter: *Adapter, _: sysgpu.Device.Descriptor) !*Device {
        if (debug) {
            var info_queue: *d3d12.IInfoQueue1 = undefined;
            const hr = adapter.device.queryInterface(&d3d12.IInfoQueue1.IID, @ptrCast(&info_queue));
            if (hr == 0) {
                defer _ = info_queue.release();

                var deny_ids = [_]d3d12.MESSAGE_ID{ .CLEARRENDERTARGETVIEW_MISMATCHINGCLEARVALUE, .CLEARDEPTHSTENCILVIEW_MISMATCHINGCLEARVALUE, .CREATERESOURCE_STATE_IGNORED };
                var severities = [_]d3d12.MESSAGE_SEVERITY{ .INFO, .MESSAGE };

                var filter = d3d12.INFO_QUEUE_FILTER{
                    .AllowList = .{},
                    .DenyList = .{
                        .pSeverityList = &severities,
                        .NumSeverities = severities.len,
                        .pIDList = &deny_ids,
                        .NumIDs = deny_ids.len,
                    },
                };

                _ = info_queue.pushStorageFilter(&filter);

                _ = info_queue.registerMessageCallback(Device.logger, .{}, null, &cookie);
            }
        }

        const queue = try allocator.create(Queue);
        errdefer allocator.destroy(queue);

        const self = try allocator.create(Device);
        errdefer allocator.destroy(self);

        self.* = .{
            .adapter = adapter,
            .device = adapter.device,
            .queue = queue,
        };

        self.queue.* = try Queue.create(self);
        errdefer self.queue.deinit();

        self.general_heap = try .create(self, .CBV_SRV_UAV, .{ .SHADER_VISIBLE = true }, general_heap_size, general_block_size);
        errdefer self.general_heap.deinit();

        self.sampler_heap = try .create(self, .SAMPLER, .{ .SHADER_VISIBLE = true }, sampler_heap_size, sampler_block_size);
        errdefer self.sampler_heap.deinit();

        self.rtv_heap = try .create(self, .RTV, .{}, rtv_heap_size, rtv_block_size);
        errdefer self.rtv_heap.deinit();

        self.dsv_heap = try .create(self, .DSV, .{}, dsv_heap_size, dsv_block_size);
        errdefer self.dsv_heap.deinit();

        self.command_manager = .create(self);

        // TODO streaming manager

        return self;
    }

    fn logger(category: d3d12.MESSAGE_CATEGORY, severity: d3d12.MESSAGE_SEVERITY, id: d3d12.MESSAGE_ID, description: [*c]const u8, _: ?*anyopaque) callconv(.winapi) void {
        std.debug.print("{s} [{s}] {s} ({d})\n", .{
            @tagName(severity),
            @tagName(category),
            description,
            @intFromEnum(id),
        });
    }

    pub fn getQueue(self: *Device) !*Queue {
        return self.queue;
    }

    pub const createSwapchain = SwapChain.create;
    pub const createShader = ShaderModule.create;
    pub const createPipelineLayout = PipelineLayout.create;
    pub const createRenderPipeline = RenderPipeline.create;
};

const CommandManager = struct {
    device: *Device,
    free_allocators: std.ArrayListUnmanaged(*d3d12.ICommandAllocator) = .empty,
    free_command_lists: std.ArrayListUnmanaged(*d3d12.IGraphicsCommandList) = .empty,

    fn create(device: *Device) CommandManager {
        return .{ .device = device };
    }
};

const Queue = struct {
    manager: Manager(Queue) = .{},
    device: *Device,
    command_queue: *d3d12.ICommandQueue,
    fence: *d3d12.IFence,
    fence_value: u64 = 0,
    fence_event: w32.HANDLE,

    fn create(device: *Device) !Queue {
        const desc = d3d12.COMMAND_QUEUE_DESC{
            .Type = .DIRECT,
            .Priority = 0,
            .Flags = .{},
            .NodeMask = 0,
        };
        var command_queue: *d3d12.ICommandQueue = undefined;
        _ = device.device.createCommandQueue(&desc, &d3d12.ICommandQueue.IID, @ptrCast(&command_queue));
        errdefer _ = command_queue.release();

        var fence: *d3d12.IFence = undefined;
        _ = device.device.createFence(0, .{}, &d3d12.IFence.IID, @ptrCast(&fence));
        errdefer _ = fence.release();

        const fence_event = w32.CreateEventW(null, 0, 0, null).?;
        errdefer w32.CloseHandle(fence_event);

        return .{
            .device = device,
            .command_queue = command_queue,
            .fence = fence,
            .fence_event = fence_event,
        };
    }

    fn deinit(self: *Queue) void {
        _ = self; // autofix
        unreachable;
    }

    fn signal(self: *Queue) !void {
        const hr = self.command_queue.signal(self.fence, self.fence_value);
        if (hr != 0) {
            return error.SignalFailed;
        }
    }
};

pub const SwapChain = struct {
    manager: Manager(SwapChain) = .{},
    device: *Device,
    surface: *Surface,
    queue: *Queue,
    swapchain: *dxgi.ISwapChain3,
    width: u32,
    height: u32,
    back_buffer_count: u32,
    sync_interval: u32,
    present_flags: dxgi.PRESENT_FLAG,
    textures: [2]*Texture,
    views: [2]*TextureView,
    fence_values: [2]u64,
    buffer_index: u32 = 0,

    fn create(device: *Device, surface: *Surface, desc: sysgpu.SwapChain.Descriptor) !*SwapChain {
        const instance = device.adapter.instance;

        const back_buffer_count = 2;
        var swapchain_desc = dxgi.SWAP_CHAIN_DESC1{
            .Width = desc.width,
            .Height = desc.height,
            .Format = conv.formatToTexture(desc.format),
            .Stereo = 0,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .BufferUsage = conv.usage(desc.usage),
            .BufferCount = back_buffer_count,
            .Scaling = .STRETCH,
            .SwapEffect = .FLIP_DISCARD,
            .AlphaMode = .UNSPECIFIED,
            .Flags = .{ .ALLOW_TEARING = instance.allow_tearing },
        };

        var swapchain: *dxgi.ISwapChain3 = undefined;
        _ = instance.factory.createSwapChainForHwnd(@ptrCast(device.queue.command_queue), surface.hwnd, &swapchain_desc, null, null, @ptrCast(&swapchain));
        errdefer _ = swapchain.release();

        var textures: [back_buffer_count]*Texture = undefined;
        var views: [back_buffer_count]*TextureView = undefined;
        var fence_values: [back_buffer_count]u64 = undefined;
        errdefer {
            for (views) |view| view.manager.release();
            for (textures) |texture| texture.manager.release();
        }

        for (0..back_buffer_count) |i| {
            var buffer: *d3d12.IResource = undefined;
            _ = swapchain.getBuffer(@intCast(i), &d3d12.IResource.IID, @ptrCast(&buffer));

            const texture = try Texture.createForSwapchain(device, desc, buffer);
            const view = try texture.createView(.{});

            textures[i] = texture;
            views[i] = view;
            fence_values[i] = 0;
        }

        const self = try allocator.create(SwapChain);
        self.* = .{
            .device = device,
            .surface = surface,
            .queue = device.queue,
            .swapchain = swapchain,
            .width = desc.width,
            .height = desc.height,
            .back_buffer_count = back_buffer_count,
            .sync_interval = if (desc.present_mode == .immediate) 0 else 1,
            .present_flags = .{ .ALLOW_TEARING = desc.present_mode == .immediate and instance.allow_tearing },
            .textures = textures,
            .views = views,
            .fence_values = fence_values,
        };

        return self;
    }

    fn deinit(self: *SwapChain) void {
        _ = self; // autofix
        unreachable;
    }

    pub fn present(self: *SwapChain) !void {
        _ = self.swapchain.present(self.sync_interval, self.present_flags);

        self.queue.fence_value += 1;
        try self.queue.signal();
        self.fence_values[self.buffer_index] = self.queue.fence_value;
    }
};

const DescriptorHeap = struct {
    device: *Device,
    heap: *d3d12.IDescriptorHeap,
    cpu_base: d3d12.CPU_DESCRIPTOR_HANDLE,
    gpu_base: d3d12.GPU_DESCRIPTOR_HANDLE,
    descriptor_size: u32,
    descriptor_count: u32,
    block_size: u32,
    next_alloc: u32,

    fn create(device: *Device, heap_type: d3d12.DESCRIPTOR_HEAP_TYPE, flags: d3d12.DESCRIPTOR_HEAP_FLAGS, count: u32, block_size: u32) !DescriptorHeap {
        const desc = d3d12.DESCRIPTOR_HEAP_DESC{
            .Type = heap_type,
            .NumDescriptors = count,
            .Flags = flags,
            .NodeMask = 0,
        };

        var heap: *d3d12.IDescriptorHeap = undefined;
        _ = device.device.createDescriptorHeap(&desc, &d3d12.IDescriptorHeap.IID, @ptrCast(&heap));
        errdefer _ = heap.release();

        const size = device.device.getDescriptorHandleIncrementSize(heap_type);

        var cpu_base: d3d12.CPU_DESCRIPTOR_HANDLE = undefined;
        _ = heap.getCpuDescriptorHandleForHeapStart(&cpu_base);

        var gpu_base: d3d12.GPU_DESCRIPTOR_HANDLE = .{ .ptr = 0 };
        if (flags.SHADER_VISIBLE)
            _ = heap.getGpuDescriptorHandleForHeapStart(&gpu_base);

        return .{
            .device = device,
            .heap = heap,
            .cpu_base = cpu_base,
            .gpu_base = gpu_base,
            .descriptor_size = size,
            .descriptor_count = count,
            .block_size = block_size,
            .next_alloc = 0,
        };
    }

    fn deinit(self: *DescriptorHeap) void {
        _ = self; // autofix
        unreachable;
    }
};

const Texture = struct {
    manager: Manager(Texture) = .{},
    device: *Device,
    resource: Resource,
    usage: sysgpu.Texture.UsageFlags,
    dimension: sysgpu.Texture.Dimension,
    size: sysgpu.Extent3D,
    format: sysgpu.Texture.Format,
    mip_level_count: u32,
    sample_count: u32,

    pub fn deinit(self: *Texture) void {
        _ = self; // autofix
        unreachable;
    }

    fn createForSwapchain(device: *Device, desc: sysgpu.SwapChain.Descriptor, resource: *d3d12.IResource) !*Texture {
        const texture = try allocator.create(Texture);
        texture.* = .{
            .device = device,
            .resource = Resource.init(resource, .PRESENT),
            .usage = desc.usage,
            .dimension = .@"2d",
            .size = .{ .width = desc.width, .height = desc.height, .depth_or_array_layers = 1 },
            .format = desc.format,
            .mip_level_count = 1,
            .sample_count = 1,
        };

        return texture;
    }

    const createView = TextureView.create;

    fn calcSubresource(texture: *Texture, mip_level: u32, array_slice: u32) u32 {
        return mip_level + (array_slice * texture.mip_level_count);
    }
};

const TextureView = struct {
    manager: Manager(TextureView) = .{},
    texture: *Texture,
    format: sysgpu.Texture.Format,
    dimension: sysgpu.TextureView.Dimension,
    base_mip_level: u32,
    mip_level_count: u32,
    base_array_layer: u32,
    array_layer_count: u32,
    aspect: sysgpu.Texture.Aspect,
    base_subresource: u32,

    fn create(texture: *Texture, desc: sysgpu.TextureView.Descriptor) !*TextureView {
        texture.manager.reference();

        const texture_dimension: sysgpu.TextureView.Dimension = switch (texture.dimension) {
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

    pub fn deinit(self: *TextureView) void {
        _ = self; // autofix
        unreachable;
    }
};

pub const Resource = struct {
    // NOTE - this is a naive sync solution as a placeholder until render graphs are implemented

    resource: *d3d12.IResource,
    // mem_allocator: ?*MemoryAllocator = null,
    read_state: d3d12.RESOURCE_STATES,
    // allocation: ?MemoryAllocator.Allocation = null,
    // memory_location: MemoryLocation = .unknown,
    // size: u64 = 0,

    pub fn init(resource: *d3d12.IResource, read_state: d3d12.RESOURCE_STATES) Resource {
        return .{ .resource = resource, .read_state = read_state };
    }

    pub fn deinit(self: *Resource) void {
        _ = self; // autofix
        unreachable;
    }
};

const ShaderModule = struct {
    manager: Manager(ShaderModule) = .{},
    code: []const u8,

    fn create(_: *Device, code: []const u8) !*ShaderModule {
        const self = try allocator.create(ShaderModule);
        self.* = .{ .code = code };
        return self;
    }

    fn compile(module: *ShaderModule, entrypoint: [:0]const u8, target: [:0]const u8) !*d3d12.IBlob {
        const flags = if (debug) unreachable else 0;

        var shader_blob: *d3d12.IBlob = undefined;
        var error_blob: ?*d3d12.IBlob = null;
        const hr = d3d12.D3DCompile(module.code.ptr, module.code.len, null, null, null, entrypoint, target, flags, 0, @ptrCast(&shader_blob), @ptrCast(&error_blob));

        if (error_blob) |errors| {
            const message: [*:0]const u8 = @ptrCast(errors.getBufferPointer());
            std.debug.print("{s}\n", .{message});
            _ = errors.release();
        }

        if (hr != 0) {
            return error.CompileShaderFailed;
        }

        return shader_blob;
    }
};

const RenderPipeline = struct {
    manager: Manager(RenderPipeline) = .{},

    fn create(device: *Device, desc: sysgpu.RenderPipeline.Descriptor) !*RenderPipeline {
        const vertex_module: *ShaderModule = @alignCast(@ptrCast(desc.vertex.module));
        const fragment_module: *ShaderModule = @alignCast(@ptrCast(desc.fragment.?.module));

        const layout: *PipelineLayout = @alignCast(@ptrCast(desc.layout));
        layout.manager.reference();
        errdefer layout.manager.release();

        const vertex_shader = try vertex_module.compile(desc.vertex.entrypoint, "vs_5_1");
        defer _ = vertex_shader.release();

        const pixel_shader = try fragment_module.compile(desc.fragment.?.entrypoint, "ps_5_1");
        defer _ = pixel_shader.release();

        var pipeline: *d3d12.IPipelineState = undefined;
        const hr = device.device.createGraphicsPipelineState(
            &.{
                .pRootSignature = layout.root_signature,
                .VS = conv.shaderBytecode(vertex_shader),
                .PS = conv.shaderBytecode(pixel_shader),
                .DS = .{},
                .HS = .{},
                .GS = .{},
                .StreamOutput = conv.streamOutputDesc(),
                .BlendState = conv.blendDesc(desc),
                .SampleMask = desc.multisample.mask,
                // .RasterizerState = conv.d3d12RasterizerDesc(desc),
                // .DepthStencilState = conv.d3d12DepthStencilDesc(desc.depth_stencil),
                // .InputLayout = .{
                //     .pInputElementDescs = if (desc.vertex.buffer_count > 0) &input_elements.buffer else null,
                //     .NumElements = @intCast(input_elements.len),
                // },
                // .IBStripCutValue = conv.d3d12IndexBufferStripCutValue(desc.primitive.strip_index_format),
                // .PrimitiveTopologyType = conv.d3d12PrimitiveTopologyType(desc.primitive.topology),
                // .NumRenderTargets = @intCast(num_render_targets),
                // .RTVFormats = rtv_formats,
                .DSVFormat = if (desc.depth_stencil) |ds| conv.formatToTexture(ds.format) else .UNKNOWN,
                .SampleDesc = .{ .Count = desc.multisample.count, .Quality = 0 },
                .NodeMask = 0,
                .CachedPSO = .{ .pCachedBlob = null, .CachedBlobSizeInBytes = 0 },
                .Flags = .{},
            },
            &d3d12.IPipelineState.IID,
            @ptrCast(&pipeline),
        );
        _ = hr; // autofix

        unreachable;
    }
};

const max_bind_groups: u32 = 4;

const PipelineLayout = struct {
    manager: Manager(PipelineLayout) = .{},
    root_signature: *d3d12.IRootSignature,
    group_layouts: []*BindGroupLayout,
    group_parameter_indices: std.BoundedArray(u32, max_bind_groups),

    fn create(device: *Device, desc: sysgpu.PipelineLayout.Descriptor) !*PipelineLayout {
        const group_layouts = try allocator.alloc(*BindGroupLayout, desc.bind_group_layout_count);
        errdefer allocator.free(group_layouts);

        const group_parameter_indices = std.BoundedArray(u32, max_bind_groups){};

        const parameter_count: u32 = 0;
        const range_count: u32 = 0;
        for (0..desc.bind_group_layout_count) |_| {
            unreachable;
        }

        var parameters = try std.ArrayListUnmanaged(d3d12.ROOT_PARAMETER).initCapacity(allocator, parameter_count);
        defer parameters.deinit(allocator);

        var ranges = try std.ArrayListUnmanaged(d3d12.DESCRIPTOR_RANGE).initCapacity(allocator, range_count);
        defer ranges.deinit(allocator);

        for (0..desc.bind_group_layout_count) |_| {
            unreachable;
        }

        var root_signature_blob: *d3d12.IBlob = undefined;
        var opt_errors: ?*d3d12.IBlob = null;
        const hr = d3d12.D3D12SerializeRootSignature(
            &.{
                .NumParameters = @intCast(parameters.items.len),
                .pParameters = parameters.items.ptr,
                .NumStaticSamplers = 0,
                .pStaticSamplers = null,
                .Flags = .{ .ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT = true },
            },
            .VERSION_1_0,
            @ptrCast(&root_signature_blob),
            @ptrCast(&opt_errors),
        );
        if (opt_errors) |errors| {
            const message: [*:0]const u8 = @ptrCast(errors.getBufferPointer());
            std.debug.print("{s}\n", .{message});
            _ = errors.release();
        }
        if (hr != 0) {
            return error.SerializeRootSignatureFailed;
        }

        defer _ = root_signature_blob.release();

        // var root_signature: *c.ID3D12RootSignature = undefined;
        // hr = d3d_device.lpVtbl.*.CreateRootSignature.?(
        //     d3d_device,
        //     0,
        //     root_signature_blob.lpVtbl.*.GetBufferPointer.?(root_signature_blob),
        //     root_signature_blob.lpVtbl.*.GetBufferSize.?(root_signature_blob),
        //     &c.IID_ID3D12RootSignature,
        //     @ptrCast(&root_signature),
        // );
        // errdefer _ = root_signature.lpVtbl.*.Release.?(root_signature);
        var root_signature: *d3d12.IRootSignature = undefined;
        _ = device.device.createRootSignature(
            0,
            root_signature_blob.getBufferPointer(),
            root_signature_blob.getBufferSize(),
            &d3d12.IRootSignature.IID,
            @ptrCast(&root_signature),
        );
        errdefer _ = root_signature.release();

        const self = try allocator.create(PipelineLayout);
        self.* = .{
            .root_signature = root_signature,
            .group_layouts = group_layouts,
            .group_parameter_indices = group_parameter_indices,
        };

        return self;
    }

    pub fn deinit(self: *PipelineLayout) void {
        _ = self; // autofix
        // TODO
    }
};

const BindGroupLayout = struct {};
