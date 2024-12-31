const std = @import("std");
const helpers = @import("custom/build-helpers.zig");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const no_stdout = b.option(bool, "no-stdout", "Disable stdout of child processes") orelse false;
    const target = b.standardTargetOptions(.{});

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

    const tests = b.step("test", "Run tests");
    const pytests = b.addSystemCommand(&.{"pytest"});
    if (b.args) |args| {
        pytests.addArgs(args);
    }
    if (no_stdout)
        _ = pytests.captureStdOut();
    pytests.failing_to_execute_foreign_is_an_error = false;
    tests.dependOn(&pytests.step);

    const docs = b.step("docs", "Generate docs");
    const doxy_run = b.addSystemCommand(&.{ "doxygen", "doxygen.config" });
    if (no_stdout)
        _ = doxy_run.captureStdOut();
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
    const ruff_run = b.addSystemCommand(&.{ "ruff", "format" });
    ruff_run.failing_to_execute_foreign_is_an_error = false;
    if (b.args) |args| {
        ruff_run.addArgs(args);
    }
    if (no_stdout)
        _ = ruff_run.captureStdOut();
    fmt_step.dependOn(&fmt.step);
    fmt_step.dependOn(&ruff_run.step);

    const clean_step = b.step("clean", "Clean up created files and documentation.");
    if (@import("builtin").os.tag != .windows) {
        clean_step.dependOn(&b.addRemoveDirTree(b.pathFromRoot(".zig-cache")).step);
    }
    clean_step.dependOn(&b.addRemoveDirTree(b.pathFromRoot("zig-out")).step);
    clean_step.dependOn(&b.addRemoveDirTree(b.pathFromRoot("html")).step);
    helpers.addRemoveDirTreeRecursive(b, clean_step, b.pathFromRoot("."), "__pycache__") catch |err| {
        std.debug.print("{}\n", .{err});
    };
    helpers.addRemoveDirTreeRecursive(b, clean_step, b.pathFromRoot("."), ".pytest_cache") catch |err| {
        std.debug.print("{}\n", .{err});
    };
    helpers.addRemoveDirTreeRecursive(b, clean_step, b.pathFromRoot("."), ".ruff_cache") catch |err| {
        std.debug.print("{}\n", .{err});
    };
    helpers.addRemoveDirTreeRecursive(b, clean_step, b.pathFromRoot("."), ".direnv") catch |err| {
        std.debug.print("{}\n", .{err});
    };

    // Currently, this will cache the steps and so if it passes, it will always pass, but this should only be used on new systems and once
    const healthcheck = b.step("check", "Checks that the necessary build components are installed.");
    healthcheck.dependOn(&helpers.addCheck(b, "ruff", .{}).step);
    healthcheck.dependOn(&helpers.addCheck(b, "pytest", .{}).step);
    healthcheck.dependOn(&helpers.addCheck(b, "doxygen", .{}).step);
    healthcheck.dependOn(&helpers.addCheck(b, "doxypypy", .{}).step);

    const all = b.step("all", "Run install, docs, and tests");
    all.dependOn(b.getInstallStep());
    all.dependOn(docs);
    all.dependOn(tests);
}
