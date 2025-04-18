const std = @import("std");
const builtin = @import("builtin");
const gpu = @import("gpu/gpu.zig");

const platform = switch (builtin.target.os.tag) {
    .windows => @import("platform/win32.zig"),
    else => unreachable,
};

pub var gpa = std.heap.GeneralPurposeAllocator(.{}){};
pub const allocator = gpa.allocator();

pub const Application = struct {
    windows: std.ArrayListUnmanaged(*Window),

    pub fn create() !Application {
        return .{
            .windows = .empty,
        };
    }

    pub fn deinit(self: *Application) void {
        _ = self; // autofix
        std.debug.print("TODO: deinit app\n", .{});
    }

    pub fn createWindow(self: *Application, options: WindowOptions) !*Window {
        const native, const size, const surface_desc = try platform.Window.create(self, options);

        const window = try allocator.create(Window);

        window.* = .{
            .title = options.title,
            .width = size[0],
            .height = size[1],
            .native = native,
        };

        window.native.front = &window.native.events[0];
        window.native.back = &window.native.events[1];

        window.instance = try gpu.Instance.create(.{});

        window.surface = try window.instance.createSurface(surface_desc);
        window.surface_descriptor = surface_desc;

        window.adapter = try window.instance.createAdapter(.{ .surface = window.surface, .power_preference = .efficent });

        const props = window.adapter.getProperties();
        std.log.info("found {s} backend on {s} adapter: {s}, {s}", .{
            @tagName(props.backend_type),
            @tagName(props.adapter_type),
            props.name,
            props.driver_description,
        });

        window.device = try window.adapter.createDevice(.{});
        window.queue = try window.device.getQueue();

        window.swap_chain_descriptor = .{
            .label = "main swap chain",
            .usage = .{ .render_attachment = true },
            .format = .bgra8_unorm,
            .width = window.width,
            .height = window.height,
            .present_mode = .fifo,
        };

        window.swap_chain = try window.device.createSwapchain(window.surface, window.swap_chain_descriptor);

        try self.windows.append(allocator, window);
        return window;
    }
};

pub const WindowOptions = struct {
    title: [:0]const u8 = "Example - 🎉",
    width: u32 = 800,
    height: u32 = 600,
};

pub const Window = struct {
    title: [:0]const u8,
    width: u32,
    height: u32,

    // gpu
    device: *gpu.Device = undefined,
    instance: *gpu.Instance = undefined,
    adapter: *gpu.Adapter = undefined,
    queue: *gpu.Queue = undefined,
    swap_chain: *gpu.SwapChain = undefined,
    swap_chain_descriptor: gpu.SwapChain.Descriptor = undefined,
    surface: *gpu.Surface = undefined,
    surface_descriptor: gpu.Surface.Descriptor = undefined,

    native: platform.Window,

    pub fn deinit(self: *Window) void {
        _ = self; // autofix
        std.debug.print("TODO: deinit window\n", .{});
    }

    pub fn getEvents(self: *Window) []const Event {
        return self.native.getEvents();
    }
};

pub const EventTag = enum {
    window_close,
    window_visible,
    window_hidden,
};

pub const Event = union(EventTag) {
    window_close,
    window_visible,
    window_hidden,
};
