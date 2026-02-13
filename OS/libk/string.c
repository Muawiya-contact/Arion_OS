#include "../include/libk/string.h"

unsigned long kstrlen(const char *s)
{
    unsigned long n = 0;
    while (s && s[n])
        n++;
    return n;
}
