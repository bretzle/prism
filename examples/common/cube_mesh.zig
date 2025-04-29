const math = @import("prism").math;
const vec2 = math.vec2;
const vec4 = math.vec4;

pub const Vertex = extern struct {
    pos: math.Vec4,
    col: math.Vec4,
    uv: math.Vec2,
};

// zig fmt: off
pub const vertices = [_]Vertex{
    .{ .pos = vec4( 1, -1,  1, 1), .col = vec4(1, 0, 1, 1), .uv = vec2(0, 1) },
    .{ .pos = vec4(-1, -1,  1, 1), .col = vec4(0, 0, 1, 1), .uv = vec2(1, 1) },
    .{ .pos = vec4(-1, -1, -1, 1), .col = vec4(0, 0, 0, 1), .uv = vec2(1, 0) },
    .{ .pos = vec4( 1, -1, -1, 1), .col = vec4(1, 0, 0, 1), .uv = vec2(0, 0) },
    .{ .pos = vec4( 1, -1,  1, 1), .col = vec4(1, 0, 1, 1), .uv = vec2(0, 1) },
    .{ .pos = vec4(-1, -1, -1, 1), .col = vec4(0, 0, 0, 1), .uv = vec2(1, 0) },

    .{ .pos = vec4(1,  1,  1, 1), .col = vec4(1, 1, 1, 1), .uv = vec2(0, 1) },
    .{ .pos = vec4(1, -1,  1, 1), .col = vec4(1, 0, 1, 1), .uv = vec2(1, 1) },
    .{ .pos = vec4(1, -1, -1, 1), .col = vec4(1, 0, 0, 1), .uv = vec2(1, 0) },
    .{ .pos = vec4(1,  1, -1, 1), .col = vec4(1, 1, 0, 1), .uv = vec2(0, 0) },
    .{ .pos = vec4(1,  1,  1, 1), .col = vec4(1, 1, 1, 1), .uv = vec2(0, 1) },
    .{ .pos = vec4(1, -1, -1, 1), .col = vec4(1, 0, 0, 1), .uv = vec2(1, 0) },

    .{ .pos = vec4(-1, 1,  1, 1), .col = vec4(0, 1, 1, 1), .uv = vec2(0, 1) },
    .{ .pos = vec4( 1, 1,  1, 1), .col = vec4(1, 1, 1, 1), .uv = vec2(1, 1) },
    .{ .pos = vec4( 1, 1, -1, 1), .col = vec4(1, 1, 0, 1), .uv = vec2(1, 0) },
    .{ .pos = vec4(-1, 1, -1, 1), .col = vec4(0, 1, 0, 1), .uv = vec2(0, 0) },
    .{ .pos = vec4(-1, 1,  1, 1), .col = vec4(0, 1, 1, 1), .uv = vec2(0, 1) },
    .{ .pos = vec4( 1, 1, -1, 1), .col = vec4(1, 1, 0, 1), .uv = vec2(1, 0) },

    .{ .pos = vec4(-1, -1,  1, 1), .col = vec4(0, 0, 1, 1), .uv = vec2(0, 1) },
    .{ .pos = vec4(-1,  1,  1, 1), .col = vec4(0, 1, 1, 1), .uv = vec2(1, 1) },
    .{ .pos = vec4(-1,  1, -1, 1), .col = vec4(0, 1, 0, 1), .uv = vec2(1, 0) },
    .{ .pos = vec4(-1, -1, -1, 1), .col = vec4(0, 0, 0, 1), .uv = vec2(0, 0) },
    .{ .pos = vec4(-1, -1,  1, 1), .col = vec4(0, 0, 1, 1), .uv = vec2(0, 1) },
    .{ .pos = vec4(-1,  1, -1, 1), .col = vec4(0, 1, 0, 1), .uv = vec2(1, 0) },

    .{ .pos = vec4( 1,  1, 1, 1), .col = vec4(1, 1, 1, 1), .uv = vec2(0, 1) },
    .{ .pos = vec4(-1,  1, 1, 1), .col = vec4(0, 1, 1, 1), .uv = vec2(1, 1) },
    .{ .pos = vec4(-1, -1, 1, 1), .col = vec4(0, 0, 1, 1), .uv = vec2(1, 0) },
    .{ .pos = vec4(-1, -1, 1, 1), .col = vec4(0, 0, 1, 1), .uv = vec2(1, 0) },
    .{ .pos = vec4( 1, -1, 1, 1), .col = vec4(1, 0, 1, 1), .uv = vec2(0, 0) },
    .{ .pos = vec4( 1,  1, 1, 1), .col = vec4(1, 1, 1, 1), .uv = vec2(0, 1) },

    .{ .pos = vec4( 1, -1, -1, 1), .col = vec4(1, 0, 0, 1), .uv = vec2(0, 1) },
    .{ .pos = vec4(-1, -1, -1, 1), .col = vec4(0, 0, 0, 1), .uv = vec2(1, 1) },
    .{ .pos = vec4(-1,  1, -1, 1), .col = vec4(0, 1, 0, 1), .uv = vec2(1, 0) },
    .{ .pos = vec4( 1,  1, -1, 1), .col = vec4(1, 1, 0, 1), .uv = vec2(0, 0) },
    .{ .pos = vec4( 1, -1, -1, 1), .col = vec4(1, 0, 0, 1), .uv = vec2(0, 1) },
    .{ .pos = vec4(-1,  1, -1, 1), .col = vec4(0, 1, 0, 1), .uv = vec2(1, 0) },
};
// zig fmt: on
