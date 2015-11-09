#include <stdint.h>

int main()
{
#if UINTPTR_MAX == 0xffffffff
    puts("32-bit");
#elif UINTPTR_MAX == 0xffffffffffffffff
    puts("64-bit");
#else
#error What?
#endif
    return 0;
}
