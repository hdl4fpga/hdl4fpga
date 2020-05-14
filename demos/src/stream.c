#include <stdlib.h>
#include <stdio.h>

void stream (char c)
{
	if (c == 0) 
		fwrite("\\", sizeof(char), 1, stdout);
	else if(c == '\\')
		fwrite("\\", sizeof(char), 1, stdout);

	fwrite(&c, sizeof(char), 1, stdout);
}

int main (int argc, char *argv[])
{
	setbuf(stdin, NULL);
	setbuf(stdout, NULL);

	char unsigned len;
	char unsigned rid;

	fwrite("\000", sizeof(char), 2, stdout);
	for(int i = 0; fread(&rid, sizeof(char), 1, stdin) > 0; i++) {
		char c;

		if (fread(&len, sizeof(char), 1, stdin) > 0) {
			stream(rid);
			stream(len);
			for (int j = 0; j <= len; j++) {
				if (fread(&c, sizeof(char), 1, stdin) > 0) {
					stream(c);
				} else
					exit(-1);
			}
			fwrite("\000", sizeof(char), 2, stdout);
		} else
			exit(-1);
	}

	return 0;
}
