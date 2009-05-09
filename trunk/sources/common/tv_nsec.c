#include <sys/stat.h>
int main()
{

  struct stat st;
  st.st_mtim.tv_nsec = 1;

  return 0;
}
