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

        pub inline fn newBuffer(binding: u32, visibility: ShaderStageFlags, binding_type: Buffer.BindingType, has_dynamic_offset: bool, min_binding_size: u64) Entry {
            return .{
                .binding = binding,
                .visibility = visibility,
                .buffer = .{ .type = binding_type, .has_dynamic_offset = has_dynamic_offset, .min_binding_size = min_binding_size },
            };
        }

        pub inline fn newSampler(binding: u32, visibility: ShaderStageFlags, binding_type: Sampler.BindingType) Entry {
            return .{
                .binding = binding,
                .visibility = visibility,
                .sampler = .{ .type = binding_type },
            };
        }

        pub inline fn newTexture(binding: u32, visibility: ShaderStageFlags, sample_type: Texture.SampleType, view_dimension: TextureView.Dimension, multisampled: bool) Entry {
            return .{
                .binding = binding,
                .visibility = visibility,
                .texture = .{
                    .sample_type = sample_type,
                    .view_dimension = view_dimension,
                    .multisampled = multisampled,
                },
            };
        }
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

        pub inline fn newBuffer(binding: u32, buf: *Buffer, offset: u64, size: u64) Entry {
            return .{
                .binding = binding,
                .buffer = buf,
                .offset = offset,
                .size = size,
            };
        }

        pub inline fn newSampler(binding: u32, sampler: *Sampler) Entry {
            return .{
                .binding = binding,
                .sampler = sampler,
                .size = 0,
            };
        }

        pub inline fn newTextureView(binding: u32, texture_view: *TextureView) Entry {
            return .{
                .binding = binding,
                .texture_view = texture_view,
                .size = 0,
            };
        }
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
