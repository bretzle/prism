const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;

const Buffer = @import("buffer.zig").Buffer;
const Sampler = @import("sampler.zig").Sampler;
const TextureView = @import("texture_view.zig").TextureView;
const BindGroupLayout = @import("bind_group_layout.zig").BindGroupLayout;

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
        label: ?[:0]const u8 = null,
        layout: *BindGroupLayout,
        entries: ?[]const Entry = null,
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
