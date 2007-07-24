#include <stdio.h>
#include <linux/version.h>

int main()
{
#if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,0)
    puts("2.6\n");
#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,4,0)
    puts("2.4\n");
#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,2,0)
    puts("2.2\n");
#elif LINUX_VERSION_CODE >= KERNEL_VERSION(2,0,0)
    puts("2.0\n");
#elif LINUX_VERSION_CODE >= KERNEL_VERSION(1,0,0)
    puts("1.0\n");
#else
    puts("0.0\n");
#endif
    return 0;
}
