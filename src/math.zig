const std = @import("std");

pub const Vec2 = extern struct {
    x: f32,
    y: f32,

    pub const zero = Vec2{ .x = 0, .y = 0 };
    pub const one = Vec2{ .x = 1, .y = 1 };

    pub fn add(lhs: Vec2, rhs: Vec2) Vec2 {
        return Vec2{ .x = lhs.x + rhs.x, .y = lhs.y + rhs.y };
    }

    pub fn sub(lhs: Vec2, rhs: Vec2) Vec2 {
        return Vec2{ .x = lhs.x - rhs.x, .y = lhs.y - rhs.y };
    }
};

pub const Point = extern struct {
    x: i32,
    y: i32,

    pub const zero = Point{ .x = 0, .y = 0 };

    pub inline fn eql(a: Point, b: Point) bool {
        return std.meta.eql(a, b);
    }
};

pub const Rect = extern struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,

    pub const zero = Rect{ .x = 0, .y = 0, .w = 0, .h = 0 };

    pub fn expand(self: Rect, n: f32) Rect {
        return Rect{
            .x = self.x - n,
            .y = self.y - n,
            .w = self.w + n * 2,
            .h = self.h + n * 2,
        };
    }

    pub fn intersection(r1: Rect, r2: Rect) Rect {
        const x1 = @max(r1.x, r2.x);
        const y1 = @max(r1.y, r2.y);
        var x2 = @min(r1.x + r1.w, r2.x + r2.w);
        var y2 = @min(r1.y + r1.h, r2.y + r2.h);
        if (x2 < x1) x2 = x1;
        if (y2 < y1) y2 = y1;
        return Rect{ .x = x1, .y = y1, .w = x2 - x1, .h = y2 - y1 };
    }

    pub fn overlaps(r: Rect, p: Vec2) bool {
        return p.x >= r.x and p.x < r.x + r.w and p.y >= r.y and p.y < r.y + r.h;
    }
};

pub const Mat3x2 = extern struct {
    // [row][col]
    data: [3][2]f32,

    pub const zero = createScale(0, 0);
    pub const identity = createScale(1, 1);

    pub fn transform(position: Vec2, origin: Vec2, scale: Vec2, rotation: f32) Mat3x2 {
        var matrix = Mat3x2.identity;
        if (origin.x != 0 or origin.y != 0) matrix = createTranslation(-origin.x, -origin.y);
        if (scale.x != 1 or scale.y != 1) matrix = matrix.mul(createScale(scale.x, scale.y));
        if (rotation != 0) matrix = matrix.mul(createRotation(rotation));
        if (position.x != 0 or position.y != 0) matrix = matrix.mul(createTranslation(position.x, position.y));
        return matrix;
    }

    pub fn createTranslation(x: f32, y: f32) Mat3x2 {
        return Mat3x2{
            .data = .{
                .{ 1, 0 },
                .{ 0, 1 },
                .{ x, y },
            },
        };
    }

    pub fn createScale(x: f32, y: f32) Mat3x2 {
        return Mat3x2{
            .data = .{
                .{ x, 0 },
                .{ 0, y },
                .{ 0, 0 },
            },
        };
    }

    pub fn createRotation(radians: f32) Mat3x2 {
        const c = @cos(radians);
        const s = @sin(radians);
        return Mat3x2{
            .data = .{
                .{ c, s },
                .{ -s, c },
                .{ 0, 0 },
            },
        };
    }

    pub fn add(a: Mat3x2, b: Mat3x2) Mat3x2 {
        var result: Mat3x2 = undefined;
        inline for (0..3) |r| inline for (0..2) |c| {
            result.data[r][c] = a.data[r][c] + b.data[r][c];
        };
        return result;
    }

    pub fn sub(a: Mat3x2, b: Mat3x2) Mat3x2 {
        var result: Mat3x2 = undefined;
        inline for (0..3) |r| inline for (0..2) |c| {
            result.data[r][c] = a.data[r][c] - b.data[r][c];
        };
        return result;
    }

    pub fn mul(a: Mat3x2, b: Mat3x2) Mat3x2 {
        const am = a.data;
        const bm = b.data;

        return Mat3x2{
            .data = .{
                .{ am[0][0] * bm[0][0] + am[0][1] * bm[1][0], am[0][0] * bm[0][1] + am[0][1] * bm[1][1] },
                .{ am[1][0] * bm[0][0] + am[1][1] * bm[1][0], am[1][0] * bm[0][1] + am[1][1] * bm[1][1] },
                .{ am[2][0] * bm[0][0] + am[2][1] * bm[1][0] + bm[2][0], am[2][0] * bm[0][1] + am[2][1] * bm[1][1] + bm[2][1] },
            },
        };
    }

    pub fn eql(a: Mat3x2, b: Mat3x2) bool {
        _ = a; // autofix
        _ = b; // autofix
        unreachable;
    }

    pub fn apply(self: Mat3x2, vec: Vec2) Vec2 {
        return .{
            .x = (vec.x * self.data[0][0]) + (vec.y * self.data[1][0]) + self.data[2][0],
            .y = (vec.x * self.data[0][1]) + (vec.y * self.data[1][1]) + self.data[2][1],
        };
    }

    pub inline fn asArray(self: *const Mat3x2) *const [6]f32 {
        return @ptrCast(&self.data);
    }
};

pub const Mat4x4 = extern struct {
    // [row][col]
    data: [4][4]f32,

    pub const identity = Mat4x4{
        .data = .{
            .{ 1, 0, 0, 0 },
            .{ 0, 1, 0, 0 },
            .{ 0, 0, 1, 0 },
            .{ 0, 0, 0, 1 },
        },
    };

    pub fn orthoOffcenter(left: f32, right: f32, bottom: f32, top: f32, near: f32, far: f32) Mat4x4 {
        var result = Mat4x4.identity;
        result.data[0][0] = 2 / (right - left);
        result.data[1][1] = 2 / (top - bottom);
        result.data[2][2] = 1 / (far - near);
        result.data[3][0] = (left + right) / (left - right);
        result.data[3][1] = (top + bottom) / (bottom - top);
        result.data[3][2] = near / (near - far);
        return result;
    }

    pub inline fn asArray(self: *const Mat4x4) *const [16]f32 {
        return @ptrCast(&self.data);
    }
};
