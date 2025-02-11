const std = @import("std");
const Arch = @import("arch.zig").Arch;

pub const Serial = struct {
    const This = @This();
    /// A function that takes a byte and writes it to the serial stream
    pub const Write = *const fn (u8) bool;

    /// The interface's writer
    writer: Write,

    pub fn writeBytes(self: *const This, bytes: []const u8) usize {
        var i: usize = 0;
        for (bytes) |byte| {
            if (self.writer(byte)) {
                i += 1;
            } else break;
        }
        return i;
    }
};

const LoggingError = error{};
/// Create a Writer that uses logCallback to write some bytes to serial
const Writer = std.io.Writer(void, LoggingError, logCallback);

/// The architecture's serial interface, null if not initialised yet
pub var serial: ?Serial = null;

/// Write a format string to the serial interface
fn log(comptime level: std.log.level, comptime format: []const u8, args: anytype) void {
    std.fmt.format(Writer{ .context = {} }, "[" ++ @tagName(level) ++ "] " ++ format, args) catch unreachable;
}

/// The standard library formatter will call this function with the bytes to print
fn logCallback(context: void, str: []const u8) usize {
    _ = context;
    if (serial) |serial_ifc| {
        return serial_ifc.writeBytes(str);
    }
    return 0;
}

pub fn init(arch: *const Arch) bool {
    const result = arch.initSerial(arch);
    if (result.success)
        serial = result.serial orelse unreachable;
    return result.success;
}
