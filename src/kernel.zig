const std = @import("std");
const builtin = @import("builtin");
const serial = @import("serial.zig");
const arch = @import("arch.zig");
const klog = std.log.scoped(.kernel);

pub const std_options = .{ .log_level = .debug, .logFn = log };

pub fn log(comptime level: std.log.Level, comptime scope: @TypeOf(.EnumLiteral), comptime format: []const u8, args: anytype) void {
    serial.log(level, "(" ++ @tagName(scope) ++ "): " ++ format, args);
}

export fn kernel_main() void {
    const arch_ifc = arch.get(builtin.cpu);
    const serial_result = serial.init(&arch_ifc) catch |e| std.debug.panicExtra(@errorReturnTrace(), null, "Failed to initialise serial, that's not great: {}\n", .{e});
    if (!serial_result)
        return;
    klog.debug("Hello, world!", .{});
    return;
}
