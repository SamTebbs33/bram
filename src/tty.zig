const std = @import("std");

const font = @import("font.zig").font;
const mbhdr = @import("multiboot.zig");

// Max size of the character buffer, hardcoded to 1024x768. This is statically allocated memory
// before we have access to malloc.
const CHAR_WIDTH: usize = 8;
const CHAR_HEIGHT: usize = 16;
const MAX_FRAMEBUFFER_WIDTH: usize = 1024;
const MAX_FRAMEBUFFER_HEIGHT: usize = 768;
const MAX_CHAR_BUFFER_SIZE: usize = (MAX_FRAMEBUFFER_WIDTH / CHAR_WIDTH) * (MAX_FRAMEBUFFER_HEIGHT / CHAR_HEIGHT);
var buffer: [MAX_CHAR_BUFFER_SIZE]u8 = std.mem.zeroes([MAX_CHAR_BUFFER_SIZE]u8);

const Tty = struct {
    screen: [*]u8,
    hdr: *mbhdr.MultibootInfo,
    charbuffer: []u8,
    linelength: u32,
    numlines: u32,
    cursor_x: u32,
    cursor_y: u32,
};

var tty: Tty = undefined;

pub fn init(screen: [*]u8, hdr: *mbhdr.MultibootInfo) void {
    tty.screen = screen;
    tty.hdr = hdr;
    tty.charbuffer = buffer[0..];
    tty.linelength = tty.hdr.framebuffer_width / CHAR_WIDTH;
    tty.numlines = tty.hdr.framebuffer_height / CHAR_HEIGHT;
    tty.cursor_x = 0;
    tty.cursor_y = 0;
}

pub fn putpixel(x: u32, y: u32, color: u32) void {
    const width: u32 = tty.hdr.framebuffer_bpp / 8;
    const where: u32 = (x * width) + (y * tty.hdr.framebuffer_pitch);
    tty.screen[where] = @intCast(color & 255);
    tty.screen[where + 1] = @intCast((color >> 8) & 255);
    tty.screen[where + 2] = @intCast((color >> 16) & 255);
}

pub fn clear_screen() void {
    for (0..tty.hdr.framebuffer_height) |y| {
        for (0..tty.hdr.framebuffer_width) |x| {
            putpixel(x, y, 0x000000FF);
        }
    }
}

pub fn draw_screen() void {
    clear_screen();
    for (0..tty.numlines) |y| {
        for (0..tty.linelength) |x| {
            const ch = tty.charbuffer[y * tty.linelength + x];
            if (ch >= 32 and ch < 128) {
                draw_char(ch - 32, CHAR_WIDTH * x, CHAR_HEIGHT * y);
            }
        }
    }
}

pub fn draw_char(glyph_index: u8, x: u32, y: u32) void {
    for (0..CHAR_WIDTH) |i| {
        for (0..CHAR_HEIGHT) |j| {
            const shift: u32 = 0x1;
            if ((font[glyph_index][j] & (shift << @intCast(7 - i))) > 0) {
                putpixel(x + i, y + j, 0xffffff);
            }
        }
    }
}

pub fn write_string(s: []const u8) void {
    const start = tty.cursor_x + (tty.linelength * tty.cursor_y);
    var i: usize = 0;
    while (i < s.len) : (i += 1) {
        tty.charbuffer[start + i] = s[i];
    }
    tty.cursor_x += s.len;
    if (tty.cursor_x >= tty.linelength) {
        tty.cursor_x = 0;
        tty.cursor_y += 1;
    }
    if (tty.cursor_y >= tty.numlines) {
        tty.cursor_y = 0;
    }

    draw_screen();
}

pub fn write_hello_world() void {
    const s = "Hello World!";
    write_string(s);
}
