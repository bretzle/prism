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

    const sampler = try device.createSampler(.{});
    defer sampler.release();

    const tex1 = try createSolidTexture(device, .purple);
    defer tex1.release();

    const tex2 = try createSolidTexture(device, .cyan);
    defer tex2.release();

    const painter = try Painter.create(prism.allocator, device);

    loop: while (true) : (window.presentFrame()) {
        for (window.getEvents()) |event| switch (event) {
            .close => break :loop,
            else => {},
        };

        // try painter.drawTri(.{ 50, 50 }, .{ 50, 100 }, .{ 100, 50 }, .red);
        try painter.drawTexture(tex1, sampler, .{ 75, 75 }, .white);
        // try painter.drawRect(.{ 125, 50, 40, 60 }, .yellow);
        try painter.drawTexture(tex2, sampler, .{ 75, 200 }, .white);

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

fn createSolidTexture(device: *gpu.Device, color: Painter.Color) !*gpu.TextureView {
    const width = 100;
    const height = 100;

    const texture_data: [width * height]Painter.Color = @splat(color);

    const tex = try device.createTexture(.{
        .format = .rgba8_unorm,
        .usage = .{ .texture_binding = true },
        .size = .{ .width = width, .height = height },
        .data = std.mem.sliceAsBytes(&texture_data),
    });
    defer tex.release();

    const view = try tex.createView(.{
        .format = .rgba8_unorm,
        .dimension = .@"2d",
        .mip_level_count = 1,
        .array_layer_count = 1,
    });

    return view;
}
