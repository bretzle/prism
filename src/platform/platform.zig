const std = @import("std");
const builtin = @import("builtin");
const prism = @import("../prism.zig");

const platform = switch (builtin.target.os.tag) {
    .windows => @import("win32.zig"),
    else => if (builtin.target.cpu.arch.isWasm())
        unreachable
    else
        unreachable,
};

const allocator = prism.allocator;

pub const Context = struct {
    ptr: *anyopaque,
    vtable: struct {
        destroy: *const fn (*anyopaque) void,
        create_window: *const fn (*anyopaque, title: []const u8, width: u32, height: u32) anyerror!Window,
    },

    pub fn create() !*Context {
        const ctx = try allocator.create(Context);
        errdefer ctx.destroy();
        ctx.* = try platform.Context.create();
        return ctx;
    }

    pub fn destroy(self: *Context) void {
        (self.vtable.destroy)(self.ptr);
    }

    pub fn createWindow(self: *Context, title: []const u8, width: u32, height: u32) !*Window {
        const window = try allocator.create(Window);
        errdefer allocator.destroy(window);
        window.* = try (self.vtable.create_window)(self.ptr, title, width, height);
        return window;
    }
};

pub const Window = struct {
    ptr: *anyopaque,
    vtable: struct {
        destroy: *const fn (*anyopaque) void,
        get_events: *const fn (*anyopaque) anyerror![]const Event,
    },

    pub fn destroy(self: *Window) void {
        (self.vtable.destroy)(self.ptr);
        allocator.destroy(self);
    }

    pub fn getEvents(self: *Window) ![]const Event {
        return try (self.vtable.get_events)(self.ptr);
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
