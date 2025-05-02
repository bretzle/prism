const std = @import("std");
const gpu = @import("../gpu/gpu.zig");
const math = @import("../math/math.zig");

pub const Index = u32;

pub const Vertex = extern struct {
    pos: [2]f32,
    tex: [2]f32,
    color: [4]f32,

    mult: u8 = 0,
    wash: u8 = 0,
    fill: u8 = 0xFF,
    pad: u8 = 0,
};

pub const Uniforms = extern struct { mvp: math.Mat4x4 };

pub const Context = struct {
    view: *gpu.TextureView,
    pipeline: *gpu.RenderPipeline,
    bindgroup: *gpu.BindGroup,
};

const Batcher = @This();

device: *gpu.Device,
vertex_buffer: *gpu.Buffer,
index_buffer: *gpu.Buffer,
uniform_buffer: *gpu.Buffer,

vertices: std.ArrayListUnmanaged(Vertex) = .empty,
indices: std.ArrayListUnmanaged(Index) = .empty,
elements: u32 = 0,

context: Context = undefined,
state: enum { progress, idle } = .idle,
encoder: ?*gpu.CommandEncoder = null,
allocator: std.mem.Allocator,

pub fn create(allocator: std.mem.Allocator, device: *gpu.Device) !Batcher {
    const vertex_buffer = try device.createBuffer(.{
        .label = "batcher vertices",
        .usage = .{ .vertex = true, .copy_dst = true },
        .size = @sizeOf(Vertex) * 3000,
        .mapped_at_creation = true,
    });

    const index_buffer = try device.createBuffer(.{
        .label = "batcher indices",
        .usage = .{ .index = true, .copy_dst = true },
        .size = @sizeOf(Index) * 1000,
        .mapped_at_creation = true,
    });

    const uniform_buffer = try device.createBuffer(.{
        .label = "batcher uniforms",
        .usage = .{ .uniform = true, .copy_dst = true },
        .size = @sizeOf(Uniforms),
        .mapped_at_creation = true,
    });

    return Batcher{
        .allocator = allocator,
        .device = device,
        .vertex_buffer = vertex_buffer,
        .index_buffer = index_buffer,
        .uniform_buffer = uniform_buffer,
    };
}

pub fn deinit(_: *Batcher) void {
    // TODO
}

pub fn begin(self: *Batcher, context: Context) !void {
    if (self.state == .progress) return error.BeginCalledTwice;
    self.context = context;
    self.state = .progress;
    if (self.encoder == null) {
        self.encoder = try self.device.createCommandEncoder(.{ .label = "batcher encoder" });
    }
}

pub fn drawTriangle(self: *Batcher, p0: [2]f32, p1: [2]f32, p2: [2]f32, color: [4]f32) void {
    const vertices, const indices = self.reserve(3, 3);

    const idx: u32 = @intCast(self.vertices.items.len - 3);
    indices[0] = idx + 0;
    indices[1] = idx + 1;
    indices[2] = idx + 2;

    vertices[0] = .{ .pos = p0, .tex = @splat(0), .color = color };
    vertices[1] = .{ .pos = p1, .tex = @splat(0), .color = color };
    vertices[2] = .{ .pos = p2, .tex = @splat(0), .color = color };
}

pub fn end(self: *Batcher) !void {
    if (self.state == .idle) return error.EndCalledTwice;
    self.state = .idle;

    // begin render pass
    if (self.encoder) |encoder| {
        try encoder.writeBuffer(self.uniform_buffer, 0, &[_]Uniforms{.{ .mvp = .ident }});

        const pass = try encoder.beginRenderPass(.{
            .color_attachments = &[_]gpu.types.RenderPassColorAttachment{.{
                .view = self.context.view,
                .load_op = .clear,
                .store_op = .store,
                .clear_value = .{ .r = 0, .g = 0, .b = 0, .a = 1 },
            }},
        });

        try pass.setPipeline(self.context.pipeline);
        try pass.setVertexBuffer(0, self.vertex_buffer, 0, self.vertex_buffer.getSize());
        try pass.setIndexBuffer(self.index_buffer, .uint32, 0, self.index_buffer.getSize());
        try pass.setBindGroup(0, self.context.bindgroup, &.{});
        try pass.drawIndexed(@intCast(self.indices.items.len), 1, 0, 0, 0);
        try pass.end();

        pass.release();
    }
}

pub fn finish(self: *Batcher, queue: *gpu.Queue) !*gpu.CommandBuffer {
    if (self.encoder) |encoder| {
        defer {
            encoder.release();
            self.encoder = null;
        }

        const vertices = self.vertices.items;
        const indices = self.indices.items;

        // write buffers to queue
        if (vertices.len != 0) {
            try queue.writeBuffer(self.vertex_buffer, 0, vertices);
            try queue.writeBuffer(self.index_buffer, 0, indices);
        }

        // reset internal state
        self.elements = 0;
        self.vertices.items.len = 0;
        self.indices.items.len = 0;

        return try encoder.finish(.{ .label = "batcher commands" });
    } else return error.NoEncoder;
}

fn reserve(self: *Batcher, vtx_count: u32, idx_count: u32) struct { []Vertex, []u32 } {
    self.elements += @divExact(idx_count, 3);
    const idx = self.indices.addManyAsSlice(self.allocator, idx_count) catch unreachable;
    const vtx = self.vertices.addManyAsSlice(self.allocator, vtx_count) catch unreachable;

    return .{ vtx, idx };
}
