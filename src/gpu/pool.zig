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
            return @bitCast(handle);
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
            return @bitCast(id);
        }
    };
}

// pub fn Handles(comptime K: type) type {
//     std.debug.assert(@typeInfo(K).@"enum".tag_type == u32);

//     const HandleRaw = u32;
//     const HandleType = K;
//     const IndexType = u16;
//     const VersionType = u16;
//     const invalid = std.math.maxInt(IndexType);

//     return struct {
//         const Self = @This();

//         handles: std.ArrayListUnmanaged(K),
//         append_cursor: IndexType,
//         last_destroyed: ?IndexType,

//         pub const empty = Self{
//             .handles = .empty,
//             .append_cursor = 1,
//             .last_destroyed = null,
//         };

//         pub fn create(self: *Self, allocator: std.mem.Allocator) HandleType {
//             if (self.last_destroyed) |last| {
//                 const version = extractVersion(self.handles.items[last]);
//                 const destroyed_id = extractIndex(self.handles.items[last]);

//                 const handle = forge(last, version);
//                 self.handles.items[last] = @enumFromInt(handle);

//                 self.last_destroyed = if (destroyed_id == invalid) null else destroyed_id;
//                 return @enumFromInt(handle);
//             } else {
//                 std.debug.assert(self.handles.len - 1 != self.append_cursor);

//                 const idx = self.append_cursor;
//                 const handle = forge(self.append_cursor, 0);
//                 self.handles[idx] = @enumFromInt(handle);

//                 self.append_cursor += 1;
//                 return @enumFromInt(handle);
//             }
//         }

//         pub fn destroy(self: *Self, handle: HandleType) void {
//             const id = extractIndex(handle);
//             const next_id = self.last_destroyed orelse invalid;
//             std.debug.assert(next_id != id);

//             const version = extractVersion(handle);
//             self.handles[id] = forge(next_id, version +% 1);

//             self.last_destroyed = id;
//         }

//         pub fn alive(self: *const Self, handle: HandleType) bool {
//             const idx = extractIndex(handle);
//             return idx < self.append_cursor and self.handles[idx] == handle;
//         }

//         pub fn extractIndex(handle: HandleType) IndexType {
//             return @truncate(@intFromEnum(handle));
//         }

//         pub fn extractVersion(handle: HandleType) VersionType {
//             return @truncate(@as(HandleRaw, @intFromEnum(handle)) >> @bitSizeOf(IndexType));
//         }

//         fn forge(idx: IndexType, version: VersionType) HandleRaw {
//             return @as(HandleRaw, idx) | @as(HandleRaw, version) << @bitSizeOf(IndexType);
//         }
//     };
// }
