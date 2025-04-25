const prism = @import("prism");
const gpu = prism.gpu;

const code = @embedFile("triangle.wgsl");

pub fn main() !void {
    var app = try prism.Application.create();
    defer app.deinit();

    const window = try app.createWindow(.{});
    defer window.deinit();

    const shader = try window.device.createShaderModuleWGSL("triangle", code);
    defer shader.release();

    const blend = gpu.types.BlendState{};
    const color_target = gpu.types.ColorTargetState{
        .format = window.framebuffer_format,
        .blend = &blend,
    };

    const pipeline = try window.device.createRenderPipeline(.{
        .vertex = .{ .module = shader, .entrypoint = "vertex_main" },
        .fragment = &.{ .module = shader, .entrypoint = "frag_main", .targets = &.{color_target} },
    });
    defer pipeline.release();

    loop: while (true) {
        for (window.getEvents()) |*event| {
            if (event.* == .window_close) break :loop;
        }

        const back_buffer_view = try window.swap_chain.getCurrentTextureView();
        defer back_buffer_view.release();

        const encoder = try window.device.createCommandEncoder(.{});
        defer encoder.release();

        const render_pass = try encoder.beginRenderPass(.{
            .color_attachments = &[_]gpu.types.RenderPassColorAttachment{.{
                .view = back_buffer_view,
                .clear_value = .{ .r = 0.776, .g = 0.988, .b = 1, .a = 1 },
                .load_op = .clear,
                .store_op = .store,
            }},
        });
        defer render_pass.release();

        try render_pass.setPipeline(pipeline);
        try render_pass.draw(3, 1, 0, 0);
        try render_pass.end();

        var command = try encoder.finish(.{});
        defer command.release();

        try window.queue.submit(&.{command});

        try window.device.tick();
        try window.swap_chain.present();
    }
}
