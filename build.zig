const std = @import("std");

pub fn build(b: *std.Build) void {
    const optimize = b.standardOptimizeOption(.{ .preferred_optimize_mode = .ReleaseSafe });
    const target = b.standardTargetOptions(.{});

    const lib = b.addStaticLibrary(.{
        .target = target,
        .optimize = optimize,
        .name = "zig-stats",
        .root_source_file = b.path("src/stats.zig"),
    });
    b.installArtifact(lib);
}
