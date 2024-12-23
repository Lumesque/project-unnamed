const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});
    b.dest_dir = ".";

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});
    b.install_prefix = "out";

    const exe = b.addExecutable(.{
        .name = "project-unnamed",
        .root_source_file = null,
        .target = target,
        .optimize = optimize,
    });

    const flags = [_][]const u8{
        "-pedantic-errors",
        "-Wall",
        "-Werror",
        "-std=c++23",
    };

    const cexe: std.Build.Module.CSourceFile = .{ .file = b.path("src/c++/main.cpp"), .flags = &flags };

    exe.addCSourceFile(cexe);
    exe.linkLibCpp();

    // This declares intent for the executable to be installed into the
    // standard location when the user invokes the "install" step (the default
    // step when running `zig build`).
    b.installArtifact(exe);

    // This *creates* a Run step in the build graph, to be executed when another
    // step is evaluated that depends on it. The next line below will establish
    // such a dependency.
    const run_cmd = b.addRunArtifact(exe);

    // By making the run step depend on the install step, it will be run from the
    // installation directory rather than directly from within the cache directory.
    // This is not necessary, however, if the application depends on other installed
    // files, this ensures they will be present and in the expected location.
    run_cmd.step.dependOn(b.getInstallStep());
    // This creates a build step. It will be visible in the `zig build --help` menu,
    // and can be selected like this: `zig build run`
    // This will evaluate the `run` step rather than the default, which is "install".
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    // This allows the user to pass arguments to the application in the build
    // command itself, like this: `zig build run -- arg1 arg2 etc`
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const docs = b.step("docs", "Generate docs");
    const doxy_run = b.addSystemCommand(&.{ "doxygen", "doxygen.config" });
    docs.dependOn(&doxy_run.step);
    // Uncomment code below if we ever generate zig files
    //const docs_install = b.addInstallDirectory(.{
    //.install_dir = .prefix,
    //.install_subdir = "docs",
    //.source_dir = exe.getEmittedDocs(),
    //});
    //docs.dependOn(&docs_install.step);
    //

    // Eventually, add clang-tidy and ruff here
    const fmt_step = b.step("fmt", "Formats generated code.");
    const fmt = b.addFmt(.{
        .paths = &.{
            "src/c++",
            "build.zig",
        },
        .check = true,
    });
    fmt_step.dependOn(&fmt.step);

    const clean_step = b.step("clean", "Clean up created files and documentation.");
    if (@import("builtin").os.tag != .windows) {
        clean_step.dependOn(&b.addRemoveDirTree(b.pathFromRoot(".zig-cache")).step);
    }
    clean_step.dependOn(&b.addRemoveDirTree(b.pathFromRoot("zig-out")).step);
    clean_step.dependOn(&b.addRemoveDirTree(b.pathFromRoot("html")).step);
}
