const std = @import("std");

pub fn build(b: *std.Build) void {
    // Build is restricted to x86 (32bit) for simplicity for now; longer goals include
    // expanding this to aarch64 + x86_64.
    const i386_cpu: std.Target.Query.CpuModel = .{ .explicit = &std.Target.x86.cpu.i386 };
    const target = b.resolveTargetQuery(.{ .os_tag = .freestanding, .cpu_arch = .x86, .cpu_model = i386_cpu });
    // Assume aarch64 if not x86 for now, consider adding more in-depth parsing later.
    const archPath = if (target.result.cpu.arch == .x86) "x86" else "aarch64";

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize = b.standardOptimizeOption(.{});

    const multiheader_module = b.createModule(.{
        .target = target,
        .optimize = optimize,
    });
    multiheader_module.addAssemblyFile(b.path(
        b.pathJoin(&[_][]const u8{ "src/arch/", archPath, "/src/boot.s" }),
    ));
    const multiheader = b.addObject(.{
        .name = "multiboot_hdr",
        .root_module = multiheader_module,
    });

    const kernel_main = b.addExecutable(.{
        .name = "bram",
        .root_module = b.createModule(.{
            .root_source_file = b.path("src/kernel.zig"),
            .target = target,
            .optimize = optimize,
        }),
    });

    kernel_main.root_module.addObject(multiheader);

    kernel_main.setLinkerScript(b.path(b.pathJoin(&[_][]const u8{ "src/arch/", archPath, "src/linker.ld" })));

    b.installArtifact(kernel_main);
}
