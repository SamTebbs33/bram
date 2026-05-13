const std = @import("std");
const builtin = @import("builtin");
const serial = @import("serial.zig");
const arch = @import("arch.zig");

pub const std_options: std.Options = .{ .log_level = .debug, .logFn = log };

pub fn log(comptime level: std.log.Level, comptime scope: @TypeOf(.enum_literal), comptime format: []const u8, args: anytype) void {
    serial.log(level, "(" ++ @tagName(scope) ++ "): " ++ format, args);
}

export fn kernel_main() void {
    const arch_ifc = arch.get(builtin.cpu);
    if (!serial.init(&arch_ifc))
        return;
    return;
}
