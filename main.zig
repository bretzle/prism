const std = @import("std");
const prism = @import("prism");
const math = prism.math;

const App = prism.Application(struct {
    const Self = @This();

    batch: prism.Batch,
    tex: *prism.gfx.Texture,

    pub fn init(self: *Self, app: *App) !void {
        self.batch = try .create(app.allocator);
        self.tex = try prism.gfx.Texture.create(app.allocator, 25, 25, .rgba);
        self.tex.update(@alignCast(std.mem.sliceAsBytes(&[1]u32{0x123456} ** (25 * 25))));
    }

    pub fn render(self: *Self, app: *App) void {
        const target = app.backbuffer();
        target.clear(.{ .color = .black });

        const center = math.Vec2f{ .x = 100, .y = 100 };
        const transform = math.Mat3x2f.transform(center, .zero, .one, 0);

        self.batch.pushMatrix(transform);
        self.batch.drawRect(.{ .x = -32, .y = -32, .w = 64, .h = 64 }, .red);
        self.batch.drawTexture(self.tex, .{ .x = 64, .y = -32 });
        _ = self.batch.popMatrix();

        self.batch.render(target);
        self.batch.clear();
    }
});

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const app = try App.create(allocator, .{});
    app.run();
}
