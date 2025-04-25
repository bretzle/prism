const std = @import("std");
const math = @import("../math/math.zig");

const Allocator = std.mem.Allocator;

/// Vertex writer manages the placement of vertices by tracking which are unique. If a duplicate vertex is added
/// with `put`, only it's index will be written to the index buffer.
/// `I` should match the integer type used for the index buffer
pub fn VertexWriter(comptime V: type, comptime I: type) type {
    return struct {
        const Self = @This();

        const MapEntry = struct {
            packed_index: I = null_index,
            next_sparse: I = null_index,
        };

        const null_index: I = math.maxInt(I);

        vertices: []V,
        indices: []I,
        sparse_to_packed_map: []MapEntry,

        next_collision_index: I,
        next_packed_index: I,
        written_indices_count: I,

        /// Allocate storage and set default values
        /// `sparse_vertices_count` is the number of vertices in the source before de-duplication / remapping
        /// Put more succinctly, the largest index value in source index buffer
        /// `max_vertex_count` is largest permutation of vertices assuming that {vertex, uv, normal} never map 1:1 and always
        /// create a new mapping
        pub fn create(allocator: Allocator, indices_count: I, sparse_vertices_count: I, max_vertex_count: I) !Self {
            const self = Self{
                .vertices = try allocator.alloc(V, max_vertex_count),
                .indices = try allocator.alloc(I, indices_count),
                .sparse_to_packed_map = try allocator.alloc(MapEntry, max_vertex_count),
                .next_collision_index = sparse_vertices_count,
                .next_packed_index = 0,
                .written_indices_count = 0,
            };
            @memset(self.sparse_to_packed_map, .{});
            return self;
        }

        pub fn deinit(self: *Self, allocator: Allocator) void {
            allocator.free(self.vertices);
            allocator.free(self.indices);
            allocator.free(self.sparse_to_packed_map);
        }

        pub fn put(self: *Self, vertex: V, sparse_index: I) void {
            if (self.sparse_to_packed_map[sparse_index].packed_index == null_index) {
                // New start of chain, reserve a new packed index and add entry to `index_map`
                const packed_index = self.next_packed_index;
                self.sparse_to_packed_map[sparse_index].packed_index = packed_index;
                self.vertices[packed_index] = vertex;
                self.indices[self.written_indices_count] = packed_index;
                self.written_indices_count += 1;
                self.next_packed_index += 1;
                return;
            }
            var previous_sparse_index: I = undefined;
            var current_sparse_index = sparse_index;
            while (current_sparse_index != null_index) {
                const packed_index = self.sparse_to_packed_map[current_sparse_index].packed_index;
                if (std.mem.eql(u8, &std.mem.toBytes(self.vertices[packed_index]), &std.mem.toBytes(vertex))) {
                    // We already have a record for this vertex in our chain
                    self.indices[self.written_indices_count] = packed_index;
                    self.written_indices_count += 1;
                    return;
                }
                previous_sparse_index = current_sparse_index;
                current_sparse_index = self.sparse_to_packed_map[current_sparse_index].next_sparse;
            }
            // This is a new mapping for the given sparse index
            const packed_index = self.next_packed_index;
            const remapped_sparse_index = self.next_collision_index;
            self.indices[self.written_indices_count] = packed_index;
            self.vertices[packed_index] = vertex;
            self.sparse_to_packed_map[previous_sparse_index].next_sparse = remapped_sparse_index;
            self.sparse_to_packed_map[remapped_sparse_index].packed_index = packed_index;
            self.next_packed_index += 1;
            self.next_collision_index += 1;
            self.written_indices_count += 1;
        }

        pub fn indexBuffer(self: *const Self) []I {
            return self.indices;
        }

        pub fn vertexBuffer(self: *const Self) []V {
            return self.vertices[0..self.next_packed_index];
        }
    };
}

test VertexWriter {
    const Vec3 = [3]f32;
    const Vertex = extern struct { pos: Vec3, normal: Vec3 };
    const Face = struct { pos: [3]u16, normal: [3]u16 };

    const allocator = std.testing.allocator;
    const expect = std.testing.expect;

    const vertices = [_]Vec3{
        .{ 1.0, 0.0, 0.0 }, // 0: Position
        .{ 2.0, 0.0, 0.0 }, // 1: Position
        .{ 3.0, 0.0, 0.0 }, // 2: Position
        .{ 1.0, 0.0, 0.0 }, // 3: Normal
        .{ 4.0, 0.0, 0.0 }, // 4: Position
        .{ 0.0, 1.0, 0.0 }, // 5: Normal
        .{ 5.0, 0.0, 0.0 }, // 6: Position
        .{ 0.0, 0.0, 1.0 }, // 7: Normal
        .{ 1.0, 0.0, 1.0 }, // 8: Normal
        .{ 6.0, 0.0, 0.0 }, // 9: Position
    };

    const faces = [_]Face{
        .{ .pos = .{ 0, 4, 2 }, .normal = .{ 7, 5, 3 } },
        .{ .pos = .{ 2, 3, 9 }, .normal = .{ 3, 7, 8 } },
        .{ .pos = .{ 9, 2, 4 }, .normal = .{ 8, 7, 5 } },
        .{ .pos = .{ 2, 6, 1 }, .normal = .{ 3, 5, 7 } },
        .{ .pos = .{ 9, 6, 0 }, .normal = .{ 5, 7, 8 } },
    };

    var writer = try VertexWriter(Vertex, u32).create(allocator, faces.len * 3, vertices.len, faces.len * 3);
    defer writer.deinit(allocator);

    for (faces) |face| {
        for (0..3) |x| {
            const position_index = face.pos[x];
            const position = vertices[position_index];
            const normal = vertices[face.normal[x]];
            const vertex = Vertex{
                .pos = position,
                .normal = normal,
            };
            writer.put(vertex, position_index);
        }
    }

    const indices = writer.indexBuffer();
    try expect(indices.len == faces.len * 3);

    // Face 0
    try expect(indices[0] == 0); // (0, 7) New
    try expect(indices[1] == 1); // (4, 5) New
    try expect(indices[2] == 2); // (2, 3) New

    // Face 1
    try expect(indices[3 + 0] == 2); // (2, 3) Duplicate - Reuse index
    try expect(indices[3 + 1] == 3); // (3, 7) New
    try expect(indices[3 + 2] == 4); // (9, 8) New

    // Face 2
    try expect(indices[6 + 0] == 4); // (9, 8) Duplicate - Reuse index
    try expect(indices[6 + 1] == 5); // (2, 7) New normal mapping (Don't clobber)
    try expect(indices[6 + 2] == 1); // (4, 5) Duplicate - Reuse Index

    // Face 3
    try expect(indices[9 + 0] == 2); // (2, 3) Duplicate - Reuse index
    try expect(indices[9 + 1] == 6); // (6, 5) New
    try expect(indices[9 + 2] == 7); // (1, 7) New

    // Face 4
    try expect(indices[12 + 0] == 8); // (9, 5) New normal mapping (Don't clobber)
    try expect(indices[12 + 1] == 9); // (6, 7) New normal mapping (Don't clobber)
    try expect(indices[12 + 2] == 10); // (0, 8) New normal mapping (Don't clobber)

    try expect(writer.vertexBuffer().len == 11);
}
