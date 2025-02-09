const font = @import("font.zig").font;
const mbhdr = @import("multiboot.zig");

pub fn putpixel(screen: [*]u8, x: u32, y: u32, color: u32, hdr: *mbhdr.MultibootInfo) void {
    const width: u32 = hdr.framebuffer_bpp / 8;
    const where: u32 = (x * width) + (y * hdr.framebuffer_pitch);
    screen[where] = @intCast(color & 255);
    screen[where + 1] = @intCast((color >> 8) & 255);
    screen[where + 2] = @intCast((color >> 16) & 255);
}

pub fn draw_char(screen: [*]u8, hdr: *mbhdr.MultibootInfo, ascii_code: u8, x: u32) void {
    for (0..8) |i| {
        for (0..16) |j| {
            const shift: u32 = 0x1;
            if ((font[ascii_code][j] & (shift << @intCast(8 - i))) > 0) {
                putpixel(screen, x + i, 16 + j, 0xffffff, hdr);
            }
        }
    }
}

pub fn write_hello_world(screen: [*]u8, hdr: *mbhdr.MultibootInfo) void {
    for (0..1024) |w| {
        for (0..768) |h| {
            putpixel(screen, w, h, 0x00000000, hdr);
        }
    }
    const s = "Hello World!";
    for (0..s.len) |i| {
        draw_char(screen, hdr, s[i] - 32, 0 + (8 * i));
    }
}
