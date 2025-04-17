const std = @import("std");
const builtin = @import("builtin");
const prism = @import("../prism.zig");
const backend = @import("backend.zig");
const platform = @import("../platform/platform.zig");
const windows = @import("../platform/win32.zig");
const util = @import("../util.zig");

const w32 = @import("w32");
const dxgi = w32.dxgi;
const d3d12 = w32.d3d12;

const allocator = prism.allocator;

// FIXME
const IndirectDrawCommand = [4]u32;
const IndexedIndirectDrawCommand = [5]u32;
const IndirectDispatchCommand = [3]u32;
const SwapchainComposition = enum { sdr };
const PresentMode = enum { vsync, immediate, mailbox };

pub const Backend = struct {
    factory: *dxgi.IFactory2,
    device: *d3d12.IDevice,
    command_queue: *d3d12.ICommandQueue,

    pub fn create() !backend.Backend {
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
        std.log.debug("gpu adapter: {s}", .{device_name});

        var driver_version_buf: [64]u8 = undefined;
        const driver_version = try std.fmt.bufPrint(&driver_version_buf, "{}.{}.{}.{}", .{
            w32.HIWORD(umd_version.HighPart),
            w32.LOWORD(umd_version.HighPart),
            w32.HIWORD(umd_version.LowPart),
            w32.LOWORD(umd_version.LowPart),
        });
        std.log.debug("gpu driver: {s}", .{driver_version});

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

        // initialize pools
        // TODO

        // initialize staging descriptor pools
        // TODO

        // initialize GPU descriptor heaps
        // TODO

        // deffered resource releasing
        // TODO

        const self = try allocator.create(Backend);
        self.* = .{
            .factory = factory,
            .device = device,
            .command_queue = command_queue,
        };

        return backend.Backend{
            .ptr = self,
            .vtable = .{
                .destroy = util.vcast(Backend.destroy),
                .create_device = util.vcast(Backend.createDevice),
            },
        };
    }

    // vtable implementations
    // ----------------------

    fn destroy(self: *Backend) void {
        _ = self; // autofix
        std.log.warn("TODO destroy d3d12 backend", .{});
    }

    fn createDevice(self: *Backend, window: *platform.Window) anyerror!backend.Device {
        const device = try Device.create(self, @alignCast(@ptrCast(window.ptr)));
        return backend.Device{
            .ptr = device,
            .vtable = .{
                .destroy = util.vcast(Device.destroy),
                .acquire_command_buffer = undefined,
            },
        };
    }
};

pub const Device = struct {
    parent: *Backend,
    window: *windows.Window,
    width: u32,
    height: u32,
    frame_counter: u32,

    swapchain: *dxgi.ISwapChain1,
    present_mode: PresentMode,
    swapchain_composition: SwapchainComposition,
    swapchain_color_space: void,

    fn create(parent: *Backend, window: *windows.Window) !*Device {
        const self = try allocator.create(Device);
        self.parent = parent;
        self.window = window;

        const composition = SwapchainComposition.sdr;
        self.swapchain = createSwapchain(parent, window.hwnd, composition);
        var swapchain_desc: dxgi.SWAP_CHAIN_DESC1 = undefined;
        _ = self.swapchain.getDesc1(&swapchain_desc);
        self.width = swapchain_desc.Width;
        self.height = swapchain_desc.Height;
        self.frame_counter = 0;

        self.present_mode = .vsync;
        self.swapchain_composition = composition;
        self.swapchain_color_space = {}; // FIXME

        // precahce blit pipelines for the swapchain format
        // TODO

        // initialize swapchain textures
        // TODO

        return self;
    }

    // vtable implementations
    // ----------------------

    fn destroy(self: *Device) void {
        _ = self; // autofix
        std.log.warn("TODO destroy d3d12 device", .{});
    }

    // private implementations
    // ----------------------

    fn createSwapchain(parent: *Backend, hwnd: w32.HWND, composition: SwapchainComposition) *dxgi.ISwapChain1 {
        const swapchainFormat = SwapchainCompositionToTextureFormat.getAssertContains(composition);

        var swapchain_desc = dxgi.SWAP_CHAIN_DESC1{
            .Width = 0,
            .Height = 0,
            .Format = swapchainFormat,
            .SampleDesc = .{ .Count = 1, .Quality = 0 },
            .BufferUsage = .{ .RENDER_TARGET_OUTPUT = true },
            .BufferCount = 2,
            .Scaling = .NONE,
            .SwapEffect = .FLIP_DISCARD,
            .AlphaMode = .UNSPECIFIED,
            .Flags = .{ .ALLOW_TEARING = true },
            .Stereo = 0,
        };

        var fullscreen_desc = dxgi.SWAP_CHAIN_FULLSCREEN_DESC{
            .RefreshRate = .{ .Numerator = 0, .Denominator = 0 },
            .ScanlineOrdering = .UNSPECIFIED,
            .Scaling = .UNSPECIFIED,
            .Windowed = 1,
        };

        var swapchain: *dxgi.ISwapChain1 = undefined;
        _ = parent.factory.createSwapChainForHwnd(@ptrCast(parent.command_queue), hwnd, &swapchain_desc, &fullscreen_desc, null, @ptrCast(&swapchain));

        if (composition != .sdr) {
            unreachable; // TODO
        }

        _ = parent.factory.makeWindowAssociation(hwnd, .{ .NO_WINDOW_CHANGES = true });

        return swapchain;
    }
};

const SwapchainCompositionToTextureFormat = std.EnumMap(SwapchainComposition, dxgi.FORMAT).init(.{
    .sdr = dxgi.FORMAT.B8G8R8A8_UNORM,
});
