const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const truetype = b.dependency("truetype", .{});

    const pool_mod = b.addModule("pool", .{
        .root_source_file = b.path("deps/pool.zig"),
        .target = target,
        .optimize = optimize,
    });

    const w32_mod = b.addModule("w32", .{
        .root_source_file = b.path("deps/w32/windows.zig"),
        .target = target,
        .optimize = optimize,
    });

    const prism = b.addModule("prism", .{
        .root_source_file = b.path("src/prism.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "w32", .module = w32_mod },
            .{ .name = "pool", .module = pool_mod },
            .{ .name = "truetype", .module = truetype.module("TrueType") },
        },
    });

    const exe = b.addExecutable(.{
        .name = "example - simple",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/simple.zig"),
            .target = target,
            .optimize = optimize,
            .imports = &.{
                .{ .name = "prism", .module = prism },
            },
        }),
    });

    b.installArtifact(exe);

    const run = b.addRunArtifact(exe);
    run.step.dependOn(b.getInstallStep());
    if (b.args) |args| run.addArgs(args);

    const step = b.step("run", "Run the app");
    step.dependOn(&run.step);

    const tests = b.addTest(.{ .root_module = prism });
    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}
