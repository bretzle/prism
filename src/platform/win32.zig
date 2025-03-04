const std = @import("std");
const w32 = @import("../zwindows/windows.zig");
const gfx = @import("../gfx.zig");
const prism = @import("../prism.zig");
const math = @import("../math.zig");

pub fn Application(comptime ParentApp: type, comptime T: type) type {
    _ = T; // autofix
    return struct {
        const Self = @This();
        const class_name = @typeName(Self);

        hwnd: w32.HWND,
        renderer: *gfx.Renderer,

        pub fn init(self: *Self) !void {
            const parent = self.getParent();

            const instance = w32.GetModuleHandleA(null).?;
            const class = w32.WNDCLASSEXA{
                .cbWndExtra = 8,
                .lpfnWndProc = windowProc,
                .hInstance = @ptrCast(instance),
                .lpszClassName = class_name,
            };

            if (w32.RegisterClassExA(&class) == 0) unreachable;

            const style = w32.WS_OVERLAPPEDWINDOW;
            const size = clientToWindow(parent.config.size, style);
            const hwnd = w32.CreateWindowExA(
                0,
                class_name,
                parent.config.name,
                style,
                w32.CW_USEDEFAULT,
                w32.CW_USEDEFAULT,
                size[0],
                size[1],
                null,
                null,
                @ptrCast(w32.GetModuleHandleA(null)),
                parent,
            ) orelse unreachable;

            _ = w32.DwmSetWindowAttribute(hwnd, w32.DWMWA_USE_IMMERSIVE_DARK_MODE, &@as(i32, 1), @sizeOf(i32));
            _ = w32.DwmSetWindowAttribute(hwnd, w32.DWMWA_WINDOW_CORNER_PREFERENCE, &@as(i32, 3), @sizeOf(i32));
            _ = w32.SetWindowLongPtrA(hwnd, w32.GWLP_USERDATA, parent);

            self.* = .{
                .hwnd = hwnd,
                .renderer = try .create(parent.allocator, .{ .x = 800, .y = 600 }, hwnd),
            };
        }

        pub fn ready(self: *Self) void {
            _ = w32.ShowWindow(self.hwnd, w32.SW_RESTORE);
        }

        pub fn step(_: *Self) void {
            var msg: w32.MSG = undefined;
            while (w32.PeekMessageA(&msg, null, 0, 0, w32.PM_REMOVE) != 0) {
                _ = w32.TranslateMessage(&msg);
                _ = w32.DispatchMessageA(&msg);
            }
        }

        pub fn getSize(self: *const Self) math.Point {
            var rect = w32.RECT{};
            _ = w32.GetWindowRect(self.hwnd, &rect);
            return .{ .x = rect.right - rect.left, .y = rect.bottom - rect.top };
        }

        inline fn getParent(self: *Self) *ParentApp {
            return @fieldParentPtr("impl", self);
        }

        fn windowProc(hwnd: w32.HWND, msg: u32, wparam: w32.WPARAM, lparam: w32.LPARAM) callconv(.c) w32.LRESULT {
            const ptr = w32.GetWindowLongPtrA(hwnd, w32.GWLP_USERDATA) orelse return w32.DefWindowProcA(hwnd, msg, wparam, lparam);
            const parent: *ParentApp = @alignCast(@ptrCast(ptr));
            const self: *Self = &parent.impl;
            _ = self; // autofix

            switch (msg) {
                w32.WM_DESTROY => w32.PostQuitMessage(0),
                w32.WM_CLOSE => parent.exit(),
                else => return w32.DefWindowProcA(hwnd, msg, wparam, lparam),
            }

            return 0;
        }

        fn clientToWindow(size: [2]i32, style: u32) [2]i32 {
            var rect = w32.RECT{ .right = size[0], .bottom = size[1] };
            _ = w32.AdjustWindowRectEx(&rect, style, 0, 0);
            return [2]i32{ rect.right - rect.left, rect.bottom - rect.top };
        }
    };
}
