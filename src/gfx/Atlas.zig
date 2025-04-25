//! Implements a [texture atlas](https://en.wikipedia.org/wiki/Texture_atlas).
//!
//! This implementation is based on "A Thousand Ways to Pack the Bin - A Practical Approach to
//! Two-Dimensional Rectangle Bin Packing" by Jukka Jylänki. This specific implementation originates
//! [from Mitchell Hashimoto](https://gist.github.com/mitchellh/0c023dbd381c42e145b5da8d58b1487f)
//! which is itself based heavily on Nicolas P. Rougier's freetype-gl project as well as Jukka's C++
//! [implementation](https://github.com/juj/RectangleBinPack).
//!
//! There are two known limitations:
//!
//!   * Written data must be packed, no support for custom strides.
//!   * Texture is always a square, no ability to set width != height. Note
//!     that regions written INTO the atlas do not have to be square, only
//!     the full atlas texture itself.

const std = @import("std");
const math = @import("../math/math.zig");
const assert = std.debug.assert;
const Allocator = std.mem.Allocator;

pub const Error = error{
    AtlasFull,
};

pub const Format = enum {
    greyscale,
    rgb,
    rgba,

    pub fn depth(self: Format) u8 {
        return switch (self) {
            .greyscale => 1,
            .rgb => 3,
            .rgba => 4,
        };
    }
};

const Node = struct {
    x: u32,
    y: u32,
    width: u32,
};

pub const Region = struct {
    x: u32,
    y: u32,
    width: u32,
    height: u32,

    const UV = struct { x: f32, y: f32, width: f32, height: f32 };

    fn calculateUV(r: Region, size: u32) UV {
        var uv = UV{
            .x = @floatFromInt(r.x),
            .y = @floatFromInt(r.y),
            .width = @floatFromInt(r.width),
            .height = @floatFromInt(r.height),
        };
        uv.x /= @floatFromInt(size);
        uv.y /= @floatFromInt(size);
        uv.width /= @floatFromInt(size);
        uv.height /= @floatFromInt(size);
        return uv;
    }
};

const Atlas = @This();

data: []u8,
size: u32,
nodes: std.ArrayListUnmanaged(Node) = .empty,
format: Format,
modified: bool = false,
resized: bool = false,

pub fn create(allocator: Allocator, size: u32, format: Format) !Atlas {
    var self = Atlas{
        .data = try allocator.alloc(u8, size * size * format.depth()),
        .size = size,
        .format = format,
    };
    errdefer self.deinit(allocator);

    try self.nodes.ensureUnusedCapacity(allocator, 64);

    self.clear();
    self.modified = false;

    return self;
}

pub fn deinit(self: *Atlas, allocator: Allocator) void {
    self.nodes.deinit(allocator);
    allocator.free(self.data);
}

/// Reserve a region within the atlas with the given width and height.
///
/// May allocate to add a new rectangle into the internal list of rectangles.
/// This will not automatically enlarge the texture if it is full.
pub fn reserve(self: *Atlas, allocator: Allocator, width: u32, height: u32) !Region {
    // x, y are populated within :best_idx below
    var region: Region = .{ .x = 0, .y = 0, .width = width, .height = height };

    // If our width/height are 0, then we return the region as-is. This
    // may seem like an error case but it simplifies downstream callers who
    // might be trying to write empty data.
    if (width == 0 and height == 0) return region;

    // Find the location in our nodes list to insert the new node for this region.
    const best_idx: usize = best_idx: {
        var best_height: u32 = math.maxInt(u32);
        var best_width: u32 = best_height;
        var chosen: ?usize = null;

        var i: usize = 0;
        while (i < self.nodes.items.len) : (i += 1) {
            // Check if our region fits within this node.
            const y = self.fit(i, width, height) orelse continue;

            const node = self.nodes.items[i];
            if ((y + height) < best_height or ((y + height) == best_height and (node.width > 0 and node.width < best_width))) {
                chosen = i;
                best_width = node.width;
                best_height = y + height;
                region.x = node.x;
                region.y = y;
            }
        }

        // If we never found a chosen index, the atlas cannot fit our region.
        break :best_idx chosen orelse return Error.AtlasFull;
    };

    // Insert our new node for this rectangle at the exact best index
    try self.nodes.insert(allocator, best_idx, .{
        .x = region.x,
        .y = region.y + height,
        .width = width,
    });

    // Optimize our rectangles
    var i: usize = best_idx + 1;
    while (i < self.nodes.items.len) : (i += 1) {
        const node = &self.nodes.items[i];
        const prev = self.nodes.items[i - 1];
        if (node.x < (prev.x + prev.width)) {
            const shrink = prev.x + prev.width - node.x;
            node.x += shrink;
            node.width -|= shrink;
            if (node.width <= 0) {
                _ = self.nodes.orderedRemove(i);
                i -= 1;
                continue;
            }
        }

        break;
    }
    self.merge();

    return region;
}

/// Set the data associated with a reserved region. The data is expected
/// to fit exactly within the region. The data must be formatted with the
/// proper bpp configured on init.
pub fn set(self: *Atlas, reg: Region, data: []const u8) void {
    assert(reg.x < (self.size - 1));
    assert((reg.x + reg.width) <= (self.size - 1));
    assert(reg.y < (self.size - 1));
    assert((reg.y + reg.height) <= (self.size - 1));

    const depth = self.format.depth();
    var i: u32 = 0;
    while (i < reg.height) : (i += 1) {
        const tex_offset = (((reg.y + i) * self.size) + reg.x) * depth;
        const data_offset = i * reg.width * depth;
        const src = data[data_offset .. data_offset + (reg.width * depth)];
        @memcpy(self.data[tex_offset .. tex_offset + src.len], src);
    }

    self.modified = true;
}

/// Grow the texture to the new size, preserving all previously written data.
pub fn grow(self: *Atlas, allocator: Allocator, new_size: u32) !void {
    assert(new_size >= self.size);
    if (new_size == self.size) return;

    // Preserve our old values so we can copy the old data
    const old_data = self.data;
    const old_size = self.size;

    // Allocate our new data
    self.data = try allocator.alloc(u8, new_size * new_size * self.format.depth());
    defer allocator.free(old_data);
    errdefer {
        allocator.free(self.data);
        self.data = old_data;
    }

    // Add our new rectangle for our added righthand space. We do this
    // right away since its the only operation that can fail and we want
    // to make error cleanup easier.
    try self.nodes.append(allocator, .{
        .x = old_size - 1,
        .y = 1,
        .width = new_size - old_size,
    });

    // If our allocation and rectangle add succeeded, we can go ahead
    // and persist our new size and copy over the old data.
    self.size = new_size;
    @memset(self.data, 0);
    self.set(.{
        .x = 0, // don't bother skipping border so we can avoid strides
        .y = 1, // skip the first border row
        .width = old_size,
        .height = old_size - 2, // skip the last border row
    }, old_data[old_size * self.format.depth() ..]);

    // We are both modified and resized
    self.modified = true;
    self.resized = true;
}

/// Empty the atlas. This doesn't reclaim any previously allocated memory.
pub fn clear(self: *Atlas) void {
    self.modified = true;
    @memset(self.data, 0);
    self.nodes.clearRetainingCapacity();

    // Add our initial rectangle. This is the size of the full texture
    // and is the initial rectangle we fit our regions in. We keep a 1px border
    // to avoid artifacting when sampling the texture.
    self.nodes.appendAssumeCapacity(.{ .x = 1, .y = 1, .width = self.size - 2 });
}

/// Attempts to fit a rectangle of width x height into the node at idx.
/// The return value is the y within the texture where the rectangle can be
/// placed. The x is the same as the node.
fn fit(self: *Atlas, idx: usize, width: u32, height: u32) ?u32 {
    // If the added width exceeds our texture size, it doesn't fit.
    const node = self.nodes.items[idx];
    if ((node.x + width) > (self.size - 1)) return null;

    // Go node by node looking for space that can fit our width.
    var y = node.y;
    var i = idx;
    var width_left = width;
    while (width_left > 0) : (i += 1) {
        const n = self.nodes.items[i];
        if (n.y > y) y = n.y;

        // If the added height exceeds our texture size, it doesn't fit.
        if ((y + height) > (self.size - 1)) return null;

        width_left -|= n.width;
    }

    return y;
}

/// Merge adjacent nodes with the same y value.
fn merge(self: *Atlas) void {
    var i: usize = 0;
    while (i < self.nodes.items.len - 1) {
        const node = &self.nodes.items[i];
        const next = self.nodes.items[i + 1];
        if (node.y == next.y) {
            node.width += next.width;
            _ = self.nodes.orderedRemove(i + 1);
            continue;
        }

        i += 1;
    }
}
