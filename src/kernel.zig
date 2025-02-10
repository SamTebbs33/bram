const std = @import("std");
const builtin = @import("builtin");
const serial = @import("serial.zig");
const arch = @import("arch.zig");

pub fn log(comptime level: std.log.level, comptime scope: @TypeOf(.EnumLiteral), comptime format: []const u8, args: anytype) void {
    serial.log(level, "(" ++ @tagName(scope) ++ "): " ++ format, args);
}

export fn kernel_main() void {
    const arch_ifc = arch.get(builtin.cpu);
    serial.init(arch_ifc);
    return;
}
