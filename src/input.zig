const std = @import("std");
const math = @import("math.zig");

const Vec2 = math.Vec2;
const Point = math.Point;

pub const max_controllers = 8;
pub const max_controller_buttons = 64;
pub const max_controller_axis = 16;
pub const max_mouse_buttons = 16;
pub const max_keyboard_keys = 512;

pub const Key = enum(u32) {
    unknown = 0,
    a = 4,
    b = 5,
    c = 6,
    d = 7,
    e = 8,
    f = 9,
    g = 10,
    h = 11,
    i = 12,
    j = 13,
    k = 14,
    l = 15,
    m = 16,
    n = 17,
    o = 18,
    p = 19,
    q = 20,
    r = 21,
    s = 22,
    t = 23,
    u = 24,
    v = 25,
    w = 26,
    x = 27,
    y = 28,
    z = 29,
    d1 = 30,
    d2 = 31,
    d3 = 32,
    d4 = 33,
    d5 = 34,
    d6 = 35,
    d7 = 36,
    d8 = 37,
    d9 = 38,
    d0 = 39,
    enter = 40,
    escape = 41,
    backspace = 42,
    tab = 43,
    space = 44,
    minus = 45,
    equals = 46,
    left_bracket = 47,
    right_bracket = 48,
    backslash = 49,
    semicolon = 51,
    apostrophe = 52,
    tilde = 53,
    comma = 54,
    period = 55,
    slash = 56,
    capslock = 57,
    f1 = 58,
    f2 = 59,
    f3 = 60,
    f4 = 61,
    f5 = 62,
    f6 = 63,
    f7 = 64,
    f8 = 65,
    f9 = 66,
    f10 = 67,
    f11 = 68,
    f12 = 69,
    f13 = 104,
    f14 = 105,
    f15 = 106,
    f16 = 107,
    f17 = 108,
    f18 = 109,
    f19 = 110,
    f20 = 111,
    f21 = 112,
    f22 = 113,
    f23 = 114,
    f24 = 115,
    print_screen = 70,
    scroll_lock = 71,
    pause = 72,
    insert = 73,
    home = 74,
    page_up = 75,
    delete = 76,
    end = 77,
    page_down = 78,
    right = 79,
    left = 80,
    down = 81,
    up = 82,
    numlock = 83,
    application = 101,
    execute = 116,
    help = 117,
    menu = 118,
    select = 119,
    stop = 120,
    redo = 121,
    undo = 122,
    cut = 123,
    copy = 124,
    paste = 125,
    find = 126,
    mute = 127,
    volume_up = 128,
    volume_down = 129,
    alt_erase = 153,
    sys_req = 154,
    cancel = 155,
    clear = 156,
    prior = 157,
    enter2 = 158,
    separator = 159,
    out = 160,
    oper = 161,
    clear_again = 162,
    keypad_a = 188,
    keypad_b = 189,
    keypad_c = 190,
    keypad_d = 191,
    keypad_e = 192,
    keypad_f = 193,
    keypad0 = 98,
    keypad00 = 176,
    keypad000 = 177,
    keypad1 = 89,
    keypad2 = 90,
    keypad3 = 91,
    keypad4 = 92,
    keypad5 = 93,
    keypad6 = 94,
    keypad7 = 95,
    keypad8 = 96,
    keypad9 = 97,
    keypad_divide = 84,
    keypad_multiply = 85,
    keypad_minus = 86,
    keypad_plus = 87,
    keypad_enter = 88,
    keypad_peroid = 99,
    keypad_equals = 103,
    keypad_comma = 133,
    keypad_left_paren = 182,
    keypad_right_paren = 183,
    keypad_left_brace = 184,
    keypad_right_brace = 185,
    keypad_tab = 186,
    keypad_backspace = 187,
    keypad_xor = 194,
    keypad_power = 195,
    keypad_percent = 196,
    keypad_less = 197,
    keypad_greater = 198,
    keypad_ampersand = 199,
    keypad_colon = 203,
    keypad_hash = 204,
    keypad_space = 205,
    keypad_clear = 216,
    left_control = 224,
    left_shift = 225,
    left_alt = 226,
    left_os = 227,
    right_control = 228,
    right_shift = 229,
    right_alt = 230,
    right_os = 231,
    _,
};

pub const MouseButton = enum(u32) {
    left = 0,
    middle = 1,
    right = 2,
    _,
};

pub const KeyboardState = struct {
    pressed: [max_keyboard_keys]bool = .{false} ** max_keyboard_keys,
    down: [max_keyboard_keys]bool = .{false} ** max_keyboard_keys,
    released: [max_keyboard_keys]bool = .{false} ** max_keyboard_keys,
    timestamp: [max_keyboard_keys]u64 = .{0} ** max_keyboard_keys,
    text: []const u8 = &[0]u8{},

    inline fn ctrl(self: *const KeyboardState) bool {
        return self.down[@intFromEnum(Key.left_control)] or self.down[@intFromEnum(Key.right_control)];
    }

    inline fn shift(self: *const KeyboardState) bool {
        return self.down[@intFromEnum(Key.left_shift)] or self.down[@intFromEnum(Key.right_shift)];
    }

    inline fn alt(self: *const KeyboardState) bool {
        return self.down[@intFromEnum(Key.left_alt)] or self.down[@intFromEnum(Key.right_alt)];
    }

    pub fn onPress(_: *KeyboardState, _: Key) void {
        unreachable;
    }

    pub fn onRelease(_: *KeyboardState, _: Key) void {
        unreachable;
    }
};

pub const MouseState = struct {
    pressed: [max_mouse_buttons]bool = .{false} ** max_mouse_buttons,
    down: [max_mouse_buttons]bool = .{false} ** max_mouse_buttons,
    released: [max_mouse_buttons]bool = .{false} ** max_mouse_buttons,
    timestamp: [max_mouse_buttons]u64 = .{0} ** max_mouse_buttons,
    position: Vec2 = .zero,
    wheel: Point = .zero,

    pub fn onPress(self: *MouseState, button: MouseButton) void {
        const idx: u32 = @intFromEnum(button);
        std.debug.assert(idx < max_mouse_buttons);

        self.down[idx] = true;
        self.pressed[idx] = true;
        self.timestamp[idx] = 69;
    }

    pub fn onRelease(self: *MouseState, button: MouseButton) void {
        const idx: u32 = @intFromEnum(button);
        std.debug.assert(idx < max_mouse_buttons);

        self.down[idx] = false;
        self.released[idx] = true;
    }

    pub fn onMove(self: *MouseState, x: f32, y: f32) void {
        self.position = .{ .x = x, .y = y };
    }
};

pub const InputState = struct {
    keyboard: KeyboardState = .{},
    mouse: MouseState = .{},
};

pub const Input = struct {
    state: InputState = .{},
    last_state: InputState = .{},
    repeat_delay: f32 = 0.35,
    repeat_interval: f32 = 0.025,

    pub fn step(self: *Input) void {
        self.last_state = self.state;

        @memset(&self.state.keyboard.pressed, false);
        @memset(&self.state.keyboard.released, false);

        @memset(&self.state.mouse.pressed, false);
        @memset(&self.state.mouse.released, false);

        self.state.mouse.wheel = .zero;
        self.state.keyboard.text = &[0]u8{}; // TODO free
    }

    pub inline fn mouse(self: *const Input) Vec2 {
        return self.state.mouse.position;
    }

    pub inline fn buttonPressed(self: *const Input, button: MouseButton) bool {
        const idx: u32 = @intFromEnum(button);
        std.debug.assert(idx < max_mouse_buttons);
        return self.state.mouse.pressed[idx];
    }

    pub inline fn buttonDown(self: *const Input, button: MouseButton) bool {
        const idx: u32 = @intFromEnum(button);
        std.debug.assert(idx < max_mouse_buttons);
        return self.state.mouse.down[idx];
    }

    pub inline fn buttonReleased(self: *const Input, button: MouseButton) bool {
        const idx: u32 = @intFromEnum(button);
        std.debug.assert(idx < max_mouse_buttons);
        return self.state.mouse.released[idx];
    }

    pub inline fn mouseWheel(self: *const Input) Point {
        return self.state.mouse.wheel;
    }

    pub inline fn keyPressed(self: *const Input, key: Key) bool {
        const idx: u32 = @intFromEnum(key);
        std.debug.assert(idx < max_keyboard_keys);
        return self.state.keyboard.pressed[idx];
    }

    pub inline fn keyDown(self: *const Input, key: Key) bool {
        const idx: u32 = @intFromEnum(key);
        std.debug.assert(idx < max_keyboard_keys);
        return self.state.keyboard.down[idx];
    }

    pub inline fn keyReleased(self: *const Input, key: Key) bool {
        const idx: u32 = @intFromEnum(key);
        std.debug.assert(idx < max_keyboard_keys);
        return self.state.keyboard.released[idx];
    }

    pub inline fn repeating(self: *const Input, key: Key) bool {
        _ = self; // autofix
        _ = key; // autofix
        @compileError("TODO: repeating keys");
    }

    pub inline fn ctrl(self: *const Input) bool {
        return self.state.keyboard.ctrl();
    }

    pub inline fn shift(self: *const Input) bool {
        return self.state.keyboard.shift();
    }

    pub inline fn alt(self: *const Input) bool {
        return self.state.keyboard.alt();
    }

    // TODO bindings
    // TODO controllers
};
