const prism = @import("prism");

pub fn main() !void {
    var app = try prism.Prism.create();
    defer app.destroy();

    const window = try app.createWindow(800, 600, "hello 🦄");
    defer window.destroy();

    const device = try app.createGPUDevice(window);
    defer device.destroy();

    loop: while (true) {
        for (try window.getEvents()) |*event| {
            if (event.* == .window_close) break :loop;
        }
    }
}
