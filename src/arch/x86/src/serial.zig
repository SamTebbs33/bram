const std = @import("std");
const arch = @import("arch.zig");
/// The I/O port numbers associated with each serial port
pub const Port = enum(u16) {
    COM1 = 0x3F8,
    COM2 = 0x2F8,
    COM3 = 0x3E8,
    COM4 = 0x2E8,
};

/// Errors thrown by serial functions
pub const SerialError = error{
    /// The given baudrate is outside of the allowed range
    InvalidBaudRate,

    /// The given char len is outside the allowed range.
    InvalidCharacterLength,
};

/// The line control register. Used for setting communication parameters.
const LCR: u16 = 3;

/// The maximum baudrate supported by the controller
const MAX_BAUD: u32 = 115200;

/// Default baudrate
pub const DEFAULT_BAUDRATE = 38400;

/// Compute a value that sets the provided parameters: character length, stop bit, parity bit and MSB (allows configuration of the divisors).
fn getLCRValue(char_len: u8, stop_bit: bool, parity_bit: bool, msb: u1) SerialError!u8 {
    if (char_len != 0 and (char_len < 5 or char_len > 8))
        return SerialError.InvalidCharacterLength;
    const stop_bit_val: u8 = @intCast(@intFromBool(stop_bit));
    const parity_bit_val: u8 = @intCast(@intFromBool(parity_bit));
    const msb_val: u8 = @intCast(msb);
    return char_len & 0x3 |
        stop_bit_val << 2 |
        parity_bit_val << 3 |
        msb_val << 7;
}

/// Compute a divisor to achieve the desired baud rate. The serial controller uses a divisor as it's more space-efficient.
fn getBaudDivisor(baud: u32) SerialError!u16 {
    if (baud > MAX_BAUD or baud == 0)
        return SerialError.InvalidBaudRate;
    return @truncate(MAX_BAUD / baud);
}

/// Checks if the transmission buffer is empty, which means data can be sent.
fn transmitIsEmpty(port: Port) bool {
    return arch.in(@intFromEnum(port) + 5) & 0x20 > 0;
}

/// Waits until the transmission queue is empty then writes a byte to the serial port.
pub fn write(char: u8, port: Port) void {
    while (!transmitIsEmpty(port)) {
        arch.halt();
    }
    arch.out(char, @intFromEnum(port));
}

/// Initialise a serial port to a certain baudrate
pub fn init(baud: u32, port: Port) SerialError!void {
    const divisor: u16 = try getBaudDivisor(baud);
    const port_int = @intFromEnum(port);
    // Send a byte to start setting the baudrate
    arch.out(getLCRValue(0, false, false, 1) catch |e| {
        std.debug.panicExtra(@errorReturnTrace(), null, "Failed to initialise serial output setup: {}", .{e});
    }, port_int + LCR);
    // Send the divisor's lsb
    arch.out(@truncate(divisor), port_int);
    // Send the divisor's msb
    arch.out(@truncate(divisor >> 8), port_int + 1);
    // Send the properties to use
    arch.out(getLCRValue(8, true, false, 0) catch |e| {
        std.debug.panicExtra(@errorReturnTrace(), null, "Failed to setup serial properties: {}", .{e});
    }, port_int + LCR);
    // Stop initialisation
    arch.out(@as(u8, 0), port_int + 1);
}

test "getLCRValue computes the correct value" {
    // Check valid combinations
    inline for ([_]u8{ 0, 5, 6, 7, 8 }) |char_len| {
        inline for ([_]bool{ true, false }) |stop_bit| {
            inline for ([_]bool{ true, false }) |parity_bit| {
                inline for ([_]u1{ 0, 1 }) |msb| {
                    const val = try getLCRValue(char_len, stop_bit, parity_bit, msb);
                    const msb_val: u8 = @intCast(msb);
                    const stop_bit_val: u8 = @intFromBool(stop_bit);
                    const parity_bit_val: u8 = @intFromBool(parity_bit);
                    const expected = char_len & 0x3 |
                        stop_bit_val << 2 |
                        parity_bit_val << 3 |
                        msb_val << 7;
                    try std.testing.expectEqual(val, expected);
                }
            }
        }
    }

    // Check invalid char lengths
    try std.testing.expectError(SerialError.InvalidCharacterLength, getLCRValue(4, false, false, 0));
    try std.testing.expectError(SerialError.InvalidCharacterLength, getLCRValue(9, false, false, 0));
}

test "baudDivisor" {
    // Check invalid baudrates
    inline for ([_]u32{ 0, MAX_BAUD + 1 }) |baud| {
        try std.testing.expectError(SerialError.InvalidBaudRate, getBaudDivisor(baud));
    }

    // Check valid baudrates
    var baud: u32 = 1;
    while (baud <= MAX_BAUD) : (baud += 1) {
        const val = try getBaudDivisor(baud);
        const expected: u16 = @truncate(MAX_BAUD / baud);
        try std.testing.expectEqual(val, expected);
    }
}
