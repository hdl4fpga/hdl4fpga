#include <stdio.h>
void main () {
	char c = -128;
	printf("c = %d\n", c);
	c = -c;
	printf("c = %d\n", c);
}
