const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;

pub const Surface = opaque {
    // pub const DescriptorFromAndroidNativeWindow = struct { window: *anyopaque };
    // pub const DescriptorFromCanvasHTMLSelector = struct { selector: [:0]const u8 };
    // pub const DescriptorFromMetalLayer = struct { layer: *anyopaque };
    // pub const DescriptorFromWaylandSurface = struct { display: *anyopaque, surface: *anyopaque };
    // pub const DescriptorFromWindowsCoreWindow = struct { core_window: *anyopaque };
    pub const DescriptorFromWindowsHWND = struct { hinstance: *anyopaque, hwnd: *anyopaque };
    // pub const DescriptorFromWindowsSwapChainPanel = struct { swap_chain_panel: *anyopaque };
    // pub const DescriptorFromXlibWindow = struct { display: *anyopaque, window: u32 };

    pub const Descriptor = struct {
        label: [:0]const u8 = "unnamed",
        data: union {
            // android_native_window: DescriptorFromAndroidNativeWindow,
            // canvas_html_selector: DescriptorFromCanvasHTMLSelector,
            // metal_layer: DescriptorFromMetalLayer,
            // wayland_surface: DescriptorFromWaylandSurface,
            // windows_core_window: DescriptorFromWindowsCoreWindow,
            windows_hwnd: DescriptorFromWindowsHWND,
            // windows_swap_chain_panel: DescriptorFromWindowsSwapChainPanel,
            // xlib_window: DescriptorFromXlibWindow,
        },
    };

    pub inline fn reference(self: *Surface) void {
        const surface: *impl.Surface = @alignCast(@ptrCast(self));
        surface.manager.reference();
    }

    pub inline fn release(self: *Surface) void {
        const surface: *impl.Surface = @alignCast(@ptrCast(self));
        surface.manager.release();
    }
};
