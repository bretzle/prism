const prism = @import("prism");
const gpu = prism.gpu;

const code =
    \\float4 vertex_main(uint VertexIndex_0 : SV_VertexID) : SV_Position 
    \\{
    \\    float2 pos[3] = {
    \\        float2(0.0, 0.5),
    \\        float2(-0.5, -0.5),
    \\        float2(0.5, -0.5)
    \\    };
    \\
    \\    return float4(pos[VertexIndex_0].x, pos[VertexIndex_0].y, 0.0, 1.0);
    \\}
    \\
    \\float4 frag_main() : SV_Target0 
    \\{
    \\    return float4(1.0, 0.0, 0.0, 1.0);
    \\}
;

pub fn main() !void {
    var app = try prism.Application.create();
    defer app.deinit();

    const window = try app.createWindow(.{});
    defer window.deinit();

    const shader = try window.device.createShader(code);
    defer shader.release();

    const blend: gpu.BlendState = .default;
    const color_target = gpu.ColorTargetState{
        .format = window.framebuffer_format,
        .blend = &blend,
    };

    const layout = try window.device.createPipelineLayout(.{});
    defer layout.release();

    const pipeline = try window.device.createRenderPipeline(.{
        .vertex = .{ .module = shader, .entrypoint = "vertex_main" },
        .fragment = .{ .module = shader, .entrypoint = "frag_main", .targets = &.{color_target} },
        .layout = layout,
    });
    defer pipeline.release();

    loop: while (true) {
        for (window.getEvents()) |*event| {
            if (event.* == .window_close) break :loop;
        }

        //     const back_buffer_view = window.swapchain.getCurrentTextureView().?;
        //     defer back_buffer_view.release();

        //     const encoder = window.device.createCommandEncoder(.{});
        //     defer encoder.release();

        //     const render_pass = encoder.beginRenderPass(.init(.{
        //         .color_attachments = &[_]gpu.RenderPassColorAttachments{.{
        //             .view = back_buffer_view,
        //             .clear_value = .{ .r = 0.776, .g = 0.988, .b = 1, .a = 1 },
        //             .loap_op = .clear,
        //             .store_op = .store,
        //         }},
        //     }));
        //     defer render_pass.release();

        //     render_pass.setPipeline(pipeline);
        //     render_pass.draw(3, 1, 0, 0);
        //     render_pass.end();

        //     var command = encoder.finish(.{});
        //     defer command.release();

        //     window.queue.submit(&.{command});
        try window.swap_chain.present();
    }
}
