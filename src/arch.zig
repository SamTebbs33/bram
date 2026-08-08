const std = @import("std");
const Serial = @import("serial.zig").Serial;

pub const Arch = struct {
    pub const SerialResult = struct { success: bool, serial: ?Serial };

    // 1. Defined as a normal method instead of a field
    pub fn initSerial(self: *const Arch) SerialResult {
        return initSerialBase(self);
    }
};

pub fn initSerialBase(self: *const Arch) Arch.SerialResult {
    _ = self;
    return .{ .success = false, .serial = null };
}

pub fn get(cpu: std.Target.Cpu) Arch {
    return switch (cpu.arch) {
        else => .{},
    };
}
