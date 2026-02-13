#include "../../include/kernel/memory.h"

void *kmalloc(unsigned long size)
{
    (void)size;
    return 0;
}

void kfree(void *ptr)
{
    (void)ptr;
}
