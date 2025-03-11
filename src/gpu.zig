const std = @import("std");
const math = @import("math.zig");
const impl = @import("gpu/d3d11.zig");
const Pool = @import("gpu/pool.zig").Pool;
const gpu = @This();

pub usingnamespace @import("gpu/types.zig");

pub const allocator = std.heap.page_allocator; // FIXME

const Buffer = impl.Buffer;
const Shader = impl.Shader;
const Texture = impl.Texture;
const Pipeline = impl.Pipeline;

const pools = struct {
    var buffers: Pool(BufferId, Buffer) = undefined;
    var shaders: Pool(ShaderId, Shader) = undefined;
    var textures: Pool(TextureId, Texture) = undefined;
    var pipelines: Pool(PipelineId, Pipeline) = undefined;
};

pub const BufferId = enum(u32) { invalid, _ };
pub const ShaderId = enum(u32) { invalid, _ };
pub const TextureId = enum(u32) { invalid, _ };
pub const PassId = enum(u32) { default, _ };
pub const PipelineId = enum(u32) { invalid, _ };

pub fn init(size: math.Point, handle: *anyopaque) !void {
    pools.buffers = try .init(allocator);
    pools.shaders = try .init(allocator);
    pools.textures = try .init(allocator);
    pools.pipelines = try .init(allocator);

    try impl.init(size, handle);
}

pub fn resizeFramebuffer(size: math.Point) void {
    impl.resizeFramebuffer(size);
}

pub fn createBuffer(desc: gpu.BufferDesc) BufferId {
    const buffer = Buffer.create(desc);
    return pools.buffers.add(buffer);
}

pub fn updateBuffer(id: BufferId, bytes: []const u8) void {
    const buffer = pools.buffers.get(id);
    buffer.update(bytes);
}

pub fn createShader(desc: gpu.ShaderDesc) !ShaderId {
    const shader = try Shader.create(desc);
    return pools.shaders.add(shader);
}

pub fn createTexture(desc: gpu.TextureDesc) TextureId {
    const texture = Texture.create(desc);
    return pools.textures.add(texture);
}

pub fn updateTexture(id: TextureId, bytes: []const u8) void {
    const texture = pools.textures.get(id);
    texture.update(0, 0, texture.width, texture.height, bytes);
}

pub fn updateTexturePart(id: TextureId, x: u32, y: u32, width: u32, height: u32, bytes: []const u8) void {
    const texture = pools.textures.get(id);
    texture.update(x, y, width, height, bytes);
}

pub fn textureSizef(id: TextureId) [2]f32 {
    const texture = pools.textures.get(id);
    const width: f32 = @floatFromInt(texture.width);
    const height: f32 = @floatFromInt(texture.height);
    return .{ width, height };
}

pub fn createPipeline(desc: gpu.PipelineDesc) PipelineId {
    const pipeline = Pipeline.create(desc);
    return pools.pipelines.add(pipeline);
}

pub fn beginPass(pass: PassId, action: gpu.PassAction) void {
    std.debug.assert(pass == .default); // TODO

    impl.beginPass(action);
}

pub fn endPass() void {
    // do nothing?
}

pub fn applyPipeline(id: PipelineId) void {
    const pipeline = pools.pipelines.get(id);
    const shader = pools.shaders.get(pipeline.shader);
    impl.applyPipeline(pipeline, shader);
}

pub fn applyBindings(bindings: gpu.Bindings) void {
    const ibuf = pools.buffers.get(bindings.index_buffer);
    const vbuf = pools.buffers.get(bindings.vertex_buffer);

    var textures = std.BoundedArray(*Texture, 8){};
    for (bindings.textures.constSlice()) |id| {
        if (id != .invalid) {
            textures.appendAssumeCapacity(pools.textures.get(id));
        }
    }

    impl.applyBindings(ibuf, vbuf, textures.constSlice(), bindings.samplers.constSlice());
}

pub fn applyUniforms(id: ShaderId, typ: gpu.ShaderType, data: []const f32) void {
    const shader = pools.shaders.get(id);
    impl.applyUniforms(shader, typ, data);
}

pub fn draw(base: u32, elements: u32, instances: u32) void {
    impl.draw(base, elements, instances);
}

pub fn applyViewport(x: i32, y: i32, w: i32, h: i32) void {
    impl.applyViewport(x, y, w, h);
}

pub fn applyScissor(x: i32, y: i32, w: i32, h: i32) void {
    impl.applyScissor(x, y, w, h);
}

pub fn clear(params: gpu.ClearParams) void {
    impl.clear(params);
}

pub fn commit() void {
    impl.commit();
}
