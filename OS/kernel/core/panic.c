#include "../../include/kernel/panic.h"
#include "../../include/libk/stdio.h"

void kernel_panic(const char *msg)
{
    kprintf("PANIC: %s\n", msg);
    for (;;)
    {
        __asm__ __volatile__("hlt");
    }
}
