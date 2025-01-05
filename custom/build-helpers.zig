const std = @import("std");
const Step = std.Build.Step;

pub const CheckFn = *const fn (step: *Step, _: std.Progress.Node) anyerror!void;
pub const CustomOptions = struct {
    name: []const u8 = "check",
    target: ?std.Build.ResolvedTarget = null,
    version: ?std.SemanticVersion = null,
    optimize: std.builtin.OptimizeMode = .Debug,
    code_model: std.builtin.CodeModel = .default,
    linkage: ?std.builtin.LinkMode = null,
    max_rss: usize = 0,
    link_libc: ?bool = null,
    single_threaded: ?bool = null,
    pic: ?bool = null,
    strip: ?bool = null,
    unwind_tables: ?bool = null,
    omit_frame_pointer: ?bool = null,
    sanitize_thread: ?bool = null,
    error_tracing: ?bool = null,
    use_llvm: ?bool = null,
    use_lld: ?bool = null,
    zig_lib_dir: ?std.Build.LazyPath = null,
    /// Embed a `.manifest` file in the compilation if the object format supports it.
    /// https://learn.microsoft.com/en-us/windows/win32/sbscs/manifest-files-reference
    /// Manifest files must have the extension `.manifest`.
    /// Can be set regardless of target. The `.manifest` file will be ignored
    /// if the target object format does not support embedded manifests.
    win32_manifest: ?std.Build.LazyPath = null,
};

pub fn addCheck(b: *std.Build, comptime prog: []const u8, options: CustomOptions) *Step.Compile {
    const tmp = std.Build.Step.Compile.create(b, .{
        .name = options.name,
        .kind = .@"test",
        .root_module = .{
            .root_source_file = null,
            .target = options.target orelse b.host,
            .optimize = options.optimize,
            .link_libc = options.link_libc,
            .single_threaded = options.single_threaded,
            .pic = options.pic,
            .strip = options.strip,
            .unwind_tables = options.unwind_tables,
            .omit_frame_pointer = options.omit_frame_pointer,
            .sanitize_thread = options.sanitize_thread,
            .error_tracing = options.error_tracing,
        },
        .max_rss = options.max_rss,
        .use_llvm = options.use_llvm,
        .use_lld = options.use_lld,
        .zig_lib_dir = options.zig_lib_dir orelse b.zig_lib_dir,
    });
    const s = std.Build.Step.init(.{ .id = .custom, .name = prog ++ " in path", .owner = b, .makeFn = struct {
        pub fn findProg(step: *Step, _: std.Progress.Node) anyerror!void {
            _ = step.owner.findProgram(
                &[_][]const u8{
                    prog,
                },
                &[_][]const u8{},
            ) catch |err| {
                return step.fail("{s}: Unable to find '{s}' in path.\n", .{ @errorName(err), prog });
            };
        }
    }.findProg });
    tmp.step = s;
    return tmp;
}

pub fn addRemoveDirTreeRecursive(b: *std.Build, _step: *std.Build.Step, path: []const u8, dirname: []const u8) !void {
    var dir = try std.fs.cwd().openDir(path, .{ .iterate = true });
    defer dir.close();
    var it = dir.iterate();
    while (try it.next()) |file| {
        if (std.mem.eql(u8, file.name, dirname)) {
            if (std.fs.path.join(std.heap.page_allocator, &.{ path, file.name })) |resdir| {
                _step.dependOn(&b.addRemoveDirTree(b.pathFromRoot(resdir)).step);
            } else |err| {
                std.debug.print("Could not join paths {s} and {s}", .{ path, file.name });
                return err;
            }
        } else if (file.kind == .directory) {
            if (std.fs.path.join(std.heap.page_allocator, &.{ path, file.name })) |newdir| {
                addRemoveDirTreeRecursive(b, _step, newdir, dirname) catch |err| {
                    std.debug.print("Could not find {s}\n", .{newdir});
                    return err;
                };
            } else |err| {
                std.debug.print("Could not join paths {s} and {s}", .{ path, file.name });
                return err;
            }
        }
    }
}
