const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const Buffer = @import("buffer.zig").Buffer;
const Sampler = @import("sampler.zig").Sampler;
const Texture = @import("texture.zig").Texture;

const ShaderStageFlags = types.ShaderStageFlags;
const StorageTextureBindingLayout = types.StorageTextureBindingLayout;

pub const BindGroupLayout = opaque {
    pub const Entry = struct {
        binding: u32,
        visibility: ShaderStageFlags,
        buffer: Buffer.BindingLayout = .{},
        sampler: Sampler.BindingLayout = .{},
        texture: Texture.BindingLayout = .{},
        storage_texture: StorageTextureBindingLayout = .{},
    };

    pub const Descriptor = struct {
        label: ?[:0]const u8 = null,
        entries: []const Entry = &.{},
    };

    pub inline fn setLabel(self: *BindGroupLayout, label: [:0]const u8) void {
        _ = self; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *BindGroupLayout) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn release(self: *BindGroupLayout) void {
        _ = self; // autofix
        unreachable;
    }
};
