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

    const window = try app.createWindow(.{ .width = 800, .height = 800 });
    const device = window.getDevice();
    const swapchain = window.getSwapchain();
    // const queue = window.getQueue();

    const shader = try device.createShaderModule(.hlsl, @embedFile("shaders/fractal.hlsl"));
    defer shader.release();

    // const vertex_attributes = [_]gpu.types.VertexAttribute{
    //     .{ .format = .float32x4, .offset = @offsetOf(Vertex, "pos"), .shader_location = 0 },
    //     .{ .format = .float32x2, .offset = @offsetOf(Vertex, "uv"), .shader_location = 1 },
    // };

    // const vertex_buffer_layout = gpu.types.VertexBufferLayout{
    //     .array_stride = @sizeOf(Vertex),
    //     .attributes = &vertex_attributes,
    // };

    const blend = gpu.types.BlendState{};
    const color_target = gpu.types.ColorTargetState{
        .format = .bgra8_unorm,
        .blend = &blend,
    };

    // const bgl = try device.createBindGroupLayout(.{
    //     .entries = &.{
    //         .newBuffer(0, .{ .vertex = true }, .uniform, true, 0),
    //         .newSampler(1, .{ .fragment = true }, .filtering),
    //         .newTexture(2, .{ .fragment = true }, .float, .@"2d", false),
    //     },
    // });
    // defer bgl.release();

    // const pipeline_layout = try device.createPipelineLayout(.{
    //     .bind_group_layouts = &.{bgl},
    // });
    // defer pipeline_layout.release();

    const pipeline = try device.createRenderPipeline(.{
        .vertex = .{ .module = shader, .entrypoint = "vertex_main" },
        .fragment = .{ .module = shader, .entrypoint = "frag_main", .targets = &.{color_target} },
        .depth_stencil = .{ .format = .depth24_plus, .depth_write_enabled = true, .depth_compare = .less },
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
        .usage = .{ .copy_dst = true, .uniform = true },
        .size = @sizeOf(Unfiorms),
    });
    defer uniform_buffer.release();

    // The texture to put on the cube
    const cube_texture = try device.createTexture(.{
        .usage = .{ .texture_binding = true, .copy_dst = true },
        .size = .{ .width = window.width(), .height = window.height() },
        .format = .bgra8_unorm,
    });

    // The texture on which we render
    const cube_texture_render = try device.createTexture(.{
        .usage = .{ .render_attachment = true, .copy_src = true },
        .size = .{ .width = window.width(), .height = window.height() },
        .format = .bgra8_unorm,
    });

    const sampler = try device.createSampler(.{
        .mag_filter = .linear,
        .min_filter = .linear,
    });

    const cube_texture_view = try cube_texture.createView(.{
        .format = .bgra8_unorm,
        .dimension = .@"2d",
        .mip_level_count = 1,
        .array_layer_count = 1,
    });
    const cube_texture_view_render = try cube_texture_render.createView(.{
        .format = .bgra8_unorm,
        .dimension = .@"2d",
        .mip_level_count = 1,
        .array_layer_count = 1,
    });

    // const bind_group = try device.createBindGroup(.{
    //     .layout = bgl,
    //     .entries = &.{
    //         .newBuffer(0, uniform_buffer, 0, @sizeOf(Unfiorms)),
    //         .newSampler(1, sampler),
    //         .newTextureView(2, cube_texture_view),
    //     },
    // });

    const depth_texture = try device.createTexture(.{
        .usage = .{ .render_attachment = true },
        .size = .{ .width = window.width(), .height = window.height() },
        .format = .depth24_plus,
    });
    const depth_texture_view = try depth_texture.createView(.{
        .format = .depth24_plus,
        .dimension = .@"2d",
        .array_layer_count = 1,
        .mip_level_count = 1,
    });

    // defer {
    //     cube_texture.release();
    //     cube_texture_render.release();
    //     sampler.release();
    //     cube_texture_view.release();
    //     cube_texture_view_render.release();
    //     bind_group.release();
    //     depth_texture.release();
    //     depth_texture_view.release();
    // }

    var timer = try prism.time.Timer.start();

    loop: while (true) : (window.presentFrame()) {
        for (window.getEvents()) |event| switch (event) {
            .close => break :loop,
            else => {},
        };

        const back_buffer_view = try swapchain.getCurrentTextureView();
        defer back_buffer_view.release();

        const cube_color_attachment = gpu.types.RenderPassColorAttachment{
            .view = cube_texture_view_render,
            .clear_value = .{ .r = 0.5, .g = 0.5, .b = 0.5, .a = 1 },
            .load_op = .clear,
            .store_op = .store,
        };
        const color_attachment = gpu.types.RenderPassColorAttachment{
            .view = back_buffer_view,
            .clear_value = .{ .r = 0.5, .g = 0.5, .b = 0.5, .a = 1 },
            .load_op = .clear,
            .store_op = .store,
        };

        const depth_stencil_attachment = gpu.types.RenderPassDepthStencilAttachment{
            .view = depth_texture_view,
            .depth_load_op = .clear,
            .depth_store_op = .store,
            .depth_clear_value = 1.0,
        };

        const encoder = try device.createCommandEncoder();
        defer encoder.release();

        const cube_render_pass_info = gpu.types.RenderPassDescriptor{
            .color_attachments = &.{cube_color_attachment},
            .depth_stencil_attachment = &depth_stencil_attachment,
        };
        const render_pass_info = gpu.types.RenderPassDescriptor{
            .color_attachments = &.{color_attachment},
            .depth_stencil_attachment = &depth_stencil_attachment,
        };

        {
            const time = timer.read();
            const model = math.Mat4x4.mul(&.rotateX(time * math.pi / 2.0), &.rotateZ(time * math.pi / 2.0));
            const view = math.Mat4x4.lookAt(
                vec3(0, -4, 0),
                vec3(0, 0, 0),
                vec3(0, 0, 1),
            );
            const proj = math.Mat4x4.perspectiveFov(math.pi * 2.0 / 5.0, window.aspectRatio(), 1, 100);
            const mvp = model.mul(&view).mul(&proj);
            try encoder.writeBuffer(uniform_buffer, 0, &[_]Unfiorms{.{ .mvp = mvp }});
        }

        const pass = try encoder.beginRenderPass(render_pass_info);
        try pass.setPipeline(pipeline);
        // try pass.setBindGroup(0, bind_group, &.{0});
        try pass.setVertexBuffer(0, vertex_buffer, 0, @sizeOf(Vertex));
        try pass.setUniformBuffer(0, uniform_buffer);
        try pass.setTexture(0, cube_texture_view, sampler);
        try pass.draw(vertices.len, 1, 0, 0);
        try pass.end();
        pass.release();

        // try encoder.copyTexture(
        //     .{ .texture = cube_texture_render },
        //     .{ .texture = cube_texture },
        //     .{ .width = window.width(), .height = window.height() },
        // );

        const cube_pass = try encoder.beginRenderPass(cube_render_pass_info);
        try cube_pass.setPipeline(pipeline);
        // try cube_pass.setBindGroup(0, bind_group, &.{0});
        try cube_pass.setVertexBuffer(0, vertex_buffer, 0, @sizeOf(Vertex));
        try cube_pass.setUniformBuffer(0, uniform_buffer);
        try cube_pass.setTexture(0, cube_texture_view, sampler);
        try cube_pass.draw(vertices.len, 1, 0, 0);
        try cube_pass.end();
        cube_pass.release();

        const command = try encoder.finish();
        defer encoder.release();

        try device.submit(&.{command});
    }
}
