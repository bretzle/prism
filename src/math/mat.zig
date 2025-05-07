const std = @import("std");
const math = @import("math.zig");
const vec = @import("vec.zig");
const quat = @import("quat.zig");

pub fn Mat2x2(comptime Scalar: type) type {
    return extern struct {
        /// The column vectors of the matrix.
        ///
        /// ```
        /// [4]Vec4{
        ///     vec4( 1,  0,  0,  0),
        ///     vec4( 0,  1,  0,  0),
        ///     vec4( 0,  0,  1,  0),
        ///     vec4(tx, ty, tz, tw),
        /// }
        /// ```
        ///
        /// Use the create() constructor to write code which visually matches the same layout as you'd
        /// see used in scientific / maths communities.
        v: [cols]Vec,

        /// The number of columns, e.g. Mat3x4.cols == 3
        pub const cols = 2;

        /// The number of rows, e.g. Mat3x4.rows == 4
        pub const rows = 2;

        /// The scalar type of this matrix, e.g. Mat3x3.T == f32
        pub const T = Scalar;

        /// The underlying Vec type, e.g. Mat3x3.Vec == Vec3
        pub const Vec = vec.Vec2(Scalar);

        /// The Vec type corresponding to the number of rows, e.g. Mat3x3.RowVec == Vec3
        pub const RowVec = Vec;

        /// The Vec type corresponding to the numebr of cols, e.g. Mat3x4.ColVec = Vec4
        pub const ColVec = Vec;

        const Matrix = @This();

        const Shared = MatShared(RowVec, ColVec, Matrix);

        /// Identity matrix
        pub const ident = Matrix.create(
            &RowVec.create(1, 0),
            &RowVec.create(0, 1),
        );

        /// Constructs a 2x2 matrix with the given rows
        pub inline fn create(r0: *const RowVec, r1: *const RowVec) Matrix {
            return .{ .v = [_]Vec{
                Vec.create(r0.x(), r1.x()),
                Vec.create(r0.y(), r1.y()),
            } };
        }

        /// Returns the row `i` of the matrix.
        pub inline fn row(m: *const Matrix, i: usize) RowVec {
            // Note: we inline RowVec.create manually here as it is faster in debug builds.
            // return RowVec.create(m.v[0].v[i], m.v[1].v[i]);
            return .{ .v = .{ m.v[0].v[i], m.v[1].v[i] } };
        }

        /// Returns the column `i` of the matrix.
        pub inline fn col(m: *const Matrix, i: usize) RowVec {
            // Note: we inline RowVec.create manually here as it is faster in debug builds.
            // return RowVec.create(m.v[i].v[0], m.v[i].v[1]);
            return .{ .v = .{ m.v[i].v[0], m.v[i].v[1] } };
        }

        /// Transposes the matrix.
        pub inline fn transpose(m: *const Matrix) Matrix {
            return .{ .v = [_]Vec{
                Vec.create(m.v[0].v[0], m.v[1].v[0]),
                Vec.create(m.v[0].v[1], m.v[1].v[1]),
            } };
        }

        /// Constructs a 1D matrix which scales each dimension by the given scalar.
        pub inline fn scaleScalar(t: Vec.T) Matrix {
            return create(
                &RowVec.create(t, 0),
                &RowVec.create(0, 1),
            );
        }

        /// Constructs a 1D matrix which translates coordinates by the given scalar.
        pub inline fn translateScalar(t: Vec.T) Matrix {
            return create(
                &RowVec.create(1, t),
                &RowVec.create(0, 1),
            );
        }

        pub const mul = Shared.mul;
        pub const mulVec = Shared.mulVec;
        pub const format = Shared.format;
    };
}

pub fn Mat3x3(comptime Scalar: type) type {
    return extern struct {
        /// The column vectors of the matrix.
        ///
        /// ```
        /// [4]Vec4{
        ///     vec4( 1,  0,  0,  0),
        ///     vec4( 0,  1,  0,  0),
        ///     vec4( 0,  0,  1,  0),
        ///     vec4(tx, ty, tz, tw),
        /// }
        /// ```
        ///
        /// Use the create() constructor to write code which visually matches the same layout as you'd
        /// see used in scientific / maths communities.
        v: [cols]Vec,

        /// The number of columns, e.g. Mat3x4.cols == 3
        pub const cols = 3;

        /// The number of rows, e.g. Mat3x4.rows == 4
        pub const rows = 3;

        /// The scalar type of this matrix, e.g. Mat3x3.T == f32
        pub const T = Scalar;

        /// The underlying Vec type, e.g. Mat3x3.Vec == Vec3
        pub const Vec = vec.Vec3(Scalar);

        /// The Vec type corresponding to the number of rows, e.g. Mat3x3.RowVec == Vec3
        pub const RowVec = Vec;

        /// The Vec type corresponding to the numebr of cols, e.g. Mat3x4.ColVec = Vec4
        pub const ColVec = Vec;

        const Matrix = @This();

        const Shared = MatShared(RowVec, ColVec, Matrix);

        /// Identity matrix
        pub const ident = Matrix.create(
            &RowVec.create(1, 0, 0),
            &RowVec.create(0, 1, 0),
            &RowVec.create(0, 0, 1),
        );

        /// Constructs a 3x3 matrix with the given rows
        pub inline fn create(r0: *const RowVec, r1: *const RowVec, r2: *const RowVec) Matrix {
            return .{ .v = [_]Vec{
                Vec.create(r0.x(), r1.x(), r2.x()),
                Vec.create(r0.y(), r1.y(), r2.y()),
                Vec.create(r0.z(), r1.z(), r2.z()),
            } };
        }

        /// Returns the row `i` of the matrix.
        pub inline fn row(m: *const Matrix, i: usize) RowVec {
            // Note: we inline RowVec.create manually here as it is faster in debug builds.
            // return RowVec.create(m.v[0].v[i], m.v[1].v[i], m.v[2].v[i]);
            return .{ .v = .{ m.v[0].v[i], m.v[1].v[i], m.v[2].v[i] } };
        }

        /// Returns the column `i` of the matrix.
        pub inline fn col(m: *const Matrix, i: usize) RowVec {
            // Note: we inline RowVec.create manually here as it is faster in debug builds.
            // return RowVec.create(m.v[i].v[0], m.v[i].v[1], m.v[i].v[2]);
            return .{ .v = .{ m.v[i].v[0], m.v[i].v[1], m.v[i].v[2] } };
        }

        /// Transposes the matrix.
        pub inline fn transpose(m: *const Matrix) Matrix {
            return .{ .v = [_]Vec{
                Vec.create(m.v[0].v[0], m.v[1].v[0], m.v[2].v[0]),
                Vec.create(m.v[0].v[1], m.v[1].v[1], m.v[2].v[1]),
                Vec.create(m.v[0].v[2], m.v[1].v[2], m.v[2].v[2]),
            } };
        }

        /// Constructs a 2D matrix which scales each dimension by the given vector.
        pub inline fn scale(s: math.Vec2) Matrix {
            return create(
                &RowVec.create(s.x(), 0, 0),
                &RowVec.create(0, s.y(), 0),
                &RowVec.create(0, 0, 1),
            );
        }

        /// Constructs a 2D matrix which scales each dimension by the given scalar.
        pub inline fn scaleScalar(t: Vec.T) Matrix {
            return scale(math.Vec2.splat(t));
        }

        /// Constructs a 2D matrix which translates coordinates by the given vector.
        pub inline fn translate(t: math.Vec2) Matrix {
            return create(
                &RowVec.create(1, 0, t.x()),
                &RowVec.create(0, 1, t.y()),
                &RowVec.create(0, 0, 1),
            );
        }

        /// Constructs a 2D matrix which translates coordinates by the given scalar.
        pub inline fn translateScalar(t: Vec.T) Matrix {
            return translate(math.Vec2.splat(t));
        }

        /// Returns the translation component of the matrix.
        pub inline fn translation(t: Matrix) math.Vec2 {
            return math.Vec2.create(t.v[2].x(), t.v[2].y());
        }

        pub const mul = Shared.mul;
        pub const mulVec = Shared.mulVec;
        pub const format = Shared.format;
    };
}

pub fn Mat4x4(comptime Scalar: type) type {
    return extern struct {
        /// The column vectors of the matrix.
        ///
        /// ```
        /// [4]Vec4{
        ///     vec4( 1,  0,  0,  0),
        ///     vec4( 0,  1,  0,  0),
        ///     vec4( 0,  0,  1,  0),
        ///     vec4(tx, ty, tz, tw),
        /// }
        /// ```
        ///
        /// Use the create() constructor to write code which visually matches the same layout as you'd
        /// see used in scientific / maths communities.
        v: [cols]Vec,

        /// The number of columns, e.g. Mat3x4.cols == 3
        pub const cols = 4;

        /// The number of rows, e.g. Mat3x4.rows == 4
        pub const rows = 4;

        /// The scalar type of this matrix, e.g. Mat3x3.T == f32
        pub const T = Scalar;

        /// The underlying Vec type, e.g. Mat3x3.Vec == Vec3
        pub const Vec = vec.Vec4(Scalar);

        /// The Vec type corresponding to the number of rows, e.g. Mat3x3.RowVec == Vec3
        pub const RowVec = Vec;

        /// The Vec type corresponding to the numebr of cols, e.g. Mat3x4.ColVec = Vec4
        pub const ColVec = Vec;

        const Matrix = @This();

        const Shared = MatShared(RowVec, ColVec, Matrix);

        /// Identity matrix
        pub const ident = Matrix.create(
            &Vec.create(1, 0, 0, 0),
            &Vec.create(0, 1, 0, 0),
            &Vec.create(0, 0, 1, 0),
            &Vec.create(0, 0, 0, 1),
        );

        /// Constructs a 4x4 matrix with the given rows
        pub inline fn create(r0: *const RowVec, r1: *const RowVec, r2: *const RowVec, r3: *const RowVec) Matrix {
            return .{ .v = [_]Vec{
                Vec.create(r0.x(), r1.x(), r2.x(), r3.x()),
                Vec.create(r0.y(), r1.y(), r2.y(), r3.y()),
                Vec.create(r0.z(), r1.z(), r2.z(), r3.z()),
                Vec.create(r0.w(), r1.w(), r2.w(), r3.w()),
            } };
        }

        /// Returns the row `i` of the matrix.
        pub inline fn row(m: *const Matrix, i: usize) RowVec {
            return RowVec{ .v = RowVec.Vector{ m.v[0].v[i], m.v[1].v[i], m.v[2].v[i], m.v[3].v[i] } };
        }

        /// Returns the column `i` of the matrix.
        pub inline fn col(m: *const Matrix, i: usize) RowVec {
            return RowVec{ .v = RowVec.Vector{ m.v[i].v[0], m.v[i].v[1], m.v[i].v[2], m.v[i].v[3] } };
        }

        /// Transposes the matrix.
        pub inline fn transpose(m: *const Matrix) Matrix {
            return .{ .v = [_]Vec{
                Vec.create(m.v[0].v[0], m.v[1].v[0], m.v[2].v[0], m.v[3].v[0]),
                Vec.create(m.v[0].v[1], m.v[1].v[1], m.v[2].v[1], m.v[3].v[1]),
                Vec.create(m.v[0].v[2], m.v[1].v[2], m.v[2].v[2], m.v[3].v[2]),
                Vec.create(m.v[0].v[3], m.v[1].v[3], m.v[2].v[3], m.v[3].v[3]),
            } };
        }

        /// Constructs a 3D matrix which scales each dimension by the given vector.
        pub inline fn scale(s: math.Vec3) Matrix {
            return create(
                &RowVec.create(s.x(), 0, 0, 0),
                &RowVec.create(0, s.y(), 0, 0),
                &RowVec.create(0, 0, s.z(), 0),
                &RowVec.create(0, 0, 0, 1),
            );
        }

        /// Constructs a 3D matrix which scales each dimension by the given scalar.
        pub inline fn scaleScalar(s: Vec.T) Matrix {
            return scale(math.Vec3.splat(s));
        }

        /// Constructs a 3D matrix which translates coordinates by the given vector.
        pub inline fn translate(t: math.Vec3) Matrix {
            return create(
                &RowVec.create(1, 0, 0, t.x()),
                &RowVec.create(0, 1, 0, t.y()),
                &RowVec.create(0, 0, 1, t.z()),
                &RowVec.create(0, 0, 0, 1),
            );
        }

        /// Constructs a 3D matrix which translates coordinates by the given scalar.
        pub inline fn translateScalar(t: Vec.T) Matrix {
            return translate(math.Vec3.splat(t));
        }

        /// Returns the translation component of the matrix.
        pub inline fn translation(t: *const Matrix) math.Vec3 {
            return math.Vec3.create(t.v[3].x(), t.v[3].y(), t.v[3].z());
        }

        /// Constructs a 3D matrix which rotates around the X axis by `angle_radians`.
        pub inline fn rotateX(angle_radians: f32) Matrix {
            const c = math.cos(angle_radians);
            const s = math.sin(angle_radians);
            return Matrix.create(
                &RowVec.create(1, 0, 0, 0),
                &RowVec.create(0, c, -s, 0),
                &RowVec.create(0, s, c, 0),
                &RowVec.create(0, 0, 0, 1),
            );
        }

        /// Constructs a 3D matrix which rotates around the X axis by `angle_radians`.
        pub inline fn rotateY(angle_radians: f32) Matrix {
            const c = math.cos(angle_radians);
            const s = math.sin(angle_radians);
            return Matrix.create(
                &RowVec.create(c, 0, s, 0),
                &RowVec.create(0, 1, 0, 0),
                &RowVec.create(-s, 0, c, 0),
                &RowVec.create(0, 0, 0, 1),
            );
        }

        /// Constructs a 3D matrix which rotates around the Z axis by `angle_radians`.
        pub inline fn rotateZ(angle_radians: f32) Matrix {
            const c = math.cos(angle_radians);
            const s = math.sin(angle_radians);
            return Matrix.create(
                &RowVec.create(c, -s, 0, 0),
                &RowVec.create(s, c, 0, 0),
                &RowVec.create(0, 0, 1, 0),
                &RowVec.create(0, 0, 0, 1),
            );
        }

        //https://www.euclideanspace.com/maths/geometry/rotations/conversions/quaternionToMatrix/jay.htm
        //Requires a normalized quaternion
        pub inline fn rotateByQuaternion(quaternion: quat.Quat(T)) Matrix {
            const qx = quaternion.v.x();
            const qy = quaternion.v.y();
            const qz = quaternion.v.z();
            const qw = quaternion.v.w();

            return Matrix.create(
                &RowVec.create(1 - 2 * qy * qy - 2 * qz * qz, 2 * qx * qy - 2 * qz * qw, 2 * qx * qz + 2 * qy * qw, 0),
                &RowVec.create(2 * qx * qy + 2 * qz * qw, 1 - 2 * qx * qx - 2 * qz * qz, 2 * qy * qz - 2 * qx * qw, 0),
                &RowVec.create(2 * qx * qz - 2 * qy * qw, 2 * qy * qz + 2 * qx * qw, 1 - 2 * qx * qx - 2 * qy * qy, 0),
                &RowVec.create(0, 0, 0, 1),
            );
        }

        /// Constructs a 2D projection matrix, aka. an orthographic projection matrix.
        ///
        /// First, a cuboid is defined with the parameters:
        ///
        /// * (right - left) defining the distance between the left and right faces of the cube
        /// * (top - bottom) defining the distance between the top and bottom faces of the cube
        /// * (near - far) defining the distance between the back (near) and front (far) faces of the cube
        pub inline fn projection2D(v: struct {
            left: f32,
            right: f32,
            bottom: f32,
            top: f32,
            near: f32,
            far: f32,
        }) Matrix {
            var p = Matrix.ident;
            p = p.mul(&Matrix.translate(math.vec3(
                (v.right + v.left) / (v.left - v.right), // translate X so that the middle of (left, right) maps to x=0 in clip space
                (v.top + v.bottom) / (v.bottom - v.top), // translate Y so that the middle of (bottom, top) maps to y=0 in clip space
                v.far / (v.far - v.near), // translate Z so that far maps to z=0
            )));
            p = p.mul(&Matrix.scale(math.vec3(
                2 / (v.right - v.left), // scale X so that [left, right] has a 2 unit range, e.g. [-1, +1]
                2 / (v.top - v.bottom), // scale Y so that [bottom, top] has a 2 unit range, e.g. [-1, +1]
                1 / (v.near - v.far), // scale Z so that [near, far] has a 1 unit range, e.g. [0, -1]
            )));
            return p;
        }

        pub inline fn lookAt(eye: vec.Vec3(T), focus: vec.Vec3(T), up: vec.Vec3(T)) Matrix {
            return lookToLh(eye, eye.sub(&focus), up);
        }

        pub inline fn lookToLh(pos: vec.Vec3(T), dir: vec.Vec3(T), up: vec.Vec3(T)) Matrix {
            const az = dir.normalize(0);
            const ax = up.cross(&az).normalize(0);
            const ay = az.cross(&ax).normalize(0);

            return Matrix.create(
                &RowVec.create(ax.x(), ax.y(), ax.z(), -ax.dot(&pos)),
                &RowVec.create(ay.x(), ay.y(), ay.z(), -ay.dot(&pos)),
                &RowVec.create(az.x(), az.y(), az.z(), -az.dot(&pos)),
                &RowVec.create(0, 0, 0, 1),
            ).transpose();
        }

        pub fn perspectiveFov(fovy: f32, aspect: f32, near: f32, far: f32) Matrix {
            const sin = @sin(fovy * 0.5);
            const cos = @cos(fovy * 0.5);

            const h = cos / sin;
            const w = h / aspect;
            const r = far / (near - far);
            return Matrix.create(
                &RowVec.create(w, 0, 0, 0),
                &RowVec.create(0, h, 0, 0),
                &RowVec.create(0, 0, r, -1),
                &RowVec.create(0, 0, r * near, 0),
            );
        }

        pub fn ortho(width: f32, height: f32) Matrix {
            return Matrix.create(
                &RowVec.create(2.0 / width, 0, 0, 0),
                &RowVec.create(0, -2.0 / height, 0, 0),
                &RowVec.create(0, 0, 1, 0),
                &RowVec.create(-1, 1, 0, 1),
            );
        }

        pub const mul = Shared.mul;
        pub const mulVec = Shared.mulVec;
        pub const eql = Shared.eql;
        pub const eqlApprox = Shared.eqlApprox;
        pub const format = Shared.format;
    };
}

pub fn MatShared(comptime RowVec: type, comptime ColVec: type, comptime Matrix: type) type {
    return struct {
        /// Matrix multiplication a*b
        pub inline fn mul(a: *const Matrix, b: *const Matrix) Matrix {
            @setEvalBranchQuota(10000);
            var result: Matrix = undefined;
            inline for (0..Matrix.rows) |row| {
                inline for (0..Matrix.cols) |col| {
                    var sum: RowVec.T = 0.0;
                    inline for (0..RowVec.n) |i| {
                        // Note: we directly access rows/columns below as it is much faster **in
                        // debug builds**, instead of using these helpers:
                        //
                        // sum += a.row(row).mul(&b.col(col)).v[i];
                        sum += a.v[i].v[row] * b.v[col].v[i];
                    }
                    result.v[col].v[row] = sum;
                }
            }
            return result;
        }

        /// Matrix * Vector multiplication
        pub inline fn mulVec(matrix: *const Matrix, vector: *const ColVec) ColVec {
            var result = [_]ColVec.T{0} ** ColVec.n;
            inline for (0..Matrix.rows) |row| {
                inline for (0..ColVec.n) |i| {
                    result[i] += matrix.v[row].v[i] * vector.v[row];
                }
            }
            return ColVec{ .v = result };
        }

        /// Check if two matrices are approximately equal. Returns true if the absolute difference between
        /// each element in matrix is less than or equal to the specified tolerance.
        pub inline fn eqlApprox(a: *const Matrix, b: *const Matrix, tolerance: ColVec.T) bool {
            inline for (0..Matrix.rows) |row| {
                if (!ColVec.eqlApprox(&a.v[row], &b.v[row], tolerance)) {
                    return false;
                }
            }
            return true;
        }

        /// Check if two matrices are approximately equal. Returns true if the absolute difference between
        /// each element in matrix is less than or equal to the epsilon tolerance.
        pub inline fn eql(a: *const Matrix, b: *const Matrix) bool {
            inline for (0..Matrix.rows) |row| {
                if (!ColVec.eql(&a.v[row], &b.v[row])) {
                    return false;
                }
            }
            return true;
        }

        /// Custom format function for all matrix types.
        pub inline fn format(self: Matrix, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) @TypeOf(writer).Error!void {
            const rows = @TypeOf(self).rows;
            try writer.print("{{", .{});
            inline for (0..rows) |r| {
                try std.fmt.formatType(self.row(r), fmt, options, writer, 1);
                if (r < rows - 1) {
                    try writer.print(", ", .{});
                }
            }
            try writer.print("}}", .{});
        }
    };
}
