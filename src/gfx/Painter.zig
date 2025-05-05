const std = @import("std");
const gpu = @import("../newgpu/gpu.zig");
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

    pub inline fn rgb(r: u8, g: u8, b: u8) Color {
        return Color{ .r = r, .g = g, .b = b };
    }
};

const Painter = @This();

pipeline: *gpu.RenderPipeline,

index_buffer: *gpu.Buffer,
vertex_buffer: *gpu.Buffer,
uniform_buffer: *gpu.Buffer,

vertices: List(Vertex) = .empty,
indices: List(u32) = .empty,
alllocator: std.mem.Allocator,

pub fn create(allocator: std.mem.Allocator, device: *gpu.Device) !*Painter {
    const shader = try device.createShaderModule(.hlsl, @embedFile("painter.hlsl"));

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

    const self = try allocator.create(Painter);
    self.* = .{
        .pipeline = pipeline,
        .vertex_buffer = vertex_buffer,
        .index_buffer = index_buffer,
        .uniform_buffer = uniform_buffer,
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
    try pass.drawIndexed(@intCast(self.indices.items.len), 1, 0, 0, 0);
    try pass.end();
    pass.release();

    self.indices.clearRetainingCapacity();
    self.vertices.clearRetainingCapacity();
}

fn reserve(self: *Painter, vtx_count: u32, idx_count: u32) !struct { []Vertex, []u32 } {
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

    vertices[0] = .{ .pos = a, .uv = @splat(0), .col = col };
    vertices[1] = .{ .pos = b, .uv = @splat(0), .col = col };
    vertices[2] = .{ .pos = c, .uv = @splat(0), .col = col };
}
