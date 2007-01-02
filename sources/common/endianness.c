#include <stdio.h>
#include <sys/types.h>
#include <sys/param.h>

int main()
{
#if defined BYTE_ORDER && defined BIG_ENDIAN && BYTE_ORDER != BIG_ENDIAN
    puts("LITTLE_ENDIAN");
#else
    puts("BIG_ENDIAN");
#endif
    return 0;
}
