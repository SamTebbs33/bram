const Arch = @import("../../../arch.zig").Arch;
const serial = @import("serial.zig");

pub fn in(port: u16) u8 {
    return asm volatile ("inb %[port], %[res]"
        : [res] "={al}" (-> u8),
        : [port] "N{dx}" (port),
    );
}

pub fn out(val: u8, port: u16) void {
    asm volatile ("outb %[val], %[port]"
        :
        : [port] "{dx}" (port),
          [val] "{al}" (val),
    );
}

pub fn halt() void {
    asm volatile ("hlt");
}

pub fn initSerial(self: *const Arch) !Arch.SerialResult {
    _ = self;
    serial.init(serial.DEFAULT_BAUDRATE, serial.Port.COM1) catch |e| return e;
    const serial_write = struct {
        fn write(byte: u8) bool {
            serial.write(byte, serial.Port.COM1);
            return true;
        }
    }.write;
    return .{ .success = true, .serial = .{ .writer = serial_write } };
}

pub fn init() Arch {
    return .{ .initSerial = initSerial };
}
