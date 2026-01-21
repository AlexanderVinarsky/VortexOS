#include "stdint.h"
#include "stdio.h"


void _cdecl cstart_(uint16_t bootDrive)
{
    puts("Putc beytes test\r\n");
    printf("Formatted %% %c %s\r\n", 'a', "string");
    printf("Formatted %d %i %x %p %o %hd %hi %hhu %hhd\r\n", 6767, -6767, 0xadda, 0xeadda, 06767, (short)67, (short)-67, (unsigned char)67, (char)-67);
    printf("Formatted %ld %lx %lld %llx\r\n", -100000000l, 0xbebel, 10201233304ll, 0xdadadaeddaull);
    for (;;);
}