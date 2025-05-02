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

    const window = try app.createWindow(.{});
    const device = window.getDevice();
    const swapchain = window.getSwapchain();
    const queue = window.getQueue();

    const shader = try device.createShaderModuleHLSL("cube.hlsl", @embedFile("shaders/cube.hlsl"));
    defer shader.release();

    const vertex_attributes = [_]gpu.types.VertexAttribute{
        .{ .format = .float32x4, .offset = @offsetOf(Vertex, "pos"), .shader_location = 0 },
        .{ .format = .float32x2, .offset = @offsetOf(Vertex, "uv"), .shader_location = 1 },
    };

    const vertex_buffer_layout = gpu.types.VertexBufferLayout{
        .array_stride = @sizeOf(Vertex),
        .step_mode = .vertex,
        .attributes = &vertex_attributes,
    };

    const blend = gpu.types.BlendState{};
    const color_target = gpu.types.ColorTargetState{
        .format = .bgra8_unorm,
        .blend = &blend,
    };

    const bgle = gpu.BindGroupLayout.Entry{
        .binding = 0,
        .visibility = .{ .vertex = true },
        .buffer = .{ .type = .uniform, .has_dynamic_offset = true, .min_binding_size = 0 },
    };
    const bgl = try device.createBindGroupLayout(.{ .entries = &.{bgle} });
    defer bgl.release();

    const pipeline_layout = try device.createPipelineLayout(.{
        .bind_group_layouts = &.{bgl},
    });
    defer pipeline_layout.release();

    const pipeline = try device.createRenderPipeline(.{
        .layout = pipeline_layout,
        .vertex = .{ .module = shader, .entrypoint = "vertex_main", .buffers = &.{vertex_buffer_layout} },
        .fragment = &.{ .module = shader, .entrypoint = "frag_main", .targets = &.{color_target} },
        .primitive = .{ .cull_mode = .back },
    });

    const vertex_buffer = try device.createBuffer(.{
        .label = "vertex",
        .usage = .{ .vertex = true },
        .size = @sizeOf(Vertex) * vertices.len,
        .mapped_at_creation = true, // TODO: this should probably default to true
    });

    const map = vertex_buffer.getMappedRange(Vertex, 0, vertices.len);
    @memcpy(map, &vertices);
    try vertex_buffer.unmap();

    const uniform_buffer = try device.createBuffer(.{
        .label = "uniform",
        .usage = .{ .uniform = true, .copy_dst = true },
        .size = @sizeOf(Unfiorms),
        .mapped_at_creation = false,
    });

    const bind_group = try device.createBindGroup(.{
        .layout = bgl,
        .entries = &.{.{
            .binding = 0,
            .buffer = uniform_buffer,
            .offset = 0,
            .size = 1,
            .elem_size = @sizeOf(Unfiorms),
        }},
    });

    var timer = try prism.time.Timer.start();

    loop: while (true) : (window.presentFrame()) {
        for (window.getEvents()) |event| switch (event) {
            .close => break :loop,
            else => {},
        };

        const back_buffer_view = try swapchain.getCurrentTextureView();
        defer back_buffer_view.release();

        const encoder = try device.createCommandEncoder(.{});
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
            try queue.writeBuffer(uniform_buffer, 0, &[_]Unfiorms{.{ .mvp = mvp }});
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
        try render_pass.setVertexBuffer(0, vertex_buffer, 0, @sizeOf(Vertex) * vertices.len);
        try render_pass.setBindGroup(0, bind_group, &.{0});
        try render_pass.draw(vertices.len, 1, 0, 0);
        try render_pass.end();

        var command = try encoder.finish(.{});
        defer command.release();

        try queue.submit(&.{command});
    }
}
