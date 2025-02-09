const std = @import("std");
const builtin = @import("builtin");
const serial = @import("serial.zig");
const arch = @import("arch.zig");
const multiboot = @import("multiboot.zig");

pub fn log(comptime level: std.log.level, comptime scope: @TypeOf(.EnumLiteral), comptime format: []const u8, args: anytype) void {
    serial.log(level, "(" ++ @tagName(scope) ++ "): " ++ format, args);
}

export fn kernel_main(magic: u32, multibootheader: *multiboot.MultibootInfo) void {
    if (magic != 0x2BADB002) {
        return;
    }

    const arch_ifc = arch.get(builtin.cpu);
    if (!serial.init(&arch_ifc))
        return;

    const screen: [*]u8 = @ptrFromInt(multibootheader.framebuffer_addr);
    _ = screen; // silence unused error for now.

    while (true) {}
}
