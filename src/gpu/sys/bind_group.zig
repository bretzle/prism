const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const Buffer = @import("buffer.zig").Buffer;
const Sampler = @import("sampler.zig").Sampler;
const TextureView = @import("texture.zig").TextureView;
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
        label: [:0]const u8 = "unnamed",
        entries: []const Entry = &.{},
    };

    pub inline fn setLabel(self: *BindGroupLayout, label: [:0]const u8) void {
        const layout: *impl.BindGroupLayout = @alignCast(@ptrCast(self));
        layout.setLabel(label);
    }

    pub inline fn reference(self: *BindGroupLayout) void {
        const layout: *impl.BindGroupLayout = @alignCast(@ptrCast(self));
        layout.manager.reference();
    }

    pub inline fn release(self: *BindGroupLayout) void {
        const layout: *impl.BindGroupLayout = @alignCast(@ptrCast(self));
        layout.manager.release();
    }
};

pub const BindGroup = opaque {
    pub const Entry = struct {
        binding: u32,
        buffer: ?*Buffer = null,
        offset: u64 = 0,
        size: u64,
        elem_size: u32 = 0, // TEMP - using StructuredBuffer until we switch to DXC for templatized raw buffers
        sampler: ?*Sampler = null,
        texture_view: ?*TextureView = null,
    };

    pub const Descriptor = struct {
        label: [:0]const u8 = "unnamed",
        layout: *BindGroupLayout,
        entries: []const Entry = &.{},
    };

    pub inline fn setLabel(self: *BindGroup, label: [:0]const u8) void {
        _ = self; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *BindGroup) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn release(self: *BindGroup) void {
        _ = self; // autofix
        unreachable;
    }
};
