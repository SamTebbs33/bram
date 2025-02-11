const std = @import("std");

pub fn build(b: *std.Build) void {
    // Build is restricted to x86 (32bit) for simplicity for now; longer goals include
    // expanding this to aarch64 + x86_64.
    const x86: std.Target.Query = .{ .os_tag = .freestanding, .cpu_arch = .x86 };
    const aarch64: std.Target.Query = .{ .os_tag = .freestanding, .cpu_arch = .aarch64 };
    const target = b.standardTargetOptions(.{ .whitelist = &[_]std.Target.Query{ aarch64, x86 }, .default_target = x86 });
    // Assume aarch64 if not x86 for now, consider adding more in-depth parsing later.
    const archPath = switch (target.result.cpu.arch) {
        .x86 => "x86",
        .aarch64 => "aarch64",
        else => @panic("Unhandled target\n"),
    };

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
