const std = @import("std");
const builtin = @import("builtin");
const prism = @import("../prism.zig");
const platform = @import("platform.zig");
const w32 = @import("w32");
const util = @import("../util.zig");

const allocator = prism.allocator;
const window_class_name = std.unicode.utf8ToUtf16LeStringLiteral("prism");

var __context: *Context = undefined;
var __event_level: u32 = 0;

pub const Context = struct {
    hinstance: w32.HINSTANCE,
    windows: std.ArrayListUnmanaged(*Window),

    pub fn create() !platform.Context {
        const self = try allocator.create(Context);
        errdefer allocator.destroy(self);

        const hinstance: w32.HINSTANCE = @ptrCast(w32.GetModuleHandleW(null) orelse return error.NoInstance);
        const wnd_class = w32.WNDCLASSEXW{
            .style = 0,
            .lpfnWndProc = &wndProcCallback,
            .cbClsExtra = 0,
            .cbWndExtra = 0,
            .hInstance = hinstance,
            .hIcon = null,
            .hCursor = @ptrCast(w32.LoadImageW(null, w32.IDC_ARROW, w32.IMAGE_CURSOR, 0, 0, w32.LR_DEFAULTSIZE | w32.LR_SHARED)),
            .hbrBackground = null,
            .lpszMenuName = null,
            .lpszClassName = window_class_name,
            .hIconSm = null,
        };

        _ = w32.RegisterClassExW(&wnd_class);
        errdefer _ = w32.UnregisterClassW(window_class_name, hinstance);

        self.* = .{
            .hinstance = hinstance,
            .windows = .empty,
        };

        __context = self;

        return platform.Context{
            .ptr = self,
            .vtable = .{
                .destroy = util.vcast(Context.destroy),
                .create_window = util.vcast(Context.createWindow),
            },
        };
    }

    pub fn destroy(self: *Context) void {
        std.debug.assert(self.windows.items.len == 0);
        _ = w32.UnregisterClassW(window_class_name, self.hinstance);
        self.windows.deinit(allocator);
    }

    fn createWindow(self: *Context, title: []const u8, width: u32, height: u32) anyerror!platform.Window {
        return try Window.create(self, title, width, height);
    }
};

pub const Window = struct {
    const EventList = std.ArrayListUnmanaged(platform.Event);

    ctx: *Context,
    width: u32,
    height: u32,
    title: []const u8,
    hwnd: w32.HWND,

    events: [2]EventList,
    front: *EventList,
    back: *EventList,

    fn create(ctx: *Context, title: []const u8, width: u32, height: u32) !platform.Window {
        const self = try allocator.create(Window);
        errdefer allocator.destroy(self);

        var rect = w32.RECT{ .left = 0, .top = 0, .right = @intCast(width), .bottom = @intCast(height) };
        _ = w32.AdjustWindowRectEx(&rect, w32.WS_OVERLAPPEDWINDOW, 0, 0);

        const title16 = try std.unicode.utf8ToUtf16LeAllocZ(allocator, title);
        defer allocator.free(title16);

        const hwnd = w32.CreateWindowExW(
            0,
            window_class_name,
            title16,
            w32.WS_OVERLAPPEDWINDOW,
            w32.CW_USEDEFAULT,
            w32.CW_USEDEFAULT,
            @intCast(rect.right - rect.left),
            @intCast(rect.bottom - rect.top),
            null,
            null,
            ctx.hinstance,
            null,
        ) orelse return error.CreateWindowFailed;
        errdefer _ = w32.DestroyWindow(hwnd);

        try ctx.windows.append(allocator, self);
        self.* = .{
            .ctx = ctx,
            .width = width,
            .height = height,
            .title = title,
            .hwnd = hwnd,
            .events = .{ .empty, .empty },
            .front = &self.events[0],
            .back = &self.events[1],
        };

        _ = w32.ShowWindow(hwnd, w32.SW_NORMAL);

        return platform.Window{
            .ptr = self,
            .vtable = .{
                .destroy = util.vcast(Window.destroy),
                .get_events = util.vcast(Window.getEvents),
            },
        };
    }

    // vtable implementations
    // ----------------------

    fn destroy(self: *Window) void {
        for (self.ctx.windows.items, 0..) |window, i| {
            if (window == self) {
                _ = self.ctx.windows.swapRemove(i);
                break;
            }
        } else unreachable;

        _ = w32.DestroyWindow(self.hwnd);
        allocator.destroy(self);
    }

    fn getEvents(self: *Window) anyerror![]const platform.Event {
        var msg: w32.MSG = undefined;
        while (w32.PeekMessageW(&msg, self.hwnd, 0, 0, w32.PM_REMOVE) != 0) {
            _ = w32.TranslateMessage(&msg);
            _ = w32.DispatchMessageW(&msg);
        }

        const back = self.back;
        self.back = self.front;
        self.front = back;
        self.back.clearRetainingCapacity();

        return self.front.items;
    }

    // private implementations
    // -----------------------

    fn processEvent(self: *Window, msg: u32, wparam: w32.WPARAM, lparam: w32.LPARAM) !w32.LRESULT {
        if (builtin.mode == .Debug) {
            for (0..__event_level) |_| {
                std.debug.print("  ", .{});
            }
            var buf = [_]u8{0} ** 6;
            const msg_str = w32.msgToStr(msg, &buf);
            std.debug.print("{s}\n", .{msg_str});
            __event_level += 1;
            defer __event_level -= 1;
        }

        switch (msg) {
            w32.WM_CLOSE => try self.addEvent(.window_close),
            w32.WM_SIZE => {}, // TODO
            else => return w32.DefWindowProcW(self.hwnd, msg, wparam, lparam),
        }

        return 0;
    }

    inline fn addEvent(self: *Window, event: platform.Event) !void {
        try self.back.append(allocator, event);
    }
};

fn wndProcCallback(hwnd: w32.HWND, msg: u32, wparam: w32.WPARAM, lparam: w32.LPARAM) callconv(.winapi) w32.LRESULT {
    const window = blk: {
        for (__context.windows.items) |window| {
            if (window.hwnd == hwnd) break :blk window;
        } else return w32.DefWindowProcW(hwnd, msg, wparam, lparam);
    };

    return window.processEvent(msg, wparam, lparam) catch |err| {
        std.debug.panic("error while handling event: {}", .{err});
    };
}
