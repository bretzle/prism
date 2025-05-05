const std = @import("std");
const prism = @import("prism");
const gpu = prism.gpu;
const math = prism.math;

const Painter = prism.gfx.Painter;

pub fn main() !void {
    var app = try prism.Application.create();
    defer app.deinit();

    const window = try app.createWindow(.{});
    const device = window.getDevice();
    const swapchain = window.getSwapchain();

    const painter = try Painter.create(prism.allocator, device);

    loop: while (true) : (window.presentFrame()) {
        for (window.getEvents()) |event| switch (event) {
            .close => break :loop,
            else => {},
        };

        try painter.drawTri(.{ 50, 50 }, .{ 50, 100 }, .{ 100, 50 }, .red);

        const backbuffer = try swapchain.getCurrentTextureView();
        defer backbuffer.release();

        const encoder = try device.createCommandEncoder();
        defer encoder.release();

        try painter.render(encoder, backbuffer);

        const command = try encoder.finish();
        defer command.release();

        try device.submit(&.{command});
    }
}
