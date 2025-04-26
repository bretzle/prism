const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const Texture = @import("texture.zig").Texture;
const TextureView = @import("texture.zig").TextureView;

const PresentMode = types.PresentMode;

pub const SwapChain = opaque {
    pub const Descriptor = struct {
        label: [:0]const u8 = "unnamed",
        usage: Texture.UsageFlags,
        format: Texture.Format,
        width: u32,
        height: u32,
        present_mode: PresentMode,
    };

    pub inline fn getCurrentTexture(self: *SwapChain) ?*Texture {
        const swapchain: *impl.SwapChain = @alignCast(@ptrCast(self));
        _ = swapchain; // autofix
        unreachable;
    }

    pub inline fn getCurrentTextureView(self: *SwapChain) !*TextureView {
        const swapchain: *impl.SwapChain = @alignCast(@ptrCast(self));
        const texture_view = try swapchain.getCurrentTextureView();
        return @ptrCast(texture_view);
    }

    pub inline fn present(self: *SwapChain) !void {
        const swapchain: *impl.SwapChain = @alignCast(@ptrCast(self));
        try swapchain.present();
    }

    pub inline fn resize(self: *SwapChain, width: u32, height: u32) !void {
        const swapchain: *impl.SwapChain = @alignCast(@ptrCast(self));
        try swapchain.resize(width, height);
    }

    pub inline fn reference(self: *SwapChain) void {
        const swapchain: *impl.SwapChain = @alignCast(@ptrCast(self));
        swapchain.manager.reference();
    }

    pub inline fn release(self: *SwapChain) void {
        const swapchain: *impl.SwapChain = @alignCast(@ptrCast(self));
        swapchain.manager.release();
    }
};
