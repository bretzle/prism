const std = @import("std");
const gpu = @import("../gpu/gpu.zig");
const math = @import("../math/math.zig");

const List = std.ArrayListUnmanaged;

const Uniforms = extern struct {
    mvp: math.Mat4x4,
};

const Vertex = extern struct {
    pos: [2]f32,
    uv: [2]f32,
    col: Color,

    mult: u8 = 0,
    wash: u8 = 0,
    fill: u8 = 0xFF,
    pad: u8 = 0,
};

pub const Color = extern struct {
    r: u8 = 0,
    g: u8 = 0,
    b: u8 = 0,
    a: u8 = 0xFF,

    pub const red = rgb(255, 0, 0);
    pub const green = rgb(0, 255, 0);
    pub const blue = rgb(0, 0, 255);
    pub const purple = rgb(255, 0, 255);
    pub const yellow = rgb(255, 255, 0);
    pub const cyan = rgb(0, 255, 255);
    pub const black = rgb(0, 0, 0);
    pub const white = rgb(255, 255, 255);

    pub inline fn rgb(r: u8, g: u8, b: u8) Color {
        return Color{ .r = r, .g = g, .b = b };
    }
};

const Batch = struct {
    offset: u32 = 0,
    elements: u32 = 0,
    // breaks batches
    texture: ?*gpu.TextureView = null,
    sampler: ?*gpu.Sampler = null,
};

const Painter = @This();

pipeline: *gpu.RenderPipeline,

index_buffer: *gpu.Buffer,
vertex_buffer: *gpu.Buffer,
uniform_buffer: *gpu.Buffer,

vertices: List(Vertex) = .empty,
indices: List(u32) = .empty,
batches: List(Batch),
alllocator: std.mem.Allocator,

pub fn create(allocator: std.mem.Allocator, device: *gpu.Device, replacement_shader: ?*gpu.ShaderModule) !*Painter {
    const shader = replacement_shader orelse try device.createShaderModule(.hlsl, @embedFile("painter.hlsl"));

    const vertex_layout = gpu.types.VertexBufferLayout{
        .array_stride = @sizeOf(Vertex),
        .step_mode = .vertex,
        .attributes = &.{
            .{ .name = "POS", .offset = @offsetOf(Vertex, "pos"), .format = .float32x2 },
            .{ .name = "TEX", .offset = @offsetOf(Vertex, "uv"), .format = .float32x2 },
            .{ .name = "COL", .offset = @offsetOf(Vertex, "col"), .format = .unorm8x4 },
            .{ .name = "MASK", .offset = @offsetOf(Vertex, "mult"), .format = .unorm8x4 },
        },
    };

    const blend = gpu.types.BlendState{
        .color = .{ .src_factor = .one, .dst_factor = .one_minus_src_alpha, .operation = .add },
        .alpha = .{ .src_factor = .one_minus_dst_alpha, .dst_factor = .one, .operation = .add },
    };
    const color_target = gpu.types.ColorTargetState{
        .format = .bgra8_unorm,
        .blend = &blend,
        .write_mask = .all,
    };

    const pipeline = try device.createRenderPipeline(.{
        .vertex = .{ .module = shader, .entrypoint = "vs_main", .layout = vertex_layout },
        .fragment = .{ .module = shader, .entrypoint = "ps_main", .targets = &.{color_target} },
    });

    const vertex_buffer = try device.createBuffer(.{
        .usage = .{ .vertex = true, .copy_dst = true },
        .size = @sizeOf(Vertex) * 1024,
    });

    const index_buffer = try device.createBuffer(.{
        .usage = .{ .index = true, .copy_dst = true },
        .size = @sizeOf(Vertex) * 1024 * 3,
    });

    const uniform_buffer = try device.createBuffer(.{
        .usage = .{ .uniform = true, .copy_dst = true },
        .size = @sizeOf(Uniforms),
    });

    var batches = try List(Batch).initCapacity(allocator, 4);
    batches.appendAssumeCapacity(.{});

    const self = try allocator.create(Painter);
    self.* = .{
        .pipeline = pipeline,
        .vertex_buffer = vertex_buffer,
        .index_buffer = index_buffer,
        .uniform_buffer = uniform_buffer,
        .batches = batches,
        .alllocator = allocator,
    };

    return self;
}

pub fn render(self: *Painter, encoder: *gpu.CommandEncoder, view: *gpu.TextureView) !void {
    if (self.indices.items.len == 0) return;

    const mvp = math.Mat4x4.ortho(@floatFromInt(view.width()), @floatFromInt(view.height()));

    try encoder.writeBuffer(self.uniform_buffer, 0, &[1]Uniforms{.{ .mvp = mvp }});
    try encoder.writeBuffer(self.index_buffer, 0, self.indices.items);
    try encoder.writeBuffer(self.vertex_buffer, 0, self.vertices.items);

    const pass = try encoder.beginRenderPass(.{
        .color_attachments = &[_]gpu.types.RenderPassColorAttachment{.{
            .view = view,
            .clear_value = .{ .r = 0.1, .g = 0.1, .b = 0.1, .a = 0 },
            .load_op = .clear,
            .store_op = .store,
        }},
    });

    try pass.setPipeline(self.pipeline);
    try pass.setVertexBuffer(0, self.vertex_buffer, 0, @sizeOf(Vertex));
    try pass.setIndexBuffer(self.index_buffer, .uint32, 0);
    try pass.setUniformBuffer(0, self.uniform_buffer);

    for (self.batches.items) |*b| {
        if (b.texture != null and b.sampler != null)
            try pass.setTexture(0, b.texture.?, b.sampler.?);
        try pass.drawIndexed(b.elements, 1, b.offset, 0, 0);
    }

    try pass.end();
    pass.release();

    self.indices.clearRetainingCapacity();
    self.vertices.clearRetainingCapacity();

    self.batches.clearRetainingCapacity();
    self.batches.appendAssumeCapacity(.{});
}

fn reserve(self: *Painter, vtx_count: u32, idx_count: u32) !struct { []Vertex, []u32 } {
    self.batch().elements += idx_count;
    return .{
        try self.vertices.addManyAsSlice(self.alllocator, vtx_count),
        try self.indices.addManyAsSlice(self.alllocator, idx_count),
    };
}

pub fn drawTri(self: *Painter, a: [2]f32, b: [2]f32, c: [2]f32, col: Color) !void {
    const idx: u32 = @intCast(self.vertices.items.len);
    const vertices, const indices = try self.reserve(3, 3);
    indices[0] = idx;
    indices[1] = idx + 1;
    indices[2] = idx + 2;

    vertices[0] = .{ .pos = a, .uv = .{ 0, 0 }, .col = col };
    vertices[1] = .{ .pos = b, .uv = .{ 0, 0 }, .col = col };
    vertices[2] = .{ .pos = c, .uv = .{ 0, 0 }, .col = col };
}

pub fn drawRect(self: *Painter, rect: [4]f32, col: Color) !void {
    try self.pushRect(.{ rect[0], rect[1] }, .{ rect[0] + rect[2], rect[1] + rect[3] }, col);
}

pub fn drawTexture(self: *Painter, texture: *gpu.TextureView, sampler: *gpu.Sampler, pos: [2]f32, col: Color) !void {
    var b = self.batch();
    if (b.texture != texture or b.sampler != sampler) {
        if (b.texture != null and b.sampler != null) {
            b = try self.addBatch();
        }
        b.texture = texture;
        b.sampler = sampler;
    }

    const width: f32 = @floatFromInt(texture.width());
    const height: f32 = @floatFromInt(texture.height());

    try self.pushQuad(pos, .{ pos[0] + width, pos[1] + height }, col);
}

inline fn batch(self: *Painter) *Batch {
    return &self.batches.items[self.batches.items.len - 1];
}

inline fn addBatch(self: *Painter) !*Batch {
    const b = try self.batches.addOne(self.alllocator);
    b.* = .{ .offset = @intCast(self.indices.items.len) };
    return b;
}

fn pushRect(self: *Painter, a: [2]f32, c: [2]f32, col: Color) !void {
    const b = [2]f32{ c[0], a[1] };
    const d = [2]f32{ a[0], c[1] };

    const idx: u32 = @intCast(self.vertices.items.len);
    const vertices, const indices = try self.reserve(4, 6);
    indices[0] = idx;
    indices[1] = idx + 1;
    indices[2] = idx + 2;
    indices[3] = idx;
    indices[4] = idx + 2;
    indices[5] = idx + 3;

    vertices[0] = .{ .pos = a, .uv = .{ 0, 0 }, .col = col };
    vertices[1] = .{ .pos = b, .uv = .{ 0, 0 }, .col = col };
    vertices[2] = .{ .pos = c, .uv = .{ 0, 0 }, .col = col };
    vertices[3] = .{ .pos = d, .uv = .{ 0, 0 }, .col = col };
}

fn pushQuad(self: *Painter, a: [2]f32, c: [2]f32, col: Color) !void {
    const b = [2]f32{ c[0], a[1] };
    const d = [2]f32{ a[0], c[1] };

    const idx: u32 = @intCast(self.vertices.items.len);
    const vertices, const indices = try self.reserve(4, 6);
    indices[0] = idx;
    indices[1] = idx + 1;
    indices[2] = idx + 2;
    indices[3] = idx;
    indices[4] = idx + 2;
    indices[5] = idx + 3;

    vertices[0] = .{ .pos = a, .uv = .{ 0, 0 }, .col = col, .mult = 0xFF, .fill = 0 };
    vertices[1] = .{ .pos = b, .uv = .{ 1, 0 }, .col = col, .mult = 0xFF, .fill = 0 };
    vertices[2] = .{ .pos = c, .uv = .{ 1, 1 }, .col = col, .mult = 0xFF, .fill = 0 };
    vertices[3] = .{ .pos = d, .uv = .{ 0, 1 }, .col = col, .mult = 0xFF, .fill = 0 };
}
