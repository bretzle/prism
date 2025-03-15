const std = @import("std");
const prism = @import("prism");
const math = prism.math;
const gpu = prism.gpu;

const App = prism.Application(struct {
    const Self = @This();

    batch: gpu.Batch,
    tex: gpu.TextureId,

    pub fn init(self: *Self) !void {
        self.batch = try .create(prism.allocator);
        self.tex = gpu.createTexture(.{ .width = 25, .height = 25, .format = .rgba });

        var buf: [25 * 25 * 4]u8 = undefined;
        @memset(std.mem.bytesAsSlice(u32, &buf), 0xFFFF70B7);
        gpu.updateTexture(self.tex, &buf);

        @memset(&buf, 0);
        gpu.updateTexturePart(self.tex, 1, 1, 23, 23, &buf);
    }

    pub fn update(_: *Self, app: *App) void {
        if (app.input.buttonDown(.left)) {
            std.debug.print("mouse pos: {any}\n", .{app.input.mouse()});
        }
    }

    pub fn render(self: *Self) void {
        const center = math.Vec2{ .x = 100, .y = 100 };
        const transform = math.Mat3x2.transform(center, .zero, .one, 0);

        self.batch.pushMatrix(transform);
        self.batch.drawRect(.{ .x = -32, .y = -32, .w = 64, .h = 64 }, .red);
        self.batch.drawTexture(self.tex, .{ .x = 64, .y = -32 });
        _ = self.batch.popMatrix();

        self.batch.render(gpu.framebufferSize());
        self.batch.clear();
    }
});

pub fn main() !void {
    try App.start(.{});
}
