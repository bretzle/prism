const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;
const types = gpu.types;

const Texture = @import("texture.zig").Texture;
const SharedFence = @import("shared_fence.zig").SharedFence;

const Extent3D = types.Extent3D;

pub const SharedTextureMemory = opaque {
    pub const AHardwareBufferDescriptor = struct { handle: *anyopaque };
    pub const DmaBufDescriptor = struct { memory_fd: c_int, allocation_size: u64, drm_modifier: u64, plane_count: usize, plane_offsets: *const u64, plane_strides: *const u32 };
    pub const DXGISharedHandleDescriptor = struct { handle: *anyopaque };
    pub const EGLImageDescriptor = struct { image: *anyopaque };
    pub const IOSurfaceDescriptor = struct { ioSurface: *anyopaque };
    pub const OpaqueFDDescriptor = struct { memory_fd: c_int, allocation_size: u64 };
    pub const VkDedicatedAllocationDescriptor = struct { dedicated_allocation: bool };
    pub const ZirconHandleDescriptor = struct { memory_fd: u32, allocation_size: u64 };

    pub const Descriptor = struct {
        label: [:0]const u8 = "unnamed",
        data: union {
            none: void,
            a_hardware_buffer_descriptor: AHardwareBufferDescriptor,
            dma_buf_descriptor: DmaBufDescriptor,
            dxgi_shared_handle_descriptor: DXGISharedHandleDescriptor,
            egl_image_descriptor: EGLImageDescriptor,
            io_surface_descriptor: IOSurfaceDescriptor,
            opaque_fd_descriptor: OpaqueFDDescriptor,
            vk_dedicated_allocation_descriptor: VkDedicatedAllocationDescriptor,
            zircon_handle_descriptor: ZirconHandleDescriptor,
        },
    };

    pub const VkImageLayoutBeginState = struct { old_layout: i32, new_layout: i32 };
    pub const VkImageLayoutEndState = struct { old_layout: i32, new_layout: i32 };

    pub const BeginAccessDescriptor = struct {
        initialized: bool,
        fence_count: usize,
        fences: *const SharedFence,
        signaled_values: *const u64,
        data: union {
            none: void,
            vk_image_layout_begin_state: VkImageLayoutBeginState,
        },
    };

    pub const EndAccessState = struct {
        initialized: bool,
        fence_count: usize,
        fences: *const SharedFence,
        signaled_values: *const u64,
        data: union {
            none: void,
            vk_image_layout_end_state: VkImageLayoutEndState,
        },
    };

    pub const Properties = struct {
        usage: Texture.UsageFlags,
        size: Extent3D,
        format: Texture.Format,
    };

    // pub const VkImageDescriptor =  struct {
    //     vk_format: i32,
    //     vk_usage_flags: Texture.UsageFlags,
    //     vk_extent3D: Extent3D,
    // };
};
