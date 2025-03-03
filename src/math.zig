const std = @import("std");

pub const Vec2f = Vec2(f32);
pub const Vec2d = Vec2(f64);
pub const Vec2i = Vec2(i32);
pub const Point = Vec2(i32);
pub const Vec3f = Vec3(f32);
pub const Vec3d = Vec3(f64);
pub const Vec4f = Vec4(f32);
pub const Vec4d = Vec4(f64);
pub const Mat3x2f = Mat3x2(f32);
pub const Mat3x2d = Mat3x2(f64);
pub const Mat4x4f = Mat4x4(f32);
pub const Mat4x4d = Mat4x4(f64);
pub const Rectf = Rect(f32);
pub const Rectd = Rect(f64);
pub const Recti = Rect(i32);
pub const Quadf = Quad(f32);
pub const Quadd = Quad(f64);
pub const Linef = Line(f32);
pub const Lined = Line(f64);
pub const Circlef = Circle(f32);
pub const Circled = Circle(f64);

pub fn Vec2(comptime T: type) type {
    return extern struct {
        const Self = @This();

        x: T,
        y: T,

        pub const zero = Self{ .x = 0, .y = 0 };
        pub const one = Self{ .x = 1, .y = 1 };

        pub inline fn eq(a: Self, b: Self) bool {
            return a.x == b.x and a.y == b.y;
        }
    };
}

pub fn Vec3(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,
        z: T,
    };
}

pub fn Vec4(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T,
        y: T,
        z: T,
        w: T,
    };
}

pub fn Rect(comptime T: type) type {
    return struct {
        const Self = @This();

        x: T = 0,
        y: T = 0,
        w: T = 0,
        h: T = 0,
    };
}

pub fn Circle(comptime T: type) type {
    return struct {
        const Self = @This();

        center: Vec2(T),
        radius: T,
    };
}

pub fn Quad(comptime T: type) type {
    return struct {
        const Self = @This();

        a: Vec2(T),
        b: Vec2(T),
        c: Vec2(T),
        d: Vec2(T),
    };
}

pub fn Line(comptime T: type) type {
    return struct {
        const Self = @This();

        a: Vec2(T),
        b: Vec2(T),
    };
}

pub fn Mat3x2(comptime T: type) type {
    return struct {
        const Self = @This();

        m11: T = 0,
        m12: T = 0,
        m21: T = 0,
        m22: T = 0,
        m31: T = 0,
        m32: T = 0,

        pub const identity = Self{ .m11 = 1, .m22 = 1 };

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
                .m11 = 1,
                .m12 = 0,
                .m21 = 0,
                .m22 = 1,
                .m31 = position.x,
                .m32 = position.y,
            };
        }

        pub fn mul(a: *const Self, b: *const Self) Self {
            return Self{
                .m11 = a.m11 * b.m11 + a.m12 * b.m21,
                .m12 = a.m11 * b.m12 + a.m12 * b.m22,
                .m21 = a.m21 * b.m11 + a.m22 * b.m21,
                .m22 = a.m21 * b.m12 + a.m22 * b.m22,
                .m31 = a.m31 * b.m11 + a.m32 * b.m21 + b.m31,
                .m32 = a.m31 * b.m12 + a.m32 * b.m22 + b.m32,
            };
        }
    };
}

pub fn Mat4x4(comptime T: type) type {
    return struct {
        const Self = @This();

        m11: T = 0,
        m12: T = 0,
        m13: T = 0,
        m14: T = 0,

        m21: T = 0,
        m22: T = 0,
        m23: T = 0,
        m24: T = 0,

        m31: T = 0,
        m32: T = 0,
        m33: T = 0,
        m34: T = 0,

        m41: T = 0,
        m42: T = 0,
        m43: T = 0,
        m44: T = 0,

        pub const identity = Self{ .m11 = 1, .m22 = 1, .m33 = 1, .m44 = 1 };

        pub fn orthoOffcenter(left: T, right: T, bottom: T, top: T, near: T, far: T) Self {
            return Self{
                .m11 = 2 / (right - left),
                .m22 = 2 / (top - bottom),
                .m33 = 1 / (near - far),
                .m41 = (left + right) / (left - right),
                .m42 = (top + bottom) / (bottom - top),
                .m43 = near / (near - far),
                .m44 = 1,
            };
        }
    };
}
