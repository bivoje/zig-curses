const std = @import("std");
const Builder = std.build.Builder;

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();

    //const lib = b.addStaticLibrary("zig-curses", "src/main.zig");
    //lib.setBuildMode(mode);
    //lib.install();

    const main_tests = b.addTest("src/main.zig");
    main_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run library tests");
    test_step.dependOn(&main_tests.step);

    const exe = b.addExecutable("sample", "src/main.zig");
    exe.setBuildMode(mode);
    exe.linkSystemLibrary("c");
    exe.linkSystemLibrary("ncursesw");
    exe.addIncludeDir("./src");

    const run_cmd = exe.run();

    const run_step = b.step("run", "Run the sample");
    run_step.dependOn(&run_cmd.step);

    b.default_step.dependOn(&exe.step);
    b.installArtifact(exe);
}
