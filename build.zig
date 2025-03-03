const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const interface = b.dependency("interface", .{});

    const prism = b.createModule(.{
        .root_source_file = b.path("src/prism.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "interface", .module = interface.module("interface") },
        },
    });

    const exe = b.addExecutable(.{
        .name = "example",
        .root_module = b.createModule(.{
            .root_source_file = b.path("main.zig"),
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
