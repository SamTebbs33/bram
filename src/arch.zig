const std = @import("std");
const Serial = @import("serial.zig").Serial;

pub const Arch = struct {
    pub const SerialResult = struct { success: bool, serial: ?Serial };
    initSerial: fn (self: *const @This()) anyerror!SerialResult = initSerialBase,
};

pub fn initSerialBase(self: *const Arch) !Arch.SerialResult {
    _ = self;
    return .{ .success = false, .serial = null };
}

pub fn get(cpu: std.Target.Cpu) Arch {
    return switch (cpu.arch) {
        else => @import("arch/x86/src/arch.zig").init(),
    };
}
