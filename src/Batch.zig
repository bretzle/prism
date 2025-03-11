const std = @import("std");
const math = @import("math.zig");
const gpu = @import("gpu.zig");
const Color = @import("Color.zig").Color;
const Vec2 = math.Vec2;

pub const ColorMode = enum { normal, wash };

pub const Vertex = extern struct {
    pos: Vec2,
    tex: Vec2,
    col: Color,

    mult: u8 = 0,
    wash: u8 = 0,
    fill: u8 = 0xFF,
    pad: u8 = 0,
};

const DrawBatch = struct {
    layer: u32 = 0,
    offset: u32 = 0,
    elements: u32 = 0,
    blend: gpu.BlendMode = .normal,
    texture: gpu.TextureId = .invalid,
    sampler: gpu.TextureSampler = .{},
    flip_vertically: bool = false,
    scissor: math.Rect = .{ .x = 0, .y = 0, .w = -1, .h = -1 },
};

const batch_shader_source = @embedFile("batch_shader.hlsl");
const batch_shader_data = gpu.ShaderDesc{
    .vertex = batch_shader_source,
    .fragment = batch_shader_source,
    .hlsl_attributes = std.BoundedArray(gpu.ShaderDesc.HLSLAttribute, 16).fromSlice(&.{
        .{ .name = "POS" },
        .{ .name = "TEX" },
        .{ .name = "COL" },
        .{ .name = "MASK" },
    }) catch unreachable,
};

const format = gpu.VertexFormat{
    .stride = @sizeOf(Vertex),
    .attributes = std.BoundedArray(gpu.VertexAttribute, 16).fromSlice(&.{
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

bindings: gpu.Bindings,
pipeline: gpu.PipelineId,
shader: gpu.ShaderId,

matrix: math.Mat3x2 = .identity,
color_mode: ColorMode = .normal,
tex_mult: u8 = 255,
tex_wash: u8 = 0,
batch: DrawBatch,
vertices: std.ArrayList(Vertex),
indices: std.ArrayList(u32),
matrix_stack: std.ArrayList(math.Mat3x2),
scissor_stack: std.ArrayList(math.Rect),
blend_stack: std.ArrayList(gpu.BlendMode),
color_mode_stack: std.ArrayList(ColorMode),
layer_stack: std.ArrayList(u32),
batches: std.ArrayList(DrawBatch),
batch_insert: u32 = 0,

idx_ptr: [*]u32 = &[0]u32{},
vtx_ptr: [*]Vertex = &[0]Vertex{},

pub fn create(allocator: std.mem.Allocator) !Self {
    const shader = try gpu.createShader(batch_shader_data);

    const ibuf = gpu.createBuffer(.empty(u32, .index, 100));
    const vbuf = gpu.createBuffer(.empty(Vertex, .vertex, 100));

    const bindings = gpu.Bindings{
        .index_buffer = ibuf,
        .vertex_buffer = vbuf,
    };

    const pipeline = gpu.createPipeline(.{
        .shader = shader,
        .format = format,
    });

    return .{
        .bindings = bindings,
        .pipeline = pipeline,
        .shader = shader,

        .batch = .{},
        .vertices = .init(allocator),
        .indices = .init(allocator),
        .matrix_stack = .init(allocator),
        .scissor_stack = .init(allocator),
        .blend_stack = .init(allocator),
        .color_mode_stack = .init(allocator),
        .layer_stack = .init(allocator),
        .batches = .init(allocator),
    };
}

pub fn pushMatrix(self: *Self, mat: math.Mat3x2) void {
    self.matrix_stack.append(mat) catch unreachable;
    self.matrix = mat.mul(self.matrix);
}

pub fn popMatrix(self: *Self) math.Mat3x2 {
    const was = self.matrix;
    self.matrix = self.matrix_stack.pop().?;
    return was;
}

pub fn render(self: *Self, size: math.Point) void {
    if ((self.batches.items.len <= 0 and self.batch.elements <= 0) or self.indices.items.len <= 0) return;

    const matrix = math.Mat4x4.orthoOffcenter(0, @floatFromInt(size.x), @floatFromInt(size.y), 0, 0.1, 1000);

    // upload data
    gpu.updateBuffer(self.bindings.index_buffer, std.mem.sliceAsBytes(self.indices.items));
    gpu.updateBuffer(self.bindings.vertex_buffer, std.mem.sliceAsBytes(self.vertices.items));

    for (0..self.batches.items.len) |i| {
        if (self.batch_insert == i and self.batch.elements > 0) {
            self.renderSingleBatch(&self.batch, &matrix);
        }

        self.renderSingleBatch(&self.batches.items[i], &matrix);
    }

    if (self.batch_insert == self.batches.items.len and self.batch.elements > 0) {
        self.renderSingleBatch(&self.batch, &matrix);
    }
}

fn renderSingleBatch(self: *Self, b: *const DrawBatch, matrix: *const math.Mat4x4) void {
    self.bindings.textures.buffer[0] = b.texture;
    self.bindings.samplers.buffer[0] = b.sampler;

    self.bindings.textures.len = 1;
    self.bindings.samplers.len = 1;

    gpu.beginPass(.backbuffer, .default);
    gpu.applyPipeline(self.pipeline);
    gpu.applyBindings(self.bindings);
    gpu.applyUniforms(self.shader, .vertex, matrix.asArray());
    gpu.draw(b.offset * 3, b.elements * 3, 0);
    gpu.endPass();
}

pub fn clear(self: *Self) void {
    self.matrix = .identity;
    self.vertices.items.len = 0;
    self.indices.items.len = 0;
    self.batch = .{};
    self.matrix_stack.items.len = 0;
}

pub fn drawRect(self: *Self, rect: math.Rect, color: Color) void {
    self.reserve(6, 4);
    self.pushRect(.{ .x = rect.x, .y = rect.y }, .{ .x = rect.x + rect.w, .y = rect.y + rect.h }, color);
}

pub fn drawTexture(self: *Self, tex: gpu.TextureId, pos: Vec2) void {
    self.setTexture(tex);

    const width, const height = gpu.textureSizef(tex);

    self.reserve(6, 4);
    self.pushRectUV(pos, .{ .x = pos.x + width, .y = pos.y + height }, .white);
}

fn reserve(self: *Self, idx_count: u32, vtx_count: u32) void {
    std.debug.assert(idx_count % 3 == 0);
    std.debug.assert(vtx_count % 2 == 0);

    self.batch.elements += @divExact(idx_count, 3);
    self.idx_ptr = (self.indices.addManyAsSlice(idx_count) catch unreachable).ptr;
    self.vtx_ptr = (self.vertices.addManyAsSlice(vtx_count) catch unreachable).ptr;
}

fn pushRect(self: *Self, a: Vec2, c: Vec2, col: Color) void {
    const b = Vec2{ .x = c.x, .y = a.y };
    const d = Vec2{ .x = a.x, .y = c.y };

    defer {
        self.idx_ptr += 6;
        self.vtx_ptr += 4;
    }

    const idx: u32 = @intCast(self.vertices.items.len - 4);
    self.idx_ptr[0] = idx;
    self.idx_ptr[1] = idx + 1;
    self.idx_ptr[2] = idx + 2;
    self.idx_ptr[3] = idx;
    self.idx_ptr[4] = idx + 2;
    self.idx_ptr[5] = idx + 3;

    self.vtx_ptr[0] = .{ .pos = self.matrix.apply(a), .tex = .zero, .col = col };
    self.vtx_ptr[1] = .{ .pos = self.matrix.apply(b), .tex = .zero, .col = col };
    self.vtx_ptr[2] = .{ .pos = self.matrix.apply(c), .tex = .zero, .col = col };
    self.vtx_ptr[3] = .{ .pos = self.matrix.apply(d), .tex = .zero, .col = col };
}

fn pushRectUV(self: *Self, a: Vec2, c: Vec2, col: Color) void {
    const b = Vec2{ .x = c.x, .y = a.y };
    const d = Vec2{ .x = a.x, .y = c.y };

    defer {
        self.idx_ptr += 6;
        self.vtx_ptr += 4;
    }

    const idx: u32 = @intCast(self.vertices.items.len - 4);
    self.idx_ptr[0] = idx;
    self.idx_ptr[1] = idx + 1;
    self.idx_ptr[2] = idx + 2;
    self.idx_ptr[3] = idx;
    self.idx_ptr[4] = idx + 2;
    self.idx_ptr[5] = idx + 3;

    self.vtx_ptr[0] = .{ .pos = self.matrix.apply(a), .mult = 0xFF, .fill = 0, .tex = .{ .x = 0, .y = 0 }, .col = col };
    self.vtx_ptr[1] = .{ .pos = self.matrix.apply(b), .mult = 0xFF, .fill = 0, .tex = .{ .x = 1, .y = 0 }, .col = col };
    self.vtx_ptr[2] = .{ .pos = self.matrix.apply(c), .mult = 0xFF, .fill = 0, .tex = .{ .x = 1, .y = 1 }, .col = col };
    self.vtx_ptr[3] = .{ .pos = self.matrix.apply(d), .mult = 0xFF, .fill = 0, .tex = .{ .x = 0, .y = 1 }, .col = col };
}

fn setTexture(self: *Self, tex: gpu.TextureId) void {
    if (self.batch.elements > 0 and self.batch.texture != .invalid and tex != self.batch.texture) {
        unreachable;
    }

    if (self.batch.texture != tex) {
        self.batch.texture = tex;
    }
}
