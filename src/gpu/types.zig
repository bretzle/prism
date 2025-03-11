const std = @import("std");
const Color = @import("../Color.zig").Color;

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

    pub fn size(self: TextureFormat, width: u32, height: u32) u32 {
        return width * height * self.stride();
    }

    pub fn stride(self: TextureFormat) u32 {
        return switch (self) {
            .none => unreachable,
            .r => 1,
            .rg => 2,
            .rgba => 4,
            .depth_stencil => 4,
        };
    }
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

pub const ShaderDesc = struct {
    pub const HLSLAttribute = struct { name: [:0]const u8, index: u8 = 0 };

    vertex: []const u8,
    fragment: []const u8,
    hlsl_attributes: std.BoundedArray(HLSLAttribute, 16),
};

pub const BufferType = enum { vertex, index };

// TODO: usage?
pub const BufferDesc = struct {
    type: BufferType,
    elem_size: u32,
    size_in_bytes: u32,
    content: ?[]const u8,
};

pub const TextureDesc = struct {
    width: u32,
    height: u32,
    format: TextureFormat = .rgba,
    content: ?*const anyopaque = null,
};

pub const PipelineDesc = struct {
    shader: gpu.ShaderId,
    depth: Compare = .none,
    cull: Cull = .none,
    blend: BlendMode = .normal,
    format: VertexFormat,
};

pub const ClearParams = struct {
    color: Color = .black,
    depth: f32 = 1,
    stencil: u8 = 0,
    mask: ClearMask = .all,
};

pub const PassAction = union(enum) {
    nothing,
    clear: ClearParams,

    pub const default = PassAction{ .clear = .{ .color = .rgba(0x12345678) } };
};

const gpu = @import("../gpu.zig");
pub const Bindings = struct {
    index_buffer: gpu.BufferId,
    vertex_buffer: gpu.BufferId,
    textures: std.BoundedArray(gpu.TextureId, 8) = .{},
    samplers: std.BoundedArray(gpu.TextureSampler, 8) = .{},
};
