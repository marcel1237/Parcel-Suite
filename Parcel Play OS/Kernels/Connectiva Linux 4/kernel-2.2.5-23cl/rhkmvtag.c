#include <stdio.h>

extern const char *linux_banner;

int
main()
{
	printf("%s", linux_banner);
	return 0;
}
