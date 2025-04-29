const std = @import("std");

const examples = [_][]const u8{
    "triangle",
    "cube",
    "fractal",
};

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
    buildExamples(b, prism, target, optimize);
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
    const step = b.step("generate", "Run code generator");
    step.dependOn(&run.step);
}

fn buildExamples(b: *std.Build, prism: *std.Build.Module, target: std.Build.ResolvedTarget, optimize: std.builtin.OptimizeMode) void {
    for (examples) |name| {
        const exe = b.addExecutable(.{
            .name = b.fmt("example - {s}", .{name}),
            .root_module = b.createModule(.{
                .root_source_file = b.path(b.fmt("examples/{s}.zig", .{name})),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "prism", .module = prism },
                },
            }),
        });

        b.installArtifact(exe);

        const run = b.addRunArtifact(exe);
        if (b.args) |args| run.addArgs(args);

        const step = b.step(b.fmt("run-{s}", .{name}), b.fmt("Run example: {s}", .{name}));
        step.dependOn(&run.step);
    }
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
