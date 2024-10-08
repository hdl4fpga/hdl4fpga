#include <stdlib.h>
#include <stdio.h>
#include <netinet/in.h>

int main (int argc, char *argv[])
{
	int c; 
	int s0;
	int s1;
	scanf("%d", &s0);
	while(scanf("%d", &s1) >= 0) {
		if ((s1-s0) != 1) {
			printf("error\n");
		}
		s0 = s1;
	}
	return 0;
}
