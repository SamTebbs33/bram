.section .bss
.align 16
stack_bottom:
.skip 16384
stack_top:

// To keep this in the first portion of the binary.
.section .text.boot
.globl _start
.type _start, @function

// Entry point for the kernel. Registers:
// x0 -> 32 bit pointer to DTB in memory (primary core only) / 0 (secondary cores)
// x1 -> 0
// x2 -> 0
// x3 -> 0
// x4 -> 32 bit kernel entry point, _start location
_start:
    ldr     x5, =stack_top
    mov     sp, x5
    bl      kernel_main
halt:
    wfe
    b halt
