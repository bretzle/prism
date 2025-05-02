const std = @import("std");

pub const Platform = enum {
    dummy,
    win32,

    fn default(target: std.Target) Platform {
        if (target.os.tag == .windows) return .win32;
        @panic("unsupported target");
    }
};

pub const Backend = enum {
    dummy,
    d3d12,

    fn default(platform: Platform) Backend {
        return switch (platform) {
            .dummy => .dummy,
            .win32 => .d3d12,
        };
    }
};

const examples = [_][]const u8{
    "triangle",
    "cube",
    "fractal",
    "batch",
};

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const platform = b.option(Platform, "platform", "platform api") orelse Platform.default(target.result);
    const backend = b.option(Backend, "backend", "backend api") orelse Backend.default(platform);

    const options = b.addOptions();
    options.addOption(Platform, "platform", platform);
    options.addOption(Backend, "backend", backend);
    options.addOption(std.builtin.OptimizeMode, "mode", optimize);

    const prism = b.addModule("prism", .{
        .root_source_file = b.path("src/prism.zig"),
        .target = target,
        .optimize = optimize,
    });

    prism.addOptions("options", options);

    if (platform == .win32) {
        prism.addAnonymousImport("w32", .{
            .root_source_file = b.path("deps/w32/windows.zig"),
            .target = target,
            .optimize = optimize,
        });
    }

    if (backend != .dummy) {
        prism.addAnonymousImport("shader", .{
            .root_source_file = b.path("deps/shader.zig"),
            .target = target,
            .optimize = optimize,
        });
    }

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

        if (target.result.os.tag == .windows and optimize != .Debug)
            exe.subsystem = .Windows;

        b.installArtifact(exe);

        const run = b.addRunArtifact(exe);
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

    const run = b.addRunArtifact(tests);
    const step = b.step("test", "Run unit tests");
    step.dependOn(&run.step);
}
