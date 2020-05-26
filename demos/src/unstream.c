#include <stdlib.h>
#include <stdio.h>

int main (int argc, char *argv[])
{
	setbuf(stdin, NULL);
	setbuf(stdout, NULL);

	int c;

	while (!((c = getchar()) < 0)) {
		if (c == '\\') {
			if ((c = getchar()) < 0) {
				fprintf(stderr, "Wrong escape sequence\n");
				exit(-1);
			}
		} else if (c == '\000')
			continue;

		if (putchar(c) < 0) {
			fprintf(stderr, "sdtout EOF\n");
			exit(-1);
		}
	}

	return 0;
}
