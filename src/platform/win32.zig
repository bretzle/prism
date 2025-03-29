const std = @import("std");
const w32 = @import("w32");
const prism = @import("../prism.zig");
const math = @import("../math.zig");
const input = @import("../input.zig");

const Icon = prism.Icon;

pub fn Application(comptime ParentApp: type) type {
    return struct {
        const Self = @This();
        const class_name = "prism.zig";

        hwnd: w32.HWND,
        cursor: ?w32.HCURSOR,

        pub fn init(self: *Self) !void {
            const parent = self.getParent();
            const config: prism.Config = parent.config;

            const instance = w32.GetModuleHandleA(null).?;
            const class = w32.WNDCLASSEXA{
                .cbWndExtra = 8,
                .lpfnWndProc = windowProc,
                .hInstance = @ptrCast(instance),
                .hCursor = w32.LoadCursorA(null, w32.IDC_ARROW),
                .hIcon = w32.LoadIconA(null, w32.IDI_WINLOGO),
                .lpszClassName = class_name,
            };

            _ = w32.RegisterClassExA(&class);

            const ex_style = w32.WS_EX_APPWINDOW | w32.WS_EX_WINDOWEDGE;
            var style: u32 = w32.WS_OVERLAPPEDWINDOW;
            if (!config.resizable) style ^= w32.WS_THICKFRAME | w32.WS_MAXIMIZEBOX;
            const size = clientToWindow(config.size, style, ex_style);
            const hwnd = w32.CreateWindowExA(
                ex_style,
                class_name,
                config.title,
                style,
                w32.CW_USEDEFAULT,
                w32.SW_HIDE,
                size.x,
                size.y,
                null,
                null,
                @ptrCast(w32.GetModuleHandleA(null)),
                parent,
            ).?;

            if (config.fullscreen) {
                // TODO
            }

            if (config.enable_clipboard) {
                // TODO
            }

            if (config.enable_dragndrop) {
                // TODO
            }

            if (config.image) |image| {
                const icon = createIconFromImage(image);
                defer _ = w32.DestroyIcon(icon);
                _ = w32.SetClassLongPtrA(hwnd, w32.GCLP_HICON, @bitCast(@intFromPtr(icon)));
            }

            // set dark mode
            _ = w32.DwmSetWindowAttribute(hwnd, w32.DWMWA_USE_IMMERSIVE_DARK_MODE, &@as(i32, 1), @sizeOf(i32));
            _ = w32.DwmSetWindowAttribute(hwnd, w32.DWMWA_WINDOW_CORNER_PREFERENCE, &@as(i32, 3), @sizeOf(i32));

            _ = w32.SetWindowLongPtrA(hwnd, w32.GWLP_USERDATA, parent);

            self.* = .{
                .hwnd = hwnd,
                .cursor = class.hCursor,
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
            var rect: w32.RECT = undefined;
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

            switch (msg) {
                w32.WM_DESTROY => w32.PostQuitMessage(0),
                w32.WM_CLOSE => parent.exit(),
                w32.WM_SETCURSOR => {
                    if (w32.LOWORD(lparam) == w32.HTCLIENT) {
                        _ = w32.SetCursor(self.cursor);
                        return 1;
                    } else {
                        return w32.DefWindowProcA(hwnd, msg, wparam, lparam);
                    }
                },
                w32.WM_SIZE => parent.is_minimized = wparam == w32.SIZE_MINIMIZED,
                w32.WM_LBUTTONDOWN, w32.WM_LBUTTONUP, w32.WM_RBUTTONDOWN, w32.WM_RBUTTONUP, w32.WM_MBUTTONDOWN, w32.WM_MBUTTONUP => {
                    const button: input.MouseButton = switch (msg) {
                        w32.WM_LBUTTONDOWN, w32.WM_LBUTTONUP => .left,
                        w32.WM_RBUTTONDOWN, w32.WM_RBUTTONUP => .right,
                        w32.WM_MBUTTONDOWN, w32.WM_MBUTTONUP => .middle,
                        else => unreachable,
                    };

                    switch (msg) {
                        w32.WM_LBUTTONDOWN, w32.WM_RBUTTONDOWN, w32.WM_MBUTTONDOWN => parent.input.state.mouse.onPress(button),
                        w32.WM_LBUTTONUP, w32.WM_RBUTTONUP, w32.WM_MBUTTONUP => parent.input.state.mouse.onRelease(button),
                        else => unreachable,
                    }
                },
                w32.WM_MOUSEMOVE => {
                    parent.input.state.mouse.onMove(@floatFromInt(w32.LOWORD(lparam)), @floatFromInt(w32.HIWORD(lparam)));
                },
                else => return w32.DefWindowProcA(hwnd, msg, wparam, lparam),
            }

            return 0;
        }
    };
}

fn clientToWindow(size: math.Point, style: u32, ex_style: u32) math.Point {
    var rect = w32.RECT{ .left = 0, .top = 0, .right = size.x, .bottom = size.y };
    _ = w32.AdjustWindowRectEx(&rect, style, 0, ex_style);
    return .{ .x = rect.right - rect.left, .y = rect.bottom - rect.top };
}

fn createIconFromImage(desc: Icon) w32.HICON {
    const bi = w32.BITMAPV5HEADER{
        .bV5Width = desc.width,
        .bV5Height = -@as(i32, desc.height), // NOTE the '-' here to indicate that origin is top-left
        .bV5Planes = 1,
        .bV5BitCount = 32,
        .bV5Compression = w32.BI_BITFIELDS,
        .bV5RedMask = 0x00FF0000,
        .bV5GreenMask = 0x0000FF00,
        .bV5BlueMask = 0x000000FF,
        .bV5AlphaMask = 0xFF000000,
    };

    var target: [*c]u8 = null;

    const dc = w32.GetDC(null);
    defer _ = w32.ReleaseDC(null, dc);

    const color = w32.CreateDIBSection(dc, @ptrCast(&bi), w32.DIB_RGB_COLORS, &target, null, 0);
    defer _ = w32.DeleteObject(color);

    const mask = w32.CreateBitmap(desc.width, desc.height, 1, 1, null);
    defer _ = w32.DeleteObject(mask);

    @memcpy(target[0..desc.pixels.len], desc.pixels);

    var info = w32.ICONINFO{
        .fIcon = 1,
        .xHotspot = 0,
        .yHotspot = 0,
        .hbmMask = mask,
        .hbmColor = color,
    };

    return w32.CreateIconIndirect(&info).?;
}
