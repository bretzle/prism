const std = @import("std");

pub fn Pool(comptime K: type, comptime V: type) type {
    std.debug.assert(@typeInfo(K).@"enum".tag_type == u32);

    const Handle = packed struct(u32) {
        index: u16,
        generation: u16,
    };

    return struct {
        const Self = @This();

        buffer: []V,
        handles: []Handle,
        cursor: u16,

        pub fn init(allocator: std.mem.Allocator) !Self {
            return .{
                .buffer = try allocator.alloc(V, 8),
                .handles = try allocator.alloc(Handle, 8),
                .cursor = 1,
            };
        }

        pub fn add(self: *Self, item: V) K {
            const handle = self.alloc();
            self.buffer[handle.index] = item;
            return @enumFromInt(@as(u32, @bitCast(handle)));
        }

        pub fn get(self: *Self, id: K) *V {
            const handle = asHandle(id);
            std.debug.assert(self.alive(handle));
            return &self.buffer[handle.index];
        }

        fn alloc(self: *Self) Handle {
            // TODO handle destroyed handles
            std.debug.assert(self.handles.len - 1 != self.cursor); // check that pool has space

            const handle = Handle{ .index = self.cursor, .generation = 0 };
            self.handles[self.cursor] = handle;
            self.cursor += 1;
            return handle;
        }

        fn alive(self: *const Self, handle: Handle) bool {
            return handle.index < self.cursor and self.handles[handle.index] == handle;
        }

        inline fn asHandle(id: K) Handle {
            return @bitCast(@as(u32, @intFromEnum(id)));
        }
    };
}
