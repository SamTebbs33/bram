ENTRY(_start)

SECTIONS
{
    /* For AArch32, use . = 0x8000; */
    . = 0x80000;
    .text :
    {
        KEEP(*(.text.boot))
        *(.text)
    }
    . = ALIGN(4096); /* align to page size */

	/* Read-only data. */
    .rodata :
    {
        *(.rodata)
    }
    . = ALIGN(4096); /* align to page size */

	/* Read-write data (initialized) */
    .data :
    {
        *(.data)
    }
    . = ALIGN(4096); /* align to page size */

	/* Read-write data (uninitialized) and stack */
    .bss :
    {
        *(COMMON)
        *(.bss)
    }
}

