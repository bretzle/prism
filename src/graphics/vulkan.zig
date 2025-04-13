const std = @import("std");
const prism = @import("../prism.zig");
const backend = @import("backend.zig");
const platform = @import("../platform/platform.zig");
const util = @import("../util.zig");
const api = @import("vulkan/api.zig");

const allocator = prism.allocator;

pub const Backend = struct {
    instance: *api.Instance,
    surfaces: std.ArrayListUnmanaged(*api.Surface),

    pub fn create() !backend.Backend {
        const self = try allocator.create(Backend);
        errdefer allocator.destroy(self);
        self.* = .{
            .instance = try api.Instance.create(),
            .surfaces = .empty,
        };

        return backend.Backend{
            .ptr = self,
            .vtable = .{
                .destroy = util.vcast(Backend.destroy),
                .create_renderer = util.vcast(Backend.createRenderer),
            },
        };
    }

    // vtable implementations
    // ----------------------

    fn destroy(self: *Backend) void {
        _ = self; // autofix
        unreachable;
    }

    fn createRenderer(self: *Backend, window: *platform.Window) anyerror!backend.Renderer {
        const surface = try self.instance.createSurface(window);
        errdefer surface.destroy();

        try self.surfaces.append(allocator, surface);
        errdefer _ = self.surfaces.pop();

        const renderer = try Renderer.create(self.instance, window, surface);
        return backend.Renderer{
            .ptr = renderer,
            .vtable = .{
                .destroy = util.vcast(Renderer.destroy),
            },
        };
    }
};

pub const Renderer = struct {
    fn create(instance: *api.Instance, window: *platform.Window, surface: *api.Surface) !*Renderer {
        _ = window; // autofix
        const  device = try instance.createSuitableDevice(.efficient, surface, false, false);
        _ = device; // autofix
        unreachable;
    }

    // vtable implementations
    // ----------------------

    fn destroy(self: *Renderer) void {
        _ = self; // autofix
        unreachable;
    }
};
