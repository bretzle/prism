const std = @import("std");
const gpu = @import("../newgpu/gpu.zig");
const prism = @import("../prism.zig");
const w32 = @import("w32");

const Application = prism.Application;
const EventQueue = std.fifo.LinearFifo(prism.Event, .Dynamic);

const allocator = prism.allocator;
const class_name = std.unicode.utf8ToUtf16LeStringLiteral("prism");
const style_ex = 0;

pub const Window = struct {
    hwnd: w32.HWND,
    events: EventQueue,

    width: u32,
    height: u32,

    instance: *gpu.Instance,
    surface: *gpu.Surface,
    adapter: *gpu.Adapter,
    device: *gpu.Device,
    swapchain: *gpu.Swapchain,
    // queue: *gpu.Queue,

    pub fn create(_: *Application, desc: prism.Window.Descriptor) !*Window {
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
            .lpszClassName = class_name,
            .hIconSm = null,
        };

        _ = w32.RegisterClassExW(&wnd_class);

        const title = try std.unicode.utf8ToUtf16LeAllocZ(allocator, desc.title);
        defer allocator.free(title);

        const style = w32.WS_OVERLAPPEDWINDOW;

        const hwnd = w32.CreateWindowExW(
            style_ex,
            class_name,
            title,
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

        updateWindowSize(dpi, style, hwnd, .{ .cx = @intCast(desc.width), .cy = @intCast(desc.height) });

        _ = w32.ShowWindow(hwnd, w32.SW_SHOW);

        const instance = try gpu.Instance.create();
        const surface = try instance.createSurface(.{ .windows = hwnd });
        const adapter = try instance.createAdapter(.{ .surface = surface, .power_preference = .performance });
        const device = try adapter.createDevice();
        // const queue = try device.getQueue();

        const size = getClientSize(hwnd);
        const swapchain_desc = gpu.Swapchain.Descriptor{
            .usage = .{ .render_attachment = true },
            .format = .bgra8_unorm,
            .width = size[0],
            .height = size[1],
            .present_mode = .fifo,
        };
        const swapchain = try device.createSwapchain(surface, swapchain_desc);

        const self = try allocator.create(Window);
        self.* = .{
            .hwnd = hwnd,
            .events = .init(allocator),
            .width = size[0],
            .height = size[1],
            .instance = instance,
            .surface = surface,
            .adapter = adapter,
            .device = device,
            .swapchain = swapchain,
        };

        _ = w32.SetWindowLongPtrW(hwnd, w32.GWLP_USERDATA, @intFromPtr(self));

        return self;
    }

    pub fn getEvents(self: *Window) []const prism.Event {
        var msg: w32.MSG = undefined;
        while (w32.PeekMessageW(&msg, self.hwnd, 0, 0, w32.PM_REMOVE) != 0) {
            _ = w32.TranslateMessage(&msg);
            _ = w32.DispatchMessageW(&msg);
        }

        return self.events.readableSlice(0);
    }

    pub fn presentFrame(self: *Window) void {
        self.events.discard(self.events.readableLength());
        // self.device.tick() catch unreachable;
        self.swapchain.present() catch unreachable;
    }

    fn processEvent(self: *Window, msg: u32, wparam: w32.WPARAM, lparam: w32.LPARAM) !w32.LRESULT {
        switch (msg) {
            w32.WM_CLOSE => try self.pushEvent(.close),
            w32.WM_SIZE => {
                // TODO this does not handle DPI correctly
                const size = getClientSize(self.hwnd);
                self.width = size[0];
                self.height = size[1];

                try self.swapchain.resize(size[0], size[1]);
                try self.pushEvent(.{ .size = size });
            },
            w32.WM_KEYDOWN, w32.WM_KEYUP, w32.WM_SYSKEYDOWN, w32.WM_SYSKEYUP => blk: {
                const vkey: w32.VIRTUAL_KEY = @enumFromInt(wparam);
                if (vkey == .PROCESSKEY) break :blk;

                if (msg == w32.WM_SYSKEYDOWN and vkey == .F4) {
                    break :blk try self.pushEvent(.close);
                }

                const KeyFlags = packed struct(u32) {
                    repeat_count: u16,
                    scancode: u8,
                    extended: u1,
                    reserved: u4,
                    context: bool,
                    previous: bool,
                    transition: bool,
                };

                const flags: KeyFlags = @bitCast(@as(u32, @truncate(@as(usize, @bitCast(lparam)))));
                const scancode: u9 = flags.scancode | (@as(u9, flags.extended) << 8);

                const event = prism.KeyEvent{
                    .key = keyFromScancode(scancode),
                    .mods = getKeyboardMods(),
                };

                if (msg == w32.WM_KEYDOWN or msg == w32.WM_SYSKEYDOWN)
                    if (flags.previous)
                        try self.pushEvent(.{ .key_repeat = event })
                    else
                        try self.pushEvent(.{ .key_press = event })
                else
                    try self.pushEvent(.{ .key_release = event });
            },
            w32.WM_LBUTTONDOWN, w32.WM_LBUTTONUP, w32.WM_RBUTTONDOWN, w32.WM_RBUTTONUP, w32.WM_MBUTTONDOWN, w32.WM_MBUTTONUP, w32.WM_XBUTTONDOWN, w32.WM_XBUTTONUP => {
                const mods = getKeyboardMods();
                const point = w32.pointFromLparam(lparam);

                const MouseFlags = packed struct(u8) {
                    left_down: bool,
                    right_down: bool,
                    shift_down: bool,
                    control_down: bool,
                    middle_down: bool,
                    xbutton1_down: bool,
                    xbutton2_down: bool,
                    _: u1,
                };

                const flags: MouseFlags = @bitCast(@as(u8, @truncate(wparam)));
                const button: prism.MouseButton = switch (msg) {
                    w32.WM_LBUTTONDOWN, w32.WM_LBUTTONUP => .left,
                    w32.WM_RBUTTONDOWN, w32.WM_RBUTTONUP => .right,
                    w32.WM_MBUTTONDOWN, w32.WM_MBUTTONUP => .middle,
                    else => if (flags.xbutton1_down) .four else .five,
                };

                const event = prism.MouseButtonEvent{
                    .button = button,
                    .mods = mods,
                    .pos = .fromInt(point.x, point.y),
                };

                switch (msg) {
                    w32.WM_LBUTTONDOWN, w32.WM_RBUTTONDOWN, w32.WM_MBUTTONDOWN, w32.WM_XBUTTONDOWN => try self.pushEvent(.{ .mouse_press = event }),
                    else => try self.pushEvent(.{ .mouse_release = event }),
                }

                if (msg == w32.WM_XBUTTONDOWN or msg == w32.WM_XBUTTONUP) return 1;
            },
            w32.WM_MOUSEMOVE => {
                const point = w32.pointFromLparam(lparam);
                try self.pushEvent(.{ .mouse_motion = .fromInt(point.x, point.y) });
            },
            w32.WM_MOUSEWHEEL => {
                const WHEEL_DELTA = 120.0;
                const wheel_high_word: u16 = @truncate((wparam >> 16) & 0xffff);
                const delta_y: f32 = @as(f32, @floatFromInt(@as(i16, @bitCast(wheel_high_word)))) / WHEEL_DELTA;

                try self.pushEvent(.{ .mouse_scroll = .create(0, delta_y) });
            },
            w32.WM_MOUSEHWHEEL => {
                // TODO
            },
            w32.WM_SETFOCUS => {
                try self.pushEvent(.focus_gained);
            },
            w32.WM_KILLFOCUS => {
                try self.pushEvent(.focus_lost);
            },
            else => return w32.DefWindowProcW(self.hwnd, msg, wparam, lparam),
        }

        return 0;
    }

    fn pushEvent(self: *Window, event: prism.Event) !void {
        try self.events.writeItem(event);
    }
};

fn wndProcCallback(hwnd: w32.HWND, msg: u32, wparam: w32.WPARAM, lparam: w32.LPARAM) callconv(.winapi) w32.LRESULT {
    const ptr: ?*Window = @ptrFromInt(w32.GetWindowLongPtrW(hwnd, w32.GWLP_USERDATA));
    if (ptr) |window| {
        return window.processEvent(msg, wparam, lparam) catch unreachable;
    }

    return w32.DefWindowProcW(hwnd, msg, wparam, lparam);
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

    // std.log.debug(
    //     "primary monitor work topleft={},{} size={}x{}",
    //     .{ work_rect.left, work_rect.top, work_size.cx, work_size.cy },
    // );

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

fn keyFromScancode(scancode: u9) prism.Key {
    const table: [0x15D]prism.Key = comptime blk: {
        var raw: [0x15D]prism.Key = undefined;

        for (&raw, 1..) |*ptr, i| ptr.* = switch (i) {
            0x1 => .escape,
            0x2 => .one,
            0x3 => .two,
            0x4 => .three,
            0x5 => .four,
            0x6 => .five,
            0x7 => .six,
            0x8 => .seven,
            0x9 => .eight,
            0xA => .nine,
            0xB => .zero,
            0xC => .minus,
            0xD => .equal,
            0xE => .backspace,
            0xF => .tab,
            0x10 => .q,
            0x11 => .w,
            0x12 => .e,
            0x13 => .r,
            0x14 => .t,
            0x15 => .y,
            0x16 => .u,
            0x17 => .i,
            0x18 => .o,
            0x19 => .p,
            0x1A => .left_bracket,
            0x1B => .right_bracket,
            0x1C => .enter,
            0x1D => .left_control,
            0x1E => .a,
            0x1F => .s,
            0x20 => .d,
            0x21 => .f,
            0x22 => .g,
            0x23 => .h,
            0x24 => .j,
            0x25 => .k,
            0x26 => .l,
            0x27 => .semicolon,
            0x28 => .apostrophe,
            0x29 => .grave,
            0x2A => .left_shift,
            0x2B => .backslash,
            0x2C => .z,
            0x2D => .x,
            0x2E => .c,
            0x2F => .v,
            0x30 => .b,
            0x31 => .n,
            0x32 => .m,
            0x33 => .comma,
            0x34 => .period,
            0x35 => .slash,
            0x36 => .right_shift,
            0x37 => .kp_multiply,
            0x38 => .left_alt,
            0x39 => .space,
            0x3A => .caps_lock,
            0x3B => .f1,
            0x3C => .f2,
            0x3D => .f3,
            0x3E => .f4,
            0x3F => .f5,
            0x40 => .f6,
            0x41 => .f7,
            0x42 => .f8,
            0x43 => .f9,
            0x44 => .f10,
            0x45 => .pause,
            0x46 => .scroll_lock,
            0x47 => .kp_7,
            0x48 => .kp_8,
            0x49 => .kp_9,
            0x4A => .kp_subtract,
            0x4B => .kp_4,
            0x4C => .kp_5,
            0x4D => .kp_6,
            0x4E => .kp_add,
            0x4F => .kp_1,
            0x50 => .kp_2,
            0x51 => .kp_3,
            0x52 => .kp_0,
            0x53 => .kp_decimal,
            0x54 => .print, // sysrq
            0x56 => .iso_backslash,
            //0x56 => .europe2,
            0x57 => .f11,
            0x58 => .f12,
            0x59 => .kp_equal,
            0x5B => .left_super, // sent by touchpad gestures
            //0x5C => .international6,
            0x64 => .f13,
            0x65 => .f14,
            0x66 => .f15,
            0x67 => .f16,
            0x68 => .f17,
            0x69 => .f18,
            0x6A => .f19,
            0x6B => .f20,
            0x6C => .f21,
            0x6D => .f22,
            0x6E => .f23,
            0x70 => .international2,
            0x73 => .international1,
            0x76 => .f24,
            //0x77 => .lang4,
            //0x78 => .lang3,
            0x79 => .international4,
            0x7B => .international5,
            0x7D => .international3,
            0x7E => .kp_comma,
            0x11C => .kp_enter,
            0x11D => .right_control,
            0x135 => .kp_divide,
            0x136 => .right_shift, // sent by IME
            0x137 => .print,
            0x138 => .right_alt,
            0x145 => .num_lock,
            0x146 => .pause,
            0x147 => .home,
            0x148 => .up,
            0x149 => .page_up,
            0x14B => .left,
            0x14D => .right,
            0x14F => .end,
            0x150 => .down,
            0x151 => .page_down,
            0x152 => .insert,
            0x153 => .delete,
            0x15B => .left_super,
            0x15C => .right_super,
            0x15D => .menu,
            else => .unknown,
        };

        break :blk raw;
    };

    return if (scancode > 0 and scancode <= table.len) table[scancode - 1] else .unknown;
}

fn getKeyboardMods() prism.KeyMods {
    return .{
        .shift = w32.GetKeyState(w32.VK_SHIFT) < 0,
        .control = w32.GetKeyState(w32.VK_CONTROL) < 0,
        .alt = w32.GetKeyState(w32.VK_MENU) < 0,
        .super = w32.GetKeyState(w32.VK_LWIN) < 0 or w32.GetKeyState(w32.VK_RWIN) < 0,
        .caps_lock = w32.GetKeyState(w32.VK_CAPITAL) & 1 == 1,
        .num_lock = w32.GetKeyState(w32.VK_NUMLOCK) & 1 == 1,
    };
}
