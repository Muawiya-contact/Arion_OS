#include "../../include/kernel/panic.h"
#include "../../include/libk/stdio.h"

void kernel_main(void)
{
    kprintf("========================================\n");
    kprintf("  Arion Operating System [x86_64]\n");
    kprintf("  Phase 2: Long Mode Transition Complete\n");
    kprintf("========================================\n");
    kprintf("\n");
    kprintf("Kernel initialized successfully!\n");
    kprintf("Running in 64-bit long mode.\n");
    kprintf("\n");

    kernel_panic("Phase 2 complete - halting system");
}
