const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const CompilationInfoRequestStatus = types.CompilationInfoRequestStatus;
const CompilationInfo = types.CompilationInfo;

pub const ShaderModule = opaque {
    pub const WorkgroupSize = struct { x: u32 = 1, y: u32 = 1, z: u32 = 1 };

    // pub const SPIRVDescriptor = struct { code: [:0]const u32 };
    pub const WGSLDescriptor = struct { code: [:0]const u8 };
    // pub const HLSLDescriptor = struct { code: [:0]const u8 };
    // pub const MSLDescriptor = struct { code: [:0]const u8, workgroup_size: WorkgroupSize };

    pub const Descriptor = struct {
        label: ?[:0]const u8 = null,
        data: union {
            // spirv_descriptor: SPIRVDescriptor,
            wgsl_descriptor: WGSLDescriptor,
            // hlsl_descriptor: HLSLDescriptor,
            // msl_descriptor: MSLDescriptor,
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
        _ = shader; // autofix
        _ = label; // autofix
        unreachable;
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
