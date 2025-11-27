const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const dep_opts = .{ .target = target, .optimize = optimize };
    const ogg_dep = b.dependency("ogg", dep_opts);
    const opus_dep = b.dependency("opus", dep_opts);

    const opusfile_lib = b.addLibrary(.{
        .name = "opusfile",
        .root_module = b.createModule(.{
            .target = target,
            .optimize = optimize,
            .link_libc = true,
        }),
    });

    // Not a Zig dep.
    const opusfile_dep = b.dependency("opusfile", .{});
    const src_path = opusfile_dep.path("src");

    opusfile_lib.addIncludePath(src_path);
    opusfile_lib.addIncludePath(opusfile_dep.path("include"));

    opusfile_lib.addCSourceFiles(.{
        .root = src_path,
        .files = &.{
            "info.c",
            "internal.c",
            "opusfile.c",
            "stream.c",
        },
    });

    opusfile_lib.linkLibrary(ogg_dep.artifact("ogg"));
    opusfile_lib.linkLibrary(opus_dep.artifact("opus"));
    opusfile_lib.addIncludePath(opusfile_dep.path("include"));
    opusfile_lib.installHeadersDirectory(opusfile_dep.path("include"), "", .{});
    opusfile_lib.installLibraryHeaders(opus_dep.artifact("opus"));
    opusfile_lib.installLibraryHeaders(ogg_dep.artifact("ogg"));

    b.installArtifact(opusfile_lib);
}
