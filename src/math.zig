const std = @import("std");

pub const Vec2f = Vec2(f32);
pub const Vec2i = Vec2(i32);
pub const Point = Vec2(i32);
pub const Vec3f = Vec3(f32);
pub const Vec4f = Vec4(f32);
pub const Mat3x2f = Mat3x2(f32);
pub const Mat4x4f = Mat4x4(f32);
pub const Rectf = Rect(f32);
pub const Recti = Rect(i32);
pub const Quadf = Quad(f32);
pub const Linef = Line(f32);
pub const Circlef = Circle(f32);

pub fn Vec2(comptime T: type) type {
    return extern struct {
        const Self = @This();

        x: T,
        y: T,

        pub const zero = Self{ .x = 0, .y = 0 };
        pub const one = Self{ .x = 1, .y = 1 };
    };
}

pub fn Vec3(comptime T: type) type {
    return extern struct {
        const Self = @This();

        x: T,
        y: T,
        z: T,
    };
}

pub fn Vec4(comptime T: type) type {
    return extern struct {
        const Self = @This();

        x: T,
        y: T,
        z: T,
        w: T,
    };
}

pub fn Rect(comptime T: type) type {
    return extern struct {
        const Self = @This();

        x: T = 0,
        y: T = 0,
        w: T = 0,
        h: T = 0,
    };
}

pub fn Circle(comptime T: type) type {
    return extern struct {
        const Self = @This();

        center: Vec2(T),
        radius: T,
    };
}

pub fn Quad(comptime T: type) type {
    return extern struct {
        const Self = @This();

        a: Vec2(T),
        b: Vec2(T),
        c: Vec2(T),
        d: Vec2(T),
    };
}

pub fn Line(comptime T: type) type {
    return extern struct {
        const Self = @This();

        a: Vec2(T),
        b: Vec2(T),
    };
}

pub fn Mat3x2(comptime T: type) type {
    return extern struct {
        const Self = @This();

        data: [3][2]T = .{ .{ 0, 0 }, .{ 0, 0 }, .{ 0, 0 } },

        pub const identity = Self{ .data = .{ .{ 1, 0 }, .{ 0, 1 }, .{ 0, 0 } } };

        pub fn transform(position: Vec2(T), origin: Vec2(T), scale: Vec2(T), rotation: T) Self {
            var matrix = Self.identity;
            if (origin.x != 0 or origin.y != 0)
                // matrix = create_translation(-origin.x, -origin.y);
                unreachable;
            if (scale.x != 1 or scale.y != 1)
                // matrix = matrix * create_scale(scale);
                unreachable;
            if (rotation != 0)
                // matrix = matrix * create_rotation(rotation);
                unreachable;
            if (position.x != 0 or position.y != 0)
                matrix = matrix.mul(&translation(position));
            return matrix;
        }

        pub fn translation(position: Vec2(T)) Self {
            return Self{
                .data = .{
                    .{ 1, 0 },
                    .{ 0, 1 },
                    .{ position.x, position.y },
                },
            };
        }

        pub fn mul(a: *const Self, b: *const Self) Self {
            const am = a.data;
            const bm = b.data;

            return Self{
                .data = .{
                    .{ am[0][0] * bm[0][0] + am[0][1] * bm[1][0], am[0][0] * bm[0][1] + am[0][1] * bm[1][1] },
                    .{ am[1][0] * bm[0][0] + am[1][1] * bm[1][0], am[1][0] * bm[0][1] + am[1][1] * bm[1][1] },
                    .{ am[2][0] * bm[0][0] + am[2][1] * bm[1][0] + bm[2][0], am[2][0] * bm[0][1] + am[2][1] * bm[1][1] + bm[2][1] },
                },
            };
        }
    };
}

pub fn Mat4x4(comptime T: type) type {
    return extern struct {
        const Self = @This();

        // [row][col]
        data: [4][4]T = .{.{ 0, 0, 0, 0 }} ** 4,

        pub const identity = Self{
            .data = .{
                .{ 1, 0, 0, 0 },
                .{ 0, 1, 0, 0 },
                .{ 0, 0, 1, 0 },
                .{ 0, 0, 0, 1 },
            },
        };

        pub fn orthoOffcenter(left: T, right: T, bottom: T, top: T, near: T, far: T) Self {
            var result = Self.identity;
            result.data[0][0] = 2 / (right - left);
            result.data[1][1] = 2 / (top - bottom);
            result.data[2][2] = 1 / (far - near);
            result.data[3][0] = (left + right) / (left - right);
            result.data[3][1] = (top + bottom) / (bottom - top);
            result.data[3][2] = near / (near - far);
            return result;
        }
    };
}

pub const eql = std.meta.eql;

// meta helpers

fn scalar(comptime T: type) type {
    const First = @typeInfo(T).@"struct".fields[0].type;
    return switch (@typeInfo(First)) {
        .int, .float => First,
        .@"struct" => scalar(First),
        else => unreachable,
    };
}

fn assertIsVector(comptime T: type) void {
    const S = scalar(T);
    switch (T) {
        Vec2(S), Vec3(S), Vec4(S) => {},
        else => comptime unreachable,
    }
}
