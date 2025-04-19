const prism = @import("prism");
const gpu = prism.gpu;

pub fn main() !void {
    var app = try prism.Application.create();
    defer app.deinit();

    const window = try app.createWindow(.{});
    defer window.deinit();

    // const pipeline = window.device.createRenderPipeline(.{});
    // defer pipeline.release();

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
