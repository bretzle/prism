const std = @import("std");
const math = @import("../math.zig");
const prism = @import("../prism.zig");

const List = std.ArrayListUnmanaged;
const Rect = math.Recti;
const Image = void;

const allocator = prism.allocator;
const ALPHA_MASK = 0xFF000000;

pub const Entry = struct {
    id: u64,
    frame: Rect,
    pack: Rect = .zero,
};

max_size: usize,
is_power_of_two: bool,
spacing: i32,
padding: i32,

dirty: bool = false,
pages: List(Image) = .empty,

const Packer = @This();

pub fn create(max_size: usize, spacing: i32, power_of_two: bool) Packer {
    _ = max_size; // autofix
    _ = spacing; // autofix
    _ = power_of_two; // autofix
    unreachable;
}

pub fn add(self: *Packer, id: u64, width: i32, height: i32, pixels: []const u32) void {
    self.addEntry(id, width, height, pixels, .{ .x = 0, .y = 0, .w = width, .h = height });
}

fn addEntry(self: *Packer, id: u64, width: i32, height: i32, pixels: []const u32, source: Rect) void {
    self.dirty = true;

    var top = source.y;
    var left = source.x;
    var right = source.x;
    var bottom = source.y;

    top_loop: for (source.y..source.y + source.h) |y| {
        for (source.x..source.x + source.w) |x| {
            const idx = x + y * width;
            if (pixels[idx] & ALPHA_MASK != 0) {
                top = y;
                break :top_loop;
            }
        }
    }

    left_loop: for (source.x..source.x + source.w) |x| {
        for (top..source.y + source.h) |y| {
            const idx = x + y * width;
            if (pixels[idx] & ALPHA_MASK != 0) {
                left = x;
                break :left_loop;
            }
        }
    }

    right_loop: {
        var x: usize = source.x + source.w - 1;
        while (x >= left) : (x -= 1) {
            for (top..source.y + source.h) |y| {
                const idx = x + y * width;
                if (pixels[idx] & ALPHA_MASK != 0) {
                    right = x + 1;
                    break :right_loop;
                }
            }
        }
    }

    bottom_loop: {
        var y: usize = source.y + source.h - 1;
        while (y >= top) : (y -= 1) {
            for (left..right) |x| {
                const idx = x + y * width;
                if (pixels[idx] & ALPHA_MASK != 0) {
                    bottom = x + 1;
                    break :bottom_loop;
                }
            }
        }
    }

    var entry = Entry{
        .id = id,
    };

    // pixels actually exist in this space
    if (right > left and bottom > top) {
        entry.empty = false;

        entry.frame.x = source.x - left;
        entry.frame.y = source.y - top;
        entry.pack.w = right - left;
        entry.pack.h = bottom - top;

        entry.memory_index = self.buffer.items.len;

        // copy pixels over
        if (entry.pack.w == width and entry.pack.h == height) {
            unreachable;
        } else {
            unreachable;
        }
    }

    self.entries.append(entry) catch unreachable;
}

pub fn pack(self: *Packer) void {
    if (!self.dirty) return;

    self.dirty = false;
    self.pages.items.len = 0;

    const count = self.entries.items.len;
    if (count == 0) return;

    unreachable;
}

pub fn clear(self: *Packer) void {
    self.pages.items.len = 0;
    self.enties.items.len = 0;
    self.buffer.items.len = 0;
    self.dirty = false;
}
