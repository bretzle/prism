const std = @import("std");
const math = @import("math.zig");
const Color = @import("Color.zig").Color;

const impl = @import("gfx/d3d11.zig");

pub const Renderer = impl.D3D11Renderer;
pub const Target = impl.D3D11Target;
pub const Texture = impl.D3D11Texture;
pub const Shader = impl.D3D11Shader;
pub const Mesh = impl.D3D11Mesh;

pub const Compare = enum {
    none,
    always,
    never,
    less,
    equal,
    less_or_equal,
    greater,
    not_equal,
    greater_or_equal,
};

pub const Cull = enum {
    none,
    front,
    back,
};

pub const BlendOp = enum {
    add,
    subtract,
    reverse_subtract,
    min,
    max,
};

pub const BlendFactor = enum {
    zero,
    one,
    src_color,
    one_minus_src_color,
    dst_color,
    one_minus_dst_color,
    src_alpha,
    one_minus_src_alpha,
    dst_alpha,
    one_minus_dst_alpha,
    constant_color,
    one_minus_constant_color,
    constant_alpha,
    one_minus_constant_alpha,
    src_alpha_saturate,
    src1_color,
    one_minus_src1_color,
    src1_alpha,
    one_minus_src1_alpha,
};

pub const BlendMask = packed struct {
    red: bool,
    green: bool,
    blue: bool,
    alpha: bool,

    pub const none = BlendMask{ .red = false, .green = false, .blue = false, .alpha = false };
    pub const rgb = BlendMask{ .red = true, .green = true, .blue = true, .alpha = false };
    pub const rgba = BlendMask{ .red = true, .green = true, .blue = true, .alpha = true };
};

pub const BlendMode = struct {
    color_op: BlendOp,
    color_src: BlendFactor,
    color_dst: BlendFactor,
    alpha_op: BlendOp,
    alpha_src: BlendFactor,
    alpha_dst: BlendFactor,
    mask: BlendMask,
    rgba: u32,

    pub const normal = BlendMode{
        .color_op = .add,
        .color_src = .one,
        .color_dst = .one_minus_src_alpha,
        .alpha_op = .add,
        .alpha_src = .one,
        .alpha_dst = .one_minus_src_alpha,
        .mask = .rgba,
        .rgba = 0xffffffff,
    };
    // pub const non_premultiplied: BlendMode = undefined;
    // pub const subtract: BlendMode = undefined;
    // pub const additive: BlendMode = undefined;

    pub inline fn create(op: BlendOp, src: BlendFactor, dst: BlendFactor) BlendMode {
        return .{
            .color_op = op,
            .color_src = src,
            .color_dst = dst,
            .alpha_op = op,
            .alpha_src = src,
            .alpha_dst = dst,
            .mask = BlendMask.rgba,
            .rgba = 0xFFFF_FFFF,
        };
    }

    pub inline fn eq(a: BlendMode, b: BlendMode) bool {
        return std.meta.eql(a, b);
    }
};

pub const TextureFilter = enum {
    none,
    linear,
    nearest,
};

pub const TextureWrap = enum {
    none,
    clamp,
    repeat,
};

pub const TextureSampler = struct {
    filter: TextureFilter = .nearest,
    wrap_x: TextureWrap = .repeat,
    wrap_y: TextureWrap = .repeat,

    pub inline fn eq(a: TextureSampler, b: TextureSampler) bool {
        return std.meta.eql(a, b);
    }
};

pub const TextureFormat = enum {
    none,
    r,
    rg,
    rgba,
    depth_stencil,
};

pub const ClearMask = packed struct {
    color: bool,
    depth: bool,
    stencil: bool,

    pub const none = ClearMask{ .color = false, .depth = false, .stencil = false };
    pub const all = ClearMask{ .color = true, .depth = true, .stencil = true };
};

pub const UniformType = enum {
    none,
    float,
    float2,
    float3,
    float4,
    mat3x2,
    mat4x4,
    texture_2d,
    sampler_2d,
};

pub const ShaderType = enum {
    vertex,
    fragment,
};

pub const UniformInfo = struct {
    name: []const u8,
    type: UniformType,
    shader: ShaderType,
    register_index: u8 = 0,
    buffer_index: u8 = 0,
    array_length: u8 = 0,
};

pub const VertexType = enum {
    none,
    float,
    float2,
    float3,
    float4,
    byte4,
    ubyte4,
    short2,
    ushort2,
    short4,
    ushort4,
};

pub const VertexAttribute = struct {
    index: u8 = 0,
    type: VertexType = .none,
    normalized: bool = false,
};

pub const VertexFormat = struct {
    attributes: std.BoundedArray(VertexAttribute, 16) = .{},
    stride: u32 = 0,
};

pub const IndexFormat = enum {
    u16,
    u32,
};

pub const ShaderData = struct {
    pub const HLSLAttribute = struct { name: [:0]const u8, index: u8 = 0 };

    vertex: []const u8,
    fragment: []const u8,
    hlsl_attributes: std.BoundedArray(HLSLAttribute, 16),
};

pub const Attachments = std.BoundedArray(*Texture, 5);
pub const AttachmentFormats = std.BoundedArray(TextureFormat, 5);

pub const DrawCall = struct {
    target: *Target,
    mesh: *Mesh,
    material: *Material,
    has_viewport: bool = false,
    has_scissor: bool = false,
    viewport: math.Rect = .zero,
    scissor: math.Rect = .zero,
    index_start: u32 = 0,
    index_count: u32 = 0,
    instance_count: u32 = 0,
    depth: Compare = .none,
    cull: Cull = .none,
    blend: BlendMode = .normal,

    pub fn perform(self: *const DrawCall) void {
        var pass = self.*;

        const index_count = pass.mesh.index_count;
        if (pass.index_start + pass.index_count > index_count) {
            unreachable;
        }

        const instance_count = pass.mesh.getInstanceCount();
        if (pass.instance_count > instance_count) {
            unreachable;
        }

        const draw_size = math.Vec2{ .x = @floatFromInt(pass.target.getWidth()), .y = @floatFromInt(pass.target.getHeight()) };

        if (!pass.has_viewport) {
            pass.viewport = .{
                .x = 0,
                .y = 0,
                .w = draw_size.x,
                .h = draw_size.y,
            };
        } else {
            unreachable;
        }

        if (pass.has_scissor) {
            unreachable;
        }

        impl.renderer.render(&pass);
    }
};

pub const ClearParams = struct {
    color: Color = .black,
    depth: f32 = 1,
    stencil: u8 = 0,
    mask: ClearMask = .all,
};

pub const Material = struct {
    const Self = @This();

    shader: *Shader,
    textures: std.ArrayList(?*Texture),
    samplers: std.ArrayList(TextureSampler),
    data: std.ArrayList(f32),

    pub fn create(allocator: std.mem.Allocator, shader: *Shader) !*Self {
        const self = try allocator.create(Self);
        self.* = .{
            .shader = shader,
            .textures = .init(allocator),
            .samplers = .init(allocator),
            .data = .init(allocator),
        };

        const uniforms = shader.uniforms();
        var float_size: u32 = 0;

        for (uniforms) |uni| {
            if (uni.type == .none) continue;

            if (uni.type == .texture_2d) {
                if (self.textures.items.len < uni.register_index + uni.array_length)
                    _ = try self.textures.resize(uni.register_index + uni.array_length);
                continue;
            }

            if (uni.type == .sampler_2d) {
                if (self.samplers.items.len < uni.register_index + uni.array_length)
                    _ = try self.samplers.resize(uni.register_index + uni.array_length);
                continue;
            }

            float_size += calcUniSize(uni);
        }

        _ = try self.data.resize(float_size);

        return self;
    }

    fn calcUniSize(uni: UniformInfo) u32 {
        return @as(u32, uni.array_length) * @as(u32, switch (uni.type) {
            .float => 1,
            .float2 => 2,
            .float3 => 3,
            .float4 => 4,
            .mat3x2 => 6,
            .mat4x4 => 16,
            else => unreachable,
        });
    }

    pub fn hasValue(self: *const Self, name: []const u8) bool {
        for (self.shader.uniforms()) |uni| {
            if (std.mem.eql(u8, uni.name, name)) {
                return true;
            }
        }
        return false;
    }

    pub fn setTexture(self: *Self, name: []const u8, texture: ?*Texture, idx: u8) void {
        for (self.shader.uniforms()) |uni| {
            if (uni.type != .texture_2d) continue;

            if (std.mem.eql(u8, uni.name, name)) {
                if (uni.register_index + idx < self.textures.items.len) {
                    self.textures.items[uni.register_index + idx] = texture;
                    return;
                }
            }
        }

        unreachable;
    }

    pub fn setTexture2(self: *Self, register_index: u8, texture: ?*Texture) void {
        if (register_index >= self.textures.items.len) {
            std.log.warn("texture reguster index [{}] is out of bounds", .{register_index});
            return;
        }

        self.textures.items[register_index] = texture;
    }

    pub fn setSampler(self: *Self, name: []const u8, sampler: TextureSampler, idx: u8) void {
        for (self.shader.uniforms()) |uni| {
            if (uni.type != .sampler_2d) continue;

            if (std.mem.eql(u8, uni.name, name)) {
                if (uni.register_index + idx < self.samplers.items.len) {
                    self.samplers.items[uni.register_index + idx] = sampler;
                    return;
                }
            }
        }

        unreachable;
    }

    pub fn setSampler2(self: *Self, register_index: u8, sampler: TextureSampler) void {
        if (register_index >= self.samplers.items.len) {
            std.log.warn("texture sampler register index [{}] is out of bounds", .{register_index});
            return;
        }

        self.samplers.items[register_index] = sampler;
    }

    pub fn setValue(self: *Self, name: []const u8, value: anytype) void {
        switch (@TypeOf(value.*)) {
            math.Mat4x4 => self.setFloats(name, value.asArray()),
            else => unreachable,
        }
    }

    fn setFloats(self: *Self, name: []const u8, data: []const f32) void {
        std.debug.assert(data.len != 0);

        var index: u32 = 0;
        var offset: u32 = 0;
        for (self.shader.uniforms()) |uni| {
            switch (uni.type) {
                .texture_2d, .sampler_2d, .none => continue,
                else => {},
            }

            if (std.mem.eql(u8, uni.name, name)) {
                const max = calcUniSize(uni);
                if (data.len > max) {
                    unreachable;
                }

                @memcpy(self.data.items[offset..][0..data.len], data);
                return;
            }

            offset += calcUniSize(uni);
            index += 1;
        }

        unreachable;
    }
};
