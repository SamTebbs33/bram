const multiboot = @import("multiboot.zig");
const tty = @import("tty.zig");
export fn kernel_main(magic: u32, multibootheader: *multiboot.MultibootInfo) void {
    if (magic != 0x2BADB002) {
        return;
    }

    const screen: [*]u8 = @ptrFromInt(multibootheader.framebuffer_addr);
    tty.write_hello_world(screen, multibootheader);

    while (true) {}
    return;
}
