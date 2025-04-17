const std = @import("std");
const builtin = @import("builtin");
const prism = @import("../prism.zig");
const gpu = @import("gpu.zig");
const platform = @import("../platform/platform.zig");
const windows = @import("../platform/win32.zig");
const util = @import("../util.zig");
const internal = @import("internal.zig");

const w32 = @import("w32");
const dxgi = w32.dxgi;
const d3d12 = w32.d3d12;

const log = std.log.scoped(.d3d12);

const allocator = prism.allocator;

// FIXME
const IndirectDrawCommand = [4]u32;
const IndexedIndirectDrawCommand = [5]u32;
const IndirectDispatchCommand = [3]u32;
const SwapchainComposition = enum { sdr };
const PresentMode = enum { vsync, immediate, mailbox };

pub const Context = struct {
    pub fn create() !gpu.Context {
        return gpu.Context{
            .ptr = undefined,
            .vtable = .{
                .destroy = util.vcast(Context.destroy),
                .create_device = util.vcast(Context.createDevice),
            },
        };
    }

    // vtable implementations
    // ----------------------

    fn destroy(_: *Context) void {}

    fn createDevice(_: *Context, window: *platform.Window) anyerror!*gpu.Device {
        const device = try D3D12Device.create(@alignCast(@ptrCast(window.ptr)));

        const gpu_device = try allocator.create(gpu.Device);
        gpu_device.* = .{
            .ptr = device,
            .vtable = .{
                // Device
                .destroy = util.vcast(D3D12Device.destroy),
                .get_command_buffer_header = D3D12CommandBuffer.getHeader,
                // State Creation
                // Debug Naming
                // Disposal
                // Render Pass
                // Compute Pass
                // TransferBuffer Data
                // Copy Pass
                // Submission/Presentation
                .acquire_command_buffer = util.vcast(D3D12Device.acquireCommandBuffer),
                // Feature Queries
            },
        };

        return gpu_device;
    }
};

pub const D3D12Device = struct {
    dxgi_debug: void = {},
    factory: *dxgi.IFactory2,
    adapter: *dxgi.IAdapter1,

    d3d12_debug: void = {},
    device: *d3d12.IDevice,

    command_queue: *d3d12.ICommandQueue,

    // indirect command signatures
    indirect_draw_command_signature: *d3d12.ICommandSignature,
    indirect_indexed_draw_command_signature: *d3d12.ICommandSignature,
    indirect_dispatch_command_signature: *d3d12.ICommandSignature,

    blit: struct {
        vertex_shader: void = {},
        from2d_shader: void = {},
        from2d_array_shader: void = {},
        from3d_shader: void = {},
        from_cube_shader: void = {},
        from_cube_array_shader: void = {},

        nearest_sampler: void = {},
        linear_sampler: void = {},

        pipelines: std.ArrayListUnmanaged(void) = .empty,
    } = .{},

    // Resources
    available_command_buffers: std.ArrayListUnmanaged(*D3D12CommandBuffer),
    submitted_command_buffers: std.ArrayListUnmanaged(void),
    uniform_buffer_pool: std.ArrayListUnmanaged(void),
    claimed_windows: std.ArrayListUnmanaged(void),
    available_fences: std.ArrayListUnmanaged(void),

    // D3D12StagingDescriptorPool *stagingDescriptorPools[D3D12_DESCRIPTOR_HEAP_TYPE_NUM_TYPES];
    // D3D12GPUDescriptorHeapPool gpuDescriptorHeapPools[2];

    // Deferred resource releasing
    buffers_to_destroy: std.ArrayListUnmanaged(void),
    textures_to_destroy: std.ArrayListUnmanaged(void),
    samplers_to_destroy: std.ArrayListUnmanaged(void),
    graphics_pipelines_to_destroy: std.ArrayListUnmanaged(void),
    compute_pipelines_to_destroy: std.ArrayListUnmanaged(void),

    // Locks
    acquire_command_buffer_lock: std.Thread.Mutex = .{},
    acquire_uniform_buffer_lock: std.Thread.Mutex = .{},
    submit_lock: std.Thread.Mutex = .{},
    window_lock: std.Thread.Mutex = .{},
    fence_lock: std.Thread.Mutex = .{},
    dispose_lock: std.Thread.Mutex = .{},

    fn create(window: *windows.Window) !*D3D12Device {
        _ = window; // autofix
        if (builtin.mode == .Debug) {
            // TODO init dxgi debug interface
        }

        var factory: *dxgi.IFactory2 = undefined;
        _ = dxgi.CreateDXGIFactory2(@intFromBool(builtin.mode == .Debug), &dxgi.IFactory2.IID, @ptrCast(&factory));

        var adapter: *dxgi.IAdapter1 = undefined;
        _ = factory.enumAdapters1(0, @ptrCast(&adapter));
        var adapter_desc: dxgi.ADAPTER_DESC1 = undefined;
        _ = adapter.getDesc1(&adapter_desc);
        var umd_version: w32.LUID = undefined;
        _ = adapter.checkInterfaceSupport(&dxgi.IDevice.IID, @alignCast(@ptrCast(&umd_version)));

        const device_name = try std.unicode.utf16LeToUtf8Alloc(allocator, std.mem.span(@as([*:0]const u16, @ptrCast(&adapter_desc.Description))));
        defer allocator.free(device_name);
        log.debug("adapter: {s}", .{device_name});

        var driver_version_buf: [64]u8 = undefined;
        const driver_version = try std.fmt.bufPrint(&driver_version_buf, "{}.{}.{}.{}", .{
            w32.HIWORD(umd_version.HighPart),
            w32.LOWORD(umd_version.HighPart),
            w32.HIWORD(umd_version.LowPart),
            w32.LOWORD(umd_version.LowPart),
        });
        log.debug("driver: {s}", .{driver_version});

        if (builtin.mode == .Debug) {
            // TODO init d3d12 debug interface
        }

        var device: *d3d12.IDevice = undefined;
        _ = d3d12.D3D12CreateDevice(@ptrCast(adapter), .@"11_1", &d3d12.IDevice.IID, @ptrCast(&device));

        if (builtin.mode == .Debug) {
            // TODO init d3d12 debug info queue
        }

        var arch: d3d12.FEATURE_DATA_ARCHITECTURE = .{ .NodeIndex = 0 };
        _ = device.checkFeatureSupport(.ARCHITECTURE, &arch, @sizeOf(@TypeOf(arch)));

        var options16: d3d12.FEATURE_DATA_OPTIONS16 = undefined;
        _ = device.checkFeatureSupport(.OPTIONS16, &options16, @sizeOf(@TypeOf(options16)));

        // create command queue
        const queue_desc = d3d12.COMMAND_QUEUE_DESC{
            .Flags = .{},
            .Type = .DIRECT,
            .NodeMask = 0,
            .Priority = 0,
        };
        var command_queue: *d3d12.ICommandQueue = undefined;
        _ = device.createCommandQueue(&queue_desc, &d3d12.ICommandQueue.IID, @ptrCast(&command_queue));

        // create indirect command signatures
        var command_signature_desc = std.mem.zeroes(d3d12.COMMAND_SIGNATURE_DESC);
        var indirect_argument_desc = std.mem.zeroes(d3d12.INDIRECT_ARGUMENT_DESC);

        indirect_argument_desc.Type = .DRAW;
        command_signature_desc.NodeMask = 0;
        command_signature_desc.ByteStride = @sizeOf(IndirectDrawCommand);
        command_signature_desc.NumArgumentDescs = 1;
        command_signature_desc.pArgumentDescs = &indirect_argument_desc;

        var indirect_draw_command_signature: *d3d12.ICommandSignature = undefined;
        _ = device.createCommandSignature(&command_signature_desc, null, &d3d12.ICommandSignature.IID, @ptrCast(&indirect_draw_command_signature));

        indirect_argument_desc.Type = .DRAW_INDEXED;
        command_signature_desc.ByteStride = @sizeOf(IndexedIndirectDrawCommand);
        command_signature_desc.pArgumentDescs = &indirect_argument_desc;

        var indirect_indexed_draw_command_signature: *d3d12.ICommandSignature = undefined;
        _ = device.createCommandSignature(&command_signature_desc, null, &d3d12.ICommandSignature.IID, @ptrCast(&indirect_indexed_draw_command_signature));

        indirect_argument_desc.Type = .DISPATCH;
        command_signature_desc.ByteStride = @sizeOf(IndirectDispatchCommand);
        command_signature_desc.pArgumentDescs = &indirect_argument_desc;

        var indirect_dispatch_command_signature: *d3d12.ICommandSignature = undefined;
        _ = device.createCommandSignature(&command_signature_desc, null, &d3d12.ICommandSignature.IID, @ptrCast(&indirect_dispatch_command_signature));

        // initialize staging descriptor pools
        // TODO

        // initialize GPU descriptor heaps
        // TODO

        const self = try allocator.create(D3D12Device);
        self.* = .{
            .factory = factory,
            .adapter = adapter,
            .device = device,
            .command_queue = command_queue,
            .indirect_draw_command_signature = indirect_draw_command_signature,
            .indirect_indexed_draw_command_signature = indirect_indexed_draw_command_signature,
            .indirect_dispatch_command_signature = indirect_dispatch_command_signature,
            .available_command_buffers = try .initCapacity(allocator, 4),
            .submitted_command_buffers = try .initCapacity(allocator, 4),
            .uniform_buffer_pool = try .initCapacity(allocator, 4),
            .claimed_windows = try .initCapacity(allocator, 4),
            .available_fences = try .initCapacity(allocator, 4),
            .buffers_to_destroy = try .initCapacity(allocator, 4),
            .textures_to_destroy = try .initCapacity(allocator, 4),
            .samplers_to_destroy = try .initCapacity(allocator, 4),
            .graphics_pipelines_to_destroy = try .initCapacity(allocator, 4),
            .compute_pipelines_to_destroy = try .initCapacity(allocator, 4),
        };

        return self;
    }

    // vtable implementation
    // ---------------------

    fn destroy(self: *D3D12Device) void {
        _ = self; // autofix
        log.warn("TODO destroy d3d12 device", .{});
    }

    fn acquireCommandBuffer(self: *D3D12Device) !*gpu.CommandBuffer {
        const buffer = blk: {
            self.acquire_command_buffer_lock.lock();
            defer self.acquire_command_buffer_lock.unlock();

            if (self.available_command_buffers.items.len == 0) {
                try D3D12CommandBuffer.allocate(self);
            }

            break :blk self.available_command_buffers.pop().?;
        };
        _ = buffer; // autofix

        unreachable;
    }
};

pub const D3D12CommandBuffer = struct {
    header: internal.CommandBufferHeader,

    fn allocate(device: *D3D12Device) !void {
        device.device.createCommandAllocator();
        device.device.createCommandList();

        unreachable;
    }

    fn getHeader(buffer: *gpu.CommandBuffer) *internal.CommandBufferHeader {
        const d3d12_buffer: *D3D12CommandBuffer = @ptrCast(buffer);
        return &d3d12_buffer.header;
    }
};
