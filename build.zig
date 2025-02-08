const std = @import("std");

pub fn build(b: *std.Build) void {
    // Build is restricted to x86 (32bit) for simplicity for now; longer goals include
    // expanding this to aarch64 + x86_64.
    const target = b.resolveTargetQuery(.{ .os_tag = .freestanding, .cpu_arch = .x86 });
    // Assume aarch64 if not x86 for now, consider adding more in-depth parsing later.
    const archPath = if (target.result.cpu.arch == .x86) "x86" else "aarch64";

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const multiheader = b.addAssembly(.{
        .name = "multiboot_hdr",
        .source_file = b.path(
            b.pathJoin(&[_][]const u8{ "arch/", archPath, "/src/boot.s" }),
        ),
        .target = target,
        .optimize = optimize,
    });

    const kernel_main = b.addExecutable(.{
        .name = "init_kernel",
        .root_source_file = b.path("src/kernel.zig"),
        .target = target,
        .optimize = optimize,
    });

    kernel_main.addObject(multiheader);

    kernel_main.setLinkerScript(b.path(b.pathJoin(&[_][]const u8{ "arch/", archPath, "src/linker.ld" })));

    b.installArtifact(kernel_main);
}
