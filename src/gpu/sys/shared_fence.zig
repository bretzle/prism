const std = @import("std");
const gpu = @import("../gpu.zig");
const impl = gpu.impl;

pub const SharedFence = opaque {
    pub const Type = enum { undefined, vk_semaphore_opaque_fd, vk_semaphore_sync_fd, vk_semaphore_zircon_handle, dxgi_shared_handle, mtl_shared_event };

    pub const VkSemaphoreOpaqueFDDescriptor = extern struct { handle: c_int };
    pub const VkSemaphoreSyncFDDescriptor = extern struct { handle: c_int };
    pub const VkSemaphoreZirconHandleDescriptor = extern struct { handle: u32 };
    pub const DXGISharedHandleDescriptor = extern struct { handle: *anyopaque };
    pub const MTLSharedEventDescriptor = extern struct { shared_event: *anyopaque };

    pub const Descriptor = extern struct {
        label: ?[:0]const u8,
        data: union {
            none: void,
            vk_semaphore_opaque_fd_descriptor: VkSemaphoreOpaqueFDDescriptor,
            vk_semaphore_sync_fd_descriptor: VkSemaphoreSyncFDDescriptor,
            vk_semaphore_zircon_handle_descriptor: VkSemaphoreZirconHandleDescriptor,
            dxgi_shared_handle_descriptor: DXGISharedHandleDescriptor,
            mtl_shared_event_descriptor: MTLSharedEventDescriptor,
        },
    };

    pub const DXGISharedHandleExportInfo = extern struct { handle: *anyopaque };
    pub const MTLSharedEventExportInfo = extern struct { shared_event: *anyopaque };
    pub const VkSemaphoreOpaqueFDExportInfo = extern struct { handle: c_int };
    pub const VkSemaphoreSyncFDExportInfo = extern struct { handle: c_int };
    pub const VkSemaphoreZirconHandleExportInfo = extern struct { handle: u32 };

    pub const ExportInfo = extern struct {
        type: Type,
        data: union {
            none: void,
            dxgi_shared_handle_export_info: DXGISharedHandleExportInfo,
            mtl_shared_event_export_info: MTLSharedEventExportInfo,
            vk_semaphore_opaque_fd_export_info: VkSemaphoreOpaqueFDExportInfo,
            vk_semaphore_sync_fd_export_info: VkSemaphoreSyncFDExportInfo,
            vk_semaphore_zircon_handle_export_info: VkSemaphoreZirconHandleExportInfo,
        },
    };
};
