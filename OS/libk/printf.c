#include "../include/libk/stdio.h"

#include <stdarg.h>
#include <stdint.h>

#define VGA_WIDTH 80
#define VGA_HEIGHT 25

static volatile uint16_t *const vga_buffer = (uint16_t *)0xB8000;
static unsigned int vga_row = 0;
static unsigned int vga_col = 0;
static uint8_t vga_color = 0x0F;

static void vga_putc(char c)
{
    if (c == '\n')
    {
        vga_col = 0;
        if (vga_row + 1 < VGA_HEIGHT)
        {
            vga_row++;
        }
        return;
    }

    const unsigned int index = vga_row * VGA_WIDTH + vga_col;
    vga_buffer[index] = (uint16_t)vga_color << 8 | (uint8_t)c;

    vga_col++;
    if (vga_col >= VGA_WIDTH)
    {
        vga_col = 0;
        if (vga_row + 1 < VGA_HEIGHT)
        {
            vga_row++;
        }
    }
}

static void vga_write(const char *s)
{
    if (!s)
    {
        return;
    }
    while (*s)
    {
        vga_putc(*s++);
    }
}

int kprintf(const char *fmt, ...)
{
    va_list args;
    va_start(args, fmt);

    int written = 0;
    for (const char *p = fmt; p && *p; ++p)
    {
        if (*p == '%' && *(p + 1) == 's')
        {
            const char *s = va_arg(args, const char *);
            vga_write(s);
            p++;
            continue;
        }
        vga_putc(*p);
        written++;
    }

    va_end(args);
    return written;
}
