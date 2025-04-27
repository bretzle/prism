//! Stores a group of heaps

const std = @import("std");
const w32 = @import("w32");
const d3d12 = w32.d3d12;

const gpu_allocator = @import("../allocator.zig");
const Device = @import("d3d12.zig").Device;
const Resource = @import("d3d12.zig").Resource;

const allocator = @import("../../prism.zig").allocator;

const AllocationSizes = struct {
    const four_mb = 4 * 1024 * 1024;

    device_memblock_size: u64 = four_mb,
    host_memblock_size: u64 = four_mb,
};

const HeapCategory = enum {
    all,
    buffer,
    rtv_dsv_texture,
    other_texture,
};

const ResourceCategory = enum {
    buffer,
    rtv_dsv_texture,
    other_texture,

    pub inline fn heapUsable(self: ResourceCategory, heap: HeapCategory) bool {
        return switch (heap) {
            .all => true,
            .buffer => self == .buffer,
            .rtv_dsv_texture => self == .rtv_dsv_texture,
            .other_texture => self == .other_texture,
        };
    }
};

pub const ResourceCreateDescriptor = struct {
    location: MemoryLocation,
    resource_category: ResourceCategory,
    resource_desc: *const d3d12.RESOURCE_DESC,
    clear_value: ?*const d3d12.CLEAR_VALUE,
    initial_state: d3d12.RESOURCE_STATES,
};

pub const MemoryLocation = enum {
    unknown,
    gpu_only,
    cpu_to_gpu,
    gpu_to_cpu,
};

const AllocationCreateDescriptor = struct {
    location: MemoryLocation,
    size: u64,
    alignment: u64,
    resource_category: ResourceCategory,
};

const max_memory_groups = 9;

const MemoryAllocator = @This();

device: *Device,

memory_groups: std.BoundedArray(MemoryGroup, max_memory_groups),
allocation_sizes: AllocationSizes,

/// a single heap,
/// use the gpu_allocator field to allocate chunks of memory
pub const MemoryHeap = struct {
    index: usize,
    heap: *d3d12.IHeap,
    size: u64,
    gpu_allocator: gpu_allocator.Allocator,

    pub fn init(group: *MemoryGroup, index: usize, size: u64, dedicated: bool) gpu_allocator.Error!MemoryHeap {
        const heap = blk: {
            var desc = d3d12.HEAP_DESC{
                .SizeInBytes = size,
                .Properties = group.heap_properties,
                .Alignment = @intCast(d3d12.DEFAULT_MSAA_RESOURCE_PLACEMENT_ALIGNMENT),
                .Flags = switch (group.heap_category) {
                    .all => .{},
                    .buffer => .ALLOW_ONLY_BUFFERS,
                    .rtv_dsv_texture => .ALLOW_ONLY_RT_DS_TEXTURES,
                    .other_texture => .ALLOW_ONLY_NON_RT_DS_TEXTURES,
                },
            };
            var heap: ?*d3d12.IHeap = null;
            const hr = group.owning_pool.device.device.createHeap(
                &desc,
                &d3d12.IHeap.IID,
                @ptrCast(&heap),
            );
            if (hr == 0x887A0024) return gpu_allocator.Error.OutOfMemory;
            if (hr != 0) return gpu_allocator.Error.Other;

            break :blk heap.?;
        };

        return MemoryHeap{
            .index = index,
            .heap = heap,
            .size = size,
            .gpu_allocator = if (dedicated)
                try gpu_allocator.Allocator.initDedicatedBlockAllocator(size)
            else
                try gpu_allocator.Allocator.initOffsetAllocator(allocator, @intCast(size), null),
        };
    }

    pub fn deinit(self: *MemoryHeap) void {
        _ = self.heap.release();
        self.gpu_allocator.deinit();
    }
};

/// a group of multiple heaps with a single heap type
pub const MemoryGroup = struct {
    owning_pool: *MemoryAllocator,

    memory_location: MemoryLocation,
    heap_category: HeapCategory,
    heap_properties: d3d12.HEAP_PROPERTIES,

    heaps: std.ArrayListUnmanaged(?*MemoryHeap),

    pub const GroupAllocation = struct {
        allocation: gpu_allocator.Allocation,
        heap: *MemoryHeap,
        size: u64,
    };

    pub fn init(owner: *MemoryAllocator, memory_location: MemoryLocation, category: HeapCategory, properties: d3d12.HEAP_PROPERTIES) MemoryGroup {
        return .{
            .owning_pool = owner,
            .memory_location = memory_location,
            .heap_category = category,
            .heap_properties = properties,
            .heaps = .empty,
        };
    }

    pub fn deinit(self: *MemoryGroup) void {
        @breakpoint();
        for (self.heaps.items) |*heap| {
            if (heap.*) |*h| h.deinit();
        }
        self.heaps.deinit(allocator);
    }

    pub fn allocate(self: *MemoryGroup, size: u64) gpu_allocator.Error!GroupAllocation {
        const memblock_size: u64 = if (self.heap_properties.Type == .DEFAULT)
            self.owning_pool.allocation_sizes.device_memblock_size
        else
            self.owning_pool.allocation_sizes.host_memblock_size;
        if (size > memblock_size) {
            return self.allocateDedicated(size);
        }

        var empty_heap_index: ?usize = null;
        for (self.heaps.items, 0..) |*heap, index| {
            if (heap.*) |h| {
                const allocation = h.gpu_allocator.allocate(@intCast(size)) catch |err| switch (err) {
                    gpu_allocator.Error.OutOfMemory => continue,
                    else => return err,
                };
                return GroupAllocation{
                    .allocation = allocation,
                    .heap = h,
                    .size = size,
                };
            } else if (empty_heap_index == null) {
                empty_heap_index = index;
            }
        }

        // couldn't allocate, use the empty heap if we got one
        const heap = try self.addHeap(memblock_size, false, empty_heap_index);
        const allocation = try heap.gpu_allocator.allocate(@intCast(size));
        return GroupAllocation{
            .allocation = allocation,
            .heap = heap,
            .size = size,
        };
    }

    fn allocateDedicated(self: *MemoryGroup, size: u64) gpu_allocator.Error!GroupAllocation {
        const memory_block = try self.addHeap(size, true, blk: {
            for (self.heaps.items, 0..) |heap, index| {
                if (heap == null) break :blk index;
            }
            break :blk null;
        });
        const allocation = try memory_block.gpu_allocator.allocate(@intCast(size));
        return GroupAllocation{
            .allocation = allocation,
            .heap = memory_block,
            .size = size,
        };
    }

    pub fn free(self: *MemoryGroup, allocation: GroupAllocation) gpu_allocator.Error!void {
        try allocation.heap.gpu_allocator.free(allocation.allocation);

        if (allocation.heap.gpu_allocator.isEmpty()) {
            const index = allocation.heap.index;
            allocation.heap.deinit();
            self.heaps.items[index] = null;
        }
    }

    fn addHeap(self: *MemoryGroup, size: u64, dedicated: bool, replace: ?usize) gpu_allocator.Error!*MemoryHeap {
        const heap_index: usize = blk: {
            if (replace) |index| {
                if (self.heaps.items[index]) |heap| {
                    heap.deinit();
                }
                self.heaps.items[index] = null;
                break :blk index;
            } else {
                const heap = try self.heaps.addOne(allocator);
                heap.* = try allocator.create(MemoryHeap);
                break :blk self.heaps.items.len - 1;
            }
        };
        errdefer _ = self.heaps.pop();

        const heap = self.heaps.items[heap_index].?;
        heap.* = try MemoryHeap.init(self, heap_index, size, dedicated);
        return heap;
    }
};

pub const Allocation = struct {
    allocation: gpu_allocator.Allocation,
    heap: *MemoryHeap,
    size: u64,
    group: *MemoryGroup,
};

pub fn init(self: *MemoryAllocator, device: *Device) !void {
    const HeapType = struct {
        location: MemoryLocation,
        properties: d3d12.HEAP_PROPERTIES,
    };
    const heap_types = [_]HeapType{ .{
        .location = .gpu_only,
        .properties = d3d12.HEAP_PROPERTIES{
            .Type = .DEFAULT,
            .CPUPageProperty = .UNKNOWN,
            .MemoryPoolPreference = .UNKNOWN,
            .CreationNodeMask = 0,
            .VisibleNodeMask = 0,
        },
    }, .{
        .location = .cpu_to_gpu,
        .properties = d3d12.HEAP_PROPERTIES{
            .Type = .CUSTOM,
            .CPUPageProperty = .WRITE_COMBINE,
            .MemoryPoolPreference = .L0,
            .CreationNodeMask = 0,
            .VisibleNodeMask = 0,
        },
    }, .{
        .location = .gpu_to_cpu,
        .properties = d3d12.HEAP_PROPERTIES{
            .Type = .CUSTOM,
            .CPUPageProperty = .WRITE_BACK,
            .MemoryPoolPreference = .L0,
            .CreationNodeMask = 0,
            .VisibleNodeMask = 0,
        },
    } };

    self.* = .{
        .device = device,
        .memory_groups = std.BoundedArray(MemoryGroup, max_memory_groups).init(0) catch unreachable,
        .allocation_sizes = .{},
    };

    var options: d3d12.FEATURE_DATA_D3D12_OPTIONS = undefined;
    const hr = device.device.checkFeatureSupport(.OPTIONS, @ptrCast(&options), @sizeOf(@TypeOf(options)));
    if (hr != 0) return gpu_allocator.Error.Other;

    const tier_one_heap = options.ResourceHeapTier == .TIER_1;

    self.memory_groups = std.BoundedArray(MemoryGroup, max_memory_groups).init(0) catch unreachable;
    inline for (heap_types) |heap_type| {
        if (tier_one_heap) {
            self.memory_groups.appendAssumeCapacity(MemoryGroup.init(self, heap_type.location, .buffer, heap_type.properties));
            self.memory_groups.appendAssumeCapacity(MemoryGroup.init(self, heap_type.location, .rtv_dsv_texture, heap_type.properties));
            self.memory_groups.appendAssumeCapacity(MemoryGroup.init(self, heap_type.location, .other_texture, heap_type.properties));
        } else {
            self.memory_groups.appendAssumeCapacity(MemoryGroup.init(self, heap_type.location, .all, heap_type.properties));
        }
    }
}

pub fn deinit(self: *MemoryAllocator) void {
    for (self.memory_groups.slice()) |*group| {
        group.deinit();
    }
}

pub fn reportMemoryLeaks(self: *const MemoryAllocator) void {
    std.log.info("memory leaks:", .{});
    var total_blocks: u64 = 0;
    for (self.memory_groups.constSlice(), 0..) |mem_group, mem_group_index| {
        std.log.info("   memory group {} ({s}, {s}):", .{
            mem_group_index,
            @tagName(mem_group.heap_category),
            @tagName(mem_group.memory_location),
        });
        for (mem_group.heaps.items, 0..) |block, block_index| {
            if (block) |found_block| {
                std.log.info("       block {}; total size: {}; allocated: {};", .{
                    block_index,
                    found_block.size,
                    found_block.gpu_allocator.getAllocated(),
                });
                total_blocks += 1;
            }
        }
    }
    std.log.info("total blocks: {}", .{total_blocks});
}

pub fn allocate(self: *MemoryAllocator, desc: *const AllocationCreateDescriptor) gpu_allocator.Error!Allocation {
    // TODO: handle alignment
    for (self.memory_groups.slice()) |*memory_group| {
        if (memory_group.memory_location != desc.location and desc.location != .unknown) continue;
        if (!desc.resource_category.heapUsable(memory_group.heap_category)) continue;
        const allocation = try memory_group.allocate(desc.size);
        return Allocation{
            .allocation = allocation.allocation,
            .heap = allocation.heap,
            .size = allocation.size,
            .group = memory_group,
        };
    }
    return gpu_allocator.Error.NoCompatibleMemoryFound;
}

pub fn free(_: *MemoryAllocator, allocation: Allocation) gpu_allocator.Error!void {
    try allocation.group.free(MemoryGroup.GroupAllocation{
        .allocation = allocation.allocation,
        .heap = allocation.heap,
        .size = allocation.size,
    });
}

pub fn createResource(self: *MemoryAllocator, desc: *const ResourceCreateDescriptor) gpu_allocator.Error!Resource {
    const allocation_desc = blk: {
        var allocation_info: d3d12.RESOURCE_ALLOCATION_INFO = undefined;
        self.device.device.getResourceAllocationInfo(
            &allocation_info,
            0,
            1,
            @ptrCast(desc.resource_desc),
        );
        // TODO: If size in bytes == UINT64_MAX then an error occured

        break :blk AllocationCreateDescriptor{
            .location = desc.location,
            .size = allocation_info.SizeInBytes,
            .alignment = allocation_info.Alignment,
            .resource_category = desc.resource_category,
        };
    };

    const allocation = try self.allocate(&allocation_desc);

    var d3d_resource: ?*d3d12.IResource = null;
    const hr = self.device.device.createPlacedResource(
        allocation.heap.heap,
        allocation.allocation.offset,
        desc.resource_desc,
        desc.initial_state,
        desc.clear_value,
        &d3d12.IResource.IID,
        @ptrCast(&d3d_resource),
    );
    if (hr != 0) return gpu_allocator.Error.Other;

    return Resource{
        .mem_allocator = self,
        .state = desc.initial_state,
        .allocation = allocation,
        .resource = d3d_resource.?,
        .memory_location = desc.location,
        .size = allocation.size,
    };
}

pub fn destroyResource(self: *MemoryAllocator, resource: Resource) gpu_allocator.Error!void {
    if (resource.allocation) |allocation| {
        try self.free(allocation);
    }
    _ = resource.resource.release();
}
