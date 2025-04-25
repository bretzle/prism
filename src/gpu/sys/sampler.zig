const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const FilterMode = types.FilterMode;
const MipmapFilterMode = types.MipmapFilterMode;
const CompareFunction = types.CompareFunction;

pub const Sampler = opaque {
    pub const AddressMode = enum { repeat, mirror_repeat, clamp_to_edge };

    pub const BindingType = enum { undefined, filtering, non_filtering, comparison };

    pub const BindingLayout = struct {
        type: BindingType = .undefined,
    };

    pub const Descriptor = struct {
        label: [:0]const u8 = "unnamed",
        address_mode_u: AddressMode = .clamp_to_edge,
        address_mode_v: AddressMode = .clamp_to_edge,
        address_mode_w: AddressMode = .clamp_to_edge,
        mag_filter: FilterMode = .nearest,
        min_filter: FilterMode = .nearest,
        mipmap_filter: MipmapFilterMode = .nearest,
        lod_min_clamp: f32 = 0.0,
        lod_max_clamp: f32 = 32.0,
        compare: CompareFunction = .undefined,
        max_anisotropy: u16 = 1,
    };

    pub inline fn setLabel(self: *Sampler, label: [:0]const u8) void {
        _ = self; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *Sampler) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn release(self: *Sampler) void {
        _ = self; // autofix
        unreachable;
    }
};
