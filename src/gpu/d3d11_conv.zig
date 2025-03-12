const std = @import("std");
const w32 = @import("w32");
const dxgi = w32.dxgi;
const d3d11 = w32.d3d11;
const gpu = @import("../gpu.zig");

pub fn texture_format(format: gpu.TextureFormat) dxgi.FORMAT {
    return switch (format) {
        .none => unreachable,
        .r => .R8_UNORM,
        .rg => .R8G8_UNORM,
        .rgba => .R8G8B8A8_UNORM,
        .depth_stencil => .D24_UNORM_S8_UINT,
    };
}

pub fn blend_op(op: gpu.BlendOp) d3d11.BLEND_OP {
    return switch (op) {
        .add => .ADD,
        .subtract => .SUBTRACT,
        .reverse_subtract => .REV_SUBTRACT,
        .min => .MIN,
        .max => .MAX,
    };
}

pub fn blend_factor(factor: gpu.BlendFactor) d3d11.BLEND {
    return switch (factor) {
        .zero => .ZERO,
        .one => .ONE,
        .src_color => .SRC_COLOR,
        .one_minus_src_color => .INV_SRC_COLOR,
        .dst_color => .DEST_COLOR,
        .one_minus_dst_color => .INV_DEST_COLOR,
        .src_alpha => .SRC_ALPHA,
        .one_minus_src_alpha => .INV_SRC_ALPHA,
        .dst_alpha => .DEST_ALPHA,
        .one_minus_dst_alpha => .INV_DEST_ALPHA,
        .constant_color => .BLEND_FACTOR,
        .one_minus_constant_color => .INV_BLEND_FACTOR,
        .constant_alpha => .BLEND_FACTOR,
        .one_minus_constant_alpha => .INV_BLEND_FACTOR,
        .src_alpha_saturate => .SRC_ALPHA_SAT,
        .src1_color => .SRC1_COLOR,
        .one_minus_src1_color => .INV_SRC1_COLOR,
        .src1_alpha => .SRC1_ALPHA,
        .one_minus_src1_alpha => .INV_SRC1_ALPHA,
    };
}

// zig fmt: off
pub fn uniform_type(typ: d3d11.SHADER_VARIABLE_TYPE, rows: u32, cols: u32) gpu.UniformType {
    if (typ != .FLOAT) return .none;

    const mapping = [4][4]gpu.UniformType{
        .{ .float, .float2, .float3, .float4 }, // row 1
        .{ .none,  .none,   .mat3x2, .none   }, // row 2
        .{ .none,  .none,   .none,   .none   }, // row 3
        .{ .none,  .none,   .none,   .mat4x4 }, // row 4
    };

    return mapping[rows - 1][cols - 1];
}
// zig fmt: on
