const prism = @import("prism");

pub fn main() !void {
    var app = try prism.Prism.create();
    defer app.destroy();

    const window = try app.createWindow(800, 600, "hello 🦄");
    defer window.destroy();

    const device = try app.createGpuDevice(window);
    defer device.destroy();

    var frame: u32 = 0;
    loop: while (true) : (frame += 1) {
        for (try window.getEvents()) |*event| {
            if (event.* == .window_close) break :loop;
        }

        const cmds = try device.acquireCommandBuffer();
        _ = cmds; // autofix
        //     if (try cmds.waitAndAcquireSwapchainTexture()) |swapchain| {
        //         const color_info = prism.ColorTargetInfo{
        //             .texture = swapchain,
        //             .clear_color = .{ .r = 1, .g = 0, .b = 0, .a = 1 },
        //             .load_op = .clear,
        //             .store_op = .store,
        //         };

        //         const pass = cmds.beginRenderPass(&.{color_info}, null);
        //         pass.end();

        //         cmds.submit();
        //     } else {
        //         cmds.cancel();
        //     }
    }
}
