const std = @import("std");

pub fn Manager(comptime T: type) type {
    return struct {
        const Self = @This();

        count: std.atomic.Value(u32) = .init(1),

        pub fn reference(self: *Self) void {
            _ = self.count.fetchAdd(1, .monotonic);
        }

        pub fn release(self: *Self) void {
            if (self.count.fetchSub(1, .release) == 1) {
                _ = self.count.load(.acquire);
                const parent: *T = @alignCast(@fieldParentPtr("manager", self));
                parent.deinit();
            }
        }
    };
}
