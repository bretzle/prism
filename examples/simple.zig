const std = @import("std");
const prism = @import("prism");
const math = prism.math;
const gpu = prism.gpu;
const ttf = prism.file.ttf;

const font_data = @embedFile("roboto.ttf");

const App = prism.Application(struct {
    const Self = @This();

    batch: gpu.Batch,
    tex: gpu.TextureId,
    text: gpu.TextureId,

    pub fn init(self: *Self) !void {
        self.batch = try .create(prism.allocator);

        var buf: [25 * 25]u32 = undefined;
        @memset(&buf, 0xFFFF70B7);
        for (1..24) |i| {
            @memset(buf[(25 * i) + 1 ..][0..23], 0);
        }

        self.tex = gpu.createTexture(.{
            .width = 25,
            .height = 25,
            .format = .rgba,
            .content = @ptrCast(&buf),
        });

        const font = try ttf.Font.loadmem(font_data);
        defer font.deinit();

        const sft = ttf.SFT{
            .font = font,
            .x_scale = 32,
            .y_scale = 32,
            .flags = ttf.SFT_DOWNWARD_Y,
        };

        const glyph = try sft.lookup('@');
        const mtx = try sft.gmetrics(glyph);

        var img = ttf.Image{
            .width = (mtx.min_width + 3) & ~@as(u32, 3),
            .height = mtx.min_height,
            .pixels = undefined,
        };
        img.pixels = try prism.allocator.alloc(u8, @intCast(img.width * img.height));
        defer prism.allocator.free(img.pixels);

        try sft.render(glyph, img);

        self.text = gpu.createTexture(.{
            .width = img.width,
            .height = img.height,
            .format = .r,
            .content = img.pixels.ptr,
        });
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
        self.batch.drawTexture(self.text, .{ .x = 64, .y = -16 });
        _ = self.batch.popMatrix();

        self.batch.render(gpu.framebufferSize());
        self.batch.clear();
    }
});

pub fn main() !void {
    const icon = prism.Icon{
        .width = 2,
        .height = 2,
        .pixels = &std.mem.toBytes([4]u32{
            0xFFFF70B7,
            0xFFFF70B7,
            0xFFFF70B7,
            0xFFFF70B7,
        }),
    };

    try App.start(.{ .image = icon });
}
