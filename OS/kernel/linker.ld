ENTRY(_start)

SECTIONS
{
    /* Load at 1MB physical address */
    . = 1M;

    /* Multiboot header must be at the start */
    .multiboot ALIGN(4K) :
    {
        KEEP(*(.multiboot))
    }

    /* Code section */
    .text ALIGN(4K) :
    {
        *(.text*)
    }

    /* Read-only data */
    .rodata ALIGN(4K) :
    {
        *(.rodata*)
    }

    /* Initialized data */
    .data ALIGN(4K) :
    {
        *(.data*)
    }

    /* Uninitialized data (BSS) - includes page tables and stack */
    .bss ALIGN(4K) :
    {
        *(COMMON)
        *(.bss*)
    }

    /* Discard sections we don't need */
    /DISCARD/ :
    {
        *(.comment)
        *(.eh_frame)
        *(.note*)
    }
}
