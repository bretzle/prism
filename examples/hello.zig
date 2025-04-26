const std = @import("std");
const prism = @import("prism");
const gpu = prism.gpu;

const code = @embedFile("triangle.wgsl");

pub fn main() !void {
    var app = try prism.Application.create();
    defer app.deinit();

    const window = try app.createWindow(.{});
    const device = window.getDevice();
    const swapchain = window.getSwapchain();
    const queue = window.getQueue();

    const shader = try device.createShaderModuleWGSL("triangle", code);
    defer shader.release();

    const blend = gpu.types.BlendState{};
    const color_target = gpu.types.ColorTargetState{
        .format = .bgra8_unorm,
        .blend = &blend,
    };

    const pipeline = try device.createRenderPipeline(.{
        .vertex = .{ .module = shader, .entrypoint = "vertex_main" },
        .fragment = &.{ .module = shader, .entrypoint = "frag_main", .targets = &.{color_target} },
    });
    defer pipeline.release();

    loop: while (true) : (window.presentFrame()) {
        for (window.getEvents()) |event| switch (event) {
            .close => break :loop,
            .key_press, .key_repeat, .key_release => |e| std.debug.print("{s}: {s}\n", .{ @tagName(event), @tagName(e.key) }),
            .mouse_press, .mouse_release => |e| std.debug.print("{s}: {s}\n", .{ @tagName(event), @tagName(e.button) }),
            .mouse_scroll => |e| std.debug.print("{s}: {}\n", .{ @tagName(event), e }),
            .focus_gained, .focus_lost => std.debug.print("{s}\n", .{@tagName(event)}),
            else => {},
        };

        const back_buffer_view = try swapchain.getCurrentTextureView();
        defer back_buffer_view.release();

        const encoder = try device.createCommandEncoder(.{});
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

        try queue.submit(&.{command});
    }
}
