const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const CompilationInfoRequestStatus = types.CompilationInfoRequestStatus;
const CompilationInfo = types.CompilationInfo;

pub const ShaderModule = opaque {
    pub const WorkgroupSize = struct { x: u32 = 1, y: u32 = 1, z: u32 = 1 };

    pub const WGSLDescriptor = struct { code: [:0]const u8 };
    pub const HLSLDescriptor = struct { code: [:0]const u8 };

    pub const Descriptor = struct {
        label: [:0]const u8 = "unnamed",
        code: union(enum) {
            wgsl: [:0]const u8,
            hlsl: [:0]const u8,
        },
    };

    pub inline fn getCompilationInfo(
        self: *ShaderModule,
        context: anytype,
        comptime callback: fn (ctx: @TypeOf(context), status: CompilationInfoRequestStatus, info: *const CompilationInfo) callconv(.Inline) void,
    ) void {
        _ = self; // autofix
        _ = callback; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *ShaderModule, label: [:0]const u8) void {
        const shader: *impl.ShaderModule = @alignCast(@ptrCast(self));
        shader.setLabel(label);
    }

    pub inline fn reference(self: *ShaderModule) void {
        const shader: *impl.ShaderModule = @alignCast(@ptrCast(self));
        shader.manager.reference();
    }

    pub inline fn release(self: *ShaderModule) void {
        const shader: *impl.ShaderModule = @alignCast(@ptrCast(self));
        shader.manager.release();
    }
};
