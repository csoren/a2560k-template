#include <stdio.h>

/* Let the C compiler know about an externally defined function */
extern const char* Hello();

int main () {
  printf("%s, World!\n", Hello());
  return 0;
}
