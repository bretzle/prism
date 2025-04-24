const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const MapModeFlags = types.MapModeFlags;

pub const Buffer = opaque {
    pub const MapCallback = *const fn (status: MapAsyncStatus, userdata: ?*anyopaque) void;

    pub const BindingType = enum { undefined, uniform, storage, read_only_storage };

    pub const MapState = enum { unmapped, pending, mapped };

    pub const MapAsyncStatus = enum { success, validation_error, unknown, device_lost, destroyed_before_callback, unmapped_before_callback, mapping_already_pending, offset_out_of_range, size_out_of_range };

    pub const UsageFlags = packed struct(u32) {
        map_read: bool = false,
        map_write: bool = false,
        copy_src: bool = false,
        copy_dst: bool = false,
        index: bool = false,
        vertex: bool = false,
        uniform: bool = false,
        storage: bool = false,
        indirect: bool = false,
        query_resolve: bool = false,
        _padding: u22 = 0,
    };

    pub const BindingLayout = struct {
        type: BindingType = .undefined,
        has_dynamic_offset: bool = false,
        min_binding_size: u64 = 0,
    };

    pub const Descriptor = struct {
        label: ?[:0]const u8 = null,
        usage: UsageFlags,
        size: u64,
        mapped_at_creation: bool = false,
    };

    pub inline fn destroy(self: *Buffer) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn getMapState(self: *Buffer) MapState {
        _ = self; // autofix
        unreachable;
    }

    /// Default `offset_bytes`: 0
    /// Default `len`: `gpu.whole_map_size` / `std.math.maxint(usize)` (whole range)
    pub inline fn getConstMappedRange(self: *Buffer, comptime T: type, offset_bytes: usize, len: usize) ?[]const T {
        _ = self; // autofix
        _ = offset_bytes; // autofix
        _ = len; // autofix
        unreachable;
    }

    /// Default `offset_bytes`: 0
    /// Default `len`: `gpu.whole_map_size` / `std.math.maxint(usize)` (whole range)
    pub inline fn getMappedRange(self: *Buffer, comptime T: type, offset_bytes: usize, len: usize) ?[]T {
        _ = self; // autofix
        _ = offset_bytes; // autofix
        _ = len; // autofix
        unreachable;
    }

    pub inline fn getSize(self: *Buffer) u64 {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn getUsage(self: *Buffer) UsageFlags {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn mapAsync(self: *Buffer, mode: MapModeFlags, offset: usize, size: usize, context: anytype, comptime callback: fn (ctx: @TypeOf(context), status: MapAsyncStatus) callconv(.Inline) void) void {
        _ = self; // autofix
        _ = mode; // autofix
        _ = offset; // autofix
        _ = size; // autofix
        _ = callback; // autofix
        unreachable;
    }

    pub inline fn unmap(self: *Buffer) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn setLabel(self: *Buffer, label: [:0]const u8) void {
        _ = self; // autofix
        _ = label; // autofix
        unreachable;
    }

    pub inline fn reference(self: *Buffer) void {
        _ = self; // autofix
        unreachable;
    }

    pub inline fn release(self: *Buffer) void {
        _ = self; // autofix
        unreachable;
    }
};
