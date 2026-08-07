const std = @import("std");
const builtin = @import("builtin");
const serial = @import("serial.zig");
const arch = @import("arch.zig");
const multiboot = @import("multiboot.zig");
const tty = @import("tty.zig");

pub fn log(comptime level: std.log.level, comptime scope: @TypeOf(.EnumLiteral), comptime format: []const u8, args: anytype) void {
    serial.log(level, "(" ++ @tagName(scope) ++ "): " ++ format, args);
}

export fn kernel_main(magic: u32, multibootheader: *multiboot.MultibootInfo) callconv(.c) void {

    // TODO: Enforce this check once x86 serial is supported.
    // const arch_ifc = arch.get(builtin.cpu);
    // if (!serial.init(&arch_ifc))
    //     return;

    if (magic != multiboot.MAGIC) {
        return;
    }

    if (multibootheader.framebuffer_addr != 0 and multibootheader.framebuffer_pitch != 0 and multibootheader.framebuffer_bpp >= 24) {
        const screen: [*]u8 = @ptrFromInt(multibootheader.framebuffer_addr);
        tty.write_hello_world(screen, multibootheader);
    }

    while (true) {}
}
