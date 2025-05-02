const std = @import("std");
const sys = @import("../gpu.zig");
const w32 = @import("w32");
const dxgi = w32.dxgi;
const d3d12 = w32.d3d12;
const conv = @import("conv.zig");
const limits = @import("../limits.zig");
const gpu_allocator = @import("../allocator.zig");

const Manager = @import("../../util.zig").Manager;
const MemoryAllocator = @import("MemoryAllocator.zig");

const general_heap_size = 1024;
const general_block_size = 16;
const sampler_heap_size = 1024;
const sampler_block_size = 16;
const rtv_heap_size = 1024;
const rtv_block_size = 16;
const dsv_heap_size = 1024;
const dsv_block_size = 1;
const upload_page_size = 64 * 1024 * 1024; // TODO - split writes and/or support large uploads

const debug = false;
const allocator = @import("../../prism.zig").allocator;
var cookie: u32 = 0;

pub const Instance = struct {
    manager: Manager(Instance) = .{},
    factory: *dxgi.IFactory4,
    allow_tearing: bool,

    pub fn create(_: sys.Instance.Descriptor) !*Instance {
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
};

pub const Surface = struct {
    manager: Manager(Surface) = .{},
    hwnd: w32.HWND,

    pub fn create(_: *Instance, desc: sys.Surface.Descriptor) !*Surface {
        const self = try allocator.create(Surface);
        self.* = .{
            .hwnd = @ptrCast(desc.data.windows_hwnd.hwnd),
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
    adapter_type: sys.Adapter.Type,

    pub fn create(instance: *Instance, desired: sys.Adapter.Descriptor) !*Adapter {
        var desc: dxgi.ADAPTER_DESC1 = undefined;
        var last_desc: dxgi.ADAPTER_DESC1 = undefined;
        var last_adapter: ?*dxgi.IAdapter1 = null;
        var last_adapter_type: sys.Adapter.Type = .unknown;

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

            const adapter_type: sys.Adapter.Type = blk: {
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

    pub fn deinit(self: *Adapter) void {
        _ = self.adapter.release();
        _ = self.device.release();
        allocator.destroy(self);
    }

    pub fn getProperties(self: *Adapter) sys.Adapter.Properties {
        return .{
            .vendor_id = self.desc.VendorId,
            .vendor_name = "", // TODO
            .architecture = "", // TODO
            .device_id = self.desc.DeviceId,
            .name = &self.description,
            .driver_description = "", // TODO
            .adapter_type = self.adapter_type,
        };
    }
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
    streaming_manager: StreamingManager = undefined,
    reference_trackers: std.ArrayListUnmanaged(*ReferenceTracker) = .empty,
    mem_allocator: MemoryAllocator = undefined,

    pub fn create(adapter: *Adapter, _: sys.Device.Descriptor) !*Device {
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

        self.streaming_manager = try StreamingManager.create(self);
        errdefer self.streaming_manager.deinit();

        try self.mem_allocator.init(self);

        return self;
    }

    pub fn deinit(self: *Device) void {
        self.queue.waitUntil(self.queue.fence_value);
        self.processQueuedOperations();

        // self.map_callbacks.deinit(allocator);
        self.reference_trackers.deinit(allocator);
        self.streaming_manager.deinit();
        self.command_manager.deinit();
        self.dsv_heap.deinit();
        self.rtv_heap.deinit();
        self.sampler_heap.deinit();
        self.general_heap.deinit();
        self.queue.manager.release();

        self.mem_allocator.deinit();

        allocator.destroy(self.queue);
        allocator.destroy(self);
    }

    pub fn tick(device: *Device) !void {
        device.processQueuedOperations();
    }

    fn processQueuedOperations(self: *Device) void {
        // Reference trackers
        {
            const fence = self.queue.fence;
            const completed_value = fence.getCompletedValue();

            var i: usize = 0;
            while (i < self.reference_trackers.items.len) {
                const reference_tracker = self.reference_trackers.items[i];

                if (reference_tracker.fence_value <= completed_value) {
                    reference_tracker.deinit();
                    _ = self.reference_trackers.swapRemove(i);
                } else {
                    i += 1;
                }
            }
        }

        // TODO MapAsync
    }

    fn createBufferResource(self: *Device, usage: sys.Buffer.UsageFlags, size: u64) !Resource {
        const resource_size = conv.d3d12ResourceSizeForBuffer(size, usage);

        const heap_type = conv.d3d12HeapType(usage);
        const resource_desc = d3d12.RESOURCE_DESC{
            .Dimension = .BUFFER,
            .Alignment = 0,
            .Width = resource_size,
            .Height = 1,
            .DepthOrArraySize = 1,
            .MipLevels = 1,
            .Format = .UNKNOWN,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .Layout = .ROW_MAJOR,
            .Flags = conv.d3d12ResourceFlagsForBuffer(usage),
        };
        const read_state = conv.d3d12ResourceStatesForBufferRead(usage);
        const initial_state = conv.d3d12ResourceStatesInitial(heap_type, read_state);

        const create_desc = MemoryAllocator.ResourceCreateDescriptor{
            .location = if (usage.map_write)
                .gpu_to_cpu
            else if (usage.map_read)
                .cpu_to_gpu
            else
                .gpu_only,
            .resource_desc = &resource_desc,
            .clear_value = null,
            .resource_category = .buffer,
            .initial_state = initial_state,
        };

        return try self.mem_allocator.createResource(&create_desc);
    }

    fn logger(category: d3d12.MESSAGE_CATEGORY, severity: d3d12.MESSAGE_SEVERITY, id: d3d12.MESSAGE_ID, description: [*c]const u8, _: ?*anyopaque) callconv(.winapi) void {
        std.debug.print("{s} [{s}] {s} ({d})\n", .{
            @tagName(severity),
            @tagName(category),
            description,
            @intFromEnum(id),
        });
    }
};

pub const Queue = struct {
    manager: Manager(Queue) = .{},
    device: *Device,
    command_queue: *d3d12.ICommandQueue,
    fence: *d3d12.IFence,
    fence_value: u64 = 0,
    fence_event: w32.HANDLE,
    command_encoder: ?*CommandEncoder = null,

    pub fn create(device: *Device) !Queue {
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

    pub fn deinit(self: *Queue) void {
        self.waitUntil(self.fence_value);

        if (self.command_encoder) |command_encoder| command_encoder.manager.release();
        _ = self.command_queue.release();
        _ = self.fence.release();
        _ = w32.CloseHandle(self.fence_event);
    }

    pub fn writeBuffer(self: *Queue, buffer: *Buffer, offset: u64, data: [*]const u8, size: u64) !void {
        const encoder = try self.getCommandEncoder();
        try encoder.writeBuffer(buffer, offset, data, size);
    }

    pub fn submit(queue: *Queue, command_buffers: []const *CommandBuffer) !void {
        var command_lists = try std.ArrayListUnmanaged(*d3d12.IGraphicsCommandList).initCapacity(
            allocator,
            command_buffers.len + 1,
        );
        defer command_lists.deinit(allocator);

        queue.fence_value += 1;

        if (queue.command_encoder) |command_encoder| {
            const command_buffer = try command_encoder.finish(.{});
            command_buffer.manager.reference(); // handled in main.zig
            defer command_buffer.manager.release();

            command_lists.appendAssumeCapacity(command_buffer.command_list);
            try command_buffer.reference_tracker.submit(queue);

            command_encoder.manager.release();
            queue.command_encoder = null;
        }

        for (command_buffers) |command_buffer| {
            command_lists.appendAssumeCapacity(command_buffer.command_list);
            try command_buffer.reference_tracker.submit(queue);
        }

        queue.command_queue.executeCommandLists(@intCast(command_lists.items.len), @ptrCast(command_lists.items.ptr));

        for (command_lists.items) |command_list| {
            queue.device.command_manager.destroyCommandList(command_list);
        }

        try queue.signal();
    }

    fn signal(self: *Queue) !void {
        const hr = self.command_queue.signal(self.fence, self.fence_value);
        if (hr != 0) {
            return error.SignalFailed;
        }
    }

    fn waitUntil(self: *Queue, fence_value: u64) void {
        const fence = self.fence;
        const fence_event = self.fence_event;

        const completed_value = fence.getCompletedValue();
        if (completed_value >= fence_value)
            return;

        const hr = fence.setEventOnCompletion(fence_value, fence_event);
        std.debug.assert(hr == 0);

        const result = w32.WaitForSingleObject(fence_event, w32.INFINITE);
        std.debug.assert(result == w32.WAIT_OBJECT_0);
    }

    fn getCommandEncoder(queue: *Queue) !*CommandEncoder {
        if (queue.command_encoder) |command_encoder| return command_encoder;

        const command_encoder = try CommandEncoder.create(queue.device, .{});
        queue.command_encoder = command_encoder;
        return command_encoder;
    }
};

const back_buffer_count = 2;

// TODO I _really_ dont like how the code here is structured
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
    desc: sys.SwapChain.Descriptor,

    pub fn create(device: *Device, surface: *Surface, desc: sys.SwapChain.Descriptor) !*SwapChain {
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

        device.processQueuedOperations();

        var swapchain: *dxgi.ISwapChain3 = undefined;
        _ = instance.factory.createSwapChainForHwnd(@ptrCast(device.queue.command_queue), surface.hwnd, &swapchain_desc, null, null, @ptrCast(&swapchain));
        errdefer _ = swapchain.release();

        const textures, const views, const fence_values = try getBuffers(swapchain, device, desc);

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
            .desc = desc,
        };

        return self;
    }

    pub fn deinit(self: *SwapChain) void {
        self.freeResources();
        _ = self.swapchain.release();
        allocator.destroy(self);
    }

    pub fn getCurrentTextureView(self: *SwapChain) !*TextureView {
        const fence_value = self.fence_values[self.buffer_index];
        self.queue.waitUntil(fence_value);

        const index = self.swapchain.getCurrentBackBufferIndex();
        self.buffer_index = index;
        self.views[index].manager.reference();
        return self.views[index];
    }

    pub fn present(self: *SwapChain) !void {
        const hr = self.swapchain.present(self.sync_interval, self.present_flags);
        if (hr != 0) {
            return error.PresentFailed;
        }

        self.queue.fence_value += 1;
        try self.queue.signal();
        self.fence_values[self.buffer_index] = self.queue.fence_value;
    }

    pub fn resize(self: *SwapChain, width: u32, height: u32) !void {
        self.freeResources();

        _ = self.swapchain.resizeBuffers(back_buffer_count, width, height, .UNKNOWN, .{});

        self.desc.width = width;
        self.desc.height = height;
        self.textures, self.views, self.fence_values = try getBuffers(self.swapchain, self.device, self.desc);
    }

    fn freeResources(self: *SwapChain) void {
        self.queue.waitUntil(self.queue.fence_value);

        for (self.views[0..self.back_buffer_count]) |view| view.manager.release();
        for (self.textures[0..self.back_buffer_count]) |texture| texture.manager.release();

        self.device.processQueuedOperations();
    }

    fn getBuffers(swapchain: *dxgi.ISwapChain3, device: *Device, desc: sys.SwapChain.Descriptor) !struct { [back_buffer_count]*Texture, [back_buffer_count]*TextureView, [back_buffer_count]u64 } {
        var textures: [back_buffer_count]*Texture = undefined;
        var views: [back_buffer_count]*TextureView = undefined;
        var fence_values: [back_buffer_count]u64 = undefined;

        for (0..back_buffer_count) |i| {
            var buffer: *d3d12.IResource = undefined;
            _ = swapchain.getBuffer(@intCast(i), &d3d12.IResource.IID, @ptrCast(&buffer));

            const texture = try Texture.createForSwapchain(device, desc, buffer);
            const view = try TextureView.create(texture, .{});

            textures[i] = texture;
            views[i] = view;
            fence_values[i] = 0;
        }

        return .{ textures, views, fence_values };
    }
};

pub const Texture = struct {
    manager: Manager(Texture) = .{},
    device: *Device,
    resource: Resource,
    // TODO - packed texture descriptor struct
    usage: sys.Texture.UsageFlags,
    dimension: sys.Texture.Dimension,
    size: sys.types.Extent3D,
    format: sys.Texture.Format,
    mip_level_count: u32,
    sample_count: u32,

    pub fn create(device: *Device, desc: sys.Texture.Descriptor) !*Texture {
        const resource_desc = d3d12.RESOURCE_DESC{
            .Dimension = conv.d3d12ResourceDimension(desc.dimension),
            .Alignment = 0,
            .Width = desc.size.width,
            .Height = desc.size.height,
            .DepthOrArraySize = @intCast(desc.size.depth_or_array_layers),
            .MipLevels = @intCast(desc.mip_level_count),
            .Format = conv.dxgiFormatForTextureResource(desc.format, desc.usage, desc.view_formats.len),
            .SampleDesc = .{ .Count = desc.sample_count, .Quality = 0 },
            .Layout = .UNKNOWN,
            .Flags = conv.d3d12ResourceFlagsForTexture(desc.usage, desc.format),
        };
        const read_state = conv.d3d12ResourceStatesForTextureRead(desc.usage);
        const initial_state = read_state;

        const clear_value = std.mem.zeroInit(d3d12.CLEAR_VALUE, .{ .Format = resource_desc.Format });

        // TODO: the code below was terribly broken, I rewrote it, Is it correct?
        // const create_desc = ResourceCreateDescriptor{
        //     .location = .gpu_only,
        //     .resource_desc = if (utils.formatHasDepthOrStencil(desc.format) or desc.usage.render_attachment)
        //         &clear_value
        //     else
        //         null,
        //     .clear_value = null,
        //     .resource_category = .buffer,
        //     .initial_state = initial_state,
        // };
        const create_desc = MemoryAllocator.ResourceCreateDescriptor{
            .location = .gpu_only,
            .resource_desc = &resource_desc,
            .clear_value = if (conv.formatHasDepthOrStencil(desc.format) or desc.usage.render_attachment)
                &clear_value
            else
                null,
            // TODO check if different textures need different resource categories.
            .resource_category = .other_texture,
            .initial_state = initial_state,
        };
        const resource = device.mem_allocator.createResource(&create_desc) catch return error.CreateTextureFailed;

        setDebugName(@ptrCast(resource.resource), desc.label);

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
        };

        return self;
    }

    pub fn deinit(self: *Texture) void {
        self.resource.deinit();
        allocator.destroy(self);
    }

    pub fn createForSwapchain(device: *Device, desc: sys.SwapChain.Descriptor, resource: *d3d12.IResource) !*Texture {
        const texture = try allocator.create(Texture);
        texture.* = .{
            .device = device,
            .resource = Resource.create(resource, .PRESENT),
            .usage = desc.usage,
            .dimension = .@"2d",
            .size = .{ .width = desc.width, .height = desc.height, .depth_or_array_layers = 1 },
            .format = desc.format,
            .mip_level_count = 1,
            .sample_count = 1,
        };

        return texture;
    }

    fn calcSubresource(texture: *Texture, mip_level: u32, array_slice: u32) u32 {
        return mip_level + (array_slice * texture.mip_level_count);
    }
};

pub const TextureView = struct {
    manager: Manager(TextureView) = .{},
    texture: *Texture,
    format: sys.Texture.Format,
    dimension: sys.TextureView.Dimension,
    base_mip_level: u32,
    mip_level_count: u32,
    base_array_layer: u32,
    array_layer_count: u32,
    aspect: sys.Texture.Aspect,
    base_subresource: u32,

    pub fn create(texture: *Texture, desc: sys.TextureView.Descriptor) !*TextureView {
        texture.manager.reference();

        const texture_dimension: sys.TextureView.Dimension = switch (texture.dimension) {
            .@"1d" => .@"1d",
            .@"2d" => .@"2d",
            .@"3d" => .@"3d",
        };

        const view = try allocator.create(TextureView);
        view.* = .{
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

        return view;
    }

    pub fn deinit(self: *TextureView) void {
        self.texture.manager.release();
        allocator.destroy(self);
    }

    fn width(self: *TextureView) u32 {
        return @max(1, self.texture.size.width >> @intCast(self.base_mip_level));
    }

    fn height(self: *TextureView) u32 {
        return @max(1, self.texture.size.height >> @intCast(self.base_mip_level));
    }

    fn srvDesc(view: *TextureView) d3d12.SHADER_RESOURCE_VIEW_DESC {
        var desc = d3d12.SHADER_RESOURCE_VIEW_DESC{
            .Format = conv.dxgiFormatForTextureView(view.format, view.aspect),
            .ViewDimension = conv.d3d12SrvDimension(view.dimension, view.texture.sample_count),
            .Shader4ComponentMapping = d3d12.DEFAULT_SHADER_4_COMPONENT_MAPPING,
            .u = undefined,
        };

        desc.u = switch (desc.ViewDimension) {
            .UNKNOWN => unreachable,
            .BUFFER => .{ .Buffer = unreachable },
            .TEXTURE1D => .{
                .Texture1D = .{
                    .MostDetailedMip = view.base_mip_level,
                    .MipLevels = view.mip_level_count,
                    .ResourceMinLODClamp = 0.0,
                },
            },
            .TEXTURE1DARRAY => .{ .Texture1DArray = unreachable },
            .TEXTURE2D => .{
                .Texture2D = .{
                    .MostDetailedMip = view.base_mip_level,
                    .MipLevels = view.mip_level_count,
                    .PlaneSlice = 0, // TODO
                    .ResourceMinLODClamp = 0.0,
                },
            },
            .TEXTURE2DARRAY => .{
                .Texture2DArray = .{
                    .MostDetailedMip = view.base_mip_level,
                    .MipLevels = view.mip_level_count,
                    .FirstArraySlice = view.base_array_layer,
                    .ArraySize = view.array_layer_count,
                    .PlaneSlice = 0,
                    .ResourceMinLODClamp = 0.0,
                },
            },
            .TEXTURE2DMS => .{ .Texture2DMS = unreachable },
            .TEXTURE2DMSARRAY => .{
                .Texture2DMSArray = .{
                    .FirstArraySlice = view.base_array_layer,
                    .ArraySize = view.array_layer_count,
                },
            },
            .TEXTURE3D => .{
                .Texture3D = .{
                    .MostDetailedMip = view.base_mip_level,
                    .MipLevels = view.mip_level_count,
                    .ResourceMinLODClamp = 0.0,
                },
            },
            .TEXTURECUBE => .{
                .TextureCube = .{
                    .MostDetailedMip = view.base_mip_level,
                    .MipLevels = view.mip_level_count,
                    .ResourceMinLODClamp = 0.0,
                },
            },
            .TEXTURECUBEARRAY => .{
                .TextureCubeArray = .{
                    .MostDetailedMip = view.base_mip_level,
                    .MipLevels = view.mip_level_count,
                    .First2DArrayFace = view.base_array_layer, // TODO - does this need a conversion?
                    .NumCubes = view.array_layer_count, // TODO - does this need a conversion?
                    .ResourceMinLODClamp = 0.0,
                },
            },
        };

        return desc;
    }
};

pub const ShaderModule = struct {
    manager: Manager(ShaderModule) = .{},
    data: union(enum) {
        air: *sys.shader.Air,
        code: [:0]const u8,
    },

    pub fn create(_: *Device, air: *sys.shader.Air, _: [:0]const u8) !*ShaderModule {
        const self = try allocator.create(ShaderModule);
        self.* = .{ .data = .{ .air = air } };
        return self;
    }

    pub fn createCode(_: *Device, code: [:0]const u8, _: [:0]const u8) !*ShaderModule {
        const self = try allocator.create(ShaderModule);
        self.* = .{ .data = .{ .code = code } };
        return self;
    }

    pub fn deinit(self: *ShaderModule) void {
        if (self.data == .air) {
            self.data.air.deinit(allocator);
            allocator.destroy(self.data.air);
        }
        allocator.destroy(self);
    }

    fn compile(self: *ShaderModule, entrypoint: [:0]const u8, target: [:0]const u8) !*d3d12.IBlob {
        const code: []const u8 = switch (self.data) {
            .air => |air| try sys.shader.CodeGen.generate(allocator, air, .hlsl, false, .{ .emit_source_file = "" }, null, null, null),
            .code => |code| code,
        };

        defer if (self.data == .air) allocator.free(code);

        // std.debug.print("{s}\n\n", .{code});

        const flags: u32 = 0;
        // if (debug)
        //     flags |= c.D3DCOMPILE_DEBUG | c.D3DCOMPILE_SKIP_OPTIMIZATION;

        var shader_blob: *d3d12.IBlob = undefined;
        var opt_errors: ?*d3d12.IBlob = null;
        const hr = d3d12.D3DCompile(
            code.ptr,
            code.len,
            null,
            null,
            null,
            entrypoint,
            target,
            flags,
            0,
            @ptrCast(&shader_blob),
            @ptrCast(&opt_errors),
        );
        if (opt_errors) |errors| {
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

pub const RenderPipeline = struct {
    manager: Manager(RenderPipeline) = .{},
    device: *Device,
    pipeline: *d3d12.IPipelineState,
    layout: *PipelineLayout,
    topology: d3d12.PRIMITIVE_TOPOLOGY,
    vertex_strides: std.BoundedArray(u32, limits.max_vertex_buffers),

    pub fn create(device: *Device, desc: sys.RenderPipeline.Descriptor) !*RenderPipeline {
        const vertex_module: *ShaderModule = @alignCast(@ptrCast(desc.vertex.module));

        var layout: *PipelineLayout = undefined;
        if (desc.layout) |raw| {
            layout = @alignCast(@ptrCast(raw));
            layout.manager.reference();
        } else if (vertex_module.data == .air) {
            var layout_desc = DefaultPipelineLayoutDescriptor{};
            defer layout_desc.deinit();

            try layout_desc.addFunction(vertex_module.data.air, .{ .vertex = true }, desc.vertex.entrypoint);
            if (desc.fragment) |frag| {
                const frag_module: *ShaderModule = @alignCast(@ptrCast(frag.module));
                try layout_desc.addFunction(frag_module.data.air, .{ .fragment = true }, frag.entrypoint);
            }

            layout = try PipelineLayout.createDefault(device, layout_desc);
        } else {
            return error.MissingPipelineLayout;
        }

        errdefer layout.manager.release();

        // Shaders
        const vertex_shader = try vertex_module.compile(desc.vertex.entrypoint, "vs_5_1");
        defer _ = vertex_shader.release();

        var opt_pixel_shader: ?*d3d12.IBlob = null;
        if (desc.fragment) |frag| {
            const frag_module: *ShaderModule = @alignCast(@ptrCast(frag.module));
            opt_pixel_shader = try frag_module.compile(frag.entrypoint, "ps_5_1");
        }
        defer if (opt_pixel_shader) |pixel_shader| {
            _ = pixel_shader.release();
        };

        // PSO
        var input_elements = std.BoundedArray(d3d12.INPUT_ELEMENT_DESC, limits.max_vertex_buffers){};
        var vertex_strides = std.BoundedArray(u32, limits.max_vertex_buffers){};
        for (0..desc.vertex.buffers.len) |i| {
            const buffer = desc.vertex.buffers[i];
            for (0..buffer.attributes.len) |j| {
                const attr = buffer.attributes[j];
                input_elements.appendAssumeCapacity(conv.d3d12InputElementDesc(i, buffer, attr));
            }
            vertex_strides.appendAssumeCapacity(@intCast(buffer.array_stride));
        }

        var num_render_targets: usize = 0;
        var rtv_formats = [_]dxgi.FORMAT{.UNKNOWN} ** limits.max_color_attachments;
        if (desc.fragment) |frag| {
            num_render_targets = frag.targets.len;
            for (0..frag.targets.len) |i| {
                const target = frag.targets[i];
                rtv_formats[i] = conv.dxgiFormatForTexture(target.format);
            }
        }

        var pipeline: *d3d12.IPipelineState = undefined;
        const hr = device.device.createGraphicsPipelineState(
            &d3d12.GRAPHICS_PIPELINE_STATE_DESC{
                .pRootSignature = layout.root_signature,
                .VS = conv.d3d12ShaderBytecode(vertex_shader),
                .PS = conv.d3d12ShaderBytecode(opt_pixel_shader),
                .DS = conv.d3d12ShaderBytecode(null),
                .HS = conv.d3d12ShaderBytecode(null),
                .GS = conv.d3d12ShaderBytecode(null),
                .StreamOutput = conv.d3d12StreamOutputDesc(),
                .BlendState = conv.d3d12BlendDesc(desc),
                .SampleMask = desc.multisample.mask,
                .RasterizerState = conv.d3d12RasterizerDesc(desc),
                .DepthStencilState = conv.d3d12DepthStencilDesc(desc.depth_stencil),
                .InputLayout = .{
                    .pInputElementDescs = if (desc.vertex.buffers.len > 0) &input_elements.buffer else null,
                    .NumElements = @intCast(input_elements.len),
                },
                .IBStripCutValue = conv.d3d12IndexBufferStripCutValue(desc.primitive.strip_index_format),
                .PrimitiveTopologyType = conv.d3d12PrimitiveTopologyType(desc.primitive.topology),
                .NumRenderTargets = @intCast(num_render_targets),
                .RTVFormats = rtv_formats,
                .DSVFormat = if (desc.depth_stencil) |ds| conv.dxgiFormatForTexture(ds.format) else .UNKNOWN,
                .SampleDesc = .{ .Count = desc.multisample.count, .Quality = 0 },
                .NodeMask = 0,
                .CachedPSO = .{ .pCachedBlob = null, .CachedBlobSizeInBytes = 0 },
                .Flags = .{},
            },
            &d3d12.IPipelineState.IID,
            @ptrCast(&pipeline),
        );
        if (hr != 0) {
            return error.CreateRenderPipelineFailed;
        }
        errdefer _ = pipeline.release();

        setDebugName(@ptrCast(pipeline), desc.label);

        // Result
        const self = try allocator.create(RenderPipeline);
        self.* = .{
            .pipeline = pipeline,
            .device = device,
            .layout = layout,
            .topology = conv.d3d12PrimitiveTopology(desc.primitive.topology),
            .vertex_strides = vertex_strides,
        };

        return self;
    }

    pub fn deinit(self: *RenderPipeline) void {
        self.layout.manager.release();
        _ = self.pipeline.release();
        allocator.destroy(self);
    }

    pub fn getBindGroupLayout(self: *RenderPipeline, group_index: u32) *BindGroupLayout {
        return self.layout.group_layouts[group_index];
    }
};

pub const PipelineLayout = struct {
    manager: Manager(PipelineLayout) = .{},
    root_signature: *d3d12.IRootSignature,
    group_layouts: []*BindGroupLayout,
    group_parameter_indices: std.BoundedArray(u32, limits.max_bind_groups),

    pub fn create(device: *Device, desc: sys.PipelineLayout.Descriptor) !*PipelineLayout {

        // Per Bind Group:
        // - up to 1 descriptor table for CBV/SRV/UAV
        // - up to 1 descriptor table for Sampler
        // - 1 root descriptor per dynamic resource
        // Root signature 1.1 hints not supported yet

        var group_layouts = try allocator.alloc(*BindGroupLayout, desc.bind_group_layouts.len);
        errdefer allocator.free(group_layouts);

        var group_parameter_indices = std.BoundedArray(u32, limits.max_bind_groups){};

        var parameter_count: u32 = 0;
        var range_count: u32 = 0;
        for (0..desc.bind_group_layouts.len) |i| {
            const layout: *BindGroupLayout = @alignCast(@ptrCast(desc.bind_group_layouts[i]));
            layout.manager.reference();
            group_layouts[i] = layout;
            group_parameter_indices.appendAssumeCapacity(parameter_count);

            var general_entry_count: u32 = 0;
            var sampler_entry_count: u32 = 0;
            for (layout.entries.items) |entry| {
                if (entry.dynamic_index) |_| {
                    parameter_count += 1;
                } else if (entry.sampler.type != .undefined) {
                    sampler_entry_count += 1;
                    range_count += 1;
                } else {
                    general_entry_count += 1;
                    range_count += 1;
                }
            }

            if (general_entry_count > 0)
                parameter_count += 1;
            if (sampler_entry_count > 0)
                parameter_count += 1;
        }

        var parameters = try std.ArrayListUnmanaged(d3d12.ROOT_PARAMETER).initCapacity(allocator, parameter_count);
        defer parameters.deinit(allocator);

        var ranges = try std.ArrayListUnmanaged(d3d12.DESCRIPTOR_RANGE).initCapacity(allocator, range_count);
        defer ranges.deinit(allocator);

        for (0..desc.bind_group_layouts.len) |group_index| {
            const layout: *BindGroupLayout = group_layouts[group_index];

            // General Table
            {
                const entry_range_base = ranges.items.len;
                for (layout.entries.items) |entry| {
                    if (entry.dynamic_index == null and entry.sampler.type == .undefined) {
                        ranges.appendAssumeCapacity(.{
                            .RangeType = entry.range_type,
                            .NumDescriptors = 1,
                            .BaseShaderRegister = entry.binding,
                            .RegisterSpace = @intCast(group_index),
                            .OffsetInDescriptorsFromTableStart = d3d12.DESCRIPTOR_RANGE_OFFSET_APPEND,
                        });
                    }
                }
                const entry_range_count = ranges.items.len - entry_range_base;
                if (entry_range_count > 0) {
                    parameters.appendAssumeCapacity(.{
                        .ParameterType = .DESCRIPTOR_TABLE,
                        .u = .{
                            .DescriptorTable = .{
                                .NumDescriptorRanges = @intCast(entry_range_count),
                                .pDescriptorRanges = ranges.items[entry_range_base..].ptr,
                            },
                        },
                        .ShaderVisibility = .ALL,
                    });
                }
            }

            // Sampler Table
            {
                const entry_range_base = ranges.items.len;
                for (layout.entries.items) |entry| {
                    if (entry.dynamic_index == null and entry.sampler.type != .undefined) {
                        ranges.appendAssumeCapacity(.{
                            .RangeType = entry.range_type,
                            .NumDescriptors = 1,
                            .BaseShaderRegister = entry.binding,
                            .RegisterSpace = @intCast(group_index),
                            .OffsetInDescriptorsFromTableStart = d3d12.DESCRIPTOR_RANGE_OFFSET_APPEND,
                        });
                    }
                }
                const entry_range_count = ranges.items.len - entry_range_base;
                if (entry_range_count > 0) {
                    parameters.appendAssumeCapacity(.{
                        .ParameterType = .DESCRIPTOR_TABLE,
                        .u = .{
                            .DescriptorTable = .{
                                .NumDescriptorRanges = @intCast(entry_range_count),
                                .pDescriptorRanges = ranges.items[entry_range_base..].ptr,
                            },
                        },
                        .ShaderVisibility = .ALL,
                    });
                }
            }

            // Dynamic Resources
            for (layout.entries.items) |entry| {
                if (entry.dynamic_index) |dynamic_index| {
                    const layout_dynamic_entry = layout.dynamic_entries.items[dynamic_index];
                    parameters.appendAssumeCapacity(.{
                        .ParameterType = layout_dynamic_entry.parameter_type,
                        .u = .{
                            .Descriptor = .{
                                .ShaderRegister = entry.binding,
                                .RegisterSpace = @intCast(group_index),
                            },
                        },
                        .ShaderVisibility = .ALL,
                    });
                }
            }
        }

        var root_signature_blob: *d3d12.IBlob = undefined;
        var opt_errors: ?*d3d12.IBlob = null;
        var hr = d3d12.D3D12SerializeRootSignature(
            &.{
                .NumParameters = @intCast(parameters.items.len),
                .pParameters = parameters.items.ptr,
                .NumStaticSamplers = 0,
                .pStaticSamplers = null,
                .Flags = .{ .ALLOW_INPUT_ASSEMBLER_INPUT_LAYOUT = true }, // TODO - would like a flag for this
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

        var root_signature: *d3d12.IRootSignature = undefined;
        hr = device.device.createRootSignature(
            0,
            root_signature_blob.getBufferPointer(),
            root_signature_blob.getBufferSize(),
            &d3d12.IRootSignature.IID,
            @ptrCast(&root_signature),
        );
        errdefer _ = root_signature.release();

        // Result
        const self = try allocator.create(PipelineLayout);
        self.* = .{
            .root_signature = root_signature,
            .group_layouts = group_layouts,
            .group_parameter_indices = group_parameter_indices,
        };

        return self;
    }

    pub fn createDefault(device: *Device, default: DefaultPipelineLayoutDescriptor) !*PipelineLayout {
        const groups = default.groups;
        var bind_group_layouts = std.BoundedArray(*sys.BindGroupLayout, limits.max_bind_groups){};
        defer {
            for (bind_group_layouts.slice()) |bind_group_layout| bind_group_layout.release();
        }

        for (groups.slice()) |entries| {
            const bind_group_layout = try BindGroupLayout.create(device, .{ .entries = entries.items });
            bind_group_layouts.appendAssumeCapacity(@ptrCast(bind_group_layout));
        }

        return PipelineLayout.create(device, .{ .bind_group_layouts = bind_group_layouts.slice() });
    }

    pub fn deinit(self: *PipelineLayout) void {
        for (self.group_layouts) |group_layout| group_layout.manager.release();

        _ = self.root_signature.release();
        allocator.free(self.group_layouts);
        allocator.destroy(self);
    }
};

pub const BindGroupLayout = struct {
    const Entry = struct {
        binding: u32,
        visibility: sys.types.ShaderStageFlags,
        buffer: sys.Buffer.BindingLayout = .{},
        sampler: sys.Sampler.BindingLayout = .{},
        texture: sys.Texture.BindingLayout = .{},
        storage_texture: sys.types.StorageTextureBindingLayout = .{},
        range_type: d3d12.DESCRIPTOR_RANGE_TYPE,
        table_index: ?u32,
        dynamic_index: ?u32,
    };

    const DynamicEntry = struct {
        parameter_type: d3d12.ROOT_PARAMETER_TYPE,
    };

    manager: Manager(BindGroupLayout) = .{},
    entries: std.ArrayListUnmanaged(Entry),
    dynamic_entries: std.ArrayListUnmanaged(DynamicEntry),
    general_table_size: u32,
    sampler_table_size: u32,

    pub fn create(_: *Device, desc: sys.BindGroupLayout.Descriptor) !*BindGroupLayout {
        var entries = std.ArrayListUnmanaged(Entry){};
        errdefer entries.deinit(allocator);

        var dynamic_entries = std.ArrayListUnmanaged(DynamicEntry){};
        errdefer dynamic_entries.deinit(allocator);

        var general_table_size: u32 = 0;
        var sampler_table_size: u32 = 0;
        for (desc.entries) |entry| {
            var table_index: ?u32 = null;
            var dynamic_index: ?u32 = null;
            if (entry.buffer.has_dynamic_offset == true) {
                dynamic_index = @intCast(dynamic_entries.items.len);
                try dynamic_entries.append(allocator, .{
                    .parameter_type = conv.d3d12RootParameterType(entry),
                });
            } else if (entry.sampler.type != .undefined) {
                table_index = sampler_table_size;
                sampler_table_size += 1;
            } else {
                table_index = general_table_size;
                general_table_size += 1;
            }

            try entries.append(allocator, .{
                .binding = entry.binding,
                .visibility = entry.visibility,
                .buffer = entry.buffer,
                .sampler = entry.sampler,
                .texture = entry.texture,
                .storage_texture = entry.storage_texture,
                .range_type = conv.d3d12DescriptorRangeType(entry),
                .table_index = table_index,
                .dynamic_index = dynamic_index,
            });
        }

        const self = try allocator.create(BindGroupLayout);
        self.* = .{
            .entries = entries,
            .dynamic_entries = dynamic_entries,
            .general_table_size = general_table_size,
            .sampler_table_size = sampler_table_size,
        };

        return self;
    }

    pub fn deinit(self: *BindGroupLayout) void {
        self.entries.deinit(allocator);
        self.dynamic_entries.deinit(allocator);
        allocator.destroy(self);
    }

    fn getEntry(layout: *BindGroupLayout, binding: u32) ?*const Entry {
        for (layout.entries.items) |*entry| {
            if (entry.binding == binding)
                return entry;
        }

        return null;
    }
};

pub const CommandEncoder = struct {
    manager: Manager(CommandEncoder) = .{},
    device: *Device,
    command_buffer: *CommandBuffer,
    reference_tracker: *ReferenceTracker,
    state_tracker: StateTracker,

    pub fn create(device: *Device, _: sys.CommandEncoder.Descriptor) !*CommandEncoder {
        const command_buffer = try CommandBuffer.create(device);

        const self = try allocator.create(CommandEncoder);
        self.* = .{
            .device = device,
            .command_buffer = command_buffer,
            .reference_tracker = command_buffer.reference_tracker,
            .state_tracker = StateTracker.create(device),
        };

        return self;
    }

    pub fn deinit(self: *CommandEncoder) void {
        self.state_tracker.deinit();
        self.command_buffer.manager.release();
        allocator.destroy(self);
    }

    pub fn copyBufferToBuffer(self: *CommandEncoder, source: *Buffer, source_offset: u64, destination: *Buffer, destination_offset: u64, size: u64) !void {
        try self.reference_tracker.referenceBuffer(source);
        try self.reference_tracker.referenceBuffer(destination);
        try self.state_tracker.transition(&source.resource, source.resource.state);
        try self.state_tracker.transition(&destination.resource, .{ .COPY_DEST = true });
        self.state_tracker.flush(self.command_buffer.command_list);

        self.command_buffer.command_list.copyBufferRegion(
            destination.resource.resource,
            destination_offset,
            source.resource.resource,
            source_offset,
            size,
        );
    }

    pub fn copyTextureToTexture(encoder: *CommandEncoder, source: *const sys.types.ImageCopyTexture, destination: *const sys.types.ImageCopyTexture, copy_size_raw: *const sys.types.Extent3D) !void {
        const command_list = encoder.command_buffer.command_list;
        const source_texture: *Texture = @alignCast(@ptrCast(source.texture));
        const destination_texture: *Texture = @alignCast(@ptrCast(destination.texture));

        try encoder.reference_tracker.referenceTexture(source_texture);
        try encoder.reference_tracker.referenceTexture(destination_texture);
        try encoder.state_tracker.transition(&source_texture.resource, source_texture.resource.state);
        try encoder.state_tracker.transition(&destination_texture.resource, .{ .COPY_DEST = true });
        encoder.state_tracker.flush(command_list);

        const copy_size = calcExtent(destination_texture.dimension, copy_size_raw.*);
        const source_origin = calcOrigin(source_texture.dimension, source.origin);
        const destination_origin = calcOrigin(destination_texture.dimension, destination.origin);

        const source_subresource_index = source_texture.calcSubresource(source.mip_level, source_origin.array_slice);
        const destination_subresource_index = destination_texture.calcSubresource(destination.mip_level, destination_origin.array_slice);

        std.debug.assert(copy_size.array_count == 1); // TODO

        command_list.copyTextureRegion(
            &.{
                .pResource = destination_texture.resource.resource,
                .Type = .SUBRESOURCE_INDEX,
                .u = .{
                    .SubresourceIndex = destination_subresource_index,
                },
            },
            destination_origin.x,
            destination_origin.y,
            destination_origin.z,
            &.{
                .pResource = source_texture.resource.resource,
                .Type = .SUBRESOURCE_INDEX,
                .u = .{
                    .SubresourceIndex = source_subresource_index,
                },
            },
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

    pub fn writeBuffer(self: *CommandEncoder, buffer: *Buffer, offset: u64, data: [*]const u8, size: u64) !void {
        const stream = try self.command_buffer.upload(size);
        @memcpy(stream.map[0..size], data[0..size]);

        try self.reference_tracker.referenceBuffer(buffer);
        try self.state_tracker.transition(&buffer.resource, .{ .COPY_DEST = true });
        self.state_tracker.flush(self.command_buffer.command_list);

        self.command_buffer.command_list.copyBufferRegion(
            buffer.resource.resource,
            offset,
            stream.resource,
            stream.offset,
            size,
        );
    }

    pub fn beginRenderPass(self: *CommandEncoder, desc: sys.types.RenderPassDescriptor) !*RenderPassEncoder {
        try self.state_tracker.endPass();
        return try RenderPassEncoder.create(self, desc);
    }

    pub fn finish(self: *CommandEncoder, desc: sys.CommandBuffer.Descriptor) !*CommandBuffer {
        try self.state_tracker.endPass();
        self.state_tracker.flush(self.command_buffer.command_list);

        const hr = self.command_buffer.command_list.close();
        if (hr != 0) {
            return error.CommandListCloseFailed;
        }

        setDebugName(@ptrCast(self.command_buffer.command_list), desc.label);

        return self.command_buffer;
    }
};

pub const CommandBuffer = struct {
    pub const StreamingResult = struct {
        resource: *d3d12.IResource,
        map: [*]u8,
        offset: u32,
    };

    manager: Manager(CommandBuffer) = .{},
    device: *Device,
    command_allocator: *d3d12.ICommandAllocator,
    command_list: *d3d12.IGraphicsCommandList,
    reference_tracker: *ReferenceTracker,
    rtv_allocation: DescriptorAllocation = .{ .index = 0 },
    rtv_next_index: u32 = rtv_block_size,
    upload_buffer: ?*d3d12.IResource = null,
    upload_map: ?[*]u8 = null,
    upload_next_offset: u32 = upload_page_size,

    pub fn create(device: *Device) !*CommandBuffer {
        const command_allocator = try device.command_manager.createCommandAllocator();
        errdefer device.command_manager.destroyCommandAllocator(command_allocator);

        const command_list = try device.command_manager.createCommandList(command_allocator);
        errdefer device.command_manager.destroyCommandList(command_list);

        const heaps = [2]*d3d12.IDescriptorHeap{ device.general_heap.heap, device.sampler_heap.heap };
        command_list.setDescriptorHeaps(2, &heaps);

        const reference_tracker = try ReferenceTracker.create(device, command_allocator);
        errdefer reference_tracker.deinit();

        const self = try allocator.create(CommandBuffer);
        self.* = .{
            .device = device,
            .command_allocator = command_allocator,
            .command_list = command_list,
            .reference_tracker = reference_tracker,
        };

        return self;
    }

    pub fn deinit(self: *CommandBuffer) void {
        // reference_tracker lifetime is managed externally
        // command_allocator lifetime is managed externally
        // command_list lifetime is managed externally
        allocator.destroy(self);
    }

    fn upload(command_buffer: *CommandBuffer, size: u64) !StreamingResult {
        if (command_buffer.upload_next_offset + size > upload_page_size) {
            std.debug.assert(size <= upload_page_size); // TODO - support large uploads
            const resource = try command_buffer.device.streaming_manager.acquire();
            const d3d_resource = resource.resource;

            try command_buffer.reference_tracker.referenceUploadPage(resource);
            command_buffer.upload_buffer = d3d_resource;

            var map: ?*anyopaque = null;
            const hr = d3d_resource.map(0, null, &map);
            if (hr != 0) {
                return error.MapForUploadFailed;
            }

            command_buffer.upload_map = @ptrCast(map);
            command_buffer.upload_next_offset = 0;
        }

        const offset = command_buffer.upload_next_offset;
        command_buffer.upload_next_offset = @intCast(conv.alignUp(offset + size, limits.min_uniform_buffer_offset_alignment));

        return StreamingResult{
            .resource = command_buffer.upload_buffer.?,
            .map = command_buffer.upload_map.? + offset,
            .offset = offset,
        };
    }

    fn allocateRtvDescriptors(self: *CommandBuffer, count: usize) !d3d12.CPU_DESCRIPTOR_HANDLE {
        if (count == 0) return .{ .ptr = 0 };

        var rtv_heap = &self.device.rtv_heap;

        if (self.rtv_next_index + count > rtv_block_size) {
            self.rtv_allocation = try rtv_heap.alloc();

            try self.reference_tracker.referenceRtvDescriptorBlock(self.rtv_allocation);
            self.rtv_next_index = 0;
        }

        const index = self.rtv_next_index;
        self.rtv_next_index = @intCast(index + count);
        return rtv_heap.cpuDescriptor(self.rtv_allocation.index + index);
    }

    fn allocateDsvDescriptor(self: *CommandBuffer) !d3d12.CPU_DESCRIPTOR_HANDLE {
        var dsv_heap = &self.device.dsv_heap;

        const allocation = try dsv_heap.alloc();
        try self.reference_tracker.referenceDsvDescriptorBlock(allocation);

        return dsv_heap.cpuDescriptor(allocation.index);
    }
};

pub const RenderPassEncoder = struct {
    manager: Manager(RenderPassEncoder) = .{},
    command_list: *d3d12.IGraphicsCommandList,
    reference_tracker: *ReferenceTracker,
    state_tracker: *StateTracker,
    color_attachments: std.BoundedArray(sys.types.RenderPassColorAttachment, limits.max_color_attachments) = .{},
    depth_attachment: ?sys.types.RenderPassDepthStencilAttachment,
    group_parameter_indices: []u32 = undefined,
    vertex_apply_count: u32 = 0,
    vertex_buffer_views: [limits.max_vertex_buffers]d3d12.VERTEX_BUFFER_VIEW,
    vertex_strides: []u32 = undefined,

    pub fn create(encoder: *CommandEncoder, desc: sys.types.RenderPassDescriptor) !*RenderPassEncoder {
        const d3d_device = encoder.device.device;
        const command_list = encoder.command_buffer.command_list;

        var width: u32 = 0;
        var height: u32 = 0;
        var color_attachments: std.BoundedArray(sys.types.RenderPassColorAttachment, limits.max_color_attachments) = .{};
        var rtv_handles = try encoder.command_buffer.allocateRtvDescriptors(desc.color_attachments.len);
        const descriptor_size = encoder.device.rtv_heap.descriptor_size;

        var rtv_handle = rtv_handles;
        for (0..desc.color_attachments.len) |i| {
            const attach = desc.color_attachments[i];
            if (attach.view) |view_raw| {
                const view: *TextureView = @alignCast(@ptrCast(view_raw));
                const texture = view.texture;

                try encoder.reference_tracker.referenceTexture(texture);
                try encoder.state_tracker.transition(&texture.resource, .{ .RENDER_TARGET = true });

                width = view.width();
                height = view.height();
                color_attachments.appendAssumeCapacity(attach);

                // TODO - rtvDesc()
                d3d_device.createRenderTargetView(texture.resource.resource, null, rtv_handle);
            } else {
                d3d_device.createRenderTargetView(
                    null,
                    &.{
                        .Format = .R8G8B8A8_UNORM,
                        .ViewDimension = .TEXTURE2D,
                        .u = .{ .Texture2D = .{ .MipSlice = 0, .PlaneSlice = 0 } },
                    },
                    rtv_handle,
                );
            }
            rtv_handle.ptr += descriptor_size;
        }

        var depth_attachment: ?sys.types.RenderPassDepthStencilAttachment = null;
        var dsv_handle: d3d12.CPU_DESCRIPTOR_HANDLE = .{ .ptr = 0 };

        if (desc.depth_stencil_attachment) |attach| {
            const view: *TextureView = @alignCast(@ptrCast(attach.view));
            const texture = view.texture;

            try encoder.reference_tracker.referenceTexture(texture);
            try encoder.state_tracker.transition(&texture.resource, .{ .DEPTH_WRITE = true });

            width = view.width();
            height = view.height();
            depth_attachment = attach.*;

            dsv_handle = try encoder.command_buffer.allocateDsvDescriptor();

            d3d_device.createDepthStencilView(texture.resource.resource, null, dsv_handle);
        }

        encoder.state_tracker.flush(command_list);

        command_list.omSetRenderTargets(
            @intCast(desc.color_attachments.len),
            @ptrCast(&rtv_handles),
            1,
            if (desc.depth_stencil_attachment != null) &dsv_handle else null,
        );

        rtv_handle = rtv_handles;
        for (0..desc.color_attachments.len) |i| {
            const attach = desc.color_attachments[i];

            if (attach.load_op == .clear) {
                const clear_color = [4]f32{
                    @floatCast(attach.clear_value.r),
                    @floatCast(attach.clear_value.g),
                    @floatCast(attach.clear_value.b),
                    @floatCast(attach.clear_value.a),
                };
                command_list.clearRenderTargetView(rtv_handle, &clear_color, 0, null);
            }

            rtv_handle.ptr += descriptor_size;
        }

        if (desc.depth_stencil_attachment) |attach| {
            const flags = d3d12.CLEAR_FLAGS{
                .DEPTH = attach.depth_load_op == .clear,
                .STENCIL = attach.stencil_load_op == .clear,
            };

            if (flags != d3d12.CLEAR_FLAGS{}) {
                command_list.clearDepthStencilView(
                    dsv_handle,
                    flags,
                    attach.depth_clear_value,
                    @intCast(attach.stencil_clear_value),
                    0,
                    null,
                );
            }
        }

        const viewport = d3d12.VIEWPORT{
            .TopLeftX = 0,
            .TopLeftY = 0,
            .Width = @floatFromInt(width),
            .Height = @floatFromInt(height),
            .MinDepth = 0,
            .MaxDepth = 1,
        };
        const scissor_rect = w32.RECT{
            .left = 0,
            .top = 0,
            .right = @intCast(width),
            .bottom = @intCast(height),
        };

        command_list.rsSetViewports(1, @ptrCast(&viewport));
        command_list.rsSetScissorRects(1, @ptrCast(&scissor_rect));

        // Result
        const self = try allocator.create(RenderPassEncoder);
        self.* = .{
            .command_list = command_list,
            .color_attachments = color_attachments,
            .depth_attachment = depth_attachment,
            .reference_tracker = encoder.reference_tracker,
            .state_tracker = &encoder.state_tracker,
            .vertex_buffer_views = std.mem.zeroes([limits.max_vertex_buffers]d3d12.VERTEX_BUFFER_VIEW),
        };

        return self;
    }

    pub fn deinit(self: *RenderPassEncoder) void {
        allocator.destroy(self);
    }

    pub fn setPipeline(self: *RenderPassEncoder, pipeline: *RenderPipeline) !void {
        try self.reference_tracker.referenceRenderPipeline(pipeline);

        self.group_parameter_indices = pipeline.layout.group_parameter_indices.slice();
        self.vertex_strides = pipeline.vertex_strides.slice();

        self.command_list.setGraphicsRootSignature(pipeline.layout.root_signature);
        self.command_list.setPipelineState(pipeline.pipeline);
        self.command_list.iaSetPrimitiveTopology(pipeline.topology);
    }

    pub fn setVertexBuffer(self: *RenderPassEncoder, slot: u32, buffer: *Buffer, offset: u64, size: u64) !void {
        try self.reference_tracker.referenceBuffer(buffer);

        var view = &self.vertex_buffer_views[slot];
        view.BufferLocation = buffer.resource.resource.getGpuVirtualAddress() + offset;
        view.SizeInBytes = @intCast(size);

        self.vertex_apply_count = @max(self.vertex_apply_count, slot + 1);
    }

    pub fn setIndexBuffer(self: *RenderPassEncoder, buffer: *Buffer, format: sys.types.IndexFormat, offset: u64, size: u64) !void {
        try self.reference_tracker.referenceBuffer(buffer);

        const d3d_size: u32 = @intCast(if (size == sys.types.whole_size) buffer.size - offset else size);
        self.command_list.iaSetIndexBuffer(&.{
            .BufferLocation = buffer.resource.resource.getGpuVirtualAddress() + offset,
            .SizeInBytes = d3d_size,
            .Format = conv.dxgiFormatForIndex(format),
        });
    }

    pub fn setBindGroup(self: *RenderPassEncoder, group_index: u32, group: *BindGroup, dynamic_offsets: []const u32) !void {
        try self.reference_tracker.referenceBindGroup(group);

        var parameter_index = self.group_parameter_indices[group_index];

        if (group.general_table) |table| {
            self.command_list.setGraphicsRootDescriptorTable(parameter_index, table);
            parameter_index += 1;
        }

        if (group.sampler_table) |table| {
            self.command_list.setGraphicsRootDescriptorTable(parameter_index, table);
            parameter_index += 1;
        }

        for (dynamic_offsets, 0..) |dynamic_offset, i| {
            const dynamic_resource = group.dynamic_resources[i];

            switch (dynamic_resource.parameter_type) {
                .CBV => self.command_list.setGraphicsRootConstantBufferView(parameter_index, dynamic_resource.address + dynamic_offset),
                .SRV => self.command_list.setGraphicsRootShaderResourceView(parameter_index, dynamic_resource.address + dynamic_offset),
                .UAV => self.command_list.setGraphicsRootUnorderedAccessView(parameter_index, dynamic_resource.address + dynamic_offset),
                else => {},
            }

            parameter_index += 1;
        }
    }

    pub fn draw(self: *RenderPassEncoder, vertex_count: u32, instance_count: u32, first_vertex: u32, first_instance: u32) !void {
        self.applyVertexBuffers();
        self.command_list.drawInstanced(vertex_count, instance_count, first_vertex, first_instance);
    }

    pub fn drawIndexed(self: *RenderPassEncoder, index_count: u32, instance_count: u32, first_index: u32, base_vertex: i32, first_instance: u32) !void {
        self.applyVertexBuffers();
        self.command_list.drawIndexedInstanced(index_count, instance_count, first_index, base_vertex, first_instance);
    }

    pub fn end(self: *RenderPassEncoder) !void {
        const command_list = self.command_list;

        for (self.color_attachments.slice()) |attach| {
            const view: *TextureView = @alignCast(@ptrCast(attach.view.?));

            if (attach.resolve_target) |resolve_target_raw| {
                const resolve_target: *TextureView = @alignCast(@ptrCast(resolve_target_raw));

                try self.reference_tracker.referenceTexture(resolve_target.texture);
                try self.state_tracker.transition(&view.texture.resource, .{ .RESOLVE_SOURCE = true });
                try self.state_tracker.transition(&resolve_target.texture.resource, .{ .RESOLVE_DEST = true });

                self.state_tracker.flush(command_list);

                // Format
                const resolve_d3d_resource = resolve_target.texture.resource.resource;
                const view_d3d_resource = view.texture.resource.resource;
                var d3d_desc: d3d12.RESOURCE_DESC = undefined;

                var format: dxgi.FORMAT = undefined;
                _ = resolve_d3d_resource.getDesc(&d3d_desc);
                format = d3d_desc.Format;
                if (conv.dxgiFormatIsTypeless(format)) {
                    _ = view_d3d_resource.getDesc(&d3d_desc);
                    format = d3d_desc.Format;
                    if (conv.dxgiFormatIsTypeless(format)) {
                        return error.NoTypedFormat;
                    }
                }

                command_list.resolveSubresource(
                    resolve_target.texture.resource.resource,
                    resolve_target.base_subresource,
                    view.texture.resource.resource,
                    view.base_subresource,
                    format,
                );

                try self.state_tracker.transition(&resolve_target.texture.resource, resolve_target.texture.resource.state);
            }

            try self.state_tracker.transition(&view.texture.resource, view.texture.resource.state);
        }

        if (self.depth_attachment) |attach| {
            const view: *TextureView = @alignCast(@ptrCast(attach.view));

            try self.state_tracker.transition(&view.texture.resource, view.texture.resource.state);
        }
    }

    fn applyVertexBuffers(encoder: *RenderPassEncoder) void {
        if (encoder.vertex_apply_count > 0) {
            for (0..encoder.vertex_apply_count) |i| {
                var view = &encoder.vertex_buffer_views[i];
                view.StrideInBytes = encoder.vertex_strides[i];
            }

            encoder.command_list.iaSetVertexBuffers(0, encoder.vertex_apply_count, &encoder.vertex_buffer_views);
            encoder.vertex_apply_count = 0;
        }
    }
};

pub const Buffer = struct {
    manager: Manager(Buffer) = .{},
    device: *Device,
    resource: Resource,
    stage_buffer: ?*Buffer,
    gpu_count: u32 = 0,
    map: ?[*]u8,
    size: u64,
    usage: sys.Buffer.UsageFlags,

    pub fn create(device: *Device, desc: sys.Buffer.Descriptor) !*Buffer {
        var resource = try device.createBufferResource(desc.usage, desc.size);
        errdefer resource.deinit();

        setDebugName(@ptrCast(resource.resource), desc.label);

        // Mapped at Creation
        var stage_buffer: ?*Buffer = null;
        var map: ?*anyopaque = null;
        if (desc.mapped_at_creation == true) {
            var map_resource: *d3d12.IResource = undefined;
            if (!desc.usage.map_write) {
                stage_buffer = try Buffer.create(device, .{
                    .usage = .{ .copy_src = true, .map_write = true },
                    .size = desc.size,
                });
                map_resource = stage_buffer.?.resource.resource;
            } else {
                map_resource = resource.resource;
            }

            // TODO - map status in callback instead of failure
            const hr = map_resource.map(0, null, &map);
            if (hr != 0) {
                return error.MapBufferAtCreationFailed;
            }
        }

        // Result
        const self = try allocator.create(Buffer);
        self.* = .{
            .device = device,
            .resource = resource,
            .stage_buffer = stage_buffer,
            .map = @ptrCast(map),
            .size = desc.size,
            .usage = desc.usage,
        };

        return self;
    }

    pub fn deinit(self: *Buffer) void {
        if (self.stage_buffer) |buffer| buffer.manager.release();
        self.resource.deinit();
        allocator.destroy(self);
    }

    pub fn getSize(self: *Buffer) u64 {
        return self.size;
    }

    pub fn getUsage(self: *Buffer) sys.Buffer.UsageFlags {
        return self.usage;
    }

    pub fn getMappedRange(self: *Buffer, offset: usize, size: usize) *anyopaque {
        return @ptrCast(self.map.?[offset .. offset + size]);
    }

    pub fn unmap(self: *Buffer) !void {
        var map_resource: *d3d12.IResource = undefined;
        if (self.stage_buffer) |stage| {
            map_resource = stage.resource.resource;
            const encoder = try self.device.queue.getCommandEncoder();
            try encoder.copyBufferToBuffer(stage, 0, self, 0, self.size);
            stage.manager.release();
            self.stage_buffer = null;
        } else {
            map_resource = self.resource.resource;
        }

        map_resource.unmap(0, null);
    }
};

pub const BindGroup = struct {
    const ResourceAccess = struct {
        resource: *Resource,
        uav: bool,
    };
    const DynamicResource = struct {
        address: d3d12.GPU_VIRTUAL_ADDRESS,
        parameter_type: d3d12.ROOT_PARAMETER_TYPE,
    };

    manager: Manager(BindGroup) = .{},
    device: *Device,
    general_allocation: ?DescriptorAllocation,
    general_table: ?d3d12.GPU_DESCRIPTOR_HANDLE,
    sampler_allocation: ?DescriptorAllocation,
    sampler_table: ?d3d12.GPU_DESCRIPTOR_HANDLE,
    dynamic_resources: []DynamicResource,
    buffers: std.ArrayListUnmanaged(*Buffer),
    textures: std.ArrayListUnmanaged(*Texture),
    accesses: std.ArrayListUnmanaged(ResourceAccess),

    pub fn create(device: *Device, desc: sys.BindGroup.Descriptor) !*BindGroup {
        const layout: *BindGroupLayout = @alignCast(@ptrCast(desc.layout));

        // General Descriptor Table
        var general_allocation: ?DescriptorAllocation = null;
        var general_table: ?d3d12.GPU_DESCRIPTOR_HANDLE = null;
        if (layout.general_table_size != 0) {
            const allocation = try device.general_heap.alloc();
            general_allocation = allocation;
            general_table = device.general_heap.gpuDescriptor(allocation.index);

            for (desc.entries) |entry| {
                const layout_entry = layout.getEntry(entry.binding) orelse return error.UnknownBinding;
                if (layout_entry.sampler.type != .undefined) continue;

                if (layout_entry.table_index) |table_index| {
                    const dest_descriptor = device.general_heap.cpuDescriptor(allocation.index + table_index);

                    if (layout_entry.buffer.type != .undefined) {
                        const buffer: *Buffer = @alignCast(@ptrCast(entry.buffer));
                        const resource = buffer.resource.resource;
                        const buffer_location = resource.getGpuVirtualAddress();

                        switch (layout_entry.buffer.type) {
                            .undefined => unreachable,
                            .uniform => {
                                const cbv_desc = d3d12.CONSTANT_BUFFER_VIEW_DESC{
                                    .BufferLocation = buffer_location,
                                    .SizeInBytes = @intCast(conv.alignUp(entry.size, limits.min_uniform_buffer_offset_alignment)),
                                };

                                device.device.createConstantBufferView(&cbv_desc, dest_descriptor);
                            },
                            .storage => unreachable,
                            .read_only_storage => unreachable,
                        }

                        continue;
                    }

                    if (layout_entry.texture.sample_type != .undefined) {
                        const view: *TextureView = @alignCast(@ptrCast(entry.texture_view));
                        const resource = view.texture.resource.resource;

                        device.device.createShaderResourceView(resource, &view.srvDesc(), dest_descriptor);
                        continue;
                    }

                    if (layout_entry.storage_texture.format != .undefined) {
                        unreachable;
                    }
                }
            }
        }

        // Sampler Descriptor Table
        var sampler_allocation: ?DescriptorAllocation = null;
        var sampler_table: ?d3d12.GPU_DESCRIPTOR_HANDLE = null;
        if (layout.sampler_table_size != 0) {
            const allocation = try device.sampler_heap.alloc();
            sampler_allocation = allocation;
            sampler_table = device.sampler_heap.gpuDescriptor(allocation.index);

            for (desc.entries) |entry| {
                const layout_entry = layout.getEntry(entry.binding) orelse return error.UnknownBinding;
                if (layout_entry.sampler.type == .undefined) continue;

                if (layout_entry.table_index) |table_index| {
                    const dest_descriptor = device.sampler_heap.cpuDescriptor(allocation.index + table_index);

                    const sampler: *Sampler = @alignCast(@ptrCast(entry.sampler));

                    device.device.createSampler(&sampler.desc, dest_descriptor);
                }
            }
        }

        // Resource tracking and dynamic resources
        const dynamic_resources = try allocator.alloc(DynamicResource, layout.dynamic_entries.items.len);
        errdefer allocator.free(dynamic_resources);

        var buffers = std.ArrayListUnmanaged(*Buffer){};
        errdefer buffers.deinit(allocator);

        var textures = std.ArrayListUnmanaged(*Texture){};
        errdefer textures.deinit(allocator);

        var accesses = std.ArrayListUnmanaged(ResourceAccess){};
        errdefer accesses.deinit(allocator);

        for (desc.entries) |entry| {
            const layout_entry = layout.getEntry(entry.binding) orelse return error.UnknownBinding;

            if (layout_entry.buffer.type != .undefined) {
                const buffer: *Buffer = @alignCast(@ptrCast(entry.buffer.?));

                try buffers.append(allocator, buffer);
                buffer.manager.reference();

                const location = buffer.resource.resource.getGpuVirtualAddress() + entry.offset;
                if (layout_entry.dynamic_index) |dynamic_index| {
                    const layout_dynamic_entry = layout.dynamic_entries.items[dynamic_index];
                    dynamic_resources[dynamic_index] = .{
                        .address = location,
                        .parameter_type = layout_dynamic_entry.parameter_type,
                    };
                }

                try accesses.append(allocator, .{ .resource = &buffer.resource, .uav = layout_entry.buffer.type == .storage });

                continue;
            }

            if (layout_entry.sampler.type != .undefined and layout_entry.texture.sample_type != .undefined) {
                unreachable;
            }

            if (layout_entry.storage_texture.format != .undefined) {
                unreachable;
            }
        }

        const self = try allocator.create(BindGroup);
        self.* = .{
            .device = device,
            .general_allocation = general_allocation,
            .general_table = general_table,
            .sampler_allocation = sampler_allocation,
            .sampler_table = sampler_table,
            .dynamic_resources = dynamic_resources,
            .buffers = buffers,
            .textures = textures,
            .accesses = accesses,
        };

        return self;
    }

    pub fn deinit(self: *BindGroup) void {
        if (self.general_allocation) |allocation|
            self.device.general_heap.free(allocation);
        if (self.sampler_allocation) |allocation|
            self.device.sampler_heap.free(allocation);

        for (self.buffers.items) |buffer| buffer.manager.release();
        for (self.textures.items) |texture| texture.manager.release();

        self.buffers.deinit(allocator);
        self.textures.deinit(allocator);
        self.accesses.deinit(allocator);
        allocator.free(self.dynamic_resources);
        allocator.destroy(self);
    }
};

pub const Sampler = struct {
    manager: Manager(Sampler) = .{},
    desc: d3d12.SAMPLER_DESC,

    pub fn create(_: *Device, desc: sys.Sampler.Descriptor) !*Sampler {
        const self = try allocator.create(Sampler);
        self.* = .{
            .desc = .{
                .Filter = @enumFromInt(conv.d3d12Filter(desc.mag_filter, desc.min_filter, desc.mipmap_filter, desc.max_anisotropy)),
                .AddressU = conv.d3d12TextureAddressMode(desc.address_mode_u),
                .AddressV = conv.d3d12TextureAddressMode(desc.address_mode_v),
                .AddressW = conv.d3d12TextureAddressMode(desc.address_mode_w),
                .MipLODBias = 0.0,
                .MaxAnisotropy = desc.max_anisotropy,
                .ComparisonFunc = if (desc.compare != .undefined) conv.d3d12ComparisonFunc(desc.compare) else .NEVER,
                .BorderColor = [4]f32{ 0.0, 0.0, 0.0, 0.0 },
                .MinLOD = desc.lod_min_clamp,
                .MaxLOD = desc.lod_max_clamp,
            },
        };

        return self;
    }

    pub fn deinit(self: *Sampler) void {
        allocator.destroy(self);
    }
};

// implementation details
// ----------------------

const DescriptorAllocation = struct {
    index: u32,
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
    free_blocks: std.ArrayListUnmanaged(DescriptorAllocation) = .empty,

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
        self.free_blocks.deinit(allocator);
        _ = self.heap.release();
    }

    fn alloc(self: *DescriptorHeap) !DescriptorAllocation {
        // Recycle finished blocks
        if (self.free_blocks.items.len == 0) {
            self.device.processQueuedOperations();
        }

        // Create new block
        if (self.free_blocks.items.len == 0) {
            if (self.next_alloc == self.descriptor_count)
                return error.OutOfDescriptorMemory;

            const index = self.next_alloc;
            self.next_alloc += self.block_size;
            try self.free_blocks.append(allocator, .{ .index = index });
        }

        // Result
        return self.free_blocks.pop().?;
    }

    fn free(self: *DescriptorHeap, allocation: DescriptorAllocation) void {
        self.free_blocks.append(allocator, allocation) catch @panic("OutOfMemory");
    }

    fn cpuDescriptor(heap: *DescriptorHeap, index: u32) d3d12.CPU_DESCRIPTOR_HANDLE {
        return .{ .ptr = heap.cpu_base.ptr + index * heap.descriptor_size };
    }

    fn gpuDescriptor(heap: *DescriptorHeap, index: u32) d3d12.GPU_DESCRIPTOR_HANDLE {
        return .{ .ptr = heap.gpu_base.ptr + index * heap.descriptor_size };
    }
};

const CommandManager = struct {
    device: *Device,
    free_allocators: std.ArrayListUnmanaged(*d3d12.ICommandAllocator) = .empty,
    free_command_lists: std.ArrayListUnmanaged(*d3d12.IGraphicsCommandList) = .empty,

    fn create(device: *Device) CommandManager {
        return .{ .device = device };
    }

    fn deinit(self: *CommandManager) void {
        for (self.free_allocators.items) |command_allocator| {
            _ = command_allocator.release();
        }
        for (self.free_command_lists.items) |command_list| {
            _ = command_list.release();
        }

        self.free_allocators.deinit(allocator);
        self.free_command_lists.deinit(allocator);
    }

    fn createCommandAllocator(self: *CommandManager) !*d3d12.ICommandAllocator {
        // Recycle finished allocators
        if (self.free_allocators.items.len == 0) {
            self.device.processQueuedOperations();
        }

        // Create new command allocator
        if (self.free_allocators.items.len == 0) {
            var command_allocator: *d3d12.ICommandAllocator = undefined;
            const hr = self.device.device.createCommandAllocator(.DIRECT, &d3d12.ICommandAllocator.IID, @ptrCast(&command_allocator));
            if (hr != 0) {
                return error.CreateCommandAllocatorFailed;
            }

            try self.free_allocators.append(allocator, command_allocator);
        }

        // Reset
        const command_allocator = self.free_allocators.pop().?;
        const hr = command_allocator.reset();
        if (hr != 0) {
            return error.ResetCommandAllocatorFailed;
        }

        return command_allocator;
    }

    fn destroyCommandAllocator(self: *CommandManager, command_allocator: *d3d12.ICommandAllocator) void {
        self.free_allocators.append(allocator, command_allocator) catch @panic("OutOfMemory");
    }

    fn createCommandList(self: *CommandManager, command_allocator: *d3d12.ICommandAllocator) !*d3d12.IGraphicsCommandList {
        if (self.free_command_lists.items.len == 0) {
            var command_list: *d3d12.IGraphicsCommandList = undefined;
            const hr = self.device.device.createCommandList(0, .DIRECT, command_allocator, null, &d3d12.IGraphicsCommandList.IID, @ptrCast(&command_list));
            if (hr != 0) {
                return error.CreateCommandListFailed;
            }

            return command_list;
        }

        const command_list = self.free_command_lists.pop().?;
        const hr = command_list.reset(command_allocator, null);
        if (hr != 0) {
            return error.ResetCommandListFailed;
        }

        return command_list;
    }

    fn destroyCommandList(self: *CommandManager, command_list: *d3d12.IGraphicsCommandList) void {
        self.free_command_lists.append(allocator, command_list) catch @panic("OutOfMemory");
    }
};

const StreamingManager = struct {
    device: *Device,
    free_buffers: std.ArrayListUnmanaged(Resource) = .{},

    fn create(device: *Device) !StreamingManager {
        return .{ .device = device };
    }

    fn deinit(self: *StreamingManager) void {
        for (self.free_buffers.items) |*resource| {
            resource.deinit();
        }
        self.free_buffers.deinit(allocator);
    }

    fn acquire(self: *StreamingManager) !Resource {
        // Recycle finished buffers
        if (self.free_buffers.items.len == 0) {
            self.device.processQueuedOperations();
        }

        // Create new buffer
        if (self.free_buffers.items.len == 0) {
            var resource = try self.device.createBufferResource(.{ .map_write = true }, upload_page_size);
            errdefer _ = resource.deinit();

            setDebugName(@ptrCast(resource.resource), "upload");
            try self.free_buffers.append(allocator, resource);
        }

        // Result
        return self.free_buffers.pop().?;
    }

    fn release(self: *StreamingManager, resource: Resource) void {
        self.free_buffers.append(allocator, resource) catch @panic("OutOfMemory");
    }
};

pub const Resource = struct {
    resource: *d3d12.IResource,
    state: d3d12.RESOURCE_STATES,
    mem_allocator: ?*MemoryAllocator = null,
    allocation: ?MemoryAllocator.Allocation = null,
    memory_location: MemoryAllocator.MemoryLocation = .unknown,
    size: u64 = 0,

    fn create(resource: *d3d12.IResource, state: d3d12.RESOURCE_STATES) Resource {
        return .{ .resource = resource, .state = state };
    }

    fn deinit(self: *Resource) void {
        if (self.mem_allocator) |mem_allocator| {
            mem_allocator.destroyResource(self.*) catch unreachable;
        } else {
            _ = self.resource.release();
        }
    }
};

// TODO put this somewhere else
const DefaultPipelineLayoutDescriptor = struct {
    pub const Group = std.ArrayListUnmanaged(sys.BindGroupLayout.Entry);

    groups: std.BoundedArray(Group, limits.max_bind_groups) = .{},

    pub fn deinit(desc: *DefaultPipelineLayoutDescriptor) void {
        for (desc.groups.slice()) |*group| {
            group.deinit(allocator);
        }
    }

    pub fn addFunction(desc: *DefaultPipelineLayoutDescriptor, air: *const sys.shader.Air, stage: sys.types.ShaderStageFlags, entry_point: [:0]const u8) !void {
        if (air.findFunction(entry_point)) |fn_inst| {
            const global_var_ref_list = air.refToList(fn_inst.global_var_refs);
            for (global_var_ref_list) |global_var_inst_idx| {
                const var_inst = air.getInst(global_var_inst_idx).@"var";
                if (var_inst.addr_space == .workgroup)
                    continue;

                const var_type = air.getInst(var_inst.type);
                const group: u32 = @intCast(air.resolveInt(var_inst.group) orelse return error.ConstExpr);
                const binding: u32 = @intCast(air.resolveInt(var_inst.binding) orelse return error.ConstExpr);

                var entry: sys.BindGroupLayout.Entry = .{ .binding = binding, .visibility = stage };
                switch (var_type) {
                    .sampler_type => entry.sampler.type = .filtering,
                    .comparison_sampler_type => entry.sampler.type = .comparison,
                    .texture_type => |texture| {
                        switch (texture.kind) {
                            .storage_1d, .storage_2d, .storage_2d_array, .storage_3d => {
                                entry.storage_texture.access = .undefined; // TODO - write_only
                                entry.storage_texture.format = switch (texture.texel_format) {
                                    .none => unreachable,
                                    .rgba8unorm => .rgba8_unorm,
                                    .rgba8snorm => .rgba8_snorm,
                                    .bgra8unorm => .bgra8_unorm,
                                    .rgba16float => .rgba16_float,
                                    .r32float => .r32_float,
                                    .rg32float => .rg32_float,
                                    .rgba32float => .rgba32_float,
                                    .rgba8uint => .rgba8_uint,
                                    .rgba16uint => .rgba16_uint,
                                    .r32uint => .r32_uint,
                                    .rg32uint => .rg32_uint,
                                    .rgba32uint => .rgba32_uint,
                                    .rgba8sint => .rgba8_sint,
                                    .rgba16sint => .rgba16_sint,
                                    .r32sint => .r32_sint,
                                    .rg32sint => .rg32_sint,
                                    .rgba32sint => .rgba32_sint,
                                };
                                entry.storage_texture.view_dimension = switch (texture.kind) {
                                    .storage_1d => .@"1d",
                                    .storage_2d => .@"2d",
                                    .storage_2d_array => .@"2d_array",
                                    .storage_3d => .@"3d",
                                    else => unreachable,
                                };
                            },
                            else => {
                                // sample_type
                                entry.texture.sample_type =
                                    switch (texture.kind) {
                                        .depth_2d,
                                        .depth_2d_array,
                                        .depth_cube,
                                        .depth_cube_array,
                                        => .depth,
                                        else => switch (texture.texel_format) {
                                            .none => .float, // TODO - is this right?
                                            .rgba8unorm, .rgba8snorm, .bgra8unorm, .rgba16float, .r32float, .rg32float, .rgba32float => .float, // TODO - unfilterable
                                            .rgba8uint, .rgba16uint, .r32uint, .rg32uint, .rgba32uint => .uint,
                                            .rgba8sint, .rgba16sint, .r32sint, .rg32sint, .rgba32sint => .sint,
                                        },
                                    };
                                entry.texture.view_dimension = switch (texture.kind) {
                                    .sampled_1d, .storage_1d => .@"1d",
                                    .sampled_2d, .multisampled_2d, .multisampled_depth_2d, .storage_2d, .depth_2d => .@"2d",
                                    .sampled_2d_array, .storage_2d_array, .depth_2d_array => .@"2d_array",
                                    .sampled_3d, .storage_3d => .@"3d",
                                    .sampled_cube, .depth_cube => .cube,
                                    .sampled_cube_array, .depth_cube_array => .cube_array,
                                };
                                entry.texture.multisampled = switch (texture.kind) {
                                    .multisampled_2d, .multisampled_depth_2d => true,
                                    else => false,
                                };
                            },
                        }
                    },
                    else => {
                        switch (var_inst.addr_space) {
                            .uniform => entry.buffer.type = .uniform,
                            .storage => {
                                if (var_inst.access_mode == .read) {
                                    entry.buffer.type = .read_only_storage;
                                } else {
                                    entry.buffer.type = .storage;
                                }
                            },
                            else => @panic("unhandled addr_space"),
                        }
                    },
                }

                while (desc.groups.len <= group) {
                    desc.groups.appendAssumeCapacity(.{});
                }

                var append = true;
                var group_entries = &desc.groups.buffer[group];
                for (group_entries.items) |*previous_entry| {
                    if (previous_entry.binding == binding) {
                        // TODO - bitfield or?
                        if (entry.visibility.vertex)
                            previous_entry.visibility.vertex = true;
                        if (entry.visibility.fragment)
                            previous_entry.visibility.fragment = true;
                        if (entry.visibility.compute)
                            previous_entry.visibility.compute = true;

                        if (previous_entry.buffer.min_binding_size < entry.buffer.min_binding_size) {
                            previous_entry.buffer.min_binding_size = entry.buffer.min_binding_size;
                        }
                        if (previous_entry.texture.sample_type != entry.texture.sample_type) {
                            if (previous_entry.texture.sample_type == .unfilterable_float and entry.texture.sample_type == .float) {
                                previous_entry.texture.sample_type = .float;
                            } else if (previous_entry.texture.sample_type == .float and entry.texture.sample_type == .unfilterable_float) {
                                // ignore
                            } else {
                                return error.IncompatibleEntries;
                            }
                        }

                        // TODO - any other differences return error

                        append = false;
                        break;
                    }
                }

                if (append)
                    try group_entries.append(allocator, entry);
            }
        }
    }
};

const ReferenceTracker = struct {
    device: *Device,
    command_allocator: *d3d12.ICommandAllocator,
    fence_value: u64 = 0,
    buffers: std.ArrayListUnmanaged(*Buffer) = .{},
    textures: std.ArrayListUnmanaged(*Texture) = .{},
    bind_groups: std.ArrayListUnmanaged(*BindGroup) = .{},
    // compute_pipelines: std.ArrayListUnmanaged(*ComputePipeline) = .{},
    render_pipelines: std.ArrayListUnmanaged(*RenderPipeline) = .{},
    rtv_descriptor_blocks: std.ArrayListUnmanaged(DescriptorAllocation) = .{},
    dsv_descriptor_blocks: std.ArrayListUnmanaged(DescriptorAllocation) = .{},
    upload_pages: std.ArrayListUnmanaged(Resource) = .{},

    pub fn create(device: *Device, command_allocator: *d3d12.ICommandAllocator) !*ReferenceTracker {
        const self = try allocator.create(ReferenceTracker);
        self.* = .{
            .device = device,
            .command_allocator = command_allocator,
        };
        return self;
    }

    pub fn deinit(self: *ReferenceTracker) void {
        self.device.command_manager.destroyCommandAllocator(self.command_allocator);

        for (self.buffers.items) |buffer| {
            buffer.gpu_count -= 1;
            buffer.manager.release();
        }

        for (self.textures.items) |texture| {
            texture.manager.release();
        }

        for (self.bind_groups.items) |group| {
            for (group.buffers.items) |buffer| buffer.gpu_count -= 1;
            group.manager.release();
        }

        // for (self.compute_pipelines.items) |pipeline| {
        //     pipeline.manager.release();
        // }

        for (self.render_pipelines.items) |pipeline| {
            pipeline.manager.release();
        }

        for (self.rtv_descriptor_blocks.items) |block| {
            self.device.rtv_heap.free(block);
        }

        for (self.dsv_descriptor_blocks.items) |block| {
            self.device.dsv_heap.free(block);
        }

        for (self.upload_pages.items) |resource| {
            self.device.streaming_manager.release(resource);
        }

        self.buffers.deinit(allocator);
        self.textures.deinit(allocator);
        self.bind_groups.deinit(allocator);
        // self.compute_pipelines.deinit(allocator);
        self.render_pipelines.deinit(allocator);
        self.rtv_descriptor_blocks.deinit(allocator);
        self.dsv_descriptor_blocks.deinit(allocator);
        self.upload_pages.deinit(allocator);
        allocator.destroy(self);
    }

    fn referenceRtvDescriptorBlock(self: *ReferenceTracker, block: DescriptorAllocation) !void {
        try self.rtv_descriptor_blocks.append(allocator, block);
    }

    fn referenceTexture(self: *ReferenceTracker, texture: *Texture) !void {
        texture.manager.reference();
        try self.textures.append(allocator, texture);
    }

    fn referenceDsvDescriptorBlock(self: *ReferenceTracker, block: DescriptorAllocation) !void {
        try self.dsv_descriptor_blocks.append(allocator, block);
    }

    fn referenceRenderPipeline(self: *ReferenceTracker, pipeline: *RenderPipeline) !void {
        pipeline.manager.reference();
        try self.render_pipelines.append(allocator, pipeline);
    }

    fn referenceBuffer(tracker: *ReferenceTracker, buffer: *Buffer) !void {
        buffer.manager.reference();
        try tracker.buffers.append(allocator, buffer);
    }

    fn referenceUploadPage(tracker: *ReferenceTracker, upload_page: Resource) !void {
        try tracker.upload_pages.append(allocator, upload_page);
    }

    fn referenceBindGroup(tracker: *ReferenceTracker, group: *BindGroup) !void {
        group.manager.reference();
        try tracker.bind_groups.append(allocator, group);
    }

    fn submit(self: *ReferenceTracker, queue: *Queue) !void {
        self.fence_value = queue.fence_value;

        for (self.buffers.items) |buffer| {
            buffer.gpu_count += 1;
        }

        for (self.bind_groups.items) |group| {
            for (group.buffers.items) |buffer| buffer.gpu_count += 1;
        }

        try self.device.reference_trackers.append(allocator, self);
    }
};

const StateTracker = struct {
    device: *Device = undefined,
    written_set: std.AutoArrayHashMapUnmanaged(*Resource, d3d12.RESOURCE_STATES) = .empty,
    barriers: std.ArrayListUnmanaged(d3d12.RESOURCE_BARRIER) = .empty,

    pub fn create(device: *Device) StateTracker {
        return .{ .device = device };
    }

    pub fn deinit(self: *StateTracker) void {
        self.written_set.deinit(allocator);
        self.barriers.deinit(allocator);
    }

    fn flush(self: *StateTracker, command_list: *d3d12.IGraphicsCommandList) void {
        if (self.barriers.items.len > 0) {
            command_list.resourceBarrier(@intCast(self.barriers.items.len), self.barriers.items.ptr);
            self.barriers.clearRetainingCapacity();
        }
    }

    fn transition(tracker: *StateTracker, resource: *Resource, new_state: d3d12.RESOURCE_STATES) !void {
        const current_state = tracker.written_set.get(resource) orelse resource.state;

        if (current_state.UNORDERED_ACCESS and new_state.UNORDERED_ACCESS) {
            try tracker.addUavBarrier(resource);
        } else if (current_state != new_state) {
            try tracker.written_set.put(allocator, resource, new_state);
            try tracker.addTransitionBarrier(resource, current_state, new_state);
        }
    }

    fn endPass(tracker: *StateTracker) !void {
        var it = tracker.written_set.iterator();
        while (it.next()) |entry| {
            const resource = entry.key_ptr.*;
            const current_state = entry.value_ptr.*;

            if (current_state != resource.state)
                try tracker.addTransitionBarrier(resource, current_state, resource.state);
        }

        tracker.written_set.clearRetainingCapacity();
    }

    fn addTransitionBarrier(tracker: *StateTracker, resource: *Resource, state_before: d3d12.RESOURCE_STATES, state_after: d3d12.RESOURCE_STATES) !void {
        try tracker.barriers.append(allocator, .{
            .Type = .TRANSITION,
            .Flags = .{},
            .u = .{
                .Transition = .{
                    .pResource = resource.resource,
                    .Subresource = d3d12.RESOURCE_BARRIER_ALL_SUBRESOURCES,
                    .StateBefore = state_before,
                    .StateAfter = state_after,
                },
            },
        });
    }

    fn addUavBarrier(tracker: *StateTracker, resource: *Resource) !void {
        try tracker.barriers.append(allocator, .{
            .Type = .UAV,
            .Flags = .{},
            .u = .{
                .UAV = .{
                    .pResource = resource.resource,
                },
            },
        });
    }
};

fn setDebugName(object: *d3d12.IObject, label: [:0]const u8) void {
    _ = object.setPrivateData(&d3d12.IObject.DebugObjectName, @intCast(label.len), @ptrCast(label.ptr));
}

fn calcExtent(dimension: sys.Texture.Dimension, extent: sys.types.Extent3D) struct {
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

fn calcOrigin(dimension: sys.Texture.Dimension, origin: sys.types.Origin3D) struct {
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
