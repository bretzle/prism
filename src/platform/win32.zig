const std = @import("std");
const builtin = @import("builtin");
const prism = @import("../prism.zig");
const w32 = @import("w32");
const util = @import("../util.zig");
const gpu = @import("../gpu/gpu.zig");

const allocator = prism.allocator;
const window_class_name = std.unicode.utf8ToUtf16LeStringLiteral("prism");
const style_ex = 0; // w32.WS_EX_APPWINDOW | w32.WS_EX_NOREDIRECTIONBITMAP;

const EventList = std.ArrayListUnmanaged(prism.Event);

var __app: *prism.Application = undefined;
var __event_level: u32 = 0;

pub const Window = struct {
    hwnd: w32.HWND,
    events: [2]EventList = .{ .empty, .empty },
    front: *EventList = undefined,
    back: *EventList = undefined,

    pub fn create(app: *prism.Application, options: prism.WindowOptions) !struct { Window, [2]u32, gpu.Surface.Descriptor } {
        __app = app;

        const hinstance: w32.HINSTANCE = @ptrCast(w32.GetModuleHandleW(null) orelse return error.NoInstance);
        const wnd_class = w32.WNDCLASSEXW{
            .style = 0,
            .lpfnWndProc = &wndProcCallback,
            .cbClsExtra = 0,
            .cbWndExtra = 0,
            .hInstance = hinstance,
            .hIcon = null,
            .hCursor = w32.LoadCursorW(null, w32.IDC_ARROW),
            .hbrBackground = null,
            .lpszMenuName = null,
            .lpszClassName = window_class_name,
            .hIconSm = null,
        };

        _ = w32.RegisterClassExW(&wnd_class);

        const title16 = try std.unicode.utf8ToUtf16LeAllocZ(allocator, options.title);
        defer allocator.free(title16);

        const style = w32.WS_OVERLAPPEDWINDOW;

        const hwnd = w32.CreateWindowExW(
            style_ex,
            window_class_name,
            title16,
            style,
            w32.CW_USEDEFAULT,
            w32.CW_USEDEFAULT,
            w32.CW_USEDEFAULT,
            w32.CW_USEDEFAULT,
            null,
            null,
            hinstance,
            null,
        ) orelse return error.Unexpected;

        const dpi = w32.GetDpiForWindow(hwnd);

        updateWindowSize(dpi, style, hwnd, .{ .cx = @intCast(options.width), .cy = @intCast(options.height) });

        const size = getClientSize(hwnd);

        _ = w32.ShowWindow(hwnd, w32.SW_SHOW);

        const surface_desc = gpu.Surface.Descriptor{
            .data = .{
                .windows_hwnd = .{
                    .hinstance = hinstance,
                    .hwnd = hwnd,
                },
            },
        };

        return .{ .{ .hwnd = hwnd }, size, surface_desc };
    }

    pub fn getEvents(self: *Window) []const prism.Event {
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

    fn processEvent(self: *Window, msg: u32, wparam: w32.WPARAM, lparam: w32.LPARAM) !w32.LRESULT {
        if (false) {
            var buf = [_]u8{0} ** 6;
            for (0..__event_level) |_| std.debug.print("  ", .{});
            std.debug.print("{s}\n", .{w32.msgToStr(msg, &buf)});
            __event_level += 1;
            defer __event_level -= 1;
        }

        switch (msg) {
            w32.WM_CLOSE => try self.pushEvent(.window_close),
            else => return w32.DefWindowProcW(self.hwnd, msg, wparam, lparam),
        }

        return 0;
    }

    inline fn pushEvent(self: *Window, event: prism.Event) !void {
        try self.back.append(allocator, event);
    }
};

fn wndProcCallback(hwnd: w32.HWND, msg: u32, wparam: w32.WPARAM, lparam: w32.LPARAM) callconv(.winapi) w32.LRESULT {
    const window = blk: {
        for (__app.windows.items) |window| {
            if (window.native.hwnd == hwnd) break :blk window;
        } else return w32.DefWindowProcW(hwnd, msg, wparam, lparam);
    };

    return window.native.processEvent(msg, wparam, lparam) catch |err| {
        std.debug.panic("error while handling event: {}", .{err});
    };
}

fn updateWindowSize(dpi: u32, window_style: w32.DWORD, hwnd: w32.HWND, requested_client_size: w32.SIZE) void {
    const monitor = blk: {
        var rect: w32.RECT = undefined;
        _ = w32.GetWindowRect(hwnd, &rect);
        break :blk w32.MonitorFromPoint(.{ .x = rect.left, .y = rect.top }, w32.MONITOR_DEFAULTTONULL).?;
    };

    const work_rect: w32.RECT = blk: {
        var info: w32.MONITORINFO = undefined;
        info.cbSize = @sizeOf(w32.MONITORINFO);
        _ = w32.GetMonitorInfoW(monitor, &info);
        break :blk info.rcWork;
    };

    const work_size: w32.SIZE = .{ .cx = work_rect.right - work_rect.left, .cy = work_rect.bottom - work_rect.top };

    std.log.debug(
        "primary monitor work topleft={},{} size={}x{}",
        .{ work_rect.left, work_rect.top, work_size.cx, work_size.cy },
    );

    const wanted_size: w32.SIZE = blk: {
        var rect: w32.RECT = .{ .left = 0, .top = 0, .right = requested_client_size.cx, .bottom = requested_client_size.cy };
        _ = w32.AdjustWindowRectExForDpi(&rect, window_style, 0, style_ex, dpi);
        break :blk .{
            .cx = rect.right - rect.left,
            .cy = rect.bottom - rect.top,
        };
    };

    const window_size: w32.SIZE = .{
        .cx = @min(wanted_size.cx, work_size.cx),
        .cy = @min(wanted_size.cy, work_size.cy),
    };

    _ = w32.SetWindowPos(
        hwnd,
        null,
        work_rect.left + @divTrunc(work_size.cx - window_size.cx, 2),
        work_rect.top + @divTrunc(work_size.cy - window_size.cy, 2),
        window_size.cx,
        window_size.cy,
        w32.SWP_NOZORDER,
    );
}

fn getClientSize(hwnd: w32.HWND) [2]u32 {
    var rect: w32.RECT = undefined;
    _ = w32.GetClientRect(hwnd, &rect);
    std.debug.assert(rect.left == 0);
    std.debug.assert(rect.top == 0);
    return .{ @intCast(rect.right), @intCast(rect.bottom) };
}
