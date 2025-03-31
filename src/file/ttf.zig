const std = @import("std");
const prism = @import("../prism.zig");
const List = std.ArrayListUnmanaged;
const assert = std.debug.assert;

const allocator = prism.allocator;

pub const Char = u32;

pub const Glyph = u32;

pub const LMetrics = struct {
    ascender: f64,
    descender: f64,
    line_gap: f64,
};

pub const GMetrics = struct {
    advance_width: f64,
    left_side_bearing: f64,
    y_offset: i32 = 0,
    min_width: u32 = 0,
    min_height: u32 = 0,
};

pub const Kerning = struct {
    x_shift: f64,
    y_shift: f64,
};

pub const Image = struct {
    pixels: []u8,
    width: u32,
    height: u32,

    pub fn fromMetrics(mtx: *const GMetrics) !Image {
        const width = @as(u32, @intCast(mtx.min_width + 3)) & ~@as(u32, 3);
        const height = @as(u32, @intCast(mtx.min_height));
        const pixels = try allocator.alloc(u8, width * height);
        return .{
            .pixels = pixels,
            .width = width,
            .height = height,
        };
    }
};

pub const SFT = struct {
    font: *Font,
    x_scale: f64,
    y_scale: f64,
    x_offset: f64 = 0,
    y_offset: f64 = 0,
    flags: i32,

    pub fn lmetrics(self: *const SFT) !LMetrics {
        const hhea = try gettable(self.font, "hhea");
        if (!is_safe_offset(self.font, hhea, 36)) return error.bad;

        const factor = self.y_scale / asF64(self.font.units_per_em);
        return .{
            .ascender = asF64(geti16(self.font, hhea + 4)) * factor,
            .descender = asF64(geti16(self.font, hhea + 6)) * factor,
            .line_gap = asF64(geti16(self.font, hhea + 8)) * factor,
        };
    }

    pub fn lookup(self: *const SFT, codepoint: Char) !Glyph {
        return glyph_id(self.font, codepoint);
    }

    pub fn gmetrics(self: *const SFT, glyph: Glyph) !GMetrics {
        const xscale = self.x_scale / asF64(self.font.units_per_em);

        const adv, const lsb = try hor_metrics(self.font, glyph);
        const outline = try outline_offset(self.font, glyph);
        const bbox = try glyph_bbox(self, outline);

        return .{
            .advance_width = asF64(adv) * xscale,
            .left_side_bearing = asF64(lsb) * xscale + self.x_offset,
            .min_width = @intCast(bbox[2] - bbox[0] + 1),
            .min_height = @intCast(bbox[3] - bbox[1] + 1),
            .y_offset = if (self.flags & SFT_DOWNWARD_Y != 0) -bbox[3] else bbox[1],
        };
    }

    pub fn kerning(_: *const SFT, leftGlyph: Glyph, rightGlyph: Glyph, kerning_: [*c]Kerning) i32 {
        _ = leftGlyph; // autofix
        _ = rightGlyph; // autofix
        _ = kerning_; // autofix
        unreachable;
    }

    pub fn render(self: *const SFT, glyph: Glyph, image: Image) !void {
        const units_per_em = asF64(self.font.units_per_em);

        const outline = try outline_offset(self.font, glyph);
        if (outline == 0) return;

        const bbox = try glyph_bbox(self, outline);

        // set up the transformation matrix such that the transformed bounding boxes min corner lines up
        // with the (0, 0) point
        const transform = [6]f64{
            self.x_scale / units_per_em,
            0.0,
            0.0,
            if (self.flags & SFT_DOWNWARD_Y != 0) -self.y_scale / units_per_em else self.y_scale / units_per_em,
            self.x_offset - asF64(bbox[0]),
            if (self.flags & SFT_DOWNWARD_Y != 0) asF64(bbox[3]) - self.y_offset else self.y_offset - asF64(bbox[1]),
        };

        var outl = try init_outline();
        defer free_outline(&outl);

        try decode_outline(&outl, self.font, outline, 0);
        try render_outline(&outl, transform, image);
    }
};

pub const Font = struct {
    mem: []const u8,
    source: enum { user, mapping },

    units_per_em: u16 = 0,
    loca_format: i16 = 0,
    num_long_hmtx: u16 = 0,

    pub fn loadmem(mem: []const u8) !*Font {
        const self = try allocator.create(Font);
        errdefer allocator.destroy(self);

        self.* = .{
            .mem = mem,
            .source = .user,
        };

        try self.init();

        return self;
    }

    pub fn deinit(self: *Font) void {
        allocator.destroy(self);
    }

    fn init(self: *Font) !void {
        if (!is_safe_offset(self, 0, 12)) return error.bad;

        // Check for a compatible scalar type (magic number)
        const scalar_type = getu32(self, 0);
        if (scalar_type != FILE_MAGIC_ONE and scalar_type != FILE_MAGIC_TWO) return error.bad;

        const head = try gettable(self, "head");
        if (!is_safe_offset(self, head, 54)) return error.bad;
        self.units_per_em = getu16(self, head + 18);
        self.loca_format = geti16(self, head + 50);

        const hhea = try gettable(self, "hhea");
        if (!is_safe_offset(self, hhea, 36)) return error.bad;
        self.num_long_hmtx = getu16(self, hhea + 34);
    }
};

pub const SFT_DOWNWARD_Y = 0x01;

const FILE_MAGIC_ONE = 0x00010000;
const FILE_MAGIC_TWO = 0x74727565;

const HORIZONTAL_KERNING = 0x01;
const MINIMUM_KERNING = 0x02;
const CROSS_STREAM_KERNING = 0x04;
const OVERRIDE_KERNING = 0x08;

const POINT_IS_ON_CURVE = 0x01;
const X_CHANGE_IS_SMALL = 0x02;
const Y_CHANGE_IS_SMALL = 0x04;
const REPEAT_FLAG = 0x08;
const X_CHANGE_IS_ZERO = 0x10;
const X_CHANGE_IS_POSITIVE = 0x10;
const Y_CHANGE_IS_ZERO = 0x20;
const Y_CHANGE_IS_POSITIVE = 0x20;

const OFFSETS_ARE_LARGE = 0x001;
const ACTUAL_XY_OFFSETS = 0x002;
const GOT_A_SINGLE_SCALE = 0x008;
const THERE_ARE_MORE_COMPONENTS = 0x020;
const GOT_AN_X_AND_Y_SCALE = 0x040;
const GOT_A_SCALE_MATRIX = 0x080;

const Point = struct { x: f64, y: f64 };

const Line = struct { beg: u16, end: u16 };

const Curve = struct { beg: u16, end: u16, ctrl: u16 };

const Cell = struct { area: f64, cover: f64 };

const Outline = struct {
    points: List(Point),
    curves: List(Curve),
    lines: List(Line),
};

const Raster = struct {
    cells: []Cell,
    width: i32,
    height: i32,
};

// simple mathematical operations
// ------------------------------

fn midpoint(a: Point, b: Point) Point {
    return .{
        .x = 0.5 * (a.x + b.x),
        .y = 0.5 * (a.y + b.y),
    };
}

/// applies an affine linear transformation matrix to a set of points
fn transform_points(points: []Point, trf: [6]f64) void {
    for (points) |*pt| {
        pt.* = .{
            .x = pt.x * trf[0] + pt.y * trf[2] + trf[4],
            .y = pt.x * trf[1] + pt.y * trf[3] + trf[5],
        };
    }
}

fn clip_points(points: []Point, width: f64, height: f64) void {
    for (points) |*pt| {
        if (pt.x < 0) pt.x = 0;
        if (pt.x >= width) pt.x = std.math.nextAfter(f64, width, 0);
        if (pt.y < 0) pt.y = 0;
        if (pt.y >= height) pt.y = std.math.nextAfter(f64, height, 0);
    }
}

// 'outline' data structure management
// -----------------------------------

fn init_outline() !Outline {
    return .{
        .points = try .initCapacity(allocator, 64),
        .curves = try .initCapacity(allocator, 64),
        .lines = try .initCapacity(allocator, 64),
    };
}

fn free_outline(self: *Outline) void {
    self.points.deinit(allocator);
    self.curves.deinit(allocator);
    self.lines.deinit(allocator);
}

// TTF parsing utilities
// ---------------------

inline fn is_safe_offset(font: *const Font, offset: u32, margin: u32) bool {
    if (offset > font.mem.len) return false;
    if (font.mem.len - offset < margin) return false;
    return true;
}

fn cinarySearch(comptime T: type, items: []const T, context: anytype, comptime compareFn: fn (@TypeOf(context), T) std.math.Order) usize {
    var low: usize = 0;
    var high: usize = items.len;

    while (low < high) {
        // Avoid overflowing in the midpoint calculation
        const mid = low + (high - low) / 2;
        switch (compareFn(context, items[mid])) {
            .eq => return mid,
            .gt => low = mid + 1,
            .lt => high = mid,
        }
    }

    return low;
}

fn cmpu32(tag: *const [4]u8, data: [16]u8) std.math.Order {
    return std.math.order(
        std.mem.readInt(u32, tag, .big),
        std.mem.readInt(u32, data[0..4], .big),
    );
}

fn cmpu16(tag: [2]u8, data: [2]u8) std.math.Order {
    return std.math.order(
        std.mem.readInt(u16, &tag, .big),
        std.mem.readInt(u16, &data, .big),
    );
}

inline fn getu8(font: *const Font, offset: u32) u8 {
    assert(offset + 1 <= font.mem.len);
    return font.mem[offset];
}

inline fn geti8(font: *const Font, offset: u32) i8 {
    return @bitCast(getu8(font, offset));
}

inline fn getu16(font: *const Font, offset: u32) u16 {
    assert(offset + 2 <= font.mem.len);
    return std.mem.readInt(u16, font.mem[offset..][0..2], .big);
}

inline fn geti16(font: *const Font, offset: u32) i16 {
    return @bitCast(getu16(font, offset));
}

fn getu32(font: *const Font, offset: u32) u32 {
    assert(offset + 4 <= font.mem.len);
    return std.mem.readInt(u32, font.mem[offset..][0..4], .big);
}

fn gettable(font: *const Font, tag: *const [4]u8) !u32 {
    const num_tables = getu16(font, 4);
    const size = @as(u32, num_tables) * 16;
    if (!is_safe_offset(font, 12, size)) return error.bad;

    const elems = std.mem.bytesAsSlice([16]u8, font.mem[12..][0..size]);
    assert(elems.len == num_tables);

    const match = std.sort.binarySearch([16]u8, elems, tag, cmpu32) orelse unreachable;
    const idx: u32 = @intCast(match * 16);
    return getu32(font, idx + 12 + 8);
}

// codepoint to glyph id translation
// ---------------------------------

/// map unicode code points to glyph indices
/// FIXME `typ` should be octal not hex!!!
fn glyph_id(font: *Font, charcode: Char) !Glyph {
    const cmap = try gettable(font, "cmap");

    if (!is_safe_offset(font, cmap, 4)) return error.bad;
    const num_entries = getu16(font, cmap + 2);

    if (!is_safe_offset(font, cmap, 4 + num_entries * 8)) return error.bad;

    // first look for a 'full reprtoire' or non-bmp map
    for (0..num_entries) |idx| {
        const entry = cmap + 4 + @as(u32, @intCast(idx)) * 8;
        const typ = getu16(font, entry) * 0x0100 + getu16(font, entry + 2);

        // complete unicode map
        if (typ == 0x0004 or typ == 0x0312) {
            unreachable;
        }
    }

    // if no 'full repertoire' cmap was found, try looking for a bmp map
    for (0..num_entries) |idx| {
        const entry = cmap + 4 + @as(u32, @intCast(idx)) * 8;
        const typ = getu16(font, entry) * 0x0100 + getu16(font, entry + 2);

        // unicode bmp
        if (typ == 0x0003 or typ == 0x0301) {
            const table = cmap + getu32(font, entry + 4);
            if (!is_safe_offset(font, table, 6)) return error.bad;

            // Dispatch based on cmap format.
            return switch (getu16(font, table)) {
                4 => fmt4(font, table + 6, charcode),
                6 => fmt6(font, table + 6, charcode),
                else => unreachable,
            };
        }
    }

    return error.not_found;
}

fn fmt4(font: *Font, table: u32, charcode: Char) Glyph {
    const key = [2]u8{ @truncate(charcode >> 8), @truncate(charcode) };

    // cmap format 4 only supports the Unicode BMP
    if (charcode > 0xFFFF) {
        return 0;
    }

    const shortcode: u16 = @truncate(charcode);

    assert(is_safe_offset(font, table, 8));
    const seg_count_x2 = getu16(font, table);
    assert(!(seg_count_x2 & 1 != 0 or seg_count_x2 == 0));

    // Find starting positions of the relevant arrays.
    const end_codes = table + 8;
    const start_codes = end_codes + seg_count_x2 + 2;
    const id_deltas = start_codes + seg_count_x2;
    const id_range_offsets = id_deltas + seg_count_x2;
    assert(is_safe_offset(font, id_range_offsets, seg_count_x2));

    // Find the segment that contains shortCode by binary searching over the highest codes in the segments.
    // segPtr = csearch(key, font->memory + endCodes, segCountX2 / 2, 2, cmpu16);
    const elems = std.mem.bytesAsSlice([2]u8, font.mem[end_codes..][0..seg_count_x2]);
    const seg_ptr = cinarySearch([2]u8, elems, key, cmpu16);
    const seg_idx_x2: u32 = @intCast(seg_ptr * 2);

    // Look up segment info from the arrays & short circuit if the spec requires.
    const start_code = getu16(font, start_codes + seg_idx_x2);
    if (start_code > shortcode)
        unreachable;

    const id_delta = getu16(font, id_deltas + seg_idx_x2);
    const id_range_offset = getu16(font, id_range_offsets + seg_idx_x2);
    if (id_range_offset == 0) {
        // Intentional integer under- and overflow.
        return (shortcode +% id_delta) & 0xFFFF;
    }

    // Calculate offset into glyph array and determine ultimate value.
    const id_offset = id_range_offsets + seg_idx_x2 + id_range_offset + 2 * @as(u32, shortcode - start_code);
    assert(is_safe_offset(font, id_offset, 2));

    const id = getu16(font, id_offset);
    // Intentional integer under- and overflow.
    return if (id != 0) (id + id_delta) & 0xFFFF else 0;
}

fn fmt6(font: *Font, table: u32, charCode: Char) Glyph {
    _ = font; // autofix
    _ = table; // autofix
    _ = charCode; // autofix
    unreachable;
}

fn cmap_fmt12_13(font: *Font, table: u32, charcode: Char, which: u32) !Glyph {
    _ = font; // autofix
    _ = table; // autofix
    _ = charcode; // autofix
    _ = which; // autofix
    unreachable;
}

// glyph metrics lookup
// --------------------

/// advanceWidth, leftSideBearing
fn hor_metrics(font: *Font, glyph: Glyph) !struct { i32, i32 } {
    const hmtx = try gettable(font, "hmtx");

    if (glyph < font.num_long_hmtx) {
        // glyph is inside long metrics segment
        const offset = hmtx + 4 * glyph;
        if (!is_safe_offset(font, offset, 4)) return error.bad;

        const advanceWidth = getu16(font, offset);
        const leftSideBearing = geti16(font, offset + 2);
        return .{ advanceWidth, leftSideBearing };
    } else {
        unreachable;
    }
}

fn glyph_bbox(sft: *const SFT, outline: u32) ![4]i32 {
    // read the bounding box from the font file vervatim
    if (!is_safe_offset(sft.font, outline, 10)) return error.bad;

    var box = [4]i32{
        geti16(sft.font, outline + 2),
        geti16(sft.font, outline + 4),
        geti16(sft.font, outline + 6),
        geti16(sft.font, outline + 8),
    };

    if (box[2] <= box[0] or box[3] <= box[1]) return error.bad;

    // transform the bounding box into SFT coordinate space
    const xscale = sft.x_scale / asF64(sft.font.units_per_em);
    const yscale = sft.y_scale / asF64(sft.font.units_per_em);

    // zig fmt: off
    box[0] = @intFromFloat( @floor(asF64(box[0]) * xscale + sft.x_offset) );
    box[1] = @intFromFloat( @floor(asF64(box[1]) * yscale + sft.y_offset) );
    box[2] = @intFromFloat( @ceil (asF64(box[2]) * xscale + sft.x_offset) );
    box[3] = @intFromFloat( @ceil (asF64(box[3]) * yscale + sft.y_offset) );
    // zig fmt: on

    return box;
}

// decoding outlines
// -----------------

/// returns the offset into the font that the glyph's outline is stored at
fn outline_offset(font: *Font, glyph: Glyph) !u32 {
    const loca = try gettable(font, "loca");
    const glyf = try gettable(font, "glyf");

    var this: u32 = undefined;
    var next: u32 = undefined;

    if (font.loca_format == 0) {
        const base = loca + 2 * glyph;
        if (!is_safe_offset(font, base, 4)) return error.bad;

        this = 2 * @as(u32, getu16(font, base));
        next = 2 * @as(u32, getu16(font, base + 2));
    } else {
        const base = loca + 4 * glyph;
        if (!is_safe_offset(font, base, 8)) return error.bad;

        this = getu32(font, base);
        next = getu32(font, base + 4);
    }

    return if (this == next) 0 else glyf + this;
}

/// for a 'simple' outline, determines each point of the outline with a set of flags
fn simple_flags(font: *Font, offset: *u32, num_pts: usize, flags: []u8) !void {
    var off = offset.*;
    var value: u8 = 0;
    var repeat: u8 = 0;

    for (0..num_pts) |i| {
        if (repeat != 0) {
            repeat -= 1;
        } else {
            if (!is_safe_offset(font, off, 1)) return error.bad;
            value = getu8(font, off);
            off += 1;

            if (value & REPEAT_FLAG != 0) {
                if (!is_safe_offset(font, off, 1)) return error.bad;
                repeat = getu8(font, off);
                off += 1;
            }
        }

        flags[i] = value;
    }

    offset.* = off;
}

/// for a 'simple' outline, decodes both X and Y coordinates for each point of the outline
fn simple_points(font: *Font, offset_: u32, flags: []u8, points: []Point) !void {
    var offset = offset_;
    var accum: i64 = 0;
    var value: i64 = 0;
    var bit: i64 = 0;
    for (0..points.len) |i| {
        if (flags[i] & X_CHANGE_IS_SMALL != 0) {
            if (!is_safe_offset(font, offset, 1)) return error.bad;
            value = getu8(font, offset);
            offset += 1;
            bit = @intFromBool(!!(flags[i] & X_CHANGE_IS_POSITIVE != 0));
            accum -= (value ^ -bit) + bit;
        } else if (flags[i] & X_CHANGE_IS_ZERO == 0) {
            if (!is_safe_offset(font, offset, 2)) return error.bad;
            accum += geti16(font, offset);
            offset += 2;
        }
        points[i].x = @floatFromInt(accum);
    }

    accum = 0;
    value = 0;
    bit = 0;
    for (0..points.len) |i| {
        if (flags[i] & Y_CHANGE_IS_SMALL != 0) {
            if (!is_safe_offset(font, offset, 1)) return error.bad;
            value = getu8(font, offset);
            offset += 1;
            bit = @intFromBool(!!(flags[i] & Y_CHANGE_IS_POSITIVE != 0));
            accum -= (value ^ -bit) + bit;
        } else if (flags[i] & Y_CHANGE_IS_ZERO == 0) {
            if (!is_safe_offset(font, offset, 2)) return error.bad;
            accum += geti16(font, offset);
            offset += 2;
        }
        points[i].y = @floatFromInt(accum);
    }
}

fn decode_contour(outl: *Outline, flags_: []u8, base_point_: usize, count_: u16) !void {
    var flags = flags_.ptr;
    var count = count_;
    var base_point = base_point_;

    // Skip contours with less than two points, since the following algorithm can't handle them and
    // they should appear invisible either way (because they don't have any area).
    if (count < 2) return;

    assert(base_point <= 0xFFFF - count);

    var loose_end: u16 = 0;
    var beg: u16 = 0;
    var ctrl: u16 = 0;
    var center: u16 = 0;
    var cur: u16 = 0;
    var got_ctrl: u32 = 0;

    if (flags[0] & POINT_IS_ON_CURVE != 0) {
        loose_end = @intCast(base_point);
        base_point += 1;
        flags += 1;
        count -= 1;
    } else if (flags[count - 1] & POINT_IS_ON_CURVE != 0) {
        count -= 1;
        loose_end = @intCast(base_point + count);
    } else {
        unreachable;
    }

    beg = loose_end;
    got_ctrl = 0;

    for (0..count) |i| {
        cur = @intCast(base_point + i);

        if (flags[i] & POINT_IS_ON_CURVE != 0) {
            if (got_ctrl != 0) {
                try outl.curves.append(allocator, Curve{ .beg = beg, .end = cur, .ctrl = ctrl });
            } else {
                try outl.lines.append(allocator, Line{ .beg = beg, .end = cur });
            }
            beg = cur;
            got_ctrl = 0;
        } else {
            if (got_ctrl != 0) {
                center = @intCast(outl.points.items.len);
                // assert()
                try outl.points.append(allocator, midpoint(outl.points.items[ctrl], outl.points.items[cur]));

                // assert()
                try outl.curves.append(allocator, Curve{ .beg = beg, .end = center, .ctrl = ctrl });

                beg = center;
            }
            ctrl = cur;
            got_ctrl = 1;
        }
    }

    if (got_ctrl != 0) {
        try outl.curves.append(allocator, Curve{ .beg = beg, .end = loose_end, .ctrl = ctrl });
    } else {
        try outl.lines.append(allocator, Line{ .beg = beg, .end = loose_end });
    }
}

fn simple_outline(outl: *Outline, font: *Font, offset_: u32, num_contours: u32) !void {
    assert(num_contours > 0);

    var offset = offset_;
    const base_point = outl.points.items.len;

    if (!is_safe_offset(font, offset, num_contours * 2 + 2)) return error.bad;

    var num_pts = getu16(font, offset + (num_contours - 1) * 2);
    assert(num_pts != 0xFFFF);
    num_pts += 1;
    assert(outl.points.items.len <= 0xFFFF - num_pts);

    try outl.points.ensureTotalCapacity(allocator, base_point + num_pts);

    const endPts = try allocator.alloc(u16, num_contours);
    defer allocator.free(endPts);

    const flags = try allocator.alloc(u8, num_pts);
    defer allocator.free(flags);

    for (0..num_contours) |i| {
        endPts[i] = getu16(font, offset);
        offset += 2;
    }

    // Ensure that endPts are never falling
    // Falling endPts have no sensible interpretation and most likely only occur in malicious input
    // Therefore, we bail, should we ever encounter such input
    for (0..num_contours - 1) |i| {
        if (endPts[i + 1] < endPts[i] + 1) {
            return error.bad;
        }
    }

    offset += 2 + getu16(font, offset);

    try simple_flags(font, &offset, num_pts, flags);
    try simple_points(font, offset, flags, outl.points.addManyAsSliceAssumeCapacity(num_pts));

    assert(outl.points.items.len == base_point + num_pts);

    var beg: u16 = 0;
    for (0..num_contours) |i| {
        const count = endPts[i] - beg + 1;
        try decode_contour(outl, flags[beg..], base_point + beg, count);
        beg = endPts[i] + 1;
    }
}

// static int  compound_outline(SFT_Font *font, uint_fast32_t offset, int recDepth, Outline *outl);

fn decode_outline(outl: *Outline, font: *Font, offset: u32, rec_depth: i32) !void {
    _ = rec_depth; // autofix
    if (!is_safe_offset(font, offset, 10)) return error.bad;

    const num_contours: i32 = geti16(font, offset);

    if (num_contours > 0) {
        // glyphs has a 'simple' outline consisting of a number of contours
        try simple_outline(outl, font, offset + 10, @intCast(num_contours));
    } else if (num_contours < 0) {
        unreachable;
    }
}

// tesselation
// -----------

/// A heuristic to tell whether a given curve can be approximated closely enough by a line
fn is_flat(outl: *Outline, curve: Curve) bool {
    const maxArea2 = 2.0;
    const a = outl.points.items[curve.beg];
    const b = outl.points.items[curve.ctrl];
    const c = outl.points.items[curve.end];
    const g = Point{ .x = b.x - a.x, .y = b.y - a.y };
    const h = Point{ .x = c.x - a.x, .y = c.y - a.y };
    const area2 = @abs(g.x * h.y - h.x * g.y);
    return area2 <= maxArea2;
}

fn tesselate_curve(outl: *Outline, curve_: Curve) !void {
    var curve = curve_;

    const stack_size = 10;
    var stack: [stack_size]Curve = undefined;
    var top: u32 = 0;

    while (true) {
        if (is_flat(outl, curve) or top >= stack_size) {
            try outl.lines.append(allocator, .{ .beg = curve.beg, .end = curve.end });
            if (top == 0) break;
            top -= 1;
            curve = stack[top];
        } else {
            const ctrl0: u16 = @intCast(outl.points.items.len);
            try outl.points.append(allocator, midpoint(outl.points.items[curve.beg], outl.points.items[curve.ctrl]));

            const ctrl1: u16 = @intCast(outl.points.items.len);
            try outl.points.append(allocator, midpoint(outl.points.items[curve.ctrl], outl.points.items[curve.end]));

            const pivot: u16 = @intCast(outl.points.items.len);
            try outl.points.append(allocator, midpoint(outl.points.items[ctrl0], outl.points.items[ctrl1]));

            stack[top] = .{ .beg = curve.beg, .end = pivot, .ctrl = ctrl0 };
            top += 1;
            curve = .{ .beg = pivot, .end = curve.end, .ctrl = ctrl1 };
        }
    }
}

fn tesselate_curves(outl: *Outline) !void {
    for (outl.curves.items) |curve| {
        try tesselate_curve(outl, curve);
    }
}

// silhouette rasterization
// ------------------------

/// draws a line into the buffer. Uses a custom 2D raycasting algorithm to do so
fn draw_line(buf: Raster, origin: Point, goal: Point) void {
    const delta = Point{ .x = goal.x - origin.x, .y = goal.y - origin.y };
    const dir = [2]i32{ @intFromFloat(std.math.sign(delta.x)), @intFromFloat(std.math.sign(delta.y)) };

    if (dir[1] == 0) return;

    const crossingIncr = Point{
        .x = if (dir[0] != 0) @abs(1.0 / delta.x) else 1.0,
        .y = @abs(1.0 / delta.y),
    };

    var pixel: [2]i32 = .{ 0, 0 };
    var nextCrossing = Point{ .x = 0, .y = 0 };
    var numSteps: u32 = 0;

    if (dir[0] == 0) {
        pixel[0] = @intFromFloat(@floor(origin.x));
        nextCrossing.x = 100.0;
    } else {
        if (dir[0] > 0) {
            pixel[0] = @intFromFloat(@floor(origin.x));
            nextCrossing.x = (origin.x - @as(f64, @floatFromInt(pixel[0]))) * crossingIncr.x;
            nextCrossing.x = crossingIncr.x - nextCrossing.x;
            numSteps += @intFromFloat(@ceil(goal.x) - @floor(origin.x) - 1);
        } else {
            pixel[0] = @intFromFloat(@ceil(origin.x) - 1);
            nextCrossing.x = (origin.x - @as(f64, @floatFromInt(pixel[0]))) * crossingIncr.x;
            numSteps += @intFromFloat(@ceil(origin.x) - @floor(goal.x) - 1);
        }
    }

    if (dir[1] > 0) {
        pixel[1] = @intFromFloat(@floor(origin.y));
        nextCrossing.y = (origin.y - @as(f64, @floatFromInt(pixel[1]))) * crossingIncr.y;
        nextCrossing.y = crossingIncr.y - nextCrossing.y;
        numSteps += @as(u32, @intFromFloat(@ceil(goal.y) - @floor(origin.y))) - 1;
    } else {
        pixel[1] = @intFromFloat(@ceil(origin.y) - 1);
        nextCrossing.y = (origin.y - @as(f64, @floatFromInt(pixel[1]))) * crossingIncr.y;
        numSteps += @intFromFloat(@ceil(origin.y) - @floor(goal.y) - 1);
    }

    var nextDistance = @min(nextCrossing.x, nextCrossing.y);
    const halfDeltaX = 0.5 * delta.x;

    var xAverage: f64 = 0;
    var yDifference: f64 = 0;
    var prevDistance: f64 = 0;

    var cptr: *Cell = undefined;
    var cell: Cell = undefined;

    for (0..numSteps) |_| {
        xAverage = origin.x + (prevDistance + nextDistance) * halfDeltaX;
        yDifference = (nextDistance - prevDistance) * delta.y;
        cptr = &buf.cells[@intCast(pixel[1] * buf.width + pixel[0])];
        cell = cptr.*;
        cell.cover += yDifference;
        xAverage -= @floatFromInt(pixel[0]);
        cell.area += (1.0 - xAverage) * yDifference;
        cptr.* = cell;
        prevDistance = nextDistance;
        const alongX = nextCrossing.x < nextCrossing.y;
        pixel[0] += if (alongX) dir[0] else 0;
        pixel[1] += if (alongX) 0 else dir[1];
        nextCrossing.x += if (alongX) crossingIncr.x else 0.0;
        nextCrossing.y += if (alongX) 0.0 else crossingIncr.y;
        nextDistance = @min(nextCrossing.x, nextCrossing.y);
    }

    xAverage = origin.x + (prevDistance + 1.0) * halfDeltaX;
    yDifference = (1.0 - prevDistance) * delta.y;
    cptr = &buf.cells[@intCast(pixel[1] * buf.width + pixel[0])];
    cell = cptr.*;
    cell.cover += yDifference;
    xAverage -= @floatFromInt(pixel[0]);
    cell.area += (1.0 - xAverage) * yDifference;
    cptr.* = cell;
}

fn draw_lines(outl: *Outline, buf: Raster) void {
    for (outl.lines.items) |line| {
        const origin = outl.points.items[line.beg];
        const goal = outl.points.items[line.end];
        draw_line(buf, origin, goal);
    }
}

// post-processing
// ---------------

/// Integrate the values in the buffer to arrive at the final grayscale image.
fn post_process(buf: Raster, image: []u8) void {
    var accum: f64 = 0;
    for (0..image.len) |i| {
        const cell = buf.cells[i];
        var value = @abs(accum + cell.area);
        value = @min(value, 1.0);
        value = value * 255.0 + 0.5;
        image[i] = @intFromFloat(value);
        accum += cell.cover;
    }
}

// glyph rendering
// ---------------

fn render_outline(outl: *Outline, transform: [6]f64, image: Image) !void {
    const num_pixels: u32 = @intCast(image.width * image.height);

    const cells = try allocator.alloc(Cell, num_pixels);
    defer allocator.free(cells);

    @memset(cells, Cell{ .area = 0, .cover = 0 });

    const buf = Raster{
        .cells = cells,
        .width = @intCast(image.width),
        .height = @intCast(image.height),
    };

    transform_points(outl.points.items, transform);
    clip_points(outl.points.items, asF64(image.width), asF64(image.height));

    try tesselate_curves(outl);

    draw_lines(outl, buf);
    post_process(buf, image.pixels);
}

inline fn asF64(x: anytype) f64 {
    return @floatFromInt(x);
}
