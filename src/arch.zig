const std = @import("std");
const Serial = @import("serial.zig").Serial;

pub const Arch = struct {
    initSerial: fn (self: @This()) struct { success: bool, serial: ?Serial } = initSerialBase,
};

pub fn initSerialBase(self: *Arch) struct { success: bool, serial: ?Serial } {
    _ = self;
    return .{ false, null };
}

pub fn get(cpu: std.Target.Cpu) Arch {
    return switch (cpu.arch) {
        else => .{},
    };
}
