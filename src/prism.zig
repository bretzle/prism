const std = @import("std");
const gfx = @import("gfx.zig");

pub const math = @import("math.zig");
pub const Color = @import("Color.zig").Color;
pub const Batch = @import("Batch.zig");

pub const Flags = packed struct {
    fixed_timestamp: bool = false,
    vsync: bool = false,
    fullscreen: bool = false,
    resizable: bool = false,
    audio_enabled: bool = false,
};

pub const Config = struct {
    name: [:0]const u8 = "prism",
    size: [2]i32 = .{ 800, 600 },
    target_framerate: u32 = 60,
    audio_frequency: u32 = 44100,
    flags: Flags = .{ .vsync = true, .resizable = true, .fixed_timestamp = true, .audio_enabled = true },
};

const w32 = @import("zwindows/windows.zig");

pub fn Application(comptime T: type) type {
    return struct {
        const Self = @This();

        config: Config,
        userdata: T = undefined,
        allocator: std.mem.Allocator,
        hwnd: w32.HWND,

        renderer: *gfx.Renderer,

        pub fn create(allocator: std.mem.Allocator, config: Config) !*Self {
            comptime validate(T);

            const self = try allocator.create(Self);
            errdefer allocator.destroy(self);

            const instance = w32.GetModuleHandleA(null).?;
            const class = w32.WNDCLASSEXA{
                .cbWndExtra = 8,
                .lpfnWndProc = windowProc,
                .hInstance = @ptrCast(instance),
                .lpszClassName = "poop",
            };

            if (w32.RegisterClassExA(&class) == 0) unreachable;

            const style = w32.WS_OVERLAPPEDWINDOW;
            const size = clientToWindow(config.size, style);
            const hwnd = w32.CreateWindowExA(
                0,
                "poop",
                config.name,
                style,
                w32.CW_USEDEFAULT,
                w32.CW_USEDEFAULT,
                size[0],
                size[1],
                null,
                null,
                @ptrCast(w32.GetModuleHandleA(null)),
                self,
            ) orelse unreachable;

            _ = w32.SetWindowLongPtrA(hwnd, w32.GWLP_USERDATA, self);

            self.* = .{
                .config = config,
                .userdata = undefined,
                .allocator = allocator,
                .hwnd = hwnd,
                .renderer = try .create(allocator, .{ .x = 800, .y = 600 }, hwnd),
            };

            try self.userdata.init(self);

            return self;
        }

        pub fn run(self: *Self) void {
            _ = w32.ShowWindow(self.hwnd, w32.SW_RESTORE);

            while (true) {
                var msg: w32.MSG = undefined;
                while (w32.PeekMessageA(&msg, null, 0, 0, w32.PM_REMOVE) != 0) {
                    _ = w32.TranslateMessage(&msg);
                    _ = w32.DispatchMessageA(&msg);
                }

                self.renderer.update();

                self.renderer.beforeRender(self.getSize());
                self.userdata.render(self);
                self.renderer.afterRender();
            }
        }

        pub fn isRunning(_: *const Self) bool {
            unreachable;
        }

        pub fn exit(_: *const Self) void {
            unreachable;
        }

        pub fn path(_: *const Self) []const u8 {
            unreachable;
        }

        pub fn userPath(_: *const Self) []const u8 {
            unreachable;
        }

        pub fn getTitle(_: *const Self) []const u8 {
            unreachable;
        }

        pub fn setTitle(_: *const Self, _: []const u8) void {
            unreachable;
        }

        pub fn getPosition(_: *const Self) math.Point {
            unreachable;
        }

        pub fn setPosition(_: *const Self, _: math.Point) void {
            unreachable;
        }

        pub fn setSize(_: *const Self, _: math.Point) void {
            unreachable;
        }

        pub fn getSize(self: *const Self) math.Point {
            var rect = w32.RECT{};
            _ = w32.GetWindowRect(self.hwnd, &rect);
            return .{ .x = rect.right - rect.left, .y = rect.bottom - rect.top };
        }

        pub fn focused(_: *const Self) bool {
            unreachable;
        }

        var back = gfx.Target{ .is_backbuffer = true };
        pub fn backbuffer(_: *const Self) *gfx.Target {
            return &back;
        }

        fn windowProc(hwnd: w32.HWND, msg: u32, wparam: w32.WPARAM, lparam: w32.LPARAM) callconv(.c) w32.LRESULT {
            return w32.DefWindowProcA(hwnd, msg, wparam, lparam);
        }
    };
}

fn compileAssert(comptime cond: bool, comptime msg: []const u8) void {
    if (!cond) {
        @compileError(msg);
    }
}

fn validate(comptime T: type) void {
    compileAssert(std.meta.hasMethod(T, "init"), "T should implement init(self: *T, app: *App)");
    compileAssert(std.meta.hasMethod(T, "render"), "T should implement render(self: *T, app: *App)");
}

fn clientToWindow(size: [2]i32, style: u32) [2]i32 {
    var rect = w32.RECT{ .right = size[0], .bottom = size[1] };
    _ = w32.AdjustWindowRectEx(&rect, style, 0, 0);
    return [2]i32{ rect.right - rect.left, rect.bottom - rect.top };
}
