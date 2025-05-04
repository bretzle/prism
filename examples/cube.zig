const std = @import("std");
const prism = @import("prism");
const gpu = prism.gpu;
const math = prism.math;

const Vertex = @import("common/cube_mesh.zig").Vertex;
const vertices = @import("common/cube_mesh.zig").vertices;
const vec3 = math.vec3;

const Unfiorms = extern struct {
    mvp: math.Mat4x4,
};

pub fn main() !void {
    var app = try prism.Application.create();
    defer app.deinit();

    const window = try app.createWindow(.{ .width = 100, .height = 100 });
    const device = window.getDevice();
    const swapchain = window.getSwapchain();

    const shader = try device.createShaderModule(.hlsl, @embedFile("shaders/cube.hlsl"));
    defer shader.release();

    // const vertex_attributes = [_]gpu.types.VertexAttribute{
    //     .{ .format = .float32x4, .offset = @offsetOf(Vertex, "pos"), .shader_location = 0 },
    //     .{ .format = .float32x2, .offset = @offsetOf(Vertex, "uv"), .shader_location = 1 },
    // };

    // const vertex_buffer_layout = gpu.types.VertexBufferLayout{
    //     .array_stride = @sizeOf(Vertex),
    //     .step_mode = .vertex,
    //     .attributes = &vertex_attributes,
    // };

    const blend = gpu.types.BlendState{};
    const color_target = gpu.types.ColorTargetState{
        .format = .bgra8_unorm,
        .blend = &blend,
    };

    const pipeline = try device.createRenderPipeline(.{
        .vertex = .{ .module = shader, .entrypoint = "vertex_main" },
        .fragment = .{ .module = shader, .entrypoint = "frag_main", .targets = &.{color_target} },
        .primitive = .{ .cull_mode = .back },
    });
    defer pipeline.release();

    const vertex_buffer = try device.createBuffer(.{
        .usage = .{ .vertex = true },
        .size = @sizeOf(Vertex) * vertices.len,
        .data = std.mem.sliceAsBytes(&vertices),
    });
    defer vertex_buffer.release();

    const uniform_buffer = try device.createBuffer(.{
        .usage = .{ .uniform = true, .copy_dst = true },
        .size = @sizeOf(Unfiorms),
    });
    defer uniform_buffer.release();
    var timer = try prism.time.Timer.start();

    loop: while (true) : (window.presentFrame()) {
        for (window.getEvents()) |event| switch (event) {
            .close => break :loop,
            else => {},
        };

        const back_buffer_view = try swapchain.getCurrentTextureView();
        defer back_buffer_view.release();

        const encoder = try device.createCommandEncoder();
        defer encoder.release();

        // write mvp
        {
            const time = timer.read();
            const model = math.Mat4x4.mul(&.rotateX(time * math.pi / 2.0), &.rotateZ(time * math.pi / 2.0));
            const view = math.Mat4x4.lookAt(
                vec3(0, 4, 2),
                vec3(0, 0, 0),
                vec3(0, 0, 1),
            );
            const proj = math.Mat4x4.perspectiveFov(math.pi / 4.0, window.aspectRatio(), 0.1, 10);
            const mvp = model.mul(&view).mul(&proj);
            try encoder.writeBuffer(uniform_buffer, 0, &[_]Unfiorms{.{ .mvp = mvp }});
        }

        const render_pass = try encoder.beginRenderPass(.{
            .color_attachments = &[_]gpu.types.RenderPassColorAttachment{.{
                .view = back_buffer_view,
                .clear_value = .{ .r = 0, .g = 0, .b = 0, .a = 0 },
                .load_op = .clear,
                .store_op = .store,
            }},
        });
        defer render_pass.release();

        try render_pass.setPipeline(pipeline);
        try render_pass.setVertexBuffer(0, vertex_buffer, 0, @sizeOf(Vertex));
        try render_pass.setUniformBuffer(0, uniform_buffer);
        try render_pass.draw(vertices.len, 1, 0, 0);
        try render_pass.end();

        var command = try encoder.finish();
        defer command.release();

        try device.submit(&.{command});
    }
}
