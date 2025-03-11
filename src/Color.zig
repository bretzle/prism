const std = @import("std");

pub const Color = extern struct {
    pub const transparent = Self{ .r = 0x00, .g = 0x00, .b = 0x00 };
    pub const white = Self{ .r = 0xFF, .g = 0xFF, .b = 0xFF };
    pub const black = Self{ .r = 0x00, .g = 0x00, .b = 0x00 };
    pub const red = Self{ .r = 0xFF, .g = 0x00, .b = 0x00 };
    pub const green = Self{ .r = 0x00, .g = 0xFF, .b = 0x00 };
    pub const blue = Self{ .r = 0x00, .g = 0x00, .b = 0xFF };
    pub const yellow = Self{ .r = 0xFF, .g = 0xFF, .b = 0x00 };
    pub const orange = Self{ .r = 0xFF, .g = 0xA5, .b = 0x00 };
    pub const purple = Self{ .r = 0xFF, .g = 0x00, .b = 0xFF };
    pub const teal = Self{ .r = 0x00, .g = 0xFF, .b = 0xFF };

    const Self = @This();

    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,
    a: u8 = 0xFF,

    pub fn rgba(value: u32) Self {
        return .{
            .r = @truncate((value & 0xFF000000) >> 24),
            .g = @truncate((value & 0x00FF0000) >> 16),
            .b = @truncate((value & 0x0000FF00) >> 8),
            .a = @truncate((value & 0x000000FF)),
        };
    }

    pub fn floats(self: Color) [4]f32 {
        return .{ asF32(self.r) / 255, asF32(self.g) / 255, asF32(self.b) / 255, asF32(self.a) / 255 };
    }
};

inline fn asF32(x: anytype) f32 {
    return @floatFromInt(x);
}
