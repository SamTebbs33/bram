const multiboot = @import("multiboot.zig");

export fn kernel_main(magic: u32, multibootheader: *multiboot.MultibootInfo) void {
    if (magic != 0x2BADB002) {
        return;
    }

    const screen: [*]u8 = @ptrFromInt(multibootheader.framebuffer_addr);
    _ = screen; // silence unused error for now.

    while (true) {}
    return;
}
