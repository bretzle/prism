const std = @import("std");
const math = @import("math.zig");
const gfx = @import("gfx.zig");
const Color = @import("Color.zig").Color;

pub const ColorMode = enum { normal, wash };

pub const Vertex = extern struct {
    pos: math.Vec2f,
    tex: math.Vec2f,
    col: Color,

    mult: u8,
    wash: u8,
    fill: u8,
    pad: u8 = 0,
};

const batch_shader_source = @embedFile("batch_shader.hlsl");
const batch_shader_data = gfx.ShaderData{
    .vertex = batch_shader_source,
    .fragment = batch_shader_source,
    .hlsl_attributes = std.BoundedArray(gfx.ShaderData.HLSLAttribute, 16).fromSlice(&.{
        .{ .semantic_name = "POS" },
        .{ .semantic_name = "TEX" },
        .{ .semantic_name = "COL" },
        .{ .semantic_name = "MASK" },
    }) catch unreachable,
};

const format = gfx.VertexFormat{
    .stride = 8 + 8 + 4 + 4,
    .attributes = std.BoundedArray(gfx.VertexAttribute, 16).fromSlice(&.{
        .{ .index = 0, .type = .float2, .normalized = false },
        .{ .index = 1, .type = .float2, .normalized = false },
        .{ .index = 2, .type = .ubyte4, .normalized = true },
        .{ .index = 3, .type = .ubyte4, .normalized = true },
    }) catch unreachable,
};

pub const texture_uniform = "u_texture";
pub const sampler_uniform = "u_texture_sampler";
pub const matrix_uniform = "u_matrix";

const Self = @This();

default_material: *gfx.Material,
mesh: *gfx.Mesh,
matrix: math.Mat3x2f = .identity,
color_mode: ColorMode = .normal,
tex_mult: u8 = 255,
tex_wash: u8 = 0,
batch: DrawBatch,
vertices: std.ArrayList(Vertex),
indices: std.ArrayList(u32),
matrix_stack: std.ArrayList(math.Mat3x2f),
scissor_stack: std.ArrayList(math.Rectf),
blend_stack: std.ArrayList(gfx.BlendMode),
material_stack: std.ArrayList(*gfx.Material),
color_mode_stack: std.ArrayList(ColorMode),
layer_stack: std.ArrayList(u32),
batches: std.ArrayList(DrawBatch),
batch_insert: u32 = 0,

pub fn create(allocator: std.mem.Allocator) !Self {
    const shader = try gfx.Shader.create(allocator, &batch_shader_data);

    return .{
        .default_material = try gfx.Material.create(allocator, shader),
        .mesh = try gfx.Mesh.create(allocator),
        .batch = .{},
        .vertices = .init(allocator),
        .indices = .init(allocator),
        .matrix_stack = .init(allocator),
        .scissor_stack = .init(allocator),
        .blend_stack = .init(allocator),
        .material_stack = .init(allocator),
        .color_mode_stack = .init(allocator),
        .layer_stack = .init(allocator),
        .batches = .init(allocator),
    };
}

pub fn pushMatrix(self: *Self, mat: math.Mat3x2f) void {
    self.matrix_stack.append(mat) catch unreachable;
    self.matrix = mat.mul(&self.matrix);
}

pub fn popMatrix(self: *Self) math.Mat3x2f {
    const was = self.matrix;
    self.matrix = self.matrix_stack.pop().?;
    return was;
}

pub fn render(self: *Self, target: *gfx.Target) void {
    if ((self.batches.items.len <= 0 and self.batch.elements <= 0) or self.indices.items.len <= 0) return;

    const matrix = math.Mat4x4f.orthoOffcenter(0, @floatFromInt(target.getWidth()), @floatFromInt(target.getHeight()), 0, 0.1, 1000);

    // upload data
    self.mesh.indexData(.u32, std.mem.sliceAsBytes(self.indices.items), self.indices.items.len);
    self.mesh.vertexData(format, std.mem.sliceAsBytes(self.vertices.items), self.vertices.items.len);

    var pass = gfx.DrawCall{
        .target = target,
        .mesh = self.mesh,
        .material = undefined,
        .has_viewport = false,
        .viewport = .{},
        .instance_count = 0,
        .depth = .none,
        .cull = .none,
    };

    for (0..self.batches.items.len) |i| {
        if (self.batch_insert == i and self.batch.elements > 0) {
            self.renderSingleBatch(&pass, &self.batch, &matrix);
        }

        self.renderSingleBatch(&pass, &self.batches.items[i], &matrix);
    }

    if (self.batch_insert == self.batches.items.len and self.batch.elements > 0) {
        self.renderSingleBatch(&pass, &self.batch, &matrix);
    }
}

fn renderSingleBatch(self: *Self, pass: *gfx.DrawCall, b: *const DrawBatch, matrix: *const math.Mat4x4f) void {
    pass.material = b.material orelse self.default_material;

    if (pass.material.hasValue(texture_uniform)) {
        pass.material.setTexture(texture_uniform, b.texture, 0);
    } else {
        pass.material.setTexture2(0, b.texture);
    }

    if (pass.material.hasValue(sampler_uniform)) {
        pass.material.setSampler(sampler_uniform, b.sampler, 0);
    } else {
        pass.material.setSampler2(0, b.sampler);
    }

    pass.material.setValue(matrix_uniform, matrix);

    pass.blend = b.blend;
    pass.has_scissor = b.scissor.w >= 0 and b.scissor.h >= 0;
    pass.scissor = b.scissor;
    pass.index_start = b.offset * 3;
    pass.index_count = b.elements * 3;

    pass.perform();
}

pub fn clear(self: *Self) void {
    self.matrix = .identity;
    self.vertices.items.len = 0;
    self.indices.items.len = 0;
    self.batch = .{};
    self.matrix_stack.items.len = 0;
}

pub fn drawRect(self: *Self, rect: math.Rectf, color: Color) void {
    self.PUSH_QUAD(rect.x, rect.y, rect.x + rect.w, rect.y, rect.x + rect.w, rect.y + rect.h, rect.x, rect.y + rect.h, 0, 0, 0, 0, 0, 0, 0, 0, color, color, color, color, 0, 0, 255);
}

inline fn PUSH_QUAD(self: *Self, px0: anytype, py0: anytype, px1: anytype, py1: anytype, px2: anytype, py2: anytype, px3: anytype, py3: anytype, tx0: anytype, ty0: anytype, tx1: anytype, ty1: anytype, tx2: anytype, ty2: anytype, tx3: anytype, ty3: anytype, col0: anytype, col1: anytype, col2: anytype, col3: anytype, mult: anytype, fill: anytype, wash: anytype) void {
    self.batch.elements += 2;
    const indices = self.indices.addManyAsArray(6) catch unreachable;
    const idx: u32 = @intCast(self.vertices.items.len);
    indices.* = .{ idx + 0, idx + 1, idx + 2, idx + 0, idx + 2, idx + 3 };

    const vertices = self.vertices.addManyAsArray(4) catch unreachable;
    vertices.* = .{
        MAKE_VERTEX(self.matrix, px0, py0, tx0, ty0, col0, mult, fill, wash),
        MAKE_VERTEX(self.matrix, px1, py1, tx1, ty1, col1, mult, fill, wash),
        MAKE_VERTEX(self.matrix, px2, py2, tx2, ty2, col2, mult, fill, wash),
        MAKE_VERTEX(self.matrix, px3, py3, tx3, ty3, col3, mult, fill, wash),
    };
}

inline fn MAKE_VERTEX(mat: anytype, px: anytype, py: anytype, tx: anytype, ty: anytype, c: anytype, m: anytype, w: anytype, f: anytype) Vertex {
    return Vertex{
        .pos = .{
            .x = (px * mat.m11) + (py * mat.m21) + mat.m31,
            .y = (px * mat.m12) + (py * mat.m22) + mat.m32,
        },
        .tex = .{ .x = tx, .y = ty },
        .col = c,
        .mult = m,
        .wash = w,
        .fill = f,
    };
}

const DrawBatch = struct {
    layer: u32 = 0,
    offset: u32 = 0,
    elements: u32 = 0,
    material: ?*gfx.Material = null,
    blend: gfx.BlendMode = .normal,
    texture: ?*gfx.Texture = null,
    sampler: gfx.TextureSampler = .{},
    flip_vertically: bool = false,
    scissor: math.Rectf = .{ .x = 0, .y = 0, .w = -1, .h = -1 },
};
