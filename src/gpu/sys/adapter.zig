const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const Device = @import("device.zig").Device;
const Instance = @import("instance.zig").Instance;
const Surface = @import("surface.zig").Surface;

const FeatureName = types.FeatureName;
const SupportedLimits = types.SupportedLimits;
const PowerPreference = types.PowerPreference;

pub const Adapter = opaque {
    pub const Type = enum { discrete_gpu, integrated_gpu, cpu, unknown };

    pub const Descriptor = struct {
        surface: ?*Surface = null,
        power_preference: PowerPreference = .efficient,
        force_fallback_adapter: bool = false,
        compatibility_mode: bool = false,
    };

    pub const Properties = struct {
        vendor_id: u32,
        vendor_name: [*:0]const u8,
        architecture: [*:0]const u8,
        device_id: u32,
        name: [*:0]const u8,
        driver_description: [*:0]const u8,
        adapter_type: Type,
    };

    pub inline fn createDevice(self: *Adapter, desc: Device.Descriptor) !*Device {
        const adapter: *impl.Adapter = @alignCast(@ptrCast(self));
        const device = try impl.Device.create(adapter, desc);
        return @ptrCast(device);
    }

    pub inline fn enumerateFeatures(self: *Adapter) ![]FeatureName {
        const adapter: *impl.Adapter = @alignCast(@ptrCast(self));
        _ = adapter; // autofix
        unreachable;
    }

    pub inline fn getInstance(self: *Adapter) *Instance {
        const adapter: *impl.Adapter = @alignCast(@ptrCast(self));
        _ = adapter; // autofix
        unreachable;
    }

    pub inline fn getLimits(self: *Adapter, limits: *SupportedLimits) bool {
        const adapter: *impl.Adapter = @alignCast(@ptrCast(self));
        _ = adapter; // autofix
        _ = limits; // autofix
        unreachable;
    }

    pub inline fn getProperties(self: *Adapter) Properties {
        const adapter: *impl.Adapter = @alignCast(@ptrCast(self));
        return adapter.getProperties();
    }

    pub inline fn hasFeature(self: *Adapter, feature: FeatureName) bool {
        const adapter: *impl.Adapter = @alignCast(@ptrCast(self));
        _ = adapter; // autofix
        _ = feature; // autofix
        unreachable;
    }

    pub inline fn reference(self: *Adapter) void {
        const adapter: *impl.Adapter = @alignCast(@ptrCast(self));
        adapter.manager.reference();
    }

    pub inline fn release(self: *Adapter) void {
        const adapter: *impl.Adapter = @alignCast(@ptrCast(self));
        adapter.manager.release();
    }
};
