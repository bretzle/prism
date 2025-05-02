const std = @import("std");
const prism = @import("prism");
const gpu = prism.gpu;
const math = prism.math;

const Vertex = prism.gfx.Batcher.Vertex;

pub fn main() !void {
    var app = try prism.Application.create();
    defer app.deinit();

    const window = try app.createWindow(.{});
    const device = window.getDevice();
    const swapchain = window.getSwapchain();
    const queue = window.getQueue();

    var batcher = try prism.gfx.Batcher.create(prism.allocator, device);
    defer batcher.deinit();

    // const shader = try device.createShaderModuleWGSL("batch", @embedFile("shaders/batch.wgsl"));
    const shader = try device.createShaderModuleHLSL("batch", @embedFile("shaders/batch.hlsl"));
    defer shader.release();

    const vertex_buffer_layout = gpu.types.VertexBufferLayout{
        .array_stride = @sizeOf(Vertex),
        .attributes = &.{
            .{ .format = .float32x2, .offset = @offsetOf(Vertex, "pos"), .shader_location = 0 },
            .{ .format = .float32x2, .offset = @offsetOf(Vertex, "tex"), .shader_location = 1 },
            .{ .format = .float32x4, .offset = @offsetOf(Vertex, "color"), .shader_location = 2 },
            .{ .format = .unorm8x4, .offset = @offsetOf(Vertex, "mult"), .shader_location = 3 },
        },
    };

    const bgl = try device.createBindGroupLayout(.{
        .entries = &.{
            .newBuffer(0, .{ .vertex = true }, .uniform, false, 0),
            .newTexture(1, .{ .fragment = true }, .float, .@"2d", false),
            .newSampler(2, .{ .fragment = true }, .filtering),
        },
    });

    const layout = try device.createPipelineLayout(.{
        .bind_group_layouts = &.{bgl},
    });

    const blend = gpu.types.BlendState{};
    const color_target = gpu.types.ColorTargetState{
        .format = .bgra8_unorm,
        .blend = &blend,
    };

    const pipeline = try device.createRenderPipeline(.{
        .layout = layout,
        .vertex = .{ .module = shader, .entrypoint = "vertex_main", .buffers = &.{vertex_buffer_layout} },
        .fragment = &.{ .module = shader, .entrypoint = "fragment_main", .targets = &.{color_target} },
    });
    defer pipeline.release();

    const sampler = try device.createSampler(.{ .mag_filter = .linear, .min_filter = .linear });
    defer sampler.release();

    const diffuse_texture = try device.createTexture(.{
        .usage = .{ .texture_binding = true, .copy_dst = true },
        .size = .{ .width = 1, .height = 1 },
        .format = .bgra8_unorm,
    });
    defer diffuse_texture.release();

    const diffuse_view = try diffuse_texture.createView(.{});
    defer diffuse_texture.release();

    const bindgroup = try device.createBindGroup(.{
        .layout = pipeline.getBindGroupLayout(0),
        .entries = &.{
            .newBuffer(0, batcher.uniform_buffer, 0, @sizeOf(prism.gfx.Batcher.Uniforms)),
            .newTextureView(1, diffuse_view),
            .newSampler(2, sampler),
        },
    });
    defer bindgroup.release();

    loop: while (true) : (window.presentFrame()) {
        for (window.getEvents()) |event| switch (event) {
            .close => break :loop,
            else => {},
        };

        const view = try swapchain.getCurrentTextureView();
        defer view.release();

        try batcher.begin(.{
            .view = view,
            .pipeline = pipeline,
            .bindgroup = bindgroup,
            // .clear_color = .{ .r = 1, .g = 0, .b = 0, .a = 1 },
        });

        batcher.drawTriangle(.{ 0, 0 }, .{ 0, 0.5 }, .{ 0.5, 0 }, .{ 0, 1, 0, 1 });

        try batcher.end();

        const command = try batcher.finish(queue);
        defer command.release();

        try queue.submit(&.{command});
    }
}
