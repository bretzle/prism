const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // const pool_mod = b.addModule("pool", .{
    //     .root_source_file = b.path("deps/pool.zig"),
    //     .target = target,
    //     .optimize = optimize,
    // });

    const w32_mod = b.addModule("w32", .{
        .root_source_file = b.path("deps/w32/windows.zig"),
        .target = target,
        .optimize = optimize,
    });

    const shader_mod = b.addModule("shader", .{
        .root_source_file = b.path("deps/shader.zig"),
        .target = target,
        .optimize = optimize,
    });

    const prism = b.addModule("prism", .{
        .root_source_file = b.path("src/prism.zig"),
        .target = target,
        .optimize = optimize,
        .imports = &.{
            .{ .name = "w32", .module = w32_mod },
            .{ .name = "shader", .module = shader_mod },
            // .{ .name = "truetype", .module = truetype.module("TrueType") },
        },
    });

    buildTools(b, target, optimize);
    buildExample(b, prism, target, optimize);
    buildTest(b, prism, target, optimize);
}

fn buildTools(b: *std.Build, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const generator = b.addExecutable(.{
        .name = "generator",
        .root_module = b.createModule(.{
            .root_source_file = b.path("tools/generator/generator.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    const run = b.addRunArtifact(generator);
    const step = b.step("generate", "run code generator");
    step.dependOn(&run.step);
}

fn buildExample(b: *std.Build, prism: *std.Build.Module, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const exe = b.addExecutable(.{
        .name = "example - hello",
        .root_module = b.createModule(.{
            .root_source_file = b.path("examples/hello.zig"),
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
}

fn buildTest(b: *std.Build, prism: *std.Build.Module, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    const tests = b.addTest(.{
        .root_module = prism,
        .target = target,
        .optimize = optimize,
    });
    const run_tests = b.addRunArtifact(tests);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&run_tests.step);
}
